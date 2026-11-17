import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/folder_picker_service.dart';
import '../../core/services/git_service.dart';
import '../../core/services/installation_maintenance_service.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/size_formatter.dart';
import '../commit/commit_panel.dart';
import '../dialogs/branch_management_dialog.dart';
import '../dialogs/clone_repository_dialog.dart';
import '../dialogs/git_metadata_clear_dialog.dart';
import '../dialogs/log_viewer_dialog.dart';
import '../dialogs/installation_cleanup_dialog.dart';
import '../dialogs/operation_plan_dialog.dart';
import '../dialogs/remote_management_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../dialogs/stash_management_dialog.dart';
import '../dialogs/update_dialog.dart';
import '../dialogs/user_guide_dialog.dart';
import '../explorer/file_explorer_panel.dart';
import '../repository/repository_controller.dart';
import '../start/start_view.dart';
import 'widgets/app_brand.dart';
import 'widgets/app_outcome_snack_bar.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({
    super.key,
    this.initialRepositoryPath,
    required this.onThemeModeChanged,
    required this.onColorSchemeChanged,
    required this.onFontFamilyChanged,
    required this.onFontScaleChanged,
    required this.onLanguagePreferenceChanged,
  });

  final String? initialRepositoryPath;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<AppColorSchemePreference> onColorSchemeChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontScaleChanged;
  final ValueChanged<AppLanguagePreference> onLanguagePreferenceChanged;

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final RepositoryController _controller = RepositoryController();
  final FolderPickerService _folderPicker = const FolderPickerService();
  final FocusNode _explorerFocus = FocusNode(debugLabel: 'explorer-shortcuts');
  final InstallationMaintenanceService _maintenance =
      const InstallationMaintenanceService();

  bool _isOpening = false;
  bool _isCommitFieldFocused = false;
  AppThemePreference _lastThemePreference = AppThemePreference.system;
  AppColorSchemePreference _lastColorScheme = AppColorSchemePreference.emerald;
  String _lastFontFamily = '';
  double _lastFontScale = AppSettings.defaultFontScale;
  AppLanguagePreference _lastLanguagePreference = AppLanguagePreference.system;
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
    await _performStartupMaintenance();
    final initialPath = widget.initialRepositoryPath;
    if (initialPath != null && initialPath.trim().isNotEmpty && mounted) {
      await _openRepositoryPath(initialPath);
    }
  }

  Future<void> _performStartupMaintenance() async {
    try {
      final scan = await _maintenance.scan();
      if (scan.items.isNotEmpty) {
        final result = await _maintenance.cleanup(scan);
        _log.info(
          'maintenance',
          '启动自动清理：移除 ${result.removed.length} 项，'
              '失败 ${result.failed.length} 项',
        );
      } else {
        _log.detail('maintenance', '启动扫描：没有需要清理的旧版本或安装包');
      }
      await _maintenance.scheduleLauncherSelfUpdate();
      final remaining = await _maintenance.scan();
      if (remaining.items.isNotEmpty && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showDialog<void>(
              context: context,
              builder: (context) => const InstallationCleanupDialog(),
            );
          }
        });
      }
    } catch (error) {
      _log.error('maintenance', '启动自动维护失败：$error');
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
      _syncColorScheme();
      _syncFontFamily();
      _syncFontScale();
      _syncLanguagePreference();
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

  void _syncColorScheme() {
    final colorScheme = _controller.settings.colorSchemePreference;
    if (_lastColorScheme == colorScheme) return;
    _lastColorScheme = colorScheme;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onColorSchemeChanged(colorScheme);
      }
    });
  }

  void _syncLanguagePreference() {
    final preference = _controller.settings.languagePreference;
    if (_lastLanguagePreference == preference) return;
    _lastLanguagePreference = preference;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onLanguagePreferenceChanged(preference);
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
    final l10n = context.l10n;
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
      if (!await _confirmDiscardPendingPlan(l10n.tr('打开另一个仓库'))) {
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

  Future<void> _openEmptyFolder() async {
    if (_isOpening) return;
    final l10n = context.l10n;
    setState(() => _isOpening = true);
    try {
      final path = await _folderPicker.pickFolder(
        initialDirectory: _controller.repositoryPath,
        title: l10n.tr('打开空白文件夹'),
      );
      if (path == null || !mounted) return;
      final gitPath = '$path${Platform.pathSeparator}.git';
      if (FileSystemEntity.typeSync(gitPath) != FileSystemEntityType.notFound) {
        await _openRepositoryPath(path);
        return;
      }
      final initialize = await showDialog<bool>(
        context: context,
        builder: (context) {
          final colors = Theme.of(context).colorScheme;
          return AlertDialog(
            icon: Icon(Icons.account_tree_outlined, color: colors.primary),
            title: Text(l10n.tr('是否马上初始化 Git 仓库？')),
            content: Text(
              l10n.tr('当前文件夹还不是 Git 仓库。现在执行 git init 后即可在软件中管理和提交。'),
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.tr('暂不初始化')),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon: const Icon(Icons.check_rounded, size: 17),
                label: Text(l10n.tr('立即初始化')),
              ),
            ],
          );
        },
      );
      if (initialize != true || !mounted) return;
      await GitService.initializeRepository(path);
      await _openRepositoryPath(path);
    } catch (error) {
      _log.error('repository', '初始化空白文件夹失败：$error');
      if (mounted) {
        _showOutcome(OperationOutcome.failure(error.toString()));
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _cloneRepository() async {
    final path = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CloneRepositoryDialog(),
    );
    if (path == null || !mounted) return;
    await _openRepositoryPath(path);
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
    if (!await _confirmDiscardPendingPlan(context.l10n.tr('打开另一个仓库'))) {
      return;
    }
    _log.info('history', '从最近仓库打开：$path');
    await _openRepositoryPath(path);
  }

  Future<void> _openProjectDirectory() async {
    final path = _controller.repositoryPath;
    if (path == null || path.isEmpty) {
      _showOutcome(OperationOutcome.failure(context.l10n.tr('当前没有打开的项目。')));
      return;
    }
    try {
      await _folderPicker.openDirectory(path);
      _log.detail('ui', '已在 Windows 资源管理器中打开项目目录：$path');
    } catch (error) {
      _log.error('ui', '打开项目目录失败：$error');
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            context.l10n.tr('无法打开项目目录：{error}', {
              'error': error.toString().replaceFirst(
                'FileSystemException: ',
                '',
              ),
            }),
          ),
        );
      }
    }
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
    showAppOutcomeSnackBar(context, outcome, onViewLogs: _showLogs);
  }

  Future<void> _renameActiveSelection() async {
    final panel = _controller.panelFor(_controller.activeSide);
    if (panel.selectedPaths.isEmpty) {
      _showOutcome(OperationOutcome.failure(context.l10n.tr('请先勾选要重命名的项目。')));
      return;
    }
    if (panel.selectedPaths.length > 1) {
      _showOutcome(OperationOutcome.failure(context.l10n.tr('重命名时只能勾选一个项目。')));
      return;
    }

    final path = panel.selectedPaths.single;
    final l10n = context.l10n;
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
        title: Row(
          children: [
            const Icon(Icons.drive_file_rename_outline_rounded, size: 21),
            const SizedBox(width: 9),
            Text(l10n.tr('重命名')),
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
                decoration: InputDecoration(labelText: l10n.tr('新名称')),
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(
                  '此操作只会加入待执行计划。确认并执行计划后，'
                  '软件才会运行 git mv。',
                ),
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('取消')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text(l10n.tr('加入执行计划')),
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
      _showOutcome(OperationOutcome.failure(context.l10n.tr('请先勾选要删除的项目。')));
      return;
    }
    final paths = panel.selectedPaths.toList(growable: false);
    final l10n = context.l10n;
    _log.detail('ui', '打开删除确认：${paths.join(' | ')}');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final preview = paths.take(6).toList(growable: false);
        return AlertDialog(
          icon: Icon(Icons.delete_forever_outlined, color: colors.error),
          title: Text(l10n.tr('将删除 {count} 个项目加入计划', {'count': paths.length})),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr(
                      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”'
                      '中再次确认，才会使用 git rm 或 git clean 执行。',
                    ),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 230),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: colors.error.withValues(alpha: 0.18),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final path in preview)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Tooltip(
                                message: path,
                                child: Text(
                                  path,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          if (paths.length > preview.length)
                            Text(
                              l10n.tr('以及其他 {count} 项', {
                                'count': paths.length - preview.length,
                              }),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.tr('取消')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              label: Text(l10n.tr('加入删除计划')),
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
      if (outcome.isSuccess) {
        await _showOperationPlan();
      } else {
        _explorerFocus.requestFocus();
      }
    }
  }

  Future<void> _pushCurrentBranch() async {
    if (!_controller.hasRepository) return;
    final l10n = context.l10n;
    final branch = _controller.branch.isEmpty
        ? l10n.tr('当前分支')
        : _controller.branch;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_upload_outlined),
        title: Text(l10n.tr('将推送 {branch} 加入计划', {'branch': branch})),
        content: SizedBox(
          width: 430,
          child: Text(
            l10n.tr(
              '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；'
              '否则优先使用 origin 并设置当前分支的 upstream。',
            ),
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.tr('取消')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: Text(l10n.tr('加入推送计划')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _log.info('ui', '用户确认推送 $branch');
    final outcome = await _controller.pushCurrentBranch();
    if (mounted) {
      _showOutcome(outcome);
      if (outcome.isSuccess) {
        await _showOperationPlan();
      } else {
        _explorerFocus.requestFocus();
      }
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

  Future<void> _showUserGuide() async {
    _log.detail('ui', '打开使用指南');
    await showDialog<void>(
      context: context,
      builder: (context) => const UserGuideDialog(),
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

  Future<void> _showBranches() async {
    _log.detail('ui', '打开分支管理');
    await showDialog<void>(
      context: context,
      builder: (context) => BranchManagementDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showGitMetadata() async {
    final outcome = await showDialog<OperationOutcome>(
      context: context,
      barrierDismissible: false,
      builder: (context) => GitMetadataClearDialog(controller: _controller),
    );
    if (outcome != null && mounted) {
      _showOutcome(outcome);
    }
  }

  Future<void> _showStashes() async {
    _log.detail('ui', '打开 Stash 管理');
    await showDialog<void>(
      context: context,
      builder: (context) => StashManagementDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showOperationPlan() async {
    _log.detail('ui', '打开待执行操作计划，共 ${_controller.pendingOperations.length} 步');
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => OperationPlanDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<bool> _confirmDiscardPendingPlan(String action) async {
    if (!_controller.hasPendingOperations) {
      return true;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final l10n = context.l10n;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: colors.error),
          title: Text(l10n.tr('放弃待执行操作计划？')),
          content: SizedBox(
            width: 460,
            child: Text(
              l10n.tr(
                '当前有 {count} 步操作尚未执行。{action}会清除这些计划，'
                '仓库不会发生这些变更。',
                {
                  'count': _controller.pendingOperations.length,
                  'action': action,
                },
              ),
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.tr('返回')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: colors.error),
              child: Text(l10n.tr('放弃计划并继续')),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      _controller.clearPendingOperations();
      return true;
    }
    return false;
  }

  Future<void> _closeRepository() async {
    if (!await _confirmDiscardPendingPlan(context.l10n.tr('关闭仓库'))) {
      return;
    }
    _controller.closeRepository();
    _explorerFocus.unfocus();
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
            ? OperationOutcome.success(context.l10n.tr('仓库视图已刷新'))
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
              onOpenEmptyFolder: _openEmptyFolder,
              onCloneRepository: _cloneRepository,
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
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          AppBrand(onTap: _controller.hasRepository ? _closeRepository : null),
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
                      fontSize: 11.5,
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
            label: l10n.tr('打开'),
            onTap: _openRepository,
          ),
          if (_controller.hasRepository)
            _TopBarButton(
              icon: Icons.folder_copy_outlined,
              label: l10n.tr('项目目录'),
              onTap: _openProjectDirectory,
            ),
          if (_controller.hasRepository)
            _TopBarButton(
              icon: Icons.delete_forever_outlined,
              label: l10n.tr('Git 元数据'),
              onTap: _showGitMetadata,
            ),
          _TopBarButton(
            icon: Icons.system_update_alt_rounded,
            label: l10n.tr('更新'),
            onTap: () => _showUpdates(),
          ),
          _TopBarButton(
            icon: Icons.receipt_long_outlined,
            label: l10n.tr('操作日志'),
            onTap: _showLogs,
          ),
          _TopBarButton(
            icon: Icons.menu_book_outlined,
            label: l10n.tr('指南'),
            onTap: _showUserGuide,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _showSettings,
            tooltip: l10n.tr('设置'),
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
                          onManageBranches: _showBranches,
                          onManageStashes: _showStashes,
                          onPlanRequested: _showOperationPlan,
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
    final l10n = context.l10n;
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
                        _controller.projectName ?? l10n.tr('Git 仓库'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.account_tree_outlined,
                      label: _controller.branch.isEmpty
                          ? l10n.tr('无分支')
                          : _controller.branch,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.tr(sizeUnitDescription(_controller.settings)),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          _SummaryMetric(
            label: l10n.tr('项目大小'),
            value: size,
            icon: Icons.data_usage_rounded,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: l10n.tr('文件'),
            value: '${stats?.fileCount ?? 0}',
            icon: Icons.insert_drive_file_outlined,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: l10n.tr('待提交'),
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
    final l10n = context.l10n;
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
              label: l10n.tr('剪切'),
              shortcut: 'Ctrl X',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.cut),
            ),
            _OperationButton(
              icon: Icons.content_copy_rounded,
              label: l10n.tr('复制'),
              shortcut: 'Ctrl C',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.copy),
            ),
            _OperationButton(
              icon: Icons.content_paste_rounded,
              label: l10n.tr('粘贴'),
              shortcut: 'Ctrl V',
              enabled:
                  clipboard != null &&
                  !_controller.isBusy &&
                  !_controller.localOperationsLocked,
              onTap: _handlePaste,
            ),
            _OperationButton(
              icon: Icons.drive_file_rename_outline_rounded,
              label: l10n.tr('重命名'),
              shortcut: 'F2',
              enabled:
                  selectedCount == 1 &&
                  !_controller.isBusy &&
                  !_controller.localOperationsLocked,
              onTap: _renameActiveSelection,
            ),
            _OperationButton(
              icon: Icons.delete_outline_rounded,
              label: l10n.tr('删除'),
              shortcut: 'Delete',
              enabled:
                  selectedCount > 0 &&
                  !_controller.isBusy &&
                  !_controller.localOperationsLocked,
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
                        ? l10n.tr('粘贴到左侧')
                        : l10n.tr('粘贴到右侧'),
                    style: TextStyle(
                      fontSize: 11,
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
                selectedCount == 0
                    ? l10n.tr('勾选文件后可剪切或复制')
                    : l10n.tr('已选择 {count} 项', {'count': selectedCount}),
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 10),
            Tooltip(
              message: l10n.tr('查看、移除或确认执行所有待处理操作'),
              child: OutlinedButton.icon(
                onPressed: _controller.isBusy ? null : _showOperationPlan,
                icon: Icon(
                  _controller.hasPendingOperations
                      ? Icons.playlist_add_check_circle_outlined
                      : Icons.playlist_add_rounded,
                  size: 16,
                ),
                label: Text(
                  l10n.tr('待执行 {count}', {
                    'count': _controller.pendingOperations.length,
                  }),
                ),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 8,
                  ),
                  foregroundColor: _controller.hasPendingOperations
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  side: BorderSide(
                    color: _controller.hasPendingOperations
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineVariant,
                  ),
                  textStyle: Theme.of(context).textTheme.labelMedium
                      ?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
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
              l10n.tr('双击文件夹进入 · 点击面板切换粘贴目标'),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _refreshRepository,
              tooltip: l10n.tr('刷新仓库 (Ctrl+R)'),
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
        textStyle: Theme.of(context).textTheme.labelMedium
            ?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
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
              fontSize: 11,
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
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
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
          textStyle: Theme.of(context).textTheme.labelMedium
              ?.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
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
    final l10n = context.l10n;
    final badgeColor = Theme.of(context).colorScheme.primary;
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
          l10n.tr(isCut ? '待移动 {count} 项' : '待复制 {count} 项', {
            'count': selection.paths.length,
          }),
          style: TextStyle(
            fontSize: 11.5,
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
