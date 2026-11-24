import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_info.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/runtime_messages.dart';
import '../../core/models/git_remote.dart';
import '../../core/models/operation_safety.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/external_link_service.dart';
import '../../core/services/folder_picker_service.dart';
import '../../core/services/git_service.dart';
import '../../core/services/installation_maintenance_service.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/size_formatter.dart';
import '../commit/commit_panel.dart';
import '../dialogs/branch_management_dialog.dart';
import '../dialogs/clone_repository_dialog.dart';
import '../dialogs/git_metadata_clear_dialog.dart';
import '../dialogs/git_runtime_recovery_dialog.dart';
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
import '../start/repository_bootstrap_plan_controller.dart';
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
  final ExternalLinkService _externalLinks = ExternalLinkService();

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
        _log.infoEvent(
          'maintenance',
          'maintenance.startup.cleanup',
          details: {
            'removed': '${result.removed.length}',
            'failed': '${result.failed.length}',
          },
        );
      } else {
        _log.detailEvent('maintenance', 'maintenance.startup.scan.clean');
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
      _log.errorEvent(
        'maintenance',
        'maintenance.startup.failed',
        details: {'error': '$error'},
      );
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
      _log.detailEvent(
        'shortcut',
        'shortcut.openRepository',
        details: {'shortcut': 'Ctrl+O'},
      );
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
      _log.detailEvent(
        'shortcut',
        'shortcut.rename',
        details: {'shortcut': 'F2'},
      );
      _runShortcut(_renameActiveSelection);
      return true;
    }
    if (key == LogicalKeyboardKey.delete) {
      _log.detailEvent(
        'shortcut',
        'shortcut.delete',
        details: {'shortcut': 'Delete'},
      );
      _runShortcut(_deleteActiveSelection);
      return true;
    }
    if (keyboard.isControlPressed &&
        keyboard.isShiftPressed &&
        key == LogicalKeyboardKey.keyU) {
      _log.detailEvent(
        'shortcut',
        'shortcut.push',
        details: {'shortcut': 'Ctrl+Shift+U'},
      );
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
    _log.detailEvent(
      'shortcut',
      'shortcut.command',
      details: {'key': key.keyLabel, 'control': '${keyboard.isControlPressed}'},
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
    if (!await _ensureGitAvailable()) return;
    if (!mounted) return;
    final l10n = context.l10n;
    _log.detailEvent('repository', 'repository.picker.opened');
    setState(() => _isOpening = true);
    try {
      final path = await _folderPicker.pickRepositoryFolder(
        initialDirectory: _controller.repositoryPath,
      );
      if (path == null) {
        _log.detailEvent('repository', 'repository.picker.cancelled');
        return;
      }
      if (!await _confirmDiscardPendingPlan(
        l10n.tr('openingAnotherRepository'),
      )) {
        return;
      }
      _log.infoEvent(
        'repository',
        'repository.picker.selected',
        details: {'path': path},
      );
      await _openRepositoryPath(path);
    } catch (error) {
      _log.errorEvent(
        'repository',
        'repository.picker.failed',
        details: {'error': '$error'},
      );
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            RuntimeMessages.operationFailed(
              error.toString().replaceFirst('Unsupported operation: ', ''),
              eventId: 'repository.picker.failed',
            ),
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
    if (!await _ensureGitAvailable()) return;
    if (!mounted) return;
    setState(() => _isOpening = true);
    try {
      final path = await _folderPicker.pickFolder(
        initialDirectory: _controller.repositoryPath,
        title: context.l10n.tr('openEmptyFolder'),
      );
      if (path == null || !mounted) return;
      final gitPath = '$path${Platform.pathSeparator}.git';
      if (FileSystemEntity.typeSync(gitPath) != FileSystemEntityType.notFound) {
        await _openRepositoryPath(path);
        return;
      }
      final initialized = await _showInitializationPlan(path);
      if (initialized && mounted) {
        await _openRepositoryPath(path);
      }
    } catch (error) {
      _log.errorEvent(
        'repository',
        'repository.initializeBlank.failed',
        details: {'error': '$error'},
      );
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            RuntimeMessages.operationFailed(
              error,
              eventId: 'repository.initializeBlank.failed',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<void> _cloneRepository() async {
    if (_isOpening) return;
    if (!await _ensureGitAvailable()) return;
    if (!mounted) return;
    final request = await showDialog<CloneRepositoryRequest>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CloneRepositoryDialog(),
    );
    if (request == null || !mounted) return;
    setState(() => _isOpening = true);
    try {
      final cloned = await _showClonePlan(request);
      if (cloned && mounted) {
        await _openRepositoryPath(request.destinationPath);
      }
    } finally {
      if (mounted) setState(() => _isOpening = false);
    }
  }

  Future<bool> _showInitializationPlan(String path) async {
    if (!mounted) return false;
    final snapshot = await GitService.inspectInitializationTarget(path);
    if (!mounted) return false;
    if (!snapshot.targetExists || snapshot.gitMetadataType != 'notFound') {
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor(
            'theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata',
          ),
        ),
      );
      return false;
    }
    final precondition = OperationPrecondition(bootstrap: snapshot);
    final plan = RepositoryBootstrapPlanController(
      operation: PlannedRepositoryOperation(
        id: 'bootstrap-init',
        kind: PlannedOperationKind.initializeRepository,
        title: RuntimeMessages.messageFor('planTitleInitializeRepository'),
        description: RuntimeMessages.messageFor(
          'planDescriptionInitializeRepository',
          parameters: {'path': path},
        ),
        run: () async {
          try {
            await GitService.initializeRepository(path);
            return OperationOutcome.success(
              RuntimeMessages.messageFor(
                'gitRepositoryInitialized',
                eventId: 'repository.initialize.succeeded',
                technicalDetails: {'path': path},
              ),
            );
          } catch (error) {
            return OperationOutcome.failure(
              RuntimeMessages.operationFailed(
                error,
                eventId: 'repository.initialize.failed',
                target: path,
              ),
            );
          }
        },
        affectedPaths: const [],
      ),
      precondition: precondition,
      validate: (expected) async {
        final current = await GitService.inspectInitializationTarget(path);
        return compareBootstrapSnapshots(
          expected: expected.bootstrap!,
          actual: current,
        );
      },
      refreshPrecondition: () async => OperationPrecondition(
        bootstrap: await GitService.inspectInitializationTarget(path),
      ),
      logService: _log,
    );
    try {
      if (!mounted) return false;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => OperationPlanDialog(planHost: plan),
      );
      return plan.lastResult?.isSuccess == true;
    } finally {
      plan.dispose();
    }
  }

  Future<bool> _showClonePlan(CloneRepositoryRequest request) async {
    if (!mounted) return false;
    final snapshot = await GitService.inspectCloneTarget(
      request.remoteUrl,
      request.destinationPath,
    );
    if (!mounted) return false;
    if (!await Directory(snapshot.parentPath).exists()) {
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor(
            'theCloneDestinationParentFolderDoesNotExist',
            technicalDetails: {'path': snapshot.parentPath},
          ),
        ),
      );
      return false;
    }
    if (snapshot.targetExists && !snapshot.targetIsEmpty) {
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor(
            'theCloneDestinationFolderIsNotEmpty',
            technicalDetails: {'path': request.destinationPath},
          ),
        ),
      );
      return false;
    }
    final precondition = OperationPrecondition(bootstrap: snapshot);
    final plan = RepositoryBootstrapPlanController(
      operation: PlannedRepositoryOperation(
        id: 'bootstrap-clone',
        kind: PlannedOperationKind.cloneRepository,
        title: RuntimeMessages.messageFor('planTitleCloneRepository'),
        description: RuntimeMessages.messageFor(
          'planDescriptionCloneRepository',
          parameters: {
            'url': GitRemote.maskRemoteUrl(request.remoteUrl),
            'path': request.destinationPath,
          },
        ),
        run: () async {
          try {
            await GitService.cloneRepository(
              request.remoteUrl,
              request.destinationPath,
            );
            return OperationOutcome.success(
              RuntimeMessages.messageFor(
                'gitRepositoryCloned',
                eventId: 'repository.clone.succeeded',
                technicalDetails: {
                  'path': request.destinationPath,
                  'url': GitRemote.maskRemoteUrl(request.remoteUrl),
                },
              ),
            );
          } catch (error) {
            return OperationOutcome.failure(
              RuntimeMessages.operationFailed(
                error,
                eventId: 'repository.clone.failed',
                target: request.destinationPath,
              ),
            );
          }
        },
        affectedPaths: const [],
      ),
      precondition: precondition,
      validate: (expected) async {
        final current = await GitService.inspectCloneTarget(
          request.remoteUrl,
          request.destinationPath,
        );
        return compareBootstrapSnapshots(
          expected: expected.bootstrap!,
          actual: current,
        );
      },
      refreshPrecondition: () async => OperationPrecondition(
        bootstrap: await GitService.inspectCloneTarget(
          request.remoteUrl,
          request.destinationPath,
        ),
      ),
      logService: _log,
    );
    try {
      if (!mounted) return false;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => OperationPlanDialog(planHost: plan),
      );
      return plan.lastResult?.isSuccess == true;
    } finally {
      plan.dispose();
    }
  }

  Future<void> _openRepositoryPath(String path) async {
    if (!mounted) return;
    if (!await _ensureGitAvailable()) return;
    _log.detailEvent(
      'repository',
      'repository.open.started',
      details: {'path': path},
    );
    setState(() => _isOpening = true);
    try {
      final outcome = await _controller.openRepository(path);
      if (!mounted) return;
      _showOutcome(outcome);
      if (outcome.isSuccess) {
        _log.infoEvent(
          'repository',
          'repository.open.completed',
          details: {'path': _controller.repositoryPath ?? path},
        );
      } else {
        _log.errorEvent(
          'repository',
          'repository.open.failed',
          details: {'outcomeKey': outcome.message.key, 'path': path},
        );
      }
      if (outcome.isSuccess) {
        _explorerFocus.requestFocus();
      }
    } catch (error) {
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            RuntimeMessages.operationFailed(
              error.toString().replaceFirst('Unsupported operation: ', ''),
              eventId: 'repository.open.failed',
            ),
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
    if (!await _ensureGitAvailable()) return;
    if (!mounted) return;
    if (!await _confirmDiscardPendingPlan(
      context.l10n.tr('openingAnotherRepository'),
    )) {
      return;
    }
    _log.infoEvent('history', 'history.open', details: {'path': path});
    await _openRepositoryPath(path);
  }

  Future<bool> _ensureGitAvailable() async {
    if (_controller.isGitAvailable) return true;
    if (!mounted) return false;
    final recovered = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => GitRuntimeRecoveryDialog(
        runtimeManager: _controller.gitRuntime,
        externalLinks: _externalLinks,
      ),
    );
    return recovered == true || _controller.isGitAvailable;
  }

  Future<void> _recheckGitRuntime() async {
    final status = await _controller.refreshGitRuntime();
    if (!mounted) return;
    if (!status.isAvailable) {
      await showDialog<void>(
        context: context,
        builder: (context) => GitRuntimeRecoveryDialog(
          runtimeManager: _controller.gitRuntime,
          externalLinks: _externalLinks,
        ),
      );
    }
  }

  Future<void> _openGitDownload() async {
    try {
      await _externalLinks.openExternalUrl(AppInfo.gitForWindowsDownloadUrl);
    } catch (error) {
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            RuntimeMessages.messageFor(
              'unableToOpenTheGitDownloadPage',
              parameters: {'error': '$error'},
              eventId: 'ui.openGitDownload.failed',
            ),
          ),
        );
      }
    }
  }

  Future<void> _openProjectDirectory() async {
    final path = _controller.repositoryPath;
    if (path == null || path.isEmpty) {
      _showOutcome(
        OperationOutcome.failure(RuntimeMessages.messageFor('noProjectIsOpen')),
      );
      return;
    }
    try {
      await _folderPicker.openDirectory(path);
      _log.detailEvent(
        'ui',
        'ui.projectDirectory.opened',
        details: {'path': path},
      );
    } catch (error) {
      _log.errorEvent(
        'ui',
        'ui.projectDirectory.failed',
        details: {'path': path, 'error': '$error'},
      );
      if (mounted) {
        _showOutcome(
          OperationOutcome.failure(
            RuntimeMessages.messageFor(
              'unableToOpenProjectFolder',
              parameters: {
                'error': error.toString().replaceFirst(
                  'FileSystemException: ',
                  '',
                ),
              },
              eventId: 'ui.projectDirectory.failed',
            ),
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
    _log.detailEvent(
      'ui',
      'ui.outcome.presented',
      details: {
        'success': '${outcome.isSuccess}',
        'messageKey': outcome.message.key,
        'eventId': outcome.message.eventId,
      },
    );
    showAppOutcomeSnackBar(context, outcome, onViewLogs: _showLogs);
  }

  Future<void> _renameActiveSelection() async {
    final panel = _controller.panelFor(_controller.activeSide);
    if (panel.selectedPaths.isEmpty) {
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor('selectAnItemToRename'),
        ),
      );
      return;
    }
    if (panel.selectedPaths.length > 1) {
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor('selectExactlyOneItemToRename'),
        ),
      );
      return;
    }

    final path = panel.selectedPaths.single;
    final l10n = context.l10n;
    _log.detailEvent('ui', 'ui.renameDialog.opened', details: {'path': path});
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
            Text(l10n.tr('rename')),
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
                decoration: InputDecoration(labelText: l10n.tr('newName')),
                onSubmitted: (value) => Navigator.pop(context, value),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(
                  'thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation',
                ),
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.tr('cancel2')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, textController.text),
            child: Text(l10n.tr('addToPlan')),
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
      _showOutcome(
        OperationOutcome.failure(
          RuntimeMessages.messageFor('selectItemsToDelete'),
        ),
      );
      return;
    }
    final paths = panel.selectedPaths.toList(growable: false);
    final l10n = context.l10n;
    _log.detailEvent(
      'ui',
      'ui.deleteDialog.opened',
      details: {'paths': paths.join(' | ')},
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        final preview = paths.take(6).toList(growable: false);
        return AlertDialog(
          icon: Icon(Icons.delete_forever_outlined, color: colors.error),
          title: Text(
            l10n.tr('addDeletionOfItemsToThePlan', {'count': paths.length}),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr(
                      'filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns',
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
                              l10n.tr('andMore', {
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
              child: Text(l10n.tr('cancel2')),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              label: Text(l10n.tr('addDeletionToPlan')),
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
        ? l10n.tr('currentBranch')
        : _controller.branch;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_upload_outlined),
        title: Text(l10n.tr('addPushOfToThePlan', {'branch': branch})),
        content: SizedBox(
          width: 430,
          child: Text(
            l10n.tr(
              'nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded',
            ),
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.tr('cancel2')),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: Text(l10n.tr('addPushToPlan')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    _log.infoEvent('ui', 'ui.push.confirmed', details: {'branch': branch});
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
    _log.detailEvent('ui', 'ui.settingsDialog.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => SettingsDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showUpdates() async {
    _log.detailEvent('ui', 'ui.updateDialog.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => const UpdateDialog(),
    );
  }

  Future<void> _showLogs() async {
    _log.detailEvent('ui', 'ui.logViewer.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => const LogViewerDialog(),
    );
  }

  Future<void> _showUserGuide() async {
    _log.detailEvent('ui', 'ui.userGuide.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => const UserGuideDialog(),
    );
  }

  Future<void> _showRemotes() async {
    _log.detailEvent('ui', 'ui.remoteDialog.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => RemoteManagementDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showBranches() async {
    _log.detailEvent('ui', 'ui.branchDialog.opened');
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
      if (outcome.isSuccess) {
        await _showOperationPlan();
      }
    }
  }

  Future<void> _showStashes() async {
    _log.detailEvent('ui', 'ui.stashDialog.opened');
    await showDialog<void>(
      context: context,
      builder: (context) => StashManagementDialog(controller: _controller),
    );
    if (mounted) {
      _explorerFocus.requestFocus();
    }
  }

  Future<void> _showOperationPlan() async {
    _log.detailEvent(
      'ui',
      'ui.operationPlan.opened',
      details: {'count': '${_controller.pendingOperations.length}'},
    );
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => OperationPlanDialog(planHost: _controller),
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
          title: Text(l10n.tr('discardThePendingOperationPlan')),
          content: SizedBox(
            width: 460,
            child: Text(
              l10n.tr(
                'plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur',
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
              child: Text(l10n.tr('back')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: colors.error),
              child: Text(l10n.tr('discardPlanAndContinue')),
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
    if (!await _confirmDiscardPendingPlan(
      context.l10n.tr('closingTheRepository'),
    )) {
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
            ? OperationOutcome.success(
                RuntimeMessages.messageFor(
                  'repositoryViewRefreshed',
                  eventId: 'repository.refresh.succeeded',
                ),
              )
            : OperationOutcome.failure(
                RuntimeMessages.operationFailed(
                  _controller.fatalError!,
                  eventId: 'repository.refresh.failed',
                ),
              ),
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
      body: Column(
        children: [
          if (!_controller.isGitAvailable)
            _MissingGitBanner(
              checking: _controller.gitRuntimeStatus.isChecking,
              onDownload: _openGitDownload,
              onRecheck: _recheckGitRuntime,
            ),
          Expanded(
            child: _controller.hasRepository
                ? _buildRepositoryWorkspace(context)
                : StartView(
                    onOpenRepository: _openRepository,
                    onOpenEmptyFolder: _openEmptyFolder,
                    onCloneRepository: _cloneRepository,
                    isOpening: _isOpening || _controller.isBusy,
                    isGitAvailable: _controller.isGitAvailable,
                    recentRepositories: _controller.recentRepositories,
                    onOpenRecent: _openRecentRepository,
                    onRemoveRecent: _removeRecentRepository,
                    error: _controller.fatalError,
                  ),
          ),
        ],
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
            label: l10n.tr('open'),
            onTap: _openRepository,
          ),
          if (_controller.hasRepository)
            _TopBarButton(
              icon: Icons.folder_copy_outlined,
              label: l10n.tr('projectFolder'),
              onTap: _openProjectDirectory,
            ),
          if (_controller.hasRepository)
            _TopBarButton(
              icon: Icons.delete_forever_outlined,
              label: l10n.tr('gitMetadata'),
              onTap: _showGitMetadata,
            ),
          _TopBarButton(
            icon: Icons.system_update_alt_rounded,
            label: l10n.tr('updates'),
            onTap: () => _showUpdates(),
          ),
          _TopBarButton(
            icon: Icons.receipt_long_outlined,
            label: l10n.tr('logs'),
            onTap: _showLogs,
          ),
          _TopBarButton(
            icon: Icons.menu_book_outlined,
            label: l10n.tr('guide'),
            onTap: _showUserGuide,
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _showSettings,
            tooltip: l10n.tr('settings2'),
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
                        _controller.projectName ?? l10n.tr('gitRepository'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _InfoChip(
                      icon: Icons.account_tree_outlined,
                      label: _controller.branch.isEmpty
                          ? l10n.tr('noBranch')
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
            label: l10n.tr('projectSize'),
            value: size,
            icon: Icons.data_usage_rounded,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: l10n.tr('files'),
            value: '${stats?.fileCount ?? 0}',
            icon: Icons.insert_drive_file_outlined,
          ),
          const SizedBox(width: 9),
          _SummaryMetric(
            label: l10n.tr('pending2'),
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
              label: l10n.tr('cut'),
              shortcut: 'Ctrl X',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.cut),
            ),
            _OperationButton(
              icon: Icons.content_copy_rounded,
              label: l10n.tr('copy'),
              shortcut: 'Ctrl C',
              enabled: selectedCount > 0 && !_controller.isBusy,
              onTap: () => _handleClipboard(ClipboardMode.copy),
            ),
            _OperationButton(
              icon: Icons.content_paste_rounded,
              label: l10n.tr('paste'),
              shortcut: 'Ctrl V',
              enabled:
                  clipboard != null &&
                  !_controller.isBusy &&
                  !_controller.localOperationsLocked,
              onTap: _handlePaste,
            ),
            _OperationButton(
              icon: Icons.drive_file_rename_outline_rounded,
              label: l10n.tr('rename'),
              shortcut: 'F2',
              enabled:
                  selectedCount == 1 &&
                  !_controller.isBusy &&
                  !_controller.localOperationsLocked,
              onTap: _renameActiveSelection,
            ),
            _OperationButton(
              icon: Icons.delete_outline_rounded,
              label: l10n.tr('delete'),
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
                        ? l10n.tr('pasteToLeft')
                        : l10n.tr('pasteToRight'),
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
                    ? l10n.tr('selectFilesToCutOrCopy')
                    : l10n.tr('selected2', {'count': selectedCount}),
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            const SizedBox(width: 10),
            Tooltip(
              message: l10n.tr('reviewRemoveOrExecutePendingOperations'),
              child: OutlinedButton.icon(
                onPressed: _controller.isBusy ? null : _showOperationPlan,
                icon: Icon(
                  _controller.hasPendingOperations
                      ? Icons.playlist_add_check_circle_outlined
                      : Icons.playlist_add_rounded,
                  size: 16,
                ),
                label: Text(
                  l10n.tr('pending', {
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
              l10n.tr('doubleClickAFolderClickAPaneToChooseThePasteTarget'),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _refreshRepository,
              tooltip: l10n.tr('refreshRepositoryCtrlR'),
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
          l10n.tr(isCut ? 'clipboardPendingCut' : 'clipboardPendingCopy', {
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

class _MissingGitBanner extends StatelessWidget {
  const _MissingGitBanner({
    required this.checking,
    required this.onDownload,
    required this.onRecheck,
  });

  final bool checking;
  final VoidCallback onDownload;
  final VoidCallback onRecheck;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        border: Border(
          bottom: BorderSide(color: colors.error.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.tr('gitIsUnavailableRepositoryActionsAreDisabled'),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.onErrorContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: onDownload,
            child: Text(l10n.tr('downloadGit')),
          ),
          const SizedBox(width: 4),
          FilledButton.tonalIcon(
            onPressed: checking ? null : onRecheck,
            icon: checking
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              checking ? l10n.tr('checkingForGit') : l10n.tr('checkAgain'),
            ),
          ),
        ],
      ),
    );
  }
}
