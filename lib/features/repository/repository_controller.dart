import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/localization/localized_message.dart';
import '../../core/localization/runtime_messages.dart';
import '../../core/models/app_models.dart';
import '../../core/models/git_identity.dart';
import '../../core/models/git_remote.dart';
import '../../core/models/operation_plan.dart';
import '../../core/models/operation_safety.dart';
import '../../core/models/recent_repository.dart';
import '../../core/models/repository_sync.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/git_runtime_service.dart';
import '../../core/services/git_service.dart';
import '../../core/services/recent_repositories_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/utils/path_utils.dart';

export '../../core/models/operation_plan.dart';

enum ExplorerSide { left, right }

enum ClipboardMode { cut, copy }

class ExplorerSelection {
  const ExplorerSelection({required this.paths, required this.mode});

  final List<String> paths;
  final ClipboardMode mode;
}

class ExplorerPanelState {
  const ExplorerPanelState({
    this.relativePath = '',
    this.entries = const [],
    this.selectedPaths = const {},
    this.isLoading = false,
    this.error,
  });

  final String relativePath;
  final List<RepositoryEntry> entries;
  final Set<String> selectedPaths;
  final bool isLoading;
  final String? error;

  ExplorerPanelState copyWith({
    String? relativePath,
    List<RepositoryEntry>? entries,
    Set<String>? selectedPaths,
    bool? isLoading,
    Object? error = _unchanged,
  }) {
    return ExplorerPanelState(
      relativePath: relativePath ?? this.relativePath,
      entries: entries ?? this.entries,
      selectedPaths: selectedPaths ?? this.selectedPaths,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unchanged) ? this.error : error as String?,
    );
  }

  static const Object _unchanged = Object();
}

class RemoteClearInspection {
  const RemoteClearInspection({
    required this.isSuccess,
    required this.message,
    this.preview,
  });

  final bool isSuccess;
  final LocalizedMessage message;
  final RemoteClearPreview? preview;
}

class GitMetadataClearInspection {
  const GitMetadataClearInspection({
    required this.isSuccess,
    required this.message,
    required this.remotes,
  });

  final bool isSuccess;
  final LocalizedMessage message;
  final List<GitRemote> remotes;
}

class RepositoryController extends ChangeNotifier implements OperationPlanHost {
  RepositoryController({
    SettingsService? settingsService,
    GitService? gitService,
    AppLogService? logService,
    RecentRepositoriesService? recentRepositoriesService,
    GitRuntimeManager? runtimeManager,
  }) : _settingsService = settingsService ?? SettingsService(),
       _git = gitService,
       _log = logService ?? AppLogService.instance,
       _gitRuntime = runtimeManager ?? GitRuntimeManager.instance,
       _recentRepositoriesService =
           recentRepositoriesService ?? RecentRepositoriesService();

  final SettingsService _settingsService;
  final AppLogService _log;
  final GitRuntimeManager _gitRuntime;
  final RecentRepositoriesService _recentRepositoriesService;
  GitService? _git;

  String? repositoryPath;
  String? projectName;
  String branch = '';
  RepositoryStats? repositoryStats;
  BranchSyncState? syncState;
  List<GitFileStatus> changedFiles = const [];
  List<GitRemote> remotes = const [];
  List<RepositoryEntry> leftEntries = const [];
  List<RepositoryEntry> rightEntries = const [];
  ExplorerPanelState leftPanel = const ExplorerPanelState();
  ExplorerPanelState rightPanel = const ExplorerPanelState();
  ExplorerSide activeSide = ExplorerSide.left;
  ExplorerSelection? clipboard;
  AppSettings settings = const AppSettings();
  bool isInitializing = true;
  @override
  bool isBusy = false;
  bool isExecutingPlan = false;
  int planCurrentStep = 0;
  LocalizedMessage? planCurrentTitle;
  String? fatalError;
  List<RecentRepository> recentRepositories = const [];
  @override
  List<PlannedRepositoryOperation> pendingOperations = const [];
  int _operationSequence = 0;
  RepositoryStateSnapshot? _planBaseline;
  RepositoryStateSnapshot? _runtimeBaseline;
  bool _isCapturingPlan = false;

  GitService? get git => _git;
  GitRuntimeManager get gitRuntime => _gitRuntime;
  GitRuntimeStatus get gitRuntimeStatus => _gitRuntime.status;
  bool get isGitAvailable =>
      _gitRuntime.status.checkedAt == null || _gitRuntime.status.isAvailable;
  bool get hasRepository => _git != null && repositoryPath != null;
  bool get hasPendingOperations => pendingOperations.isNotEmpty;
  bool get hasQueuedCommit => pendingOperations.any(
    (operation) => operation.kind == PlannedOperationKind.commit,
  );
  bool get hasQueuedClearRemote => pendingOperations.any(
    (operation) => operation.kind == PlannedOperationKind.clearRemote,
  );
  bool get hasQueuedClearGitMetadata => pendingOperations.any(
    (operation) => operation.kind == PlannedOperationKind.clearGitMetadata,
  );
  bool get hasPendingFileChanges => pendingOperations.any(
    (operation) => const {
      PlannedOperationKind.move,
      PlannedOperationKind.copy,
      PlannedOperationKind.rename,
      PlannedOperationKind.delete,
    }.contains(operation.kind),
  );
  bool get localOperationsLocked =>
      hasQueuedCommit || hasQueuedClearRemote || hasQueuedClearGitMetadata;
  @override
  bool get canExecutePlan =>
      hasRepository &&
      isGitAvailable &&
      pendingOperations.isNotEmpty &&
      !isBusy;
  ExplorerPanelState panelFor(ExplorerSide side) =>
      side == ExplorerSide.left ? leftPanel : rightPanel;

  Future<void> initialize() async {
    _gitRuntime.addListener(_onGitRuntimeChanged);
    settings = await _settingsService.load();
    recentRepositories = await _recentRepositoriesService.load();
    isInitializing = false;
    _log.infoEvent(
      'app',
      'settings.initialize.completed',
      details: {
        'theme': settings.themePreference.name,
        'color': settings.colorSchemePreference.name,
        'language': settings.languagePreference.name,
        'units': '${settings.unitSystem.name}/${settings.baseUnit.name}',
        'font': settings.fontFamily,
        'scale': '${settings.fontScale}',
      },
    );
    notifyListeners();
  }

  Future<GitRuntimeStatus> refreshGitRuntime() async {
    final status = await _gitRuntime.refresh();
    notifyListeners();
    return status;
  }

  void _onGitRuntimeChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _gitRuntime.removeListener(_onGitRuntimeChanged);
    super.dispose();
  }

  Future<OperationOutcome> openRepository(String selectedPath) async {
    _log.infoEvent(
      'repository',
      'repository.open.requested',
      details: {'path': selectedPath},
    );
    if (!isGitAvailable) {
      _log.warningEvent(
        'repository',
        'repository.open.rejected.gitUnavailable',
      );
      return OperationOutcome.failure(
        RuntimeMessages.messageFor(
          'gitUnavailableHelp',
          eventId: 'repository.open.rejected.gitUnavailable',
        ),
      );
    }
    if (isBusy) {
      _log.warningEvent('repository', 'repository.open.rejected.busy');
      return OperationOutcome.failure(
        RuntimeMessages.messageFor(
          'operationInProgress',
          eventId: 'repository.open.rejected.busy',
        ),
      );
    }
    isBusy = true;
    fatalError = null;
    notifyListeners();

    try {
      final root = await GitService.resolveRepositoryRoot(selectedPath);
      final service = GitService(root, logService: _log);
      final branchName = await service.currentBranch();
      final initialSyncState = await _readSyncState(service);
      final status = await service.status();
      final remoteList = await service.remotes();
      final stats = await service.repositoryStats();
      final rootEntries = await service.listDirectory('');
      final left = ExplorerPanelState(entries: rootEntries);
      final right = ExplorerPanelState(entries: rootEntries);

      _git = service;
      repositoryPath = root;
      projectName = repositoryBasename(root);
      branch = branchName;
      syncState = initialSyncState;
      repositoryStats = stats;
      changedFiles = status;
      remotes = remoteList;
      leftPanel = left;
      rightPanel = right;
      clipboard = null;
      pendingOperations = const [];
      _resetPlanBaselines();
      planCurrentStep = 0;
      planCurrentTitle = null;
      try {
        recentRepositories = await _recentRepositoriesService.add(root);
      } catch (error) {
        _log.warningEvent(
          'history',
          'history.save.failed.nonFatal',
          details: {'error': '$error'},
        );
      }
      _log.infoEvent(
        'repository',
        'repository.open.completed',
        details: {
          'root': root,
          'branch': branchName,
          'changes': '${status.length}',
          'files': '${stats.fileCount}',
        },
      );
      return OperationOutcome.success(
        RuntimeMessages.operationCompletedFor(
          projectName!,
          eventId: 'repository.open.succeeded',
          technicalDetails: {'root': root, 'branch': branchName},
        ),
      );
    } catch (error) {
      fatalError = error.toString().replaceFirst('Exception: ', '');
      _git = null;
      repositoryPath = null;
      if (!await _recentRepositoriesService.isValidRepository(selectedPath)) {
        try {
          recentRepositories = await _recentRepositoriesService.remove(
            selectedPath,
          );
        } catch (historyError) {
          _log.warningEvent(
            'history',
            'history.removeInvalid.failed',
            details: {'error': '$historyError'},
          );
        }
      }
      _log.errorEvent(
        'repository',
        'repository.open.failed',
        details: {'error': fatalError!},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          fatalError!,
          eventId: 'repository.open.failed',
        ),
      );
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void closeRepository() {
    _log.infoEvent(
      'repository',
      'repository.close',
      details: {'path': repositoryPath ?? ''},
    );
    _git = null;
    repositoryPath = null;
    projectName = null;
    branch = '';
    syncState = null;
    repositoryStats = null;
    changedFiles = const [];
    remotes = const [];
    leftPanel = const ExplorerPanelState();
    rightPanel = const ExplorerPanelState();
    clipboard = null;
    pendingOperations = const [];
    _resetPlanBaselines();
    planCurrentStep = 0;
    planCurrentTitle = null;
    fatalError = null;
    notifyListeners();
  }

  Future<GitMetadataClearInspection> inspectGitMetadataForClear() async {
    if (_git == null) {
      return GitMetadataClearInspection(
        isSuccess: false,
        message: RuntimeMessages.messageFor('noRepositoryOpen'),
        remotes: const [],
      );
    }
    try {
      final remotes = await _git!.remotes();
      return GitMetadataClearInspection(
        isSuccess: true,
        message: remotes.isEmpty
            ? RuntimeMessages.messageFor('gitMetadataClearAvailable')
            : RuntimeMessages.messageFor('gitMetadataRemoteForbidden'),
        remotes: remotes,
      );
    } catch (error) {
      return GitMetadataClearInspection(
        isSuccess: false,
        message: RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.gitMetadata.inspect.failed',
        ),
        remotes: const [],
      );
    }
  }

  Future<OperationOutcome> clearGitMetadata() async {
    final root = repositoryPath;
    if (_git == null || root == null) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noRepositoryOpen'),
      );
    }
    final inspection = await inspectGitMetadataForClear();
    if (!inspection.isSuccess) {
      return OperationOutcome.failure(inspection.message);
    }
    if (inspection.remotes.isNotEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('gitMetadataRemoteForbidden'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.clearGitMetadata,
        title: RuntimeMessages.messageFor('planTitleClearGitMetadata'),
        description: RuntimeMessages.messageFor(
          'planDescriptionClearGitMetadata',
          parameters: {'path': root},
        ),
        run: () => _applyClearGitMetadata(root),
        isDangerous: true,
        isExclusive: true,
        strongConfirmationText: 'CLEAR GIT',
      ),
    );
  }

  Future<OperationOutcome> _applyClearGitMetadata(String root) async {
    try {
      final inspection = await inspectGitMetadataForClear();
      if (!inspection.isSuccess) {
        return OperationOutcome.failure(inspection.message);
      }
      if (inspection.remotes.isNotEmpty) {
        return OperationOutcome.failure(
          RuntimeMessages.messageFor('gitMetadataRemoteForbidden'),
        );
      }
      await GitService.clearRepositoryMetadata(root);
      await removeRecentRepository(root);
      closeRepository();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'gitMetadataCleared',
          eventId: 'repository.gitMetadata.clear.succeeded',
          technicalDetails: {'root': root},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'repository',
        'repository.gitMetadata.clear.failed',
        details: {'error': '$_cleanError(error)', 'root': root},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.gitMetadata.clear.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> removeRecentRepository(String path) async {
    try {
      recentRepositories = await _recentRepositoriesService.remove(path);
      notifyListeners();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'historyEntryRemoved',
          eventId: 'history.remove.succeeded',
          technicalDetails: {'path': path},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'history',
        'history.remove.failed',
        details: {'error': '$_cleanError(error)', 'path': path},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'history.remove.failed',
        ),
      );
    }
  }

  void setActiveSide(ExplorerSide side) {
    if (activeSide == side) {
      return;
    }
    activeSide = side;
    _log.detailEvent(
      'selection',
      'selection.activePane.changed',
      details: {'side': side.name},
    );
    notifyListeners();
  }

  Future<void> navigate(ExplorerSide side, String relativePath) async {
    if (_git == null) {
      return;
    }
    _log.detailEvent(
      'explorer',
      'explorer.navigate',
      details: {
        'side': side.name,
        'path': normalizeRepositoryPath(relativePath),
      },
    );
    setActiveSide(side);
    await _loadPanel(side, normalizeRepositoryPath(relativePath));
  }

  Future<void> goUp(ExplorerSide side) async {
    final panel = panelFor(side);
    _log.detailEvent(
      'explorer',
      'explorer.navigate.parent',
      details: {'side': side.name, 'from': panel.relativePath},
    );
    await navigate(side, repositoryParent(panel.relativePath));
  }

  Future<void> refresh({bool refreshStats = true}) async {
    if (_git == null || isBusy) {
      return;
    }
    _log.infoEvent('repository', 'repository.refresh.requested');
    isBusy = true;
    notifyListeners();
    try {
      final status = await _git!.status();
      final remoteList = await _git!.remotes();
      final stats = refreshStats
          ? await _git!.repositoryStats()
          : repositoryStats;
      final left = await _git!.listDirectory(leftPanel.relativePath);
      final right = await _git!.listDirectory(rightPanel.relativePath);
      changedFiles = status;
      remotes = remoteList;
      repositoryStats = stats;
      leftPanel = leftPanel.copyWith(entries: left, error: null);
      rightPanel = rightPanel.copyWith(entries: right, error: null);
      branch = await _git!.currentBranch();
      syncState = await _readSyncState(_git!);
      _log.detailEvent(
        'repository',
        'repository.refresh.completed',
        details: {
          'changes': '${changedFiles.length}',
          'left': '${leftPanel.entries.length}',
          'right': '${rightPanel.entries.length}',
        },
      );
    } catch (error) {
      _log.errorEvent(
        'repository',
        'repository.refresh.failed',
        details: {'error': '$error'},
      );
      leftPanel = leftPanel.copyWith(error: _cleanError(error));
      rightPanel = rightPanel.copyWith(error: _cleanError(error));
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void toggleSelection(ExplorerSide side, String path) {
    final panel = panelFor(side);
    final selection = Set<String>.of(panel.selectedPaths);
    final selected = selection.add(path);
    if (!selected) {
      selection.remove(path);
    }
    _setPanel(
      side,
      panel.copyWith(selectedPaths: UnmodifiableSetView(selection)),
    );
    activeSide = side;
    _log.detailEvent(
      'selection',
      'selection.toggle',
      details: {
        'side': side.name,
        'path': path,
        'selected': '$selected',
        'count': '${selection.length}',
      },
    );
    notifyListeners();
  }

  void selectOnly(ExplorerSide side, String path) {
    final panel = panelFor(side);
    _setPanel(side, panel.copyWith(selectedPaths: UnmodifiableSetView({path})));
    activeSide = side;
    _log.detailEvent(
      'selection',
      'selection.only',
      details: {'side': side.name, 'path': path},
    );
    notifyListeners();
  }

  void selectAll(ExplorerSide side) {
    final panel = panelFor(side);
    final selection = panel.entries.map((entry) => entry.relativePath).toSet();
    _setPanel(
      side,
      panel.copyWith(selectedPaths: UnmodifiableSetView(selection)),
    );
    activeSide = side;
    _log.detailEvent(
      'selection',
      'selection.all',
      details: {'side': side.name, 'count': '${selection.length}'},
    );
    notifyListeners();
  }

  void clearSelection(ExplorerSide side) {
    final panel = panelFor(side);
    _log.detailEvent(
      'selection',
      'selection.clear',
      details: {'side': side.name, 'count': '${panel.selectedPaths.length}'},
    );
    _setPanel(side, panel.copyWith(selectedPaths: const {}));
    notifyListeners();
  }

  OperationOutcome setClipboard(ClipboardMode mode) {
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.isEmpty) {
      _log.warningEvent(
        'clipboard',
        'clipboard.selection.empty',
        details: {'mode': mode.name},
      );
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('selectItemsFirst'),
      );
    }
    clipboard = ExplorerSelection(
      paths: panel.selectedPaths.toList(growable: false),
      mode: mode,
    );
    _log.infoEvent(
      'clipboard',
      mode == ClipboardMode.cut ? 'clipboard.cut' : 'clipboard.copy',
      details: {'count': '${clipboard!.paths.length}'},
    );
    _log.detailEvent(
      'clipboard',
      'clipboard.paths',
      details: {'paths': clipboard!.paths.join(' | ')},
    );
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.operationCompletedForItems(
        clipboard!.paths.length,
        eventId: mode == ClipboardMode.cut
            ? 'clipboard.cut.succeeded'
            : 'clipboard.copy.succeeded',
      ),
    );
  }

  OperationOutcome clearClipboard() {
    if (clipboard == null) {
      _log.detailEvent('clipboard', 'clipboard.clear.alreadyEmpty');
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('clipboardEmpty'),
      );
    }
    _log.detailEvent(
      'clipboard',
      'clipboard.clear',
      details: {'count': '${clipboard!.paths.length}'},
    );
    clipboard = null;
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.messageFor(
        'clipboardCleared',
        eventId: 'clipboard.clear.succeeded',
      ),
    );
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    if (isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationPlanBusyEdit'),
      );
    }
    final operation = pendingOperations
        .where((item) => item.id == id)
        .firstOrNull;
    if (operation == null) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('planOperationMissing'),
      );
    }
    pendingOperations = List.unmodifiable(
      pendingOperations.where((item) => item.id != id),
    );
    if (pendingOperations.isEmpty) {
      _resetPlanBaselines();
    }
    _log.infoEvent(
      'plan',
      'plan.entry.removed',
      details: {'kind': operation.kind.name},
    );
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.messageFor(
        'planOperationRemoved',
        eventId: 'plan.entry.removed',
      ),
    );
  }

  @override
  OperationOutcome clearPendingOperations() {
    if (isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationPlanBusyClear'),
      );
    }
    if (pendingOperations.isEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noPendingOperations'),
      );
    }
    final count = pendingOperations.length;
    pendingOperations = const [];
    _resetPlanBaselines();
    _log.infoEvent('plan', 'plan.clear', details: {'count': '$count'});
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.messageFor(
        'planCleared',
        parameters: {'count': count},
        eventId: 'plan.clear.succeeded',
      ),
    );
  }

  @override
  Future<void> recoverFromSafetyRejection() async {
    if (isBusy) return;
    pendingOperations = const [];
    _resetPlanBaselines();
    notifyListeners();
    await refresh();
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    if (!hasRepository) {
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor('noRepositoryOpen'),
        completed: 0,
        total: 0,
        remaining: const [],
      );
    }
    if (isBusy) {
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor('operationInProgress'),
        completed: 0,
        total: pendingOperations.length,
        remaining: pendingOperations,
      );
    }
    if (pendingOperations.isEmpty) {
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor('emptyOperationPlan'),
        completed: 0,
        total: 0,
        remaining: const [],
      );
    }

    final operations = List<PlannedRepositoryOperation>.of(pendingOperations);
    final strongOperation = operations
        .where((operation) => operation.strongConfirmationText != null)
        .firstOrNull;
    if (strongOperation != null &&
        strongConfirmationText != strongOperation.strongConfirmationText) {
      _log.warningEvent(
        'plan',
        'plan.preflight.strongConfirmation.mismatch',
        details: {'kind': strongOperation.kind.name},
      );
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor(
          'planStrongConfirmationRequired',
          parameters: {
            'confirmation': strongOperation.strongConfirmationText ?? '',
          },
        ),
        completed: 0,
        total: operations.length,
        remaining: operations,
      );
    }
    if (operations.any((operation) => operation.isDangerous) &&
        !confirmedDangerous) {
      _log.warningEvent('plan', 'plan.preflight.dangerousConfirmation.missing');
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor(
          'planDangerousAcknowledgmentRequired',
        ),
        completed: 0,
        total: operations.length,
        remaining: operations,
      );
    }

    isBusy = true;
    isExecutingPlan = true;
    notifyListeners();
    var completed = 0;
    try {
      final preflight = await _validatePlanStart(operations);
      if (!preflight.isSuccess) {
        _log.warningEvent(
          'plan',
          'plan.preflight.state.changed',
          details: {'validation': preflight.summary.replaceAll('\n', ' | ')},
        );
        return OperationPlanResult(
          isSuccess: false,
          message: RuntimeMessages.messageFor('planStateChanged'),
          completed: 0,
          total: operations.length,
          remaining: operations,
          validation: preflight,
        );
      }
      _runtimeBaseline = await _git!.stateSnapshot();
      _log.infoEvent(
        'plan',
        'plan.execute.started',
        details: {'count': '${operations.length}'},
      );
      for (var index = 0; index < operations.length; index++) {
        final operation = operations[index];
        if (index > 0) {
          final stepValidation = await _validateRuntimeState();
          if (!stepValidation.isSuccess) {
            pendingOperations = List.unmodifiable(operations.sublist(index));
            _log.warningEvent(
              'plan',
              'plan.execute.stepPreflight.changed',
              details: {
                'step': '${index + 1}',
                'validation': stepValidation.summary.replaceAll('\n', ' | '),
              },
            );
            return OperationPlanResult(
              isSuccess: false,
              message: RuntimeMessages.messageFor(
                'planStepStateChanged',
                parameters: {'step': index + 1},
              ),
              completed: completed,
              total: operations.length,
              remaining: pendingOperations,
              validation: stepValidation,
            );
          }
        }
        planCurrentStep = index + 1;
        planCurrentTitle = operation.title;
        _log.infoEvent(
          'plan',
          'plan.execute.step.started',
          details: {
            'step': '${index + 1}',
            'total': '${operations.length}',
            'kind': operation.kind.name,
          },
        );
        onProgress?.call(
          OperationPlanProgress(
            step: index + 1,
            total: operations.length,
            title: operation.title,
          ),
        );
        notifyListeners();
        if (index > 0) {
          final finalStepValidation = await _validateRuntimeState();
          if (!finalStepValidation.isSuccess) {
            pendingOperations = List.unmodifiable(operations.sublist(index));
            _log.warningEvent(
              'plan',
              'plan.execute.stepFinalPreflight.changed',
              details: {
                'step': '${index + 1}',
                'validation': finalStepValidation.summary.replaceAll(
                  '\n',
                  ' | ',
                ),
              },
            );
            return OperationPlanResult(
              isSuccess: false,
              message: RuntimeMessages.messageFor(
                'planStepStateChanged',
                parameters: {'step': index + 1},
              ),
              completed: completed,
              total: operations.length,
              remaining: pendingOperations,
              validation: finalStepValidation,
            );
          }
        }
        final outcome = await operation.run();
        if (!outcome.isSuccess) {
          pendingOperations = List.unmodifiable(operations.sublist(index));
          _log.errorEvent(
            'plan',
            'plan.execute.step.failed',
            details: {
              'step': '${index + 1}',
              'kind': operation.kind.name,
              'error': outcome.message.eventId,
              'messageKey': outcome.message.key,
            },
          );
          return OperationPlanResult(
            isSuccess: false,
            message: RuntimeMessages.messageFor(
              'planStepFailed',
              parameters: {
                'step': index + 1,
                'error': _outcomeDetail(outcome.message),
              },
              eventId: 'plan.execute.step.failed',
              technicalDetails: {
                'stepKind': operation.kind.name,
                'outcomeKey': outcome.message.key,
              },
            ),
            completed: completed,
            total: operations.length,
            remaining: pendingOperations,
          );
        }
        completed += 1;
        pendingOperations = List.unmodifiable(operations.sublist(index + 1));
        if (_git == null) {
          _resetPlanBaselines();
        } else {
          _runtimeBaseline = await _git!.stateSnapshot();
        }
        _log.infoEvent(
          'plan',
          'plan.execute.step.completed',
          details: {
            'step': '${index + 1}',
            'kind': operation.kind.name,
            'outcomeKey': outcome.message.key,
          },
        );
        notifyListeners();
      }
      _resetPlanBaselines();
      _log.infoEvent(
        'plan',
        'plan.execute.completed',
        details: {'count': '$completed'},
      );
      return OperationPlanResult(
        isSuccess: true,
        message: RuntimeMessages.messageFor(
          'planExecutionComplete',
          parameters: {'count': completed},
          eventId: 'plan.execute.completed',
        ),
        completed: completed,
        total: operations.length,
        remaining: const [],
      );
    } catch (error) {
      final failedIndex = completed;
      pendingOperations = List.unmodifiable(
        operations.sublist(failedIndex.clamp(0, operations.length)),
      );
      _log.errorEvent(
        'plan',
        'plan.execute.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'plan.execute.failed',
        ),
        completed: completed,
        total: operations.length,
        remaining: pendingOperations,
      );
    } finally {
      isBusy = false;
      isExecutingPlan = false;
      planCurrentStep = 0;
      planCurrentTitle = null;
      notifyListeners();
    }
  }

  Future<OperationOutcome> _queueOperation(
    PlannedRepositoryOperation operation,
  ) async {
    if (!hasRepository) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noRepositoryOpen'),
      );
    }
    if (isBusy || _isCapturingPlan) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final hasClearOperation = pendingOperations.any(
      (item) => item.kind == PlannedOperationKind.clearRemote,
    );
    if (hasClearOperation ||
        (operation.kind == PlannedOperationKind.clearRemote &&
            pendingOperations.isNotEmpty)) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('clearRemoteMustRunAlone'),
      );
    }
    final commitAlreadyQueued = hasQueuedCommit;
    const allowedAfterCommit = {
      PlannedOperationKind.fetchCurrentRemote,
      PlannedOperationKind.fetchAllRemotes,
      PlannedOperationKind.pullFastForward,
      PlannedOperationKind.pushCurrentBranch,
      PlannedOperationKind.pushRemote,
      PlannedOperationKind.pushAllRemotes,
      PlannedOperationKind.addRemote,
      PlannedOperationKind.updateRemote,
      PlannedOperationKind.removeRemoteConfig,
      PlannedOperationKind.createBranch,
      PlannedOperationKind.switchBranch,
      PlannedOperationKind.renameBranch,
      PlannedOperationKind.deleteBranch,
      PlannedOperationKind.createStash,
      PlannedOperationKind.applyStash,
      PlannedOperationKind.popStash,
      PlannedOperationKind.dropStash,
    };
    if (commitAlreadyQueued && !allowedAfterCommit.contains(operation.kind)) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('commitMustRemainLast'),
      );
    }
    if (operation.isExclusive && pendingOperations.isNotEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('exclusiveOperationMustRunAlone'),
      );
    }
    if (pendingOperations.any((item) => item.isExclusive)) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('exclusiveOperationAlreadyQueued'),
      );
    }
    _isCapturingPlan = true;
    try {
      final globalSnapshot = await _git!.stateSnapshot();
      final baseline = _planBaseline;
      if (pendingOperations.isNotEmpty && baseline != null) {
        final drift = compareRepositorySnapshots(
          expected: baseline,
          actual: globalSnapshot,
        );
        if (!drift.isSuccess) {
          _log.warningEvent(
            'plan',
            'plan.queue.state.changed',
            details: {'validation': drift.summary.replaceAll('\n', ' | ')},
          );
          return OperationOutcome.failure(
            RuntimeMessages.messageFor('planStateChanged'),
          );
        }
      }
      final pathTypes = await _git!.pathTypeSnapshot(operation.affectedPaths);
      final precondition = OperationPrecondition(
        repository: RepositoryStateSnapshot(
          rootPath: globalSnapshot.rootPath,
          branch: globalSnapshot.branch,
          head: globalSnapshot.head,
          statusFingerprint: globalSnapshot.statusFingerprint,
          remoteUrls: globalSnapshot.remoteUrls,
          pathTypes: pathTypes,
        ),
        bootstrap: operation.precondition?.bootstrap,
        remote: operation.precondition?.remote,
      );
      _operationSequence += 1;
      pendingOperations = List.unmodifiable([
        ...pendingOperations,
        PlannedRepositoryOperation(
          id: '${DateTime.now().microsecondsSinceEpoch}-$_operationSequence',
          kind: operation.kind,
          title: operation.title,
          description: operation.description,
          run: operation.run,
          isDangerous: operation.isDangerous,
          isExclusive: operation.isExclusive,
          strongConfirmationText: operation.strongConfirmationText,
          precondition: precondition,
          affectedPaths: operation.affectedPaths,
        ),
      ]);
      _planBaseline ??= globalSnapshot;
      _log.infoEvent(
        'plan',
        'plan.entry.queued',
        details: {
          'count': '${pendingOperations.length}',
          'kind': operation.kind.name,
          'titleKey': operation.title.key,
          'descriptionKey': operation.description.key,
        },
      );
      notifyListeners();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'planOperationAdded',
          eventId: 'plan.entry.queued',
          technicalDetails: {'kind': operation.kind.name},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'plan',
        'plan.queue.failed',
        details: {'error': '$_cleanError(error)', 'kind': operation.kind.name},
      );
      return OperationOutcome.failure(
        RuntimeMessages.messageFor(
          'planSnapshotFailed',
          parameters: {'error': _cleanError(error)},
          eventId: 'plan.queue.failed',
        ),
      );
    } finally {
      _isCapturingPlan = false;
    }
  }

  Future<OperationOutcome> pasteToActivePanel() async {
    if (_git == null || clipboard == null || isBusy) {
      return OperationOutcome.failure(
        clipboard == null
            ? RuntimeMessages.messageFor('clipboardEmpty')
            : RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final selection = ExplorerSelection(
      paths: List.unmodifiable(clipboard!.paths),
      mode: clipboard!.mode,
    );
    final destination = panelFor(activeSide).relativePath;
    final isMove = selection.mode == ClipboardMode.cut;
    final destinationLabel = destination.isEmpty ? '.' : destination;
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: isMove ? PlannedOperationKind.move : PlannedOperationKind.copy,
        title: RuntimeMessages.messageFor(
          isMove ? 'planTitleMove' : 'planTitleCopy',
          parameters: {
            'count': selection.paths.length,
            'destination': destinationLabel,
          },
        ),
        description: RuntimeMessages.messageFor(
          isMove ? 'planDescriptionMove' : 'planDescriptionCopy',
          parameters: {
            'count': selection.paths.length,
            'destination': destinationLabel,
          },
        ),
        run: () => _applyPaste(selection, destination),
        affectedPaths: [
          ...selection.paths,
          if (destination.isNotEmpty) destination,
        ],
      ),
    );
    if (!outcome.isSuccess) {
      return outcome;
    }
    clipboard = null;
    leftPanel = leftPanel.copyWith(selectedPaths: const {});
    rightPanel = rightPanel.copyWith(selectedPaths: const {});
    notifyListeners();
    return outcome;
  }

  Future<OperationOutcome> _applyPaste(
    ExplorerSelection selection,
    String destination,
  ) async {
    try {
      if (selection.mode == ClipboardMode.cut) {
        await _git!.movePaths(selection.paths, destination);
      } else {
        await _git!.copyPaths(selection.paths, destination);
      }
      await _reloadAfterMutation();
      return OperationOutcome.success(
        RuntimeMessages.operationCompletedForItems(
          selection.paths.length,
          eventId: selection.mode == ClipboardMode.cut
              ? 'repository.move.succeeded'
              : 'repository.copy.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'clipboard',
        'repository.paste.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.paste.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> renameSelection(String newName) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.length != 1) {
      _log.warningEvent(
        'rename',
        'repository.rename.selection.invalid',
        details: {'count': '${panel.selectedPaths.length}'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('renameSelectOne'),
      );
    }
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('nameCannotBeEmpty'),
      );
    }
    final source = panel.selectedPaths.single;
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.rename,
        title: RuntimeMessages.messageFor(
          'planTitleRename',
          parameters: {'source': source},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionRename',
          parameters: {'source': source, 'newName': trimmed},
        ),
        run: () => _applyRename(source, trimmed),
        affectedPaths: [source],
      ),
    );
    if (outcome.isSuccess) {
      leftPanel = leftPanel.copyWith(selectedPaths: const {});
      rightPanel = rightPanel.copyWith(selectedPaths: const {});
      notifyListeners();
    }
    return outcome;
  }

  Future<OperationOutcome> _applyRename(String source, String newName) async {
    try {
      await _git!.renamePath(source, newName);
      await _reloadAfterMutation();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'fileRenamed',
          parameters: {'name': newName},
          eventId: 'repository.rename.succeeded',
          technicalDetails: {'source': source, 'newName': newName},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'rename',
        'repository.rename.failed',
        details: {
          'source': source,
          'newName': newName,
          'error': '$_cleanError(error)',
        },
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.rename.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> deleteSelectedPaths() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.isEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('selectItemsToDelete'),
      );
    }
    final paths = panel.selectedPaths.toList(growable: false);
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.delete,
        title: RuntimeMessages.messageFor(
          'planTitleDelete',
          parameters: {'count': paths.length},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionDelete',
          parameters: {'count': paths.length, 'paths': paths.join(' | ')},
        ),
        run: () => _applyDelete(paths),
        isDangerous: true,
        affectedPaths: paths,
      ),
    );
    if (outcome.isSuccess) {
      clipboard = null;
      leftPanel = leftPanel.copyWith(selectedPaths: const {});
      rightPanel = rightPanel.copyWith(selectedPaths: const {});
      notifyListeners();
    }
    return outcome;
  }

  Future<OperationOutcome> _applyDelete(List<String> paths) async {
    try {
      await _git!.deletePaths(paths);
      await _reloadAfterMutation();
      return OperationOutcome.success(
        RuntimeMessages.operationCompletedForItems(
          paths.length,
          eventId: 'repository.delete.succeeded',
          technicalDetails: {'paths': paths.join(' | ')},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'delete',
        'repository.delete.failed',
        details: {'paths': paths.join(' | '), 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.delete.failed',
        ),
      );
    }
  }

  Future<List<String>> localBranches() async {
    if (_git == null) return const [];
    final branches = await _git!.localBranches();
    final current = branch;
    branches.sort((left, right) {
      if (left == current) return -1;
      if (right == current) return 1;
      return left.toLowerCase().compareTo(right.toLowerCase());
    });
    return branches;
  }

  Future<OperationOutcome> createBranch(String name) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmed = name.trim();
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.validate.failed',
        ),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.createBranch,
        title: RuntimeMessages.messageFor(
          'planTitleCreateBranch',
          parameters: {'branch': trimmed},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionCreateBranch',
          parameters: {'branch': trimmed},
        ),
        run: () => _applyCreateBranch(trimmed),
      ),
    );
  }

  Future<OperationOutcome> _applyCreateBranch(String name) async {
    try {
      await _git!.createBranch(name);
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'branchCreated',
          parameters: {'branch': name},
          eventId: 'repository.branch.create.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'branch',
        'repository.branch.create.failed',
        details: {'branch': name, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.create.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> switchBranch(String name) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmed = name.trim();
    if (trimmed == branch) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor(
          'alreadyOnBranch',
          parameters: {'branch': trimmed},
        ),
      );
    }
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.validate.failed',
          target: trimmed,
        ),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.switchBranch,
        title: RuntimeMessages.messageFor(
          'planTitleSwitchBranch',
          parameters: {'branch': trimmed},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionSwitchBranch',
          parameters: {'branch': trimmed},
        ),
        run: () => _applySwitchBranch(trimmed),
      ),
    );
  }

  Future<OperationOutcome> _applySwitchBranch(String name) async {
    try {
      await _git!.switchBranch(name);
      await _reloadAfterMutation();
      branch = await _git!.currentBranch();
      syncState = await _readSyncState(_git!);
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'branchSwitched',
          parameters: {'branch': name},
          eventId: 'repository.branch.switch.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'branch',
        'repository.branch.switch.failed',
        details: {'branch': name, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.switch.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> renameBranch(String oldName, String newName) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final oldTrimmed = oldName.trim();
    final newTrimmed = newName.trim();
    try {
      await _git!.validateBranchName(oldTrimmed);
      await _git!.validateBranchName(newTrimmed);
    } catch (error) {
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.validate.failed',
          target: newTrimmed,
        ),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.renameBranch,
        title: RuntimeMessages.messageFor(
          'planTitleRenameBranch',
          parameters: {'from': oldTrimmed, 'to': newTrimmed},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionRenameBranch',
          parameters: {'from': oldTrimmed, 'to': newTrimmed},
        ),
        run: () => _applyRenameBranch(oldTrimmed, newTrimmed),
      ),
    );
  }

  Future<OperationOutcome> _applyRenameBranch(
    String oldName,
    String newName,
  ) async {
    try {
      await _git!.renameBranch(oldName, newName);
      if (branch == oldName) {
        branch = newName;
      }
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'branchRenamed',
          parameters: {'from': oldName, 'to': newName},
          eventId: 'repository.branch.rename.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'branch',
        'repository.branch.rename.failed',
        details: {
          'from': oldName,
          'to': newName,
          'error': '$_cleanError(error)',
        },
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.rename.failed',
          target: newName,
        ),
      );
    }
  }

  Future<OperationOutcome> deleteBranch(
    String name, {
    bool force = false,
  }) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmed = name.trim();
    if (trimmed == branch) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('cannotDeleteCurrentBranch'),
      );
    }
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.validate.failed',
          target: trimmed,
        ),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.deleteBranch,
        title: RuntimeMessages.messageFor(
          'planTitleDeleteBranch',
          parameters: {'branch': trimmed},
        ),
        description: RuntimeMessages.messageFor(
          force
              ? 'planDescriptionDeleteBranchForce'
              : 'planDescriptionDeleteBranchSafe',
          parameters: {'branch': trimmed},
        ),
        run: () => _applyDeleteBranch(trimmed, force: force),
        isDangerous: true,
      ),
    );
  }

  Future<OperationOutcome> _applyDeleteBranch(
    String name, {
    required bool force,
  }) async {
    try {
      await _git!.deleteBranch(name, force: force);
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'branchDeleted',
          parameters: {'branch': name},
          eventId: 'repository.branch.delete.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'branch',
        'repository.branch.delete.failed',
        details: {
          'branch': name,
          'force': '$force',
          'error': '$_cleanError(error)',
        },
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.branch.delete.failed',
          target: name,
        ),
      );
    }
  }

  Future<List<GitStashEntry>> listStashes() async {
    if (_git == null) return const [];
    return _git!.listStashes();
  }

  Future<OperationOutcome> createStash({
    String message = '',
    bool includeUntracked = true,
  }) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmed = message.trim();
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.createStash,
        title: RuntimeMessages.messageFor(
          trimmed.isEmpty
              ? 'planTitleCreateStash'
              : 'planTitleCreateStashNamed',
          parameters: trimmed.isEmpty ? const {} : {'message': trimmed},
        ),
        description: RuntimeMessages.messageFor(
          includeUntracked
              ? 'planDescriptionCreateStashIncludeUntracked'
              : 'planDescriptionCreateStash',
          parameters: {'message': trimmed},
        ),
        run: () => _applyCreateStash(
          message: trimmed,
          includeUntracked: includeUntracked,
        ),
      ),
    );
  }

  Future<OperationOutcome> _applyCreateStash({
    required String message,
    required bool includeUntracked,
  }) async {
    try {
      await _git!.createStash(
        message: message,
        includeUntracked: includeUntracked,
      );
      await _reloadAfterMutation();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'stashCreated',
          eventId: 'repository.stash.create.succeeded',
          technicalDetails: {
            'includeUntracked': '$includeUntracked',
            if (message.isNotEmpty) 'message': message,
          },
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'stash',
        'repository.stash.create.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.stash.create.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> applyStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.applyStash,
      title: RuntimeMessages.messageFor(
        'planTitleApplyStash',
        parameters: {'selector': selector},
      ),
      description: RuntimeMessages.messageFor(
        'planDescriptionApplyStash',
        parameters: {'selector': selector},
      ),
      run: () => _applyStashAction(
        selector: selector,
        successKey: 'stashApplied',
        action: () => _git!.applyStash(selector),
        reload: true,
      ),
    );
  }

  Future<OperationOutcome> popStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.popStash,
      title: RuntimeMessages.messageFor(
        'planTitlePopStash',
        parameters: {'selector': selector},
      ),
      description: RuntimeMessages.messageFor(
        'planDescriptionPopStash',
        parameters: {'selector': selector},
      ),
      run: () => _applyStashAction(
        selector: selector,
        successKey: 'stashPopped',
        action: () => _git!.popStash(selector),
        reload: true,
      ),
    );
  }

  Future<OperationOutcome> dropStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.dropStash,
      title: RuntimeMessages.messageFor(
        'planTitleDropStash',
        parameters: {'selector': selector},
      ),
      description: RuntimeMessages.messageFor(
        'planDescriptionDropStash',
        parameters: {'selector': selector},
      ),
      run: () => _applyStashAction(
        selector: selector,
        successKey: 'stashDropped',
        action: () => _git!.dropStash(selector),
      ),
      isDangerous: true,
    );
  }

  Future<OperationOutcome> _queueStashOperation({
    required String selector,
    required PlannedOperationKind kind,
    required LocalizedMessage title,
    required LocalizedMessage description,
    required Future<OperationOutcome> Function() run,
    bool isDangerous = false,
  }) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    if (!RegExp(r'^stash@\{\d+\}$').hasMatch(selector.trim())) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('invalidStashSelector'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: kind,
        title: title,
        description: description,
        run: run,
        isDangerous: isDangerous,
      ),
    );
  }

  Future<OperationOutcome> _applyStashAction({
    required String selector,
    required String successKey,
    required Future<void> Function() action,
    bool reload = false,
  }) async {
    try {
      await action();
      if (reload) {
        await _reloadAfterMutation();
      }
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          successKey,
          parameters: {'selector': selector},
          eventId: successKey == 'stashApplied'
              ? 'repository.stash.apply.succeeded'
              : successKey == 'stashPopped'
              ? 'repository.stash.pop.succeeded'
              : 'repository.stash.drop.succeeded',
          technicalDetails: {'selector': selector},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'stash',
        'repository.stash.action.failed',
        details: {'selector': selector, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.stash.action.failed',
          target: selector,
        ),
      );
    }
  }

  Future<OperationOutcome> pushCurrentBranch() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final branchLabel = branch;
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushCurrentBranch,
        title: RuntimeMessages.messageFor(
          branchLabel.isEmpty ? 'planTitlePushCurrent' : 'planTitlePushBranch',
          parameters: branchLabel.isEmpty ? const {} : {'branch': branchLabel},
        ),
        description: RuntimeMessages.messageFor('planDescriptionPushCurrent'),
        run: _applyPushCurrentBranch,
      ),
    );
  }

  Future<OperationOutcome> fetchCurrentUpstream() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final state = syncState ?? await _readSyncState(_git!);
    if (state == null || !state.hasUpstream) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('upstreamMissing'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.fetchCurrentRemote,
        title: RuntimeMessages.messageFor(
          'planTitleFetchRemote',
          parameters: {'remote': state.upstreamRemote},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionFetchRemote',
          parameters: {'remote': state.upstreamRemote},
        ),
        run: () => _applyFetchRemote(state.upstreamRemote),
      ),
    );
  }

  Future<OperationOutcome> fetchAllRemotes() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    if (remotes.isEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noRemotesConfigured'),
      );
    }
    final names = remotes.map((remote) => remote.name).toList(growable: false);
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.fetchAllRemotes,
        title: RuntimeMessages.messageFor(
          'planTitleFetchAllRemotes',
          parameters: {'count': names.length},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionFetchAllRemotes',
          parameters: {'remotes': names.join(' | ')},
        ),
        run: () => _applyFetchAllRemotes(names),
      ),
    );
  }

  Future<OperationOutcome> _applyFetchRemote(String remoteName) async {
    try {
      final output = await _git!.fetchRemote(remoteName);
      await _reloadAfterMutation(refreshStats: false);
      _log.detailEvent(
        'sync',
        'repository.fetch.completed',
        details: {'remote': remoteName, 'output': output},
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'remoteFetched',
          parameters: {'remote': remoteName},
          eventId: 'repository.fetch.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'sync',
        'repository.fetch.failed',
        details: {'remote': remoteName, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(_syncFailureMessage(error));
    }
  }

  Future<OperationOutcome> _applyFetchAllRemotes(
    List<String> remoteNames,
  ) async {
    final succeeded = <String>[];
    final failed = <String>[];
    for (final remoteName in remoteNames) {
      try {
        await _git!.fetchRemote(remoteName);
        succeeded.add(remoteName);
      } catch (error) {
        _log.errorEvent(
          'sync',
          'repository.fetch.failed',
          details: {'remote': remoteName, 'error': '$_cleanError(error)'},
        );
        failed.add('$remoteName=${_cleanError(error)}');
      }
    }
    await _reloadAfterMutation(refreshStats: false);
    if (failed.isEmpty) {
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'allRemotesFetched',
          parameters: {'count': succeeded.length},
          eventId: 'repository.fetchAll.succeeded',
        ),
      );
    }
    return OperationOutcome.failure(
      RuntimeMessages.messageFor(
        'remoteBatchPartialFailure',
        parameters: {
          'succeeded': succeeded.length,
          'failed': failed.length,
          'details': failed.join(' | '),
        },
        eventId: 'repository.fetchAll.partialFailure',
      ),
    );
  }

  Future<OperationOutcome> pullCurrentBranchFastForward() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final state = syncState ?? await _readSyncState(_git!);
    if (state == null) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('syncStateUnavailable'),
      );
    }
    if (state.isDetached) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('detachedCannotPull'),
      );
    }
    if (state.isUnborn) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('unbornCannotPull'),
      );
    }
    if (!state.hasUpstream) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('upstreamMissing'),
      );
    }
    if (!state.worktreeClean) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('dirtyWorktreeCannotPull'),
      );
    }
    switch (state.relation) {
      case BranchSyncRelation.behind:
        break;
      case BranchSyncRelation.upToDate:
        return OperationOutcome.failure(
          RuntimeMessages.messageFor('pullUpToDate'),
        );
      case BranchSyncRelation.ahead:
        return OperationOutcome.failure(
          RuntimeMessages.messageFor('pullAhead'),
        );
      case BranchSyncRelation.diverged:
        return OperationOutcome.failure(
          RuntimeMessages.messageFor('pullDiverged'),
        );
      case BranchSyncRelation.unknown:
        return OperationOutcome.failure(
          RuntimeMessages.messageFor('pullRelationUnknown'),
        );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pullFastForward,
        title: RuntimeMessages.messageFor(
          'planTitlePull',
          parameters: {'branch': state.branch},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionPull',
          parameters: {
            'branch': state.branch,
            'remote': state.upstreamRemote,
            'upstream': state.upstreamRef,
          },
        ),
        run: _applyPullFastForward,
      ),
    );
  }

  Future<OperationOutcome> _applyPullFastForward() async {
    try {
      final result = await _git!.pullFastForward();
      await _reloadAfterMutation();
      if (!result.updated) {
        return OperationOutcome.success(
          RuntimeMessages.messageFor(
            'pullNoUpdate',
            eventId: 'repository.pull.noUpdate',
            technicalDetails: {'output': result.output},
          ),
        );
      }
      _log.detailEvent(
        'sync',
        'repository.pull.completed',
        details: {'output': result.output},
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'pullCompleted',
          parameters: {
            'branch': result.state.branch,
            'upstream': result.state.upstreamRef,
          },
          eventId: 'repository.pull.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'sync',
        'repository.pull.failed',
        details: {'error': '$_cleanError(error)'},
      );
      syncState = await _readSyncState(_git!);
      return OperationOutcome.failure(_syncFailureMessage(error));
    }
  }

  LocalizedMessage _syncFailureMessage(Object error) {
    final text = _cleanError(error);
    final lower = text.toLowerCase();
    if (lower.contains('authentication') ||
        lower.contains('permission denied') ||
        lower.contains('could not read from remote')) {
      return RuntimeMessages.messageFor(
        'syncAuthenticationFailed',
        parameters: {'error': text},
        eventId: 'repository.sync.authenticationFailed',
      );
    }
    if (lower.contains('could not resolve host') ||
        lower.contains('network') ||
        lower.contains('timed out')) {
      return RuntimeMessages.messageFor(
        'syncNetworkFailed',
        parameters: {'error': text},
        eventId: 'repository.sync.networkFailed',
      );
    }
    return RuntimeMessages.operationFailed(
      text,
      eventId: 'repository.sync.failed',
    );
  }

  LocalizedMessage _commitIdentityFailure(GitIdentityState identity) {
    return RuntimeMessages.messageFor(
      'commitIdentityUnavailable',
      eventId: 'repository.commit.identityUnavailable',
      technicalDetails: {
        if (identity.errorMessage.isNotEmpty) 'error': identity.errorMessage,
      },
    );
  }

  Future<OperationOutcome> _applyPushCurrentBranch() async {
    try {
      final output = await _git!.pushCurrentBranch();
      branch = await _git!.currentBranch();
      syncState = await _readSyncState(_git!);
      _log.detailEvent(
        'push',
        'repository.push.completed',
        details: {'output': output, 'branch': branch},
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          branch.isEmpty ? 'pushedCurrentBranch' : 'pushedBranch',
          parameters: branch.isEmpty ? const {} : {'branch': branch},
          eventId: 'repository.push.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'push',
        'repository.push.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.push.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> refreshRemotes() async {
    if (_git == null) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noRepositoryOpen'),
      );
    }
    try {
      remotes = await _git!.remotes();
      syncState = await _readSyncState(_git!);
      notifyListeners();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'remoteListRefreshed',
          eventId: 'repository.remote.refresh.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'remote',
        'repository.remote.refresh.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.remote.refresh.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> saveRemote({
    required String name,
    required String url,
    required bool updateExisting,
  }) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmedName = name.trim();
    final trimmedUrl = url.trim();
    final maskedUrl = GitRemote.maskRemoteUrl(trimmedUrl);
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: updateExisting
            ? PlannedOperationKind.updateRemote
            : PlannedOperationKind.addRemote,
        title: RuntimeMessages.messageFor(
          updateExisting ? 'planTitleUpdateRemote' : 'planTitleAddRemote',
          parameters: {'remote': trimmedName},
        ),
        description: RuntimeMessages.messageFor(
          updateExisting
              ? 'planDescriptionUpdateRemote'
              : 'planDescriptionAddRemote',
          parameters: {'remote': trimmedName, 'url': maskedUrl},
        ),
        run: () => _applySaveRemote(
          name: trimmedName,
          url: trimmedUrl,
          updateExisting: updateExisting,
        ),
      ),
    );
  }

  Future<OperationOutcome> _applySaveRemote({
    required String name,
    required String url,
    required bool updateExisting,
  }) async {
    try {
      if (updateExisting) {
        await _git!.setRemoteUrl(name, url);
      } else {
        await _git!.addRemote(name, url);
      }
      remotes = await _git!.remotes();
      syncState = await _readSyncState(_git!);
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          updateExisting ? 'remoteUpdated' : 'remoteAdded',
          parameters: {'remote': name},
          eventId: updateExisting
              ? 'repository.remote.update.succeeded'
              : 'repository.remote.add.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'remote',
        'repository.remote.save.failed',
        details: {'remote': name, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.remote.save.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> removeRemote(String name) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.removeRemoteConfig,
        title: RuntimeMessages.messageFor(
          'planTitleRemoveRemote',
          parameters: {'remote': name},
        ),
        description: RuntimeMessages.messageFor('planDescriptionRemoveRemote'),
        run: () => _applyRemoveRemote(name),
      ),
    );
  }

  Future<OperationOutcome> _applyRemoveRemote(String name) async {
    try {
      await _git!.removeRemote(name);
      remotes = await _git!.remotes();
      syncState = await _readSyncState(_git!);
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'remoteRemoved',
          parameters: {'remote': name},
          eventId: 'repository.remote.remove.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'remote',
        'repository.remote.remove.failed',
        details: {'remote': name, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.remote.remove.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> pushToRemote(String name) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushRemote,
        title: RuntimeMessages.messageFor(
          'planTitlePushRemote',
          parameters: {'remote': name},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionPushRemote',
          parameters: {'remote': name, 'branch': branch},
        ),
        run: () => _applyPushToRemote(name),
      ),
    );
  }

  Future<OperationOutcome> _applyPushToRemote(String name) async {
    try {
      final output = await _git!.pushToRemote(name);
      _log.detailEvent(
        'push',
        'repository.push.remote.completed',
        details: {'remote': name, 'output': output},
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'pushedToRemote',
          parameters: {'remote': name},
          eventId: 'repository.push.remote.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'push',
        'repository.push.remote.failed',
        details: {'remote': name, 'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.push.remote.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> pushToAllRemotes() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    if (remotes.isEmpty) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noRemotesConfigured'),
      );
    }
    final names = remotes.map((remote) => remote.name).toList(growable: false);
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushAllRemotes,
        title: RuntimeMessages.messageFor(
          'planTitlePushAllRemotes',
          parameters: {'count': names.length},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionPushAllRemotes',
          parameters: {'remotes': names.join(' | ')},
        ),
        run: () => _applyPushToAllRemotes(names),
      ),
    );
  }

  Future<OperationOutcome> _applyPushToAllRemotes(
    List<String> remoteNames,
  ) async {
    final succeeded = <String>[];
    final failed = <String>[];
    for (final remoteName in remoteNames) {
      try {
        await _git!.pushToRemote(remoteName);
        succeeded.add(remoteName);
      } catch (error) {
        _log.errorEvent(
          'push',
          'repository.push.remote.failed',
          details: {'remote': remoteName, 'error': '$_cleanError(error)'},
        );
        failed.add('$remoteName=${_cleanError(error)}');
      }
    }
    if (failed.isEmpty) {
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'pushedToAllRemotes',
          parameters: {'count': succeeded.length},
          eventId: 'repository.pushAll.succeeded',
        ),
      );
    }
    return OperationOutcome.failure(
      RuntimeMessages.messageFor(
        'remoteBatchPartialFailure',
        parameters: {
          'succeeded': succeeded.length,
          'failed': failed.length,
          'details': failed.join(' | '),
        },
        eventId: 'repository.pushAll.partialFailure',
      ),
    );
  }

  Future<RemoteClearInspection> inspectRemoteForClear(String name) async {
    if (_git == null || isBusy) {
      return RemoteClearInspection(
        isSuccess: false,
        message: RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    try {
      final preview = await _git!.previewClearRemote(name);
      return RemoteClearInspection(
        isSuccess: true,
        message: preview.isEmpty
            ? RuntimeMessages.messageFor(
                'remoteInspectionEmpty',
                parameters: {'remote': name},
              )
            : RuntimeMessages.messageFor(
                'remoteInspectionCounts',
                parameters: {
                  'remote': name,
                  'branches': preview.branchCount,
                  'tags': preview.tagCount,
                },
              ),
        preview: preview,
      );
    } catch (error) {
      _log.errorEvent(
        'remote-clear',
        'repository.remote.clear.inspect.failed',
        details: {'remote': name, 'error': '$_cleanError(error)'},
      );
      return RemoteClearInspection(
        isSuccess: false,
        message: RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.remote.clear.inspect.failed',
          target: name,
        ),
      );
    }
  }

  Future<OperationOutcome> queueClearRemote(RemoteClearPreview preview) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.clearRemote,
        title: RuntimeMessages.messageFor(
          'planTitleClearRemote',
          parameters: {'remote': preview.remoteName},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionClearRemote',
          parameters: {
            'project': preview.projectName,
            'branch': preview.targetBranch,
            'branches': preview.branchCount,
            'tags': preview.tagCount,
            'message': preview.emptyCommitMessage,
          },
        ),
        run: () => _applyClearRemote(preview),
        isDangerous: true,
        isExclusive: true,
        strongConfirmationText: preview.confirmationText,
      ),
    );
  }

  Future<OperationOutcome> _applyClearRemote(RemoteClearPreview preview) async {
    try {
      final result = await _git!.clearRemote(
        preview.remoteName,
        preview: preview,
      );
      await _reloadAfterMutation();
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'clearRemoteCompleted',
          parameters: {
            'remote': preview.remoteName,
            'branch': result.targetBranch,
            'commit': result.emptyCommitHash.substring(0, 8),
          },
          eventId: 'repository.remote.clear.succeeded',
          technicalDetails: {
            'remote': preview.remoteName,
            'project': preview.projectName,
            'branch': result.targetBranch,
            'commit': result.emptyCommitHash,
          },
        ),
      );
    } catch (error) {
      final technicalError = _cleanError(error);
      var outcome = RuntimeMessages.operationFailed(
        technicalError,
        eventId: 'repository.remote.clear.failed',
        target: preview.remoteName,
      );
      final technicalDetails = <String, String>{'error': technicalError};
      if (technicalError.contains('远端引用在确认后发生了变化')) {
        try {
          final refreshed = await _git!.previewClearRemote(preview.remoteName);
          outcome = RuntimeMessages.messageFor(
            'clearRemoteDrift',
            parameters: {
              'remote': preview.remoteName,
              'branches': refreshed.branchCount,
              'tags': refreshed.tagCount,
              'error': technicalError,
            },
            eventId: 'repository.remote.clear.drift',
          );
          technicalDetails
            ..['branches'] = '${refreshed.branchCount}'
            ..['tags'] = '${refreshed.tagCount}';
        } catch (_) {
          // The original safety rejection remains the primary result.
        }
      }
      _log.errorEvent(
        'remote-clear',
        outcome.eventId,
        details: technicalDetails,
      );
      return OperationOutcome.failure(outcome);
    }
  }

  Future<OperationOutcome> stageAllChanges() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.stageAll,
        title: RuntimeMessages.messageFor('planTitleStageAll'),
        description: RuntimeMessages.messageFor('planDescriptionStageAll'),
        run: _applyStageAllChanges,
      ),
    );
  }

  Future<OperationOutcome> _applyStageAllChanges() async {
    try {
      await _git!.stageAll();
      await _reloadAfterMutation(refreshStats: false);
      _log.detailEvent(
        'commit',
        'repository.stageAll.completed',
        details: {
          'staged': '${changedFiles.where((item) => item.isStaged).length}',
        },
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'stageAllCompleted',
          eventId: 'repository.stageAll.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'commit',
        'repository.stageAll.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.stageAll.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> unstageAllChanges() async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.unstageAll,
        title: RuntimeMessages.messageFor('planTitleUnstageAll'),
        description: RuntimeMessages.messageFor('planDescriptionUnstageAll'),
        run: _applyUnstageAllChanges,
      ),
    );
  }

  Future<OperationOutcome> _applyUnstageAllChanges() async {
    try {
      await _git!.unstageAll();
      await _reloadAfterMutation(refreshStats: false);
      _log.detailEvent('commit', 'repository.unstageAll.completed');
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'unstageAllCompleted',
          eventId: 'repository.unstageAll.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'commit',
        'repository.unstageAll.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.unstageAll.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> commitAll(String message) async {
    if (_git == null || isBusy) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      _log.warningEvent('commit', 'repository.commit.message.empty');
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('commitMessageRequired'),
      );
    }
    if (changedFiles.isEmpty && !hasPendingFileChanges) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('noChangesToCommit'),
      );
    }
    if (pendingOperations.any(
      (operation) => operation.kind == PlannedOperationKind.commit,
    )) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('commitAlreadyQueued'),
      );
    }
    final identity = await _git!.identityState();
    if (!identity.isReady) {
      _log.warningEvent(
        'identity',
        'repository.commit.identityUnavailable',
        details: {'error': identity.errorMessage},
      );
      return OperationOutcome.failure(_commitIdentityFailure(identity));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.commit,
        title: RuntimeMessages.messageFor('planTitleCommitAll'),
        description: RuntimeMessages.messageFor(
          'planDescriptionCommitAll',
          parameters: {'message': trimmed},
        ),
        run: () => _applyCommitAll(trimmed),
      ),
    );
  }

  Future<OperationOutcome> _applyCommitAll(String message) async {
    try {
      final identity = await _git!.identityState();
      if (!identity.isReady) {
        _log.warningEvent(
          'identity',
          'repository.commit.identityRecheck.failed',
          details: {'error': identity.errorMessage},
        );
        return OperationOutcome.failure(_commitIdentityFailure(identity));
      }
      await _git!.stageAll();
      await _git!.commit(message);
      await _reloadAfterMutation();
      _log.infoEvent(
        'commit',
        'repository.commit.succeeded',
        details: {'message': message},
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'commitSucceeded',
          eventId: 'repository.commit.succeeded',
          technicalDetails: {'message': message},
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'commit',
        'repository.commit.failed',
        details: {'error': '$_cleanError(error)', 'message': message},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'repository.commit.failed',
        ),
      );
    }
  }

  Future<OperationOutcome> updateSettings(AppSettings nextSettings) async {
    final oldSettings = settings;
    settings = nextSettings;
    notifyListeners();
    try {
      await _settingsService.save(nextSettings);
      _log.infoEvent('settings', 'settings.update.completed');
      _log.detailEvent(
        'settings',
        'settings.update.details',
        details: {
          'theme':
              '${oldSettings.themePreference.name}->'
              '${nextSettings.themePreference.name}',
          'color':
              '${oldSettings.colorSchemePreference.name}->'
              '${nextSettings.colorSchemePreference.name}',
          'language':
              '${oldSettings.languagePreference.name}->'
              '${nextSettings.languagePreference.name}',
          'units':
              '${oldSettings.unitSystem.name}/'
              '${nextSettings.baseUnit.name}',
          'font': '${oldSettings.fontFamily}->${nextSettings.fontFamily}',
          'scale': '${oldSettings.fontScale}->${nextSettings.fontScale}',
        },
      );
      return OperationOutcome.success(
        RuntimeMessages.messageFor(
          'settingsSaved',
          eventId: 'settings.update.succeeded',
        ),
      );
    } catch (error) {
      _log.errorEvent(
        'settings',
        'settings.update.failed',
        details: {'error': '$_cleanError(error)'},
      );
      return OperationOutcome.failure(
        RuntimeMessages.operationFailed(
          _cleanError(error),
          eventId: 'settings.update.failed',
        ),
      );
    }
  }

  Future<void> _loadPanel(
    ExplorerSide side,
    String relativePath, {
    bool announce = true,
  }) async {
    if (_git == null) {
      return;
    }
    final current = panelFor(side);
    _log.detailEvent(
      'explorer',
      'explorer.load.started',
      details: {
        'side': side.name,
        'path': relativePath.isEmpty ? '/' : relativePath,
      },
    );
    _setPanel(
      side,
      current.copyWith(
        relativePath: relativePath,
        isLoading: true,
        error: null,
      ),
    );
    if (announce) {
      notifyListeners();
    }
    try {
      final entries = await _git!.listDirectory(relativePath);
      _setPanel(
        side,
        current.copyWith(
          relativePath: relativePath,
          entries: entries,
          isLoading: false,
          error: null,
        ),
      );
      _log.detailEvent(
        'explorer',
        'explorer.load.completed',
        details: {'side': side.name, 'count': '${entries.length}'},
      );
    } catch (error) {
      _log.errorEvent(
        'explorer',
        'explorer.load.failed',
        details: {'side': side.name, 'path': relativePath, 'error': '$error'},
      );
      _setPanel(
        side,
        panelFor(side).copyWith(isLoading: false, error: _cleanError(error)),
      );
    }
    if (announce) {
      notifyListeners();
    }
  }

  Future<void> _reloadAfterMutation({bool refreshStats = true}) async {
    final service = _git;
    if (service == null) {
      return;
    }
    _log.detailEvent('repository', 'repository.reloadAfterMutation');
    changedFiles = await service.status();
    branch = await service.currentBranch();
    syncState = await _readSyncState(service);
    if (refreshStats) {
      repositoryStats = await service.repositoryStats();
    }
    await _loadPanel(
      ExplorerSide.left,
      leftPanel.relativePath,
      announce: false,
    );
    await _loadPanel(
      ExplorerSide.right,
      rightPanel.relativePath,
      announce: false,
    );
  }

  Future<OperationValidationResult> _validatePlanStart(
    List<PlannedRepositoryOperation> operations,
  ) async {
    final service = _git;
    if (service == null) {
      return const OperationValidationResult.failure([
        OperationDrift(
          kind: OperationDriftKind.repositoryRoot,
          label: 'repository',
          expected: 'open repository',
          actual: 'no repository',
        ),
      ]);
    }
    final actual = await service.stateSnapshot();
    _planBaseline ??= actual;
    final globalValidation = compareRepositorySnapshots(
      expected: _planBaseline!,
      actual: actual,
    );
    final expectedPaths = <String, String>{
      for (final operation in operations)
        ...?operation.precondition?.repository?.pathTypes,
    };
    if (expectedPaths.isEmpty) {
      return globalValidation;
    }
    final actualPaths = await service.pathTypeSnapshot(expectedPaths.keys);
    return mergeValidationResults([
      globalValidation,
      comparePathTypes(expected: expectedPaths, actual: actualPaths),
    ]);
  }

  Future<OperationValidationResult> _validateRuntimeState() async {
    final service = _git;
    final baseline = _runtimeBaseline ?? _planBaseline;
    if (service == null || baseline == null) {
      return const OperationValidationResult.success();
    }
    final actual = await service.stateSnapshot();
    return compareRepositorySnapshots(expected: baseline, actual: actual);
  }

  void _resetPlanBaselines() {
    _planBaseline = null;
    _runtimeBaseline = null;
  }

  Future<BranchSyncState?> _readSyncState(GitService service) async {
    try {
      return await service.syncState();
    } catch (error) {
      _log.warningEvent(
        'sync',
        'repository.syncState.read.failed',
        details: {'error': '$error'},
      );
      return null;
    }
  }

  void _setPanel(ExplorerSide side, ExplorerPanelState next) {
    if (side == ExplorerSide.left) {
      leftPanel = next;
      leftEntries = next.entries;
    } else {
      rightPanel = next;
      rightEntries = next.entries;
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text
        .replaceFirst('Exception: ', '')
        .replaceFirst('GitException: ', '')
        .trim();
  }

  String _outcomeDetail(LocalizedMessage message) {
    final succeeded = message.parameters['succeeded'];
    final failed = message.parameters['failed'];
    if (succeeded != null && failed != null) {
      final details = message.parameters['details']?.toString() ?? '';
      return '$succeeded succeeded and $failed failed'
          '${details.isEmpty ? '' : ': $details'}';
    }
    for (final key in const ['error', 'details', 'message', 'target']) {
      final value = message.parameters[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    final technical = message.technicalDetails['error'];
    if (technical != null && technical.trim().isNotEmpty) {
      return technical;
    }
    return message.key;
  }
}
