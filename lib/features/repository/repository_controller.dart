import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/models/app_models.dart';
import '../../core/models/git_remote.dart';
import '../../core/models/recent_repository.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/git_service.dart';
import '../../core/services/recent_repositories_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/utils/path_utils.dart';

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

class OperationOutcome {
  const OperationOutcome.success(this.message) : isSuccess = true;
  const OperationOutcome.failure(this.message) : isSuccess = false;

  final bool isSuccess;
  final String message;
}

enum PlannedOperationKind {
  move,
  copy,
  rename,
  delete,
  stageAll,
  unstageAll,
  commit,
  pushCurrentBranch,
  pushRemote,
  pushAllRemotes,
  addRemote,
  updateRemote,
  removeRemoteConfig,
  clearRemote,
}

class PlannedRepositoryOperation {
  const PlannedRepositoryOperation({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.run,
    this.isDangerous = false,
    this.strongConfirmationText,
  });

  final String id;
  final PlannedOperationKind kind;
  final String title;
  final String description;
  final bool isDangerous;
  final String? strongConfirmationText;
  final Future<OperationOutcome> Function() run;

  bool get requiresStrongConfirmation =>
      isDangerous || strongConfirmationText != null;
}

class OperationPlanProgress {
  const OperationPlanProgress({
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final String title;
}

class OperationPlanResult {
  const OperationPlanResult({
    required this.isSuccess,
    required this.message,
    required this.completed,
    required this.total,
    required this.remaining,
  });

  final bool isSuccess;
  final String message;
  final int completed;
  final int total;
  final List<PlannedRepositoryOperation> remaining;
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

class RepositoryController extends ChangeNotifier {
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
  bool isBusy = false;
  bool isExecutingPlan = false;
  int planCurrentStep = 0;
  String? planCurrentTitle;
  String? fatalError;
  List<RecentRepository> recentRepositories = const [];
  List<PlannedRepositoryOperation> pendingOperations = const [];
  int _operationSequence = 0;

  GitService? get git => _git;
  bool get hasRepository => _git != null && repositoryPath != null;
  bool get hasPendingOperations => pendingOperations.isNotEmpty;
  bool get hasQueuedCommit => pendingOperations.any(
    (operation) => operation.kind == PlannedOperationKind.commit,
  );
  bool get hasQueuedClearRemote => pendingOperations.any(
    (operation) => operation.kind == PlannedOperationKind.clearRemote,
  );
  bool get hasPendingFileChanges => pendingOperations.any(
    (operation) => const {
      PlannedOperationKind.move,
      PlannedOperationKind.copy,
      PlannedOperationKind.rename,
      PlannedOperationKind.delete,
    }.contains(operation.kind),
  );
  bool get localOperationsLocked => hasQueuedCommit || hasQueuedClearRemote;
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
      repositoryStats = stats;
      changedFiles = status;
      remotes = remoteList;
      leftPanel = left;
      rightPanel = right;
      clipboard = null;
      pendingOperations = const [];
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
    repositoryStats = null;
    changedFiles = const [];
    remotes = const [];
    leftPanel = const ExplorerPanelState();
    rightPanel = const ExplorerPanelState();
    clipboard = null;
    pendingOperations = const [];
    planCurrentStep = 0;
    planCurrentTitle = null;
    fatalError = null;
    notifyListeners();
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
    _log.info('plan', '从执行计划移除：${operation.title}');
    notifyListeners();
    return OperationOutcome.success('已移除：${operation.title}');
  }

  OperationOutcome clearPendingOperations() {
    if (isBusy) {
      return const OperationOutcome.failure('操作计划正在执行，暂时不能清空。');
    }
    if (pendingOperations.isEmpty) {
      return const OperationOutcome.failure('当前没有待执行操作。');
    }
    final count = pendingOperations.length;
    pendingOperations = const [];
    _log.info('plan', '清空执行计划：$count 步，未执行任何操作');
    notifyListeners();
    return OperationOutcome.success('已清空 $count 步待执行操作');
  }

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
      for (var index = 0; index < operations.length; index++) {
        final operation = operations[index];
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
        _log.info(
          'plan',
          '第 ${index + 1} 步完成：${operation.title}；${outcome.message}',
        );
        notifyListeners();
      }
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

  OperationOutcome _queueOperation(PlannedRepositoryOperation operation) {
    if (!hasRepository) {
      return const OperationOutcome.failure('当前没有打开的仓库。');
    }
    if (isBusy) {
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
      PlannedOperationKind.pushCurrentBranch,
      PlannedOperationKind.pushRemote,
      PlannedOperationKind.pushAllRemotes,
      PlannedOperationKind.addRemote,
      PlannedOperationKind.updateRemote,
      PlannedOperationKind.removeRemoteConfig,
    };
    if (commitAlreadyQueued && !allowedAfterCommit.contains(operation.kind)) {
      return const OperationOutcome.failure('提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。');
    }
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
        strongConfirmationText: operation.strongConfirmationText,
      ),
    ]);
    _log.info(
      'plan',
      '加入待执行操作 ${pendingOperations.length}：'
          '${operation.title}；${operation.description}',
    );
    notifyListeners();
    return OperationOutcome.success(
      '已加入执行计划：${operation.title}。尚未执行任何 Git 变更。',
    );
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
    final outcome = _queueOperation(
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
    final outcome = _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.rename,
        title: '重命名 $source',
        description: '将 $source 的新名称设为 $trimmed。',
        run: () => _applyRename(source, trimmed),
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
    final outcome = _queueOperation(
      PlannedRepositoryOperation(
        id: '',
        kind: PlannedOperationKind.delete,
        title: '删除 ${paths.length} 个项目',
        description:
            '将永久删除：${paths.join('、')}。已跟踪内容使用 git rm，'
            '未跟踪或忽略内容使用 git clean。',
        run: () => _applyDelete(paths),
        isDangerous: true,
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

  Future<OperationOutcome> pushCurrentBranch() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final branchLabel = branch.isEmpty ? '当前分支' : branch;
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.pushCurrentBranch,
          title: '推送 $branchLabel',
          description:
              '将当前分支 $branchLabel 推送到 upstream；如果没有 upstream，'
              '会使用 origin 或首个远端并设置 upstream。',
          run: _applyPushCurrentBranch,
        ),
      ),
    );
  }

  Future<OperationOutcome> _applyPushCurrentBranch() async {
    try {
      final output = await _git!.pushCurrentBranch();
      branch = await _git!.currentBranch();
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
    return Future<OperationOutcome>.value(
      _queueOperation(
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
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.removeRemoteConfig,
          title: '删除本地远端配置 $name',
          description: '仅删除本仓库中的 Git remote 配置，不会删除远端平台上的仓库。',
          run: () => _applyRemoveRemote(name),
        ),
      ),
    );
  }

  Future<OperationOutcome> _applyRemoveRemote(String name) async {
    try {
      await _git!.removeRemote(name);
      remotes = await _git!.remotes();
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
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.pushRemote,
          title: '推送到远端 $name',
          description: '把当前分支 ${branch.isEmpty ? '（未识别）' : branch} 推送到 $name。',
          run: () => _applyPushToRemote(name),
        ),
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
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.pushAllRemotes,
          title: '推送到全部 ${names.length} 个远端',
          description: '依次推送当前分支到：${names.join('、')}。',
          run: () => _applyPushToAllRemotes(names),
        ),
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
    return Future<OperationOutcome>.value(
      _queueOperation(
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
          strongConfirmationText: preview.confirmationText,
        ),
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
      _log.error('remote-clear', '清空远端失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    }
  }

  Future<OperationOutcome> stageAllChanges() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.stageAll,
          title: '暂存全部更改',
          description: '执行 git add -A，把当前全部更改加入 Git 索引。',
          run: _applyStageAllChanges,
        ),
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
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.unstageAll,
          title: '取消暂存全部更改',
          description: '把 Git 索引恢复到 HEAD，但保留工作区文件内容。',
          run: _applyUnstageAllChanges,
        ),
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
    return Future<OperationOutcome>.value(
      _queueOperation(
        PlannedRepositoryOperation(
          id: '',
          kind: PlannedOperationKind.commit,
          title: '提交全部更改',
          description:
              '提交说明：${trimmed.replaceAll('\n', ' / ')}。'
              '执行时先运行 git add -A，再运行 git commit。',
          run: () => _applyCommitAll(trimmed),
        ),
      ),
    );
  }

  Future<OperationOutcome> _applyCommitAll(String message) async {
    try {
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
      _log.info(
        'settings',
        '设置更新：theme ${oldSettings.themePreference.name} -> '
            '${nextSettings.themePreference.name}; '
            'units ${nextSettings.unitSystem.name}/${nextSettings.baseUnit.name}; '
            'font ${oldSettings.fontFamily.isEmpty ? '系统默认' : oldSettings.fontFamily}'
            ' -> ${nextSettings.fontFamily.isEmpty ? '系统默认' : nextSettings.fontFamily}; '
            'scale ${oldSettings.fontScale} -> ${nextSettings.fontScale}',
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
