import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/folder_picker_service.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/size_formatter.dart';
import '../commit/commit_panel.dart';
import '../dialogs/log_viewer_dialog.dart';
import '../dialogs/remote_management_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/update_dialog.dart';
import '../explorer/file_explorer_panel.dart';
import '../repository/repository_controller.dart';
import '../start/start_view.dart';
import 'widgets/app_brand.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({
    super.key,
    this.initialRepositoryPath,
    required this.onThemeModeChanged,
    required this.onFontFamilyChanged,
    required this.onFontScaleChanged,
  });

  final String? initialRepositoryPath;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontScaleChanged;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final RepositoryController _controller = RepositoryController();
  final FolderPickerService _folderPicker = const FolderPickerService();
  final FocusNode _explorerFocus = FocusNode(debugLabel: 'explorer-shortcuts');

  bool _isOpening = false;
  bool _isCommitFieldFocused = false;
  AppThemePreference _lastThemePreference = AppThemePreference.system;
  String _lastFontFamily = '';
  double _lastFontScale = AppSettings.defaultFontScale;
  final AppLogService _log = AppLogService.instance;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    final initialPath = widget.initialRepositoryPath;
    if (initialPath != null && initialPath.trim().isNotEmpty && mounted) {
      await _openRepositoryPath(initialPath);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    _controller.dispose();
    _explorerFocus.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      _syncThemeMode();
      _syncFontFamily();
      _syncFontScale();
      setState(() {});
    }
  }

  void _syncFontFamily() {
    final fontFamily = _controller.settings.fontFamily;
    if (_lastFontFamily == fontFamily) return;
    _lastFontFamily = fontFamily;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFontFamilyChanged(fontFamily);
      }
    });
  }

  void _syncFontScale() {
    final fontScale = _controller.settings.fontScale;
    if (_lastFontScale == fontScale) return;
    _lastFontScale = fontScale;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onFontScaleChanged(fontScale);
      }
    });
  }

  void _syncThemeMode() {
    final preference = _controller.settings.themePreference;
    if (_lastThemePreference == preference) return;
    _lastThemePreference = preference;
    final mode = switch (preference) {
      AppThemePreference.system => ThemeMode.system,
      AppThemePreference.light => ThemeMode.light,
      AppThemePreference.dark => ThemeMode.dark,
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onThemeModeChanged(mode);
      }
    });
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent || !mounted) {
      return false;
    }
    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    if (keyboard.isControlPressed && key == LogicalKeyboardKey.keyO) {
      _log.detail('shortcut', 'Ctrl+O 打开仓库');
      _runShortcut(() => unawaited(_openRepository()));
      return true;
    }
    if (!_controller.hasRepository) {
      return false;
    }
    if (ModalRoute.of(context)?.isCurrent != true ||
        _isCommitFieldFocused ||
        _primaryFocusIsEditable()) {
      return false;
    }
    if (key == LogicalKeyboardKey.f2) {
      _log.detail('shortcut', 'F2 重命名');
      _runShortcut(_renameActiveSelection);
      return true;
    }
    if (key == LogicalKeyboardKey.delete) {
      _log.detail('shortcut', 'Delete 删除');
      _runShortcut(_deleteActiveSelection);
      return true;
    }
    if (keyboard.isControlPressed &&
        keyboard.isShiftPressed &&
        key == LogicalKeyboardKey.keyU) {
      _log.detail('shortcut', 'Ctrl+Shift+U 推送');
      _runShortcut(_pushCurrentBranch);
      return true;
    }
    if (!keyboard.isControlPressed ||
        keyboard.isShiftPressed ||
        keyboard.isAltPressed) {
      return false;
    }
    final action = switch (key) {
      LogicalKeyboardKey.keyX => () => _handleClipboard(ClipboardMode.cut),
      LogicalKeyboardKey.keyC => () => _handleClipboard(ClipboardMode.copy),
      LogicalKeyboardKey.keyV => () => unawaited(_handlePaste()),
      LogicalKeyboardKey.keyA => () => _controller.selectAll(
        _controller.activeSide,
      ),
      LogicalKeyboardKey.keyR => () => unawaited(_refreshRepository()),
      _ => null,
    };
    if (action == null) {
      return false;
    }
    _log.detail(
      'shortcut',
      '${keyboard.isControlPressed ? 'Ctrl+' : ''}${key.keyLabel}',
    );
    _runShortcut(action);
    return true;
  }

  bool _primaryFocusIsEditable() {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext == null) {
      return false;
    }
    return focusContext.widget is EditableText ||
        focusContext.findAncestorStateOfType<EditableTextState>() != null;
  }

  void _runShortcut(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        action();
      }
    });
  }

  Future<void> _openRepository() async {
    if (_isOpening) return;
    _log.detail('repository', '请求打开仓库文件夹选择器');
    setState(() => _isOpening = true);
    try {
      final path = await _folderPicker.pickRepositoryFolder(
        initialDirectory: _controller.repositoryPath,
      );
      if (path == null) {
        _log.detail('repository', '用户取消文件夹选择');
        return;
      }
      _log.info('repository', '用户选择仓库：$path');
      await _openRepositoryPath(path);
    } catch (error) {
      _log.error('repository', '打开文件夹选择器失败：$error');
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            error.toString().replaceFirst('Unsupported operation: ', ''),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpening = false);
      }
    }
  }

  Future<void> _openRepositoryPath(String path) async {
    if (!mounted) return;
    _log.detail('repository', '开始打开仓库：$path');
    setState(() => _isOpening = true);
    try {
      final outcome = await _controller.openRepository(path);
      if (!mounted) return;
      _showOutcome(outcome);
      if (outcome.isSuccess) {
        _log.info('repository', '仓库已打开：${_controller.repositoryPath}');
      } else {
        _log.error('repository', '仓库打开失败：${outcome.message}');
      }
      if (outcome.isSuccess) {
        _explorerFocus.requestFocus();
      }
    } catch (error) {
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            error.toString().replaceFirst('Unsupported operation: ', ''),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpening = false);
      }
    }
  }

  Future<void> _openRecentRepository(String path) async {
    if (_isOpening) return;
    _log.info('history', '从最近仓库打开：$path');
    await _openRepositoryPath(path);
  }

  Future<void> _removeRecentRepository(String path) async {
    final outcome = await _controller.removeRecentRepository(path);
    if (mounted) {
      _showOutcome(outcome);
    }
  }

  void _showOutcome(OperationOutcome outcome) {
    _log.detail(
      'ui',
      '操作提示 ${outcome.isSuccess ? '成功' : '失败'}：${outcome.message}',
    );
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                outcome.isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              Expanded(child: Text(outcome.message)),
            ],
          ),
          backgroundColor: outcome.isSuccess
              ? const Color(0xFF1C3D35)
              : const Color(0xFF7B3434),
        ),
      );
  }

  Future<void> _renameActiveSelection() async {
    final panel = _controller.panelFor(_controller.activeSide);
    if (panel.selectedPaths.isEmpty) {
      _showOutcome(const OperationOutcome.failure('请先勾选要重命名的项目。'));
      return;
    }
    if (panel.selectedPaths.length > 1) {
      _showOutcome(const OperationOutcome.failure('重命名时只能勾选一个项目。'));
      return;
    }

    final path = panel.selectedPaths.single;
    _log.detail('ui', '打开重命名对话框：$path');
    final currentName = repositoryName(path);
    final textController = TextEditingController(text: currentName);
    final isFile = panel.entries
        .where((entry) => entry.relativePath == path)
        .any((entry) => !entry.isDirectory);
    final dotIndex = isFile ? currentName.lastIndexOf('.') : -1;
    textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: dotIndex > 0 ? dotIndex : currentName.length,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.drive_file_rename_outline_rounded, size: 21),
            SizedBox(width: 9),
            Text('重命名'),
          ],
        ),
        content: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                path,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: const InputDecoration(labelText: '新名称'),
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              const SizedBox(height: 10),
              const Text(
                '此操作会执行 git mv，并在 Git 中记录为重命名。',
                style: TextStyle(fontSize: 10.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: const Text('重命名'),
          ),
        ],
      ),
    );
    textController.dispose();
    if (newName == null || !mounted) return;
    final outcome = await _controller.renameSelection(newName);
    if (mounted) {
      _showOutcome(outcome);
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _deleteActiveSelection() async {
    final panel = _controller.panelFor(_controller.activeSide);
    if (panel.selectedPaths.isEmpty) {
      _showOutcome(const OperationOutcome.failure('请先勾选要删除的项目。'));
      return;
    }
    final paths = panel.selectedPaths.toList(growable: false);
    _log.detail('ui', '打开删除确认：${paths.join(' | ')}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final preview = paths.take(6).toList(growable: false);
        return AlertDialog(
          icon: Icon(Icons.delete_forever_outlined, color: colors.error),
          title: Text('删除 ${paths.length} 个项目？'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '已跟踪内容使用 git rm；未跟踪或忽略内容使用 git clean。'
                  '删除后文件会从工作区移除，并把已跟踪项的删除加入 Git 索引。',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final path in preview)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            path,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      if (paths.length > preview.length)
                        Text(
                          '以及其他 ${paths.length - preview.length} 项',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              label: const Text('确认删除'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;
    final outcome = await _controller.deleteSelectedPaths();
    if (mounted) {
      _showOutcome(outcome);
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _pushCurrentBranch() async {
    if (!_controller.hasRepository) return;
    final branch = _controller.branch.isEmpty ? '当前分支' : _controller.branch;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_upload_outlined),
        title: Text('推送 $branch？'),
        content: SizedBox(
          width: 430,
          child: const Text(
            '将当前提交推送到远程仓库。已配置 upstream 时直接执行 git push；'
            '否则会优先使用 origin 并设置当前分支的 upstream。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('确认推送'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _log.info('ui', '用户确认推送 $branch');
    final outcome = await _controller.pushCurrentBranch();
    if (mounted) {
      _showOutcome(outcome);
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showSettings() async {
    _log.detail('ui', '打开设置对话框');
    await showDialog<void>(
      context: context,
      builder: (context) => SettingsDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showUpdates() async {
    _log.detail('ui', '打开发布更新与更新日志对话框');
    await showDialog<void>(
      context: context,
      builder: (context) => const UpdateDialog(),
    );
  }

  Future<void> _showLogs() async {
    _log.detail('ui', '打开操作日志查看器');
    await showDialog<void>(
      context: context,
      builder: (context) => const LogViewerDialog(),
    );
  }

  Future<void> _showRemotes() async {
    _log.detail('ui', '打开远端仓库管理');
    await showDialog<void>(
      context: context,
      builder: (context) => RemoteManagementDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  void _handleClipboard(ClipboardMode mode) {
    _showOutcome(_controller.setClipboard(mode));
  }

  Future<void> _handlePaste() async {
    final outcome = await _controller.pasteToActivePanel();
    if (mounted) {
      _showOutcome(outcome);
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _refreshRepository() async {
    await _controller.refresh();
    if (mounted) {
      _showOutcome(
        _controller.fatalError == null
            ? const OperationOutcome.success('仓库视图已刷新')
            : OperationOutcome.failure(_controller.fatalError!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: _buildTopBar(context),
      ),
      body: _controller.hasRepository
          ? _buildRepositoryWorkspace(context)
          : StartView(
              onOpenRepository: _openRepository,
              isOpening: _isOpening || _controller.isBusy,
              recentRepositories: _controller.recentRepositories,
              onOpenRecent: _openRecentRepository,
              onRemoveRecent: _removeRecentRepository,
              error: _controller.fatalError,
            ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          AppBrand(
            onTap: _controller.hasRepository
                ? () {
                    _controller.closeRepository();
                    _explorerFocus.unfocus();
                  }
                : null,
          ),
          if (_controller.hasRepository) ...[
            Container(
              height: 24,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              color: colors.outlineVariant,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _controller.projectName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    toPosixPath(_controller.repositoryPath ?? ''),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const Spacer(),
          _TopBarButton(
            icon: Icons.folder_open_rounded,
            label: '打开',
            onTap: _openRepository,
          ),
          _TopBarButton(
            icon: Icons.system_update_alt_rounded,
            label: '更新',
            onTap: () => _showUpdates(),
          ),
          _TopBarButton(
            icon: Icons.receipt_long_outlined,
            label: '操作日志',
            onTap: _showLogs,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _showSettings,
            tooltip: '设置',
            icon: const Icon(Icons.settings_outlined, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildRepositoryWorkspace(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _buildProjectSummary(context),
            _buildOperationBar(context),
            Expanded(
              child: Focus(
                focusNode: _explorerFocus,
                autofocus: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FileExplorerPanel(
                                side: ExplorerSide.left,
                                state: _controller.leftPanel,
                                rootPath: _controller.repositoryPath!,
                                settings: _controller.settings,
                                isActive:
                                    _controller.activeSide == ExplorerSide.left,
                                controller: _controller,
                                showOutcome: _showOutcome,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FileExplorerPanel(
                                side: ExplorerSide.right,
                                state: _controller.rightPanel,
                                rootPath: _controller.repositoryPath!,
                                settings: _controller.settings,
                                isActive:
                                    _controller.activeSide ==
                                    ExplorerSide.right,
                                controller: _controller,
                                showOutcome: _showOutcome,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 224,
                        child: CommitPanel(
                          controller: _controller,
                          showOutcome: _showOutcome,
                          onPushRequested: _pushCurrentBranch,
                          onManageRemotes: _showRemotes,
                          onTextEditingChanged: (focused) {
                            _isCommitFieldFocused = focused;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_controller.isBusy)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildProjectSummary(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stats = _controller.repositoryStats;
    final size = stats == null
        ? '—'
        : formatFileSize(stats.totalBytes, _controller.settings);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _controller.projectName ?? 'Git 仓库',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.account_tree_outlined,
                      label: _controller.branch.isEmpty
                          ? '无分支'
                          : _controller.branch,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sizeUnitDescription(_controller.settings),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _SummaryMetric(
            label: '项目大小',
            value: size,
            icon: Icons.data_usage_rounded,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: '文件',
            value: '${stats?.fileCount ?? 0}',
            icon: Icons.insert_drive_file_outlined,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: '待提交',
            value: '${_controller.changedFiles.length}',
            icon: Icons.change_circle_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildOperationBar(BuildContext context) {
    final activePanel = _controller.panelFor(_controller.activeSide);
    final selectedCount = activePanel.selectedPaths.length;
    final clipboard = _controller.clipboard;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          children: [
            _OperationButton(
              icon: Icons.content_cut_rounded,
              label: '剪切',
              shortcut: 'Ctrl X',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.cut),
            ),
            _OperationButton(
              icon: Icons.content_copy_rounded,
              label: '复制',
              shortcut: 'Ctrl C',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.copy),
            ),
            _OperationButton(
              icon: Icons.content_paste_rounded,
              label: '粘贴',
              shortcut: 'Ctrl V',
              enabled: clipboard != null && !_controller.isBusy,
              onTap: _handlePaste,
            ),
            _OperationButton(
              icon: Icons.drive_file_rename_outline_rounded,
              label: '重命名',
              shortcut: 'F2',
              enabled: selectedCount == 1 && !_controller.isBusy,
              onTap: _renameActiveSelection,
            ),
            _OperationButton(
              icon: Icons.delete_outline_rounded,
              label: '删除',
              shortcut: 'Delete',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: _deleteActiveSelection,
            ),
            Container(
              height: 22,
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              color: colors.outlineVariant,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.south_east_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _controller.activeSide == ExplorerSide.left
                        ? '粘贴到左侧'
                        : '粘贴到右侧',
                    style: TextStyle(
                      fontSize: 10,
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (clipboard != null)
              _ClipboardView(
                selection: clipboard,
                onClear: () => _showOutcome(_controller.clearClipboard()),
              )
            else
              Text(
                selectedCount == 0 ? '勾选文件后可剪切或复制' : '已选择 $selectedCount 项',
                style: TextStyle(
                  fontSize: 10.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            const Spacer(),
            if (_controller.isBusy)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            Text(
              '双击文件夹进入 · 点击面板切换粘贴目标',
              style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _refreshRepository,
              tooltip: '刷新仓库 (Ctrl+R)',
              icon: const Icon(Icons.refresh_rounded, size: 18),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  const _TopBarButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 112,
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 9, color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  const _OperationButton({
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String shortcut;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: '$label ($shortcut)',
      child: TextButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 15),
        label: Text(label),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          foregroundColor: colors.onSurface,
          textStyle: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        ),
      ),
    );
  }
}

class _ClipboardView extends StatelessWidget {
  const _ClipboardView({required this.selection, required this.onClear});

  final ExplorerSelection selection;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final isCut = selection.mode == ClipboardMode.cut;
    final badgeColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFD27A)
        : const Color(0xFF7E651E);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isCut ? Icons.content_cut_rounded : Icons.content_copy_rounded,
          size: 12,
          color: badgeColor,
        ),
        const SizedBox(width: 5),
        Text(
          '${isCut ? '待移动' : '待复制'} ${selection.paths.length} 项',
          style: TextStyle(
            fontSize: 10,
            color: badgeColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 3),
        InkWell(
          onTap: onClear,
          borderRadius: BorderRadius.circular(3),
          child: const Padding(
            padding: EdgeInsets.all(3),
            child: Icon(Icons.close_rounded, size: 12),
          ),
        ),
      ],
    );
  }
}
