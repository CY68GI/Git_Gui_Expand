import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/models/app_models.dart';
import '../../core/models/git_identity.dart';
import '../../core/models/git_remote.dart';
import '../../core/models/operation_plan.dart';
import '../../core/models/operation_safety.dart';
import '../../core/models/recent_repository.dart';
import '../../core/models/repository_sync.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
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
  final String message;
  final RemoteClearPreview? preview;
}

class GitMetadataClearInspection {
  const GitMetadataClearInspection({
    required this.isSuccess,
    required this.message,
    required this.remotes,
  });

  final bool isSuccess;
  final String message;
  final List<GitRemote> remotes;
}

class RepositoryController extends ChangeNotifier implements OperationPlanHost {
  RepositoryController({
    SettingsService? settingsService,
    GitService? gitService,
    AppLogService? logService,
    RecentRepositoriesService? recentRepositoriesService,
  }) : _settingsService = settingsService ?? SettingsService(),
       _git = gitService,
       _log = logService ?? AppLogService.instance,
       _recentRepositoriesService =
           recentRepositoriesService ?? RecentRepositoriesService();

  final SettingsService _settingsService;
  final AppLogService _log;
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
  String? planCurrentTitle;
  String? fatalError;
  List<RecentRepository> recentRepositories = const [];
  @override
  List<PlannedRepositoryOperation> pendingOperations = const [];
  int _operationSequence = 0;
  RepositoryStateSnapshot? _planBaseline;
  RepositoryStateSnapshot? _runtimeBaseline;
  bool _isCapturingPlan = false;

  GitService? get git => _git;
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
      hasRepository && pendingOperations.isNotEmpty && !isBusy;
  ExplorerPanelState panelFor(ExplorerSide side) =>
      side == ExplorerSide.left ? leftPanel : rightPanel;

  Future<void> initialize() async {
    settings = await _settingsService.load();
    recentRepositories = await _recentRepositoriesService.load();
    isInitializing = false;
    _log.info(
      'app',
      '设置初始化完成：theme=${settings.themePreference.name} '
          'color=${settings.colorSchemePreference.name} '
          'language=${settings.languagePreference.name} '
          'units=${settings.unitSystem.name}/${settings.baseUnit.name} '
          'font=${settings.fontFamily} scale=${settings.fontScale}',
    );
    notifyListeners();
  }

  Future<OperationOutcome> openRepository(String selectedPath) async {
    _log.info('repository', '请求打开仓库：$selectedPath');
    if (isBusy) {
      _log.warning('repository', '打开请求被拒绝：当前有操作正在执行');
      return const OperationOutcome.failure('当前操作尚未完成。');
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
        _log.warning('history', '保存最近仓库失败，但仓库仍已打开：$error');
      }
      _log.info(
        'repository',
        '仓库加载完成：root=$root branch=$branchName '
            'changes=${status.length} files=${stats.fileCount}',
      );
      return OperationOutcome.success('已打开 $projectName');
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
          _log.warning('history', '移除失效仓库记录失败：$historyError');
        }
      }
      _log.error('repository', '仓库打开失败：$fatalError');
      return OperationOutcome.failure(fatalError!);
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void closeRepository() {
    _log.info('repository', '关闭仓库：${repositoryPath ?? '无'}');
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
      return const GitMetadataClearInspection(
        isSuccess: false,
        message: '当前没有打开的仓库。',
        remotes: [],
      );
    }
    try {
      final remotes = await _git!.remotes();
      return GitMetadataClearInspection(
        isSuccess: true,
        message: remotes.isEmpty
            ? '当前仓库没有配置远端，可以清除 Git 元数据。'
            : '当前仓库已连接远端，禁止清除 Git 元数据。',
        remotes: remotes,
      );
    } catch (error) {
      return GitMetadataClearInspection(
        isSuccess: false,
        message: _cleanError(error),
        remotes: const [],
      );
    }
  }

  Future<OperationOutcome> clearGitMetadata() async {
    final root = repositoryPath;
    if (_git == null || root == null) {
      return const OperationOutcome.failure('当前没有打开的仓库。');
    }
    final inspection = await inspectGitMetadataForClear();
    if (!inspection.isSuccess) {
      return OperationOutcome.failure(inspection.message);
    }
    if (inspection.remotes.isNotEmpty) {
      return const OperationOutcome.failure('当前仓库已连接远端，禁止清除 Git 元数据。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.clearGitMetadata,
        title: '清除 Git 元数据',
        description:
            '仓库：$root。将永久删除 .git 元数据，保留工作文件。'
            '提交历史、分支、标签、索引、Stash、远端配置和仓库级配置将丢失。'
            '此操作必须单独执行。',
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
        return const OperationOutcome.failure('当前仓库已连接远端，禁止清除 Git 元数据。');
      }
      await GitService.clearRepositoryMetadata(root);
      await removeRecentRepository(root);
      closeRepository();
      return const OperationOutcome.success(
        'Git 元数据已清除；工作文件保留，但提交历史、分支和索引已经移除。',
      );
    } catch (error) {
      _log.error('repository', '清除 Git 元数据失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> removeRecentRepository(String path) async {
    try {
      recentRepositories = await _recentRepositoriesService.remove(path);
      notifyListeners();
      return const OperationOutcome.success('已从历史记录移除');
    } catch (error) {
      _log.error('history', '移除历史记录失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  void setActiveSide(ExplorerSide side) {
    if (activeSide == side) {
      return;
    }
    activeSide = side;
    _log.detail('selection', '活动面板切换为 ${side.name}');
    notifyListeners();
  }

  Future<void> navigate(ExplorerSide side, String relativePath) async {
    if (_git == null) {
      return;
    }
    _log.detail(
      'explorer',
      '${side.name} 导航到 ${normalizeRepositoryPath(relativePath).isEmpty ? '/' : relativePath}',
    );
    setActiveSide(side);
    await _loadPanel(side, normalizeRepositoryPath(relativePath));
  }

  Future<void> goUp(ExplorerSide side) async {
    final panel = panelFor(side);
    _log.detail('explorer', '${side.name} 返回上一级');
    await navigate(side, repositoryParent(panel.relativePath));
  }

  Future<void> refresh({bool refreshStats = true}) async {
    if (_git == null || isBusy) {
      return;
    }
    _log.info('repository', '刷新仓库视图');
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
      _log.detail(
        'repository',
        '刷新完成：changes=${changedFiles.length} '
            'left=${leftPanel.entries.length} right=${rightPanel.entries.length}',
      );
    } catch (error) {
      _log.error('repository', '刷新失败：$error');
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
    _log.detail(
      'selection',
      '${side.name} ${selected ? '选中' : '取消选中'} $path；'
          '当前共 ${selection.length} 项',
    );
    notifyListeners();
  }

  void selectOnly(ExplorerSide side, String path) {
    final panel = panelFor(side);
    _setPanel(side, panel.copyWith(selectedPaths: UnmodifiableSetView({path})));
    activeSide = side;
    _log.detail('selection', '${side.name} 仅选中 $path');
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
    _log.detail('selection', '${side.name} 全选 ${selection.length} 项');
    notifyListeners();
  }

  void clearSelection(ExplorerSide side) {
    final panel = panelFor(side);
    _log.detail(
      'selection',
      '${side.name} 清除 ${panel.selectedPaths.length} 项选择',
    );
    _setPanel(side, panel.copyWith(selectedPaths: const {}));
    notifyListeners();
  }

  OperationOutcome setClipboard(ClipboardMode mode) {
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.isEmpty) {
      _log.warning('clipboard', '${mode.name} 失败：没有选中项目');
      return const OperationOutcome.failure('请先勾选文件或文件夹。');
    }
    clipboard = ExplorerSelection(
      paths: panel.selectedPaths.toList(growable: false),
      mode: mode,
    );
    _log.info(
      'clipboard',
      '${mode == ClipboardMode.cut ? '剪切' : '复制'} '
          '${clipboard!.paths.length} 项',
    );
    _log.detail('clipboard', '路径=${clipboard!.paths.join(' | ')}');
    notifyListeners();
    return OperationOutcome.success(
      mode == ClipboardMode.cut
          ? '已剪切 ${clipboard!.paths.length} 项'
          : '已复制 ${clipboard!.paths.length} 项',
    );
  }

  OperationOutcome clearClipboard() {
    if (clipboard == null) {
      _log.detail('clipboard', '清空剪贴板请求：已经为空');
      return const OperationOutcome.failure('剪贴板为空。');
    }
    _log.detail('clipboard', '清空 ${clipboard!.paths.length} 项剪贴板内容');
    clipboard = null;
    notifyListeners();
    return const OperationOutcome.success('已清空剪贴板。');
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    if (isBusy) {
      return const OperationOutcome.failure('操作计划正在执行，暂时不能修改。');
    }
    final operation = pendingOperations
        .where((item) => item.id == id)
        .firstOrNull;
    if (operation == null) {
      return const OperationOutcome.failure('待执行操作不存在。');
    }
    pendingOperations = List.unmodifiable(
      pendingOperations.where((item) => item.id != id),
    );
    if (pendingOperations.isEmpty) {
      _resetPlanBaselines();
    }
    _log.info('plan', '从执行计划移除：${operation.title}');
    notifyListeners();
    return OperationOutcome.success('已移除：${operation.title}');
  }

  @override
  OperationOutcome clearPendingOperations() {
    if (isBusy) {
      return const OperationOutcome.failure('操作计划正在执行，暂时不能清空。');
    }
    if (pendingOperations.isEmpty) {
      return const OperationOutcome.failure('当前没有待执行操作。');
    }
    final count = pendingOperations.length;
    pendingOperations = const [];
    _resetPlanBaselines();
    _log.info('plan', '清空执行计划：$count 步，未执行任何操作');
    notifyListeners();
    return OperationOutcome.success('已清空 $count 步待执行操作');
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
      return const OperationPlanResult(
        isSuccess: false,
        message: '当前没有打开的仓库。',
        completed: 0,
        total: 0,
        remaining: [],
      );
    }
    if (isBusy) {
      return OperationPlanResult(
        isSuccess: false,
        message: '当前操作尚未完成。',
        completed: 0,
        total: pendingOperations.length,
        remaining: pendingOperations,
      );
    }
    if (pendingOperations.isEmpty) {
      return const OperationPlanResult(
        isSuccess: false,
        message: '执行计划为空。',
        completed: 0,
        total: 0,
        remaining: [],
      );
    }

    final operations = List<PlannedRepositoryOperation>.of(pendingOperations);
    final strongOperation = operations
        .where((operation) => operation.strongConfirmationText != null)
        .firstOrNull;
    if (strongOperation != null &&
        strongConfirmationText != strongOperation.strongConfirmationText) {
      _log.warning(
        'plan',
        '执行前安全校验失败：危险确认文字不匹配；'
            '操作=${strongOperation.title}',
      );
      return OperationPlanResult(
        isSuccess: false,
        message: '请准确输入 ${strongOperation.strongConfirmationText} 以确认危险操作。',
        completed: 0,
        total: operations.length,
        remaining: operations,
      );
    }
    if (operations.any((operation) => operation.isDangerous) &&
        !confirmedDangerous) {
      _log.warning('plan', '执行前安全校验失败：未勾选危险操作确认');
      return OperationPlanResult(
        isSuccess: false,
        message: '请勾选危险操作确认项后再执行。',
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
        _log.warning(
          'plan',
          '执行前状态校验失败：${preflight.summary.replaceAll('\n', ' | ')}',
        );
        return OperationPlanResult(
          isSuccess: false,
          message: '仓库状态与确认预览不一致，已停止执行。请刷新仓库并重新建立操作计划。',
          completed: 0,
          total: operations.length,
          remaining: operations,
          validation: preflight,
        );
      }
      _runtimeBaseline = await _git!.stateSnapshot();
      _log.info('plan', '开始执行操作计划：${operations.length} 步');
      for (var index = 0; index < operations.length; index++) {
        final operation = operations[index];
        if (index > 0) {
          final stepValidation = await _validateRuntimeState();
          if (!stepValidation.isSuccess) {
            pendingOperations = List.unmodifiable(operations.sublist(index));
            _log.warning(
              'plan',
              '第 ${index + 1} 步执行前状态校验失败：'
                  '${stepValidation.summary.replaceAll('\n', ' | ')}',
            );
            return OperationPlanResult(
              isSuccess: false,
              message:
                  '执行到第 ${index + 1} 步前发现仓库状态已被外部修改，已停止。'
                  '请刷新仓库并重新建立操作计划。',
              completed: completed,
              total: operations.length,
              remaining: pendingOperations,
              validation: stepValidation,
            );
          }
        }
        planCurrentStep = index + 1;
        planCurrentTitle = operation.title;
        _log.info(
          'plan',
          '开始执行第 ${index + 1}/${operations.length} 步：${operation.title}',
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
            _log.warning(
              'plan',
              '第 ${index + 1} 步最终执行前校验失败：'
                  '${finalStepValidation.summary.replaceAll('\n', ' | ')}',
            );
            return OperationPlanResult(
              isSuccess: false,
              message:
                  '执行到第 ${index + 1} 步前发现仓库状态已被外部修改，已停止。'
                  '请刷新仓库并重新建立操作计划。',
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
          _log.error(
            'plan',
            '第 ${index + 1} 步执行失败：${operation.title}；'
                '原因=${outcome.message}',
          );
          return OperationPlanResult(
            isSuccess: false,
            message:
                '第 ${index + 1} 步“${operation.title}”失败：${outcome.message}\n'
                '后续步骤尚未执行，失败步骤已保留在计划中。',
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
        _log.info(
          'plan',
          '第 ${index + 1} 步完成：${operation.title}；${outcome.message}',
        );
        notifyListeners();
      }
      _resetPlanBaselines();
      _log.info('plan', '执行计划完成：共 $completed 步');
      return OperationPlanResult(
        isSuccess: true,
        message: '已按顺序执行全部 $completed 步操作。',
        completed: completed,
        total: operations.length,
        remaining: const [],
      );
    } catch (error) {
      final failedIndex = completed;
      pendingOperations = List.unmodifiable(
        operations.sublist(failedIndex.clamp(0, operations.length)),
      );
      _log.error('plan', '执行计划异常：$error');
      return OperationPlanResult(
        isSuccess: false,
        message: '执行计划异常：${_cleanError(error)}',
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
      return const OperationOutcome.failure('当前没有打开的仓库。');
    }
    if (isBusy || _isCapturingPlan) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final hasClearOperation = pendingOperations.any(
      (item) => item.kind == PlannedOperationKind.clearRemote,
    );
    if (hasClearOperation ||
        (operation.kind == PlannedOperationKind.clearRemote &&
            pendingOperations.isNotEmpty)) {
      return const OperationOutcome.failure('清空远端必须单独执行。请先移除或执行当前计划中的其他步骤。');
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
      return const OperationOutcome.failure('提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。');
    }
    if (operation.isExclusive && pendingOperations.isNotEmpty) {
      return const OperationOutcome.failure('此生命周期操作必须单独执行。请先移除或执行当前计划中的其他步骤。');
    }
    if (pendingOperations.any((item) => item.isExclusive)) {
      return const OperationOutcome.failure('当前计划包含必须单独执行的生命周期操作，不能再添加步骤。');
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
          _log.warning(
            'plan',
            '添加操作预览时发现仓库状态已变化：'
                '${drift.summary.replaceAll('\n', ' | ')}',
          );
          return const OperationOutcome.failure(
            '仓库状态已变化，无法继续扩展当前计划。请刷新仓库并重新建立操作计划。',
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
      _log.info(
        'plan',
        '已创建操作预览 ${pendingOperations.length}：'
            '${operation.title}；${operation.description}',
      );
      notifyListeners();
      return OperationOutcome.success(
        '已加入执行计划：${operation.title}。尚未执行任何 Git 变更。',
      );
    } catch (error) {
      _log.error('plan', '创建操作预览失败：$error');
      return OperationOutcome.failure('无法建立操作预览的安全状态快照：${_cleanError(error)}');
    } finally {
      _isCapturingPlan = false;
    }
  }

  Future<OperationOutcome> pasteToActivePanel() async {
    if (_git == null || clipboard == null || isBusy) {
      return OperationOutcome.failure(
        clipboard == null ? '剪贴板为空。' : '当前操作尚未完成。',
      );
    }
    final selection = ExplorerSelection(
      paths: List.unmodifiable(clipboard!.paths),
      mode: clipboard!.mode,
    );
    final destination = panelFor(activeSide).relativePath;
    final action = selection.mode == ClipboardMode.cut ? '移动' : '复制';
    final destinationLabel = destination.isEmpty ? '仓库根目录' : destination;
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: selection.mode == ClipboardMode.cut
            ? PlannedOperationKind.move
            : PlannedOperationKind.copy,
        title: '$action ${selection.paths.length} 项到 $destinationLabel',
        description:
            '${selection.paths.length} 个项目将使用 Git 从当前目录$action到'
            ' $destinationLabel。',
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
        selection.mode == ClipboardMode.cut
            ? '已移动 ${selection.paths.length} 项'
            : '已复制 ${selection.paths.length} 项',
      );
    } catch (error) {
      _log.error('clipboard', '粘贴失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> renameSelection(String newName) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.length != 1) {
      _log.warning('rename', '重命名失败：选中 ${panel.selectedPaths.length} 项');
      return const OperationOutcome.failure('重命名时请只勾选一个文件或文件夹。');
    }
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      return const OperationOutcome.failure('名称不能为空。');
    }
    final source = panel.selectedPaths.single;
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.rename,
        title: '重命名 $source',
        description: '将 $source 的新名称设为 $trimmed。',
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
      return OperationOutcome.success('已重命名为 $newName');
    } catch (error) {
      _log.error('rename', '重命名失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> deleteSelectedPaths() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final panel = panelFor(activeSide);
    if (panel.selectedPaths.isEmpty) {
      return const OperationOutcome.failure('请先勾选要删除的项目。');
    }
    final paths = panel.selectedPaths.toList(growable: false);
    final outcome = await _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.delete,
        title: '删除 ${paths.length} 个项目',
        description:
            '将永久删除：${paths.join('、')}。已跟踪内容使用 git rm，'
            '未跟踪或忽略内容使用 git clean。',
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
      return OperationOutcome.success('已删除 ${paths.length} 项');
    } catch (error) {
      _log.error('delete', '删除失败：$error');
      return OperationOutcome.failure(_cleanError(error));
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
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final trimmed = name.trim();
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(_cleanError(error));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.createBranch,
        title: '创建分支 $trimmed',
        description: '执行 git branch -- $trimmed，从当前 HEAD 创建本地分支。',
        run: () => _applyCreateBranch(trimmed),
      ),
    );
  }

  Future<OperationOutcome> _applyCreateBranch(String name) async {
    try {
      await _git!.createBranch(name);
      return OperationOutcome.success('已创建分支 $name');
    } catch (error) {
      _log.error('branch', '创建分支失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> switchBranch(String name) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final trimmed = name.trim();
    if (trimmed == branch) {
      return OperationOutcome.failure('已经位于分支 $trimmed。');
    }
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(_cleanError(error));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.switchBranch,
        title: '切换到分支 $trimmed',
        description: '执行 git switch $trimmed。未提交修改发生冲突时 Git 会拒绝切换。',
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
      return OperationOutcome.success('已切换到分支 $name');
    } catch (error) {
      _log.error('branch', '切换分支失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> renameBranch(String oldName, String newName) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final oldTrimmed = oldName.trim();
    final newTrimmed = newName.trim();
    try {
      await _git!.validateBranchName(oldTrimmed);
      await _git!.validateBranchName(newTrimmed);
    } catch (error) {
      return OperationOutcome.failure(_cleanError(error));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.renameBranch,
        title: '重命名分支 $oldTrimmed -> $newTrimmed',
        description: '执行 git branch -m $oldTrimmed $newTrimmed。',
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
      return OperationOutcome.success('已重命名分支 $oldName 为 $newName');
    } catch (error) {
      _log.error('branch', '重命名分支失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> deleteBranch(
    String name, {
    bool force = false,
  }) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final trimmed = name.trim();
    if (trimmed == branch) {
      return const OperationOutcome.failure('不能删除当前分支，请先切换到其他分支。');
    }
    try {
      await _git!.validateBranchName(trimmed);
    } catch (error) {
      return OperationOutcome.failure(_cleanError(error));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.deleteBranch,
        title: '删除分支 $trimmed',
        description: force
            ? '执行 git branch -D $trimmed，强制删除未合并分支。'
            : '执行 git branch -d $trimmed，仅允许删除已合并分支。',
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
      return OperationOutcome.success('已删除分支 $name');
    } catch (error) {
      _log.error('branch', '删除分支失败：$error');
      return OperationOutcome.failure(_cleanError(error));
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
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final trimmed = message.trim();
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.createStash,
        title: trimmed.isEmpty ? '创建 Stash' : '创建 Stash：$trimmed',
        description:
            '执行 git stash push${includeUntracked ? ' --include-untracked' : ''}'
            '${trimmed.isEmpty ? '。' : ' -m $trimmed。'}',
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
      return const OperationOutcome.success('Stash 已创建');
    } catch (error) {
      _log.error('stash', '创建 Stash 失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> applyStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.applyStash,
      title: '应用 $selector',
      description: '执行 git stash apply $selector，并保留 Stash 记录。',
      run: () => _applyStashAction(
        selector: selector,
        successMessage: '已应用 $selector',
        action: () => _git!.applyStash(selector),
        reload: true,
      ),
    );
  }

  Future<OperationOutcome> popStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.popStash,
      title: '弹出 $selector',
      description: '执行 git stash pop $selector，应用后删除该 Stash。',
      run: () => _applyStashAction(
        selector: selector,
        successMessage: '已弹出 $selector',
        action: () => _git!.popStash(selector),
        reload: true,
      ),
    );
  }

  Future<OperationOutcome> dropStash(String selector) {
    return _queueStashOperation(
      selector: selector,
      kind: PlannedOperationKind.dropStash,
      title: '删除 $selector',
      description: '执行 git stash drop $selector，此操作无法通过本软件撤销。',
      run: () => _applyStashAction(
        selector: selector,
        successMessage: '已删除 $selector',
        action: () => _git!.dropStash(selector),
      ),
      isDangerous: true,
    );
  }

  Future<OperationOutcome> _queueStashOperation({
    required String selector,
    required PlannedOperationKind kind,
    required String title,
    required String description,
    required Future<OperationOutcome> Function() run,
    bool isDangerous = false,
  }) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    if (!RegExp(r'^stash@\{\d+\}$').hasMatch(selector.trim())) {
      return const OperationOutcome.failure('Stash 选择器无效。');
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
    required String successMessage,
    required Future<void> Function() action,
    bool reload = false,
  }) async {
    try {
      await action();
      if (reload) {
        await _reloadAfterMutation();
      }
      return OperationOutcome.success(successMessage);
    } catch (error) {
      _log.error('stash', 'Stash 操作失败：$selector；$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> pushCurrentBranch() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final branchLabel = branch.isEmpty ? '当前分支' : branch;
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushCurrentBranch,
        title: '推送 $branchLabel',
        description:
            '将当前分支 $branchLabel 推送到 upstream；如果没有 upstream，'
            '会使用 origin 或首个远端并设置 upstream。',
        run: _applyPushCurrentBranch,
      ),
    );
  }

  Future<OperationOutcome> fetchCurrentUpstream() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final state = syncState ?? await _readSyncState(_git!);
    if (state == null || !state.hasUpstream) {
      return const OperationOutcome.failure('当前分支没有可用的 upstream，请先配置远端跟踪分支。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.fetchCurrentRemote,
        title: '获取远端 ${state.upstreamRemote}',
        description:
            '执行 git fetch --prune ${state.upstreamRemote}，'
            '更新远端跟踪引用，不修改工作区文件。',
        run: () => _applyFetchRemote(state.upstreamRemote),
      ),
    );
  }

  Future<OperationOutcome> fetchAllRemotes() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    if (remotes.isEmpty) {
      return const OperationOutcome.failure('项目没有配置远端仓库。');
    }
    final names = remotes.map((remote) => remote.name).toList(growable: false);
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.fetchAllRemotes,
        title: '获取全部 ${names.length} 个远端',
        description:
            '依次执行 git fetch --prune：${names.join('、')}。'
            '成功获取的远端跟踪引用会保留，失败的远端会逐项报告。',
        run: () => _applyFetchAllRemotes(names),
      ),
    );
  }

  Future<OperationOutcome> _applyFetchRemote(String remoteName) async {
    try {
      final output = await _git!.fetchRemote(remoteName);
      await _reloadAfterMutation(refreshStats: false);
      _log.detail(
        'sync',
        '远端 $remoteName fetch 输出：${output.isEmpty ? '无输出' : output}',
      );
      return OperationOutcome.success('已获取远端 $remoteName 的更新');
    } catch (error) {
      _log.error('sync', '获取远端 $remoteName 失败：$error');
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
        _log.error('sync', '获取远端 $remoteName 失败：$error');
        failed.add('$remoteName：${_syncFailureMessage(error)}');
      }
    }
    await _reloadAfterMutation(refreshStats: false);
    if (failed.isEmpty) {
      return OperationOutcome.success('已获取全部 ${succeeded.length} 个远端');
    }
    return OperationOutcome.failure(
      '成功 ${succeeded.length} 个，失败 ${failed.length} 个。\n'
      '${failed.join('\n')}',
    );
  }

  Future<OperationOutcome> pullCurrentBranchFastForward() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final state = syncState ?? await _readSyncState(_git!);
    if (state == null) {
      return const OperationOutcome.failure('无法读取当前分支同步状态。');
    }
    if (state.isDetached) {
      return const OperationOutcome.failure('当前处于 detached HEAD，不能 Pull 分支。');
    }
    if (state.isUnborn) {
      return const OperationOutcome.failure('当前分支尚无提交，不能 Pull。');
    }
    if (!state.hasUpstream) {
      return const OperationOutcome.failure('当前分支没有可用的 upstream。');
    }
    if (!state.worktreeClean) {
      return const OperationOutcome.failure(
        '工作区或索引不干净，已拒绝 Pull。请先提交或 Stash 更改。',
      );
    }
    switch (state.relation) {
      case BranchSyncRelation.behind:
        break;
      case BranchSyncRelation.upToDate:
        return const OperationOutcome.failure('当前分支已经与 upstream 同步，不需要 Pull。');
      case BranchSyncRelation.ahead:
        return const OperationOutcome.failure(
          '当前分支包含 upstream 的全部提交，但有本地提交未推送。',
        );
      case BranchSyncRelation.diverged:
        return const OperationOutcome.failure(
          '本地分支与 upstream 已分叉，已拒绝快进 Pull。'
          '请先使用外部 Git 执行 Merge 或 Rebase。',
        );
      case BranchSyncRelation.unknown:
        return const OperationOutcome.failure('当前分支同步关系未知。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pullFastForward,
        title: '安全快进 Pull ${state.branch}',
        description:
            '先从 ${state.upstreamRemote} 获取更新并重新检查 ahead/behind；'
            '仅在当前分支落后且不分叉时执行 git merge --ff-only '
            '${state.upstreamRef}。不会自动创建 Merge 提交。',
        run: _applyPullFastForward,
      ),
    );
  }

  Future<OperationOutcome> _applyPullFastForward() async {
    try {
      final result = await _git!.pullFastForward();
      await _reloadAfterMutation();
      if (!result.updated) {
        return OperationOutcome.success(result.output);
      }
      _log.detail('sync', '快进 Pull 输出：${result.output}');
      return OperationOutcome.success(
        '已快进更新 ${result.state.branch} 到 ${result.state.upstreamRef}',
      );
    } catch (error) {
      _log.error('sync', '安全快进 Pull 失败：$error');
      syncState = await _readSyncState(_git!);
      return OperationOutcome.failure(_syncFailureMessage(error));
    }
  }

  String _syncFailureMessage(Object error) {
    final text = _cleanError(error);
    final lower = text.toLowerCase();
    if (lower.contains('authentication') ||
        lower.contains('permission denied') ||
        lower.contains('could not read from remote')) {
      return '$text\n认证失败：请检查 Git 凭据、SSH Key 或远端访问权限。';
    }
    if (lower.contains('could not resolve host') ||
        lower.contains('network') ||
        lower.contains('timed out')) {
      return '$text\n网络连接失败：请检查网络后重试。';
    }
    return text;
  }

  String _commitIdentityFailure(GitIdentityState identity) {
    return 'Git 提交身份不可用：无法解析有效的 user.name 或 user.email。'
        '\n'
        '请在项目目录执行：\n'
        'git config --local user.name "Your Name"\n'
        'git config --local user.email "you@example.com"\n'
        '或改用 --global 配置当前用户的默认 Git 身份。';
  }

  Future<OperationOutcome> _applyPushCurrentBranch() async {
    try {
      final output = await _git!.pushCurrentBranch();
      branch = await _git!.currentBranch();
      syncState = await _readSyncState(_git!);
      _log.detail('push', '推送输出：${output.isEmpty ? '无输出' : output}');
      return OperationOutcome.success(
        '已推送 ${branch.isEmpty ? '当前分支' : branch}',
      );
    } catch (error) {
      _log.error('push', '推送失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> refreshRemotes() async {
    if (_git == null) {
      return const OperationOutcome.failure('当前没有打开的仓库。');
    }
    try {
      remotes = await _git!.remotes();
      syncState = await _readSyncState(_git!);
      notifyListeners();
      return const OperationOutcome.success('远端列表已刷新');
    } catch (error) {
      _log.error('remote', '刷新远端失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> saveRemote({
    required String name,
    required String url,
    required bool updateExisting,
  }) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
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
        title: '${updateExisting ? '更新' : '添加'}远端 $trimmedName',
        description: '${updateExisting ? '把远端地址改为' : '新增远端地址'} $maskedUrl。',
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
        updateExisting ? '远端 $name 已更新' : '远端 $name 已添加',
      );
    } catch (error) {
      _log.error('remote', '保存远端失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> removeRemote(String name) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.removeRemoteConfig,
        title: '删除本地远端配置 $name',
        description: '仅删除本仓库中的 Git remote 配置，不会删除远端平台上的仓库。',
        run: () => _applyRemoveRemote(name),
      ),
    );
  }

  Future<OperationOutcome> _applyRemoveRemote(String name) async {
    try {
      await _git!.removeRemote(name);
      remotes = await _git!.remotes();
      syncState = await _readSyncState(_git!);
      return OperationOutcome.success('远端 $name 已删除');
    } catch (error) {
      _log.error('remote', '删除远端失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> pushToRemote(String name) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushRemote,
        title: '推送到远端 $name',
        description: '把当前分支 ${branch.isEmpty ? '（未识别）' : branch} 推送到 $name。',
        run: () => _applyPushToRemote(name),
      ),
    );
  }

  Future<OperationOutcome> _applyPushToRemote(String name) async {
    try {
      final output = await _git!.pushToRemote(name);
      _log.detail('push', '远端 $name 输出：${output.isEmpty ? '无输出' : output}');
      return OperationOutcome.success('已推送到 $name');
    } catch (error) {
      _log.error('push', '推送到 $name 失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> pushToAllRemotes() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    if (remotes.isEmpty) {
      return const OperationOutcome.failure('项目没有配置远端仓库。');
    }
    final names = remotes.map((remote) => remote.name).toList(growable: false);
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.pushAllRemotes,
        title: '推送到全部 ${names.length} 个远端',
        description: '依次推送当前分支到：${names.join('、')}。',
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
        _log.error('push', '推送到 $remoteName 失败：$error');
        failed.add('$remoteName：${_cleanError(error)}');
      }
    }
    if (failed.isEmpty) {
      return OperationOutcome.success('已推送到全部 ${succeeded.length} 个远端');
    }
    return OperationOutcome.failure(
      '成功 ${succeeded.length} 个，失败 ${failed.length} 个。'
      '\n${failed.join('\n')}',
    );
  }

  Future<RemoteClearInspection> inspectRemoteForClear(String name) async {
    if (_git == null || isBusy) {
      return const RemoteClearInspection(
        isSuccess: false,
        message: '当前操作尚未完成。',
      );
    }
    try {
      final preview = await _git!.previewClearRemote(name);
      return RemoteClearInspection(
        isSuccess: true,
        message: preview.isEmpty
            ? '远端 $name 当前没有分支或标签。'
            : '远端 $name 有 ${preview.branchCount} 个分支、'
                  '${preview.tagCount} 个标签。',
        preview: preview,
      );
    } catch (error) {
      _log.error('remote-clear', '检查远端引用失败：$error');
      return RemoteClearInspection(
        isSuccess: false,
        message: _cleanError(error),
      );
    }
  }

  Future<OperationOutcome> queueClearRemote(RemoteClearPreview preview) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.clearRemote,
        title: '清空远端历史 ${preview.remoteName}',
        description:
            '项目 ${preview.projectName}，目标分支 ${preview.targetBranch}。'
            '将备份并删除原 ${preview.branchCount} 个分支、'
            '${preview.tagCount} 个标签，然后只保留一个空提交：'
            '“${preview.emptyCommitMessage}”。本地文件内容不变，'
            '但本地索引会重置为空，刷新后文件显示为未跟踪。'
            '受保护分支或服务器不支持原子推送时，整个操作会失败。',
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
        '已清空远端 ${preview.remoteName} 的历史。'
        '${result.targetBranch} 现指向空提交 '
        '${result.emptyCommitHash.substring(0, 8)}；'
        '本地索引已重置为空，文件已保留并显示为未跟踪。',
      );
    } catch (error) {
      var message = _cleanError(error);
      if (message.contains('远端引用在确认后发生了变化')) {
        try {
          final refreshed = await _git!.previewClearRemote(preview.remoteName);
          message =
              '$message\n刷新后的远端状态：远端 ${preview.remoteName} '
              '当前有 ${refreshed.branchCount} 个分支、'
              '${refreshed.tagCount} 个标签。';
        } catch (_) {
          // The original safety rejection remains the primary result.
        }
      }
      _log.error('remote-clear', '清空远端失败：$message');
      return OperationOutcome.failure(message);
    }
  }

  Future<OperationOutcome> stageAllChanges() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.stageAll,
        title: '暂存全部更改',
        description: '执行 git add -A，把当前全部更改加入 Git 索引。',
        run: _applyStageAllChanges,
      ),
    );
  }

  Future<OperationOutcome> _applyStageAllChanges() async {
    try {
      await _git!.stageAll();
      await _reloadAfterMutation(refreshStats: false);
      _log.detail(
        'commit',
        '暂存完成：staged=${changedFiles.where((item) => item.isStaged).length}',
      );
      return const OperationOutcome.success('已暂存全部更改');
    } catch (error) {
      _log.error('commit', '暂存全部失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> unstageAllChanges() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.unstageAll,
        title: '取消暂存全部更改',
        description: '把 Git 索引恢复到 HEAD，但保留工作区文件内容。',
        run: _applyUnstageAllChanges,
      ),
    );
  }

  Future<OperationOutcome> _applyUnstageAllChanges() async {
    try {
      await _git!.unstageAll();
      await _reloadAfterMutation(refreshStats: false);
      _log.detail('commit', '取消暂存完成');
      return const OperationOutcome.success('已取消暂存全部更改');
    } catch (error) {
      _log.error('commit', '取消暂存失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> commitAll(String message) async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      _log.warning('commit', '提交失败：提交说明为空');
      return const OperationOutcome.failure('请填写提交说明。');
    }
    if (changedFiles.isEmpty && !hasPendingFileChanges) {
      return const OperationOutcome.failure('没有可提交的更改。');
    }
    if (pendingOperations.any(
      (operation) => operation.kind == PlannedOperationKind.commit,
    )) {
      return const OperationOutcome.failure('执行计划中已经有提交步骤。');
    }
    final identity = await _git!.identityState();
    if (!identity.isReady) {
      _log.warning('identity', '提交未加入计划：有效 Git 身份不可用；${identity.errorMessage}');
      return OperationOutcome.failure(_commitIdentityFailure(identity));
    }
    return _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.commit,
        title: '提交全部更改',
        description:
            '提交说明：${trimmed.replaceAll('\n', ' / ')}。'
            '执行时先运行 git add -A，再运行 git commit。',
        run: () => _applyCommitAll(trimmed),
      ),
    );
  }

  Future<OperationOutcome> _applyCommitAll(String message) async {
    try {
      final identity = await _git!.identityState();
      if (!identity.isReady) {
        _log.warning('identity', '提交执行前身份复核失败：${identity.errorMessage}');
        return OperationOutcome.failure(_commitIdentityFailure(identity));
      }
      await _git!.stageAll();
      await _git!.commit(message);
      await _reloadAfterMutation();
      _log.info('commit', '提交成功：$message');
      return const OperationOutcome.success('提交成功');
    } catch (error) {
      _log.error('commit', '提交失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> updateSettings(AppSettings nextSettings) async {
    final oldSettings = settings;
    settings = nextSettings;
    notifyListeners();
    try {
      await _settingsService.save(nextSettings);
      _log.info('settings', '设置已更新');
      _log.detail(
        'settings',
        'theme=${oldSettings.themePreference.name}->${nextSettings.themePreference.name}; '
            'color=${oldSettings.colorSchemePreference.name}->'
            '${nextSettings.colorSchemePreference.name}; '
            'language=${oldSettings.languagePreference.name}->'
            '${nextSettings.languagePreference.name}; '
            'units=${oldSettings.unitSystem.name}/${nextSettings.baseUnit.name}; '
            'font=${oldSettings.fontFamily}->${nextSettings.fontFamily}; '
            'scale=${oldSettings.fontScale}->${nextSettings.fontScale}',
      );
      return const OperationOutcome.success('设置已保存');
    } catch (error) {
      _log.error('settings', '保存设置失败：$error');
      return OperationOutcome.failure(_cleanError(error));
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
    _log.detail(
      'explorer',
      '加载 ${side.name} 目录 ${relativePath.isEmpty ? '/' : relativePath}',
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
      _log.detail('explorer', '${side.name} 目录加载完成：${entries.length} 项');
    } catch (error) {
      _log.error('explorer', '${side.name} 目录加载失败：$error');
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
    _log.detail('repository', '变更后重新加载仓库视图');
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
      _log.warning('sync', '读取分支同步状态失败：$error');
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
}
