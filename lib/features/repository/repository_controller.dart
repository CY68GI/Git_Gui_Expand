import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../../core/models/app_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/git_service.dart';
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

class RepositoryController extends ChangeNotifier {
  RepositoryController({
    SettingsService? settingsService,
    GitService? gitService,
    AppLogService? logService,
  }) : _settingsService = settingsService ?? SettingsService(),
       _git = gitService,
       _log = logService ?? AppLogService.instance;

  final SettingsService _settingsService;
  final AppLogService _log;
  GitService? _git;

  String? repositoryPath;
  String? projectName;
  String branch = '';
  RepositoryStats? repositoryStats;
  List<GitFileStatus> changedFiles = const [];
  List<RepositoryEntry> leftEntries = const [];
  List<RepositoryEntry> rightEntries = const [];
  ExplorerPanelState leftPanel = const ExplorerPanelState();
  ExplorerPanelState rightPanel = const ExplorerPanelState();
  ExplorerSide activeSide = ExplorerSide.left;
  ExplorerSelection? clipboard;
  AppSettings settings = const AppSettings();
  bool isInitializing = true;
  bool isBusy = false;
  String? fatalError;

  GitService? get git => _git;
  bool get hasRepository => _git != null && repositoryPath != null;
  ExplorerPanelState panelFor(ExplorerSide side) =>
      side == ExplorerSide.left ? leftPanel : rightPanel;

  Future<void> initialize() async {
    settings = await _settingsService.load();
    isInitializing = false;
    _log.info(
      'app',
      '设置初始化完成：theme=${settings.themePreference.name} '
          'units=${settings.unitSystem.name}/${settings.baseUnit.name}',
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
      leftPanel = left;
      rightPanel = right;
      clipboard = null;
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
    leftPanel = const ExplorerPanelState();
    rightPanel = const ExplorerPanelState();
    clipboard = null;
    fatalError = null;
    notifyListeners();
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
      final stats = refreshStats
          ? await _git!.repositoryStats()
          : repositoryStats;
      final left = await _git!.listDirectory(leftPanel.relativePath);
      final right = await _git!.listDirectory(rightPanel.relativePath);
      changedFiles = status;
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

  Future<OperationOutcome> pasteToActivePanel() async {
    if (_git == null || clipboard == null || isBusy) {
      return OperationOutcome.failure(
        clipboard == null ? '剪贴板为空。' : '当前操作尚未完成。',
      );
    }
    final selection = clipboard!;
    final destination = panelFor(activeSide).relativePath;
    _log.info(
      'clipboard',
      '粘贴 ${selection.paths.length} 项到 ${destination.isEmpty ? '/' : destination}',
    );
    isBusy = true;
    notifyListeners();
    try {
      if (selection.mode == ClipboardMode.cut) {
        await _git!.movePaths(selection.paths, destination);
      } else {
        await _git!.copyPaths(selection.paths, destination);
      }
      clipboard = null;
      leftPanel = leftPanel.copyWith(selectedPaths: const {});
      rightPanel = rightPanel.copyWith(selectedPaths: const {});
      await _reloadAfterMutation();
      _log.info(
        'clipboard',
        '${selection.mode == ClipboardMode.cut ? '移动' : '复制'}完成：'
            '${selection.paths.length} 项',
      );
      return OperationOutcome.success(
        selection.mode == ClipboardMode.cut
            ? '已移动 ${selection.paths.length} 项'
            : '已复制 ${selection.paths.length} 项',
      );
    } catch (error) {
      _log.error('clipboard', '粘贴失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    } finally {
      isBusy = false;
      notifyListeners();
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
    isBusy = true;
    _log.detail('rename', '请求重命名 ${panel.selectedPaths.single} -> $trimmed');
    notifyListeners();
    try {
      final source = panel.selectedPaths.single;
      await _git!.renamePath(source, trimmed);
      leftPanel = leftPanel.copyWith(selectedPaths: const {});
      rightPanel = rightPanel.copyWith(selectedPaths: const {});
      await _reloadAfterMutation();
      _log.info('rename', '重命名完成：$source -> $trimmed');
      return OperationOutcome.success('已重命名为 $trimmed');
    } catch (error) {
      _log.error('rename', '重命名失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<OperationOutcome> stageAllChanges() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    _log.info('commit', '暂存全部更改');
    isBusy = true;
    notifyListeners();
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
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<OperationOutcome> unstageAllChanges() async {
    if (_git == null || isBusy) {
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    _log.info('commit', '取消暂存全部更改');
    isBusy = true;
    notifyListeners();
    try {
      await _git!.unstageAll();
      await _reloadAfterMutation(refreshStats: false);
      _log.detail('commit', '取消暂存完成');
      return const OperationOutcome.success('已取消暂存全部更改');
    } catch (error) {
      _log.error('commit', '取消暂存失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    } finally {
      isBusy = false;
      notifyListeners();
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
    if (changedFiles.isEmpty) {
      return const OperationOutcome.failure('没有可提交的更改。');
    }
    isBusy = true;
    _log.info('commit', '开始提交全部更改：${trimmed.replaceAll('\n', ' / ')}');
    notifyListeners();
    try {
      await _git!.stageAll();
      await _git!.commit(trimmed);
      await _reloadAfterMutation();
      _log.info('commit', '提交成功：$trimmed');
      return const OperationOutcome.success('提交成功');
    } catch (error) {
      _log.error('commit', '提交失败：$error');
      return OperationOutcome.failure(_cleanError(error));
    } finally {
      isBusy = false;
      notifyListeners();
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
            'units ${nextSettings.unitSystem.name}/${nextSettings.baseUnit.name}',
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
