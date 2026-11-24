import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/bundled_font.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/services/desktop_shortcut_service.dart';
import '../../core/services/executable_version_service.dart';
import '../../core/services/external_link_service.dart';
import '../../core/services/font_catalog_service.dart';
import '../../core/services/git_runtime_service.dart';
import '../../core/services/git_environment_service.dart';
import '../../core/services/update_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/size_formatter.dart';
import '../repository/repository_controller.dart';
import 'installation_cleanup_dialog.dart';

enum SettingsSection { font, language, appearance, units, git, about }

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.controller,
    this.fontCatalogService,
    this.desktopShortcutService,
    this.versionInfoService,
    this.initialSection = SettingsSection.font,
    this.gitPathService,
  });

  final RepositoryController controller;
  final FontCatalogService? fontCatalogService;
  final DesktopShortcutService? desktopShortcutService;
  final ExecutableVersionService? versionInfoService;
  final SettingsSection initialSection;
  final GitPathIntegrationService? gitPathService;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _draft = widget.controller.settings;
  late final FontCatalogService _fontCatalog =
      widget.fontCatalogService ?? FontCatalogService();
  late final DesktopShortcutService _desktopShortcuts =
      widget.desktopShortcutService ?? const DesktopShortcutService();
  late final ExecutableVersionService _versionInfo =
      widget.versionInfoService ?? const ExecutableVersionService();
  final UpdateService _externalLinks = const UpdateService();
  final ExternalLinkService _gitLinks = ExternalLinkService();
  late final GitPathIntegrationService _gitPaths =
      widget.gitPathService ?? GitPathIntegrationService();
  final TextEditingController _fontSearchController = TextEditingController();
  List<String> _fontFamilies = const [];
  bool _loadingFonts = true;
  ExecutableVersionInfo? _executableVersions;
  bool _versionsRequested = false;
  bool _saving = false;
  bool _creatingShortcut = false;
  bool _checkingGit = false;
  late SettingsSection _section;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
    _loadFonts();
  }

  @override
  void dispose() {
    _fontSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadFonts() async {
    final fonts = await _fontCatalog.loadInstalledFonts();
    if (!mounted) return;
    setState(() {
      _fontFamilies = fonts;
      _loadingFonts = false;
    });
  }

  Future<void> _loadExecutableVersions() async {
    final versions = await _versionInfo.load();
    if (!mounted) return;
    setState(() => _executableVersions = versions);
  }

  String _fontQuery = '';

  List<BundledFontOption> get _filteredBundledFonts {
    final query = _fontQuery.trim().toLowerCase();
    if (query.isEmpty) return bundledUiFonts;
    return bundledUiFonts
        .where(
          (font) =>
              font.label.toLowerCase().contains(query) ||
              font.family.toLowerCase().contains(query) ||
              font.description.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  List<String> get _filteredSystemFonts {
    final bundledFamilies = bundledUiFonts
        .map((font) => font.family.toLowerCase())
        .toSet();
    final query = _fontQuery.trim().toLowerCase();
    final filtered = _fontFamilies
        .where(
          (font) =>
              !bundledFamilies.contains(font.toLowerCase()) &&
              (query.isEmpty || font.toLowerCase().contains(query)),
        )
        .toList(growable: false);
    if (_draft.fontFamily.isNotEmpty &&
        !bundledFamilies.contains(_draft.fontFamily.toLowerCase()) &&
        !filtered.contains(_draft.fontFamily)) {
      return [_draft.fontFamily, ...filtered];
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(28),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1000,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 19,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text(
                    context.l10n.tr('settings2'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    tooltip: context.l10n.tr('close'),
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 190,
                    color: colors.surfaceContainerLow.withValues(alpha: 0.6),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsNavItem(
                          icon: Icons.font_download_outlined,
                          label: context.l10n.tr('font'),
                          selected: _section == SettingsSection.font,
                          onTap: () => _selectSection(SettingsSection.font),
                        ),
                        _SettingsNavItem(
                          icon: Icons.translate_rounded,
                          label: context.l10n.tr('language'),
                          selected: _section == SettingsSection.language,
                          onTap: () => _selectSection(SettingsSection.language),
                        ),
                        _SettingsNavItem(
                          icon: Icons.brightness_6_outlined,
                          label: context.l10n.tr('appearanceSettings'),
                          selected: _section == SettingsSection.appearance,
                          onTap: () =>
                              _selectSection(SettingsSection.appearance),
                        ),
                        _SettingsNavItem(
                          icon: Icons.straighten_rounded,
                          label: context.l10n.tr('units'),
                          selected: _section == SettingsSection.units,
                          onTap: () => _selectSection(SettingsSection.units),
                        ),
                        _SettingsNavItem(
                          icon: Icons.terminal_rounded,
                          label: context.l10n.tr('git'),
                          selected: _section == SettingsSection.git,
                          onTap: () => _selectSection(SettingsSection.git),
                        ),
                        _SettingsNavItem(
                          icon: Icons.info_outline_rounded,
                          label: context.l10n.tr('about'),
                          selected: _section == SettingsSection.about,
                          onTap: () => _selectSection(SettingsSection.about),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Git GUI Expand\nv${AppInfo.version}',
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: KeyedSubtree(
                              key: ValueKey(_section),
                              child: _buildSection(context),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            border: Border(
                              top: BorderSide(color: colors.outlineVariant),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _section == SettingsSection.about
                                    ? context.l10n.tr(
                                        'aboutInformationDoesNotChangeSettings',
                                      )
                                    : context.l10n.tr(
                                        'changesApplyAfterSaving',
                                      ),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(context.l10n.tr('cancel2')),
                              ),
                              const SizedBox(width: 4),
                              FilledButton.icon(
                                onPressed: _saving ? null : _save,
                                icon: _saving
                                    ? SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: colors.onPrimary,
                                        ),
                                      )
                                    : const Icon(Icons.check_rounded, size: 17),
                                label: Text(context.l10n.tr('saveSettings2')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context) {
    return switch (_section) {
      SettingsSection.font => _buildFontPage(context),
      SettingsSection.language => _buildLanguagePage(context),
      SettingsSection.appearance => _buildAppearancePage(context),
      SettingsSection.units => _buildUnitsPage(context),
      SettingsSection.git => _buildGitPage(context),
      SettingsSection.about => _buildAboutPage(context),
    };
  }

  Future<void> _recheckGit() async {
    if (_checkingGit) return;
    setState(() => _checkingGit = true);
    try {
      await widget.controller.refreshGitRuntime();
    } finally {
      if (mounted) setState(() => _checkingGit = false);
    }
  }

  Future<void> _downloadGit() async {
    try {
      await _gitLinks.openExternalUrl(AppInfo.gitForWindowsDownloadUrl);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.tr('unableToOpenTheGitDownloadPage', {
                  'error': error.toString(),
                }),
              ),
              showCloseIcon: true,
            ),
          );
      }
    }
  }

  Future<void> _changeGitPath(GitPathScope scope, {required bool add}) async {
    final l10n = context.l10n;
    final scopeLabel = l10n.tr(
      scope == GitPathScope.user ? 'userPath' : 'systemPath',
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          scope == GitPathScope.system
              ? Icons.admin_panel_settings_outlined
              : Icons.account_circle_outlined,
        ),
        title: Text(
          l10n.tr(add ? 'addPortableGitTo' : 'removePortableGitFrom', {
            'scope': scopeLabel,
          }),
        ),
        content: SizedBox(
          width: 460,
          child: Text(
            scope == GitPathScope.system
                ? l10n.tr(
                    'changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing',
                  )
                : l10n.tr(
                    'onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath',
                  ),
            style: const TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.tr('cancel2')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.tr(add ? 'confirmAdd' : 'confirmRemove')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final result = add
        ? await _gitPaths.add(scope)
        : await _gitPaths.remove(scope);
    if (!mounted) return;
    final message = switch (result.action) {
      GitPathAction.added => l10n.tr('updated', {'scope': scopeLabel}),
      GitPathAction.removed => l10n.tr('updated', {'scope': scopeLabel}),
      GitPathAction.alreadyPresent => l10n.tr('alreadyContainsPortablegit', {
        'scope': scopeLabel,
      }),
      GitPathAction.notPresent => l10n.tr(
        'doesNotContainTheManagedPortablegitPath',
        {'scope': scopeLabel},
      ),
      GitPathAction.cancelled => l10n.tr('pathChangeCancelled'),
      GitPathAction.failed => l10n.tr('pathChangeFailed', {
        'error': result.error ?? '',
      }),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          showCloseIcon: true,
          backgroundColor: result.isSuccess ? null : colorsForFailure(context),
        ),
      );
  }

  Color colorsForFailure(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  Widget _buildGitPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final status = widget.controller.gitRuntimeStatus;
    final available = status.isAvailable;
    final sourceLabel = switch (status.source) {
      GitRuntimeSource.system => l10n.tr('systemGit'),
      GitRuntimeSource.bundled => l10n.tr('bundledPortablegit'),
      null => l10n.tr('notDetected'),
    };
    return _SettingsPage(
      title: l10n.tr('gitSettings'),
      subtitle: l10n.tr(
        'detectTheGitRuntimeVersionSourceAndExecutableLocation',
      ),
      children: [
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: (available ? colors.primary : colors.error)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      available
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      color: available ? colors.primary : colors.error,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr(
                            available ? 'gitAvailable' : 'gitUnavailable',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          status.isChecking || _checkingGit
                              ? l10n.tr('checkingForGit')
                              : available
                              ? l10n.tr(
                                  'repositoryAndRemoteOperationsAreAvailable',
                                )
                              : l10n.tr(
                                  'noUsableGitWasDetectedInstallItAndCheckAgain',
                                ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: _checkingGit || status.isChecking
                        ? null
                        : _recheckGit,
                    icon: _checkingGit || status.isChecking
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded, size: 17),
                    label: Text(l10n.tr('checkAgain')),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _GitDetailRow(
                label: l10n.tr('gitVersion'),
                value: status.version.isEmpty ? '—' : status.version,
              ),
              _GitDetailRow(label: l10n.tr('gitSource'), value: sourceLabel),
              _GitDetailRow(
                label: l10n.tr('gitExecutableLocation'),
                value: status.executablePath.isEmpty
                    ? '—'
                    : status.executablePath,
                selectable: true,
              ),
              _GitDetailRow(
                label: l10n.tr('lastChecked'),
                value: status.checkedAt == null
                    ? l10n.tr('notCheckedYet')
                    : status.checkedAt!.toLocal().toString(),
              ),
              if (!available) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    l10n.tr(
                      'gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain',
                    ),
                    style: const TextStyle(fontSize: 11.5, height: 1.5),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _downloadGit,
                    icon: const Icon(Icons.download_rounded, size: 17),
                    label: Text(l10n.tr('downloadGit')),
                  ),
                ),
              ],
              if (status.isBundled) ...[
                const SizedBox(height: 16),
                Divider(color: colors.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  l10n.tr('addGitToPath'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l10n.tr(
                    'chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup',
                  ),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: () =>
                          _changeGitPath(GitPathScope.user, add: true),
                      child: Text(l10n.tr('addToUserPath')),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          _changeGitPath(GitPathScope.system, add: true),
                      child: Text(l10n.tr('addToSystemPath')),
                    ),
                    TextButton(
                      onPressed: () =>
                          _changeGitPath(GitPathScope.user, add: false),
                      child: Text(l10n.tr('removeFromUserPath')),
                    ),
                    TextButton(
                      onPressed: () =>
                          _changeGitPath(GitPathScope.system, add: false),
                      child: Text(l10n.tr('removeFromSystemPath')),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagePage(BuildContext context) {
    final l10n = context.l10n;
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _SettingsPage(
      title: l10n.tr('language2'),
      subtitle: l10n.tr(
        'chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem',
      ),
      children: [
        _SectionLabel(
          title: l10n.tr('interfaceLanguage'),
          caption: l10n.tr(
            'theLanguageChangeTakesEffectImmediatelyAfterSaving',
          ),
        ),
        const SizedBox(height: 12),
        for (final preference in AppLanguagePreference.values) ...[
          _LanguageOptionCard(
            preference: preference,
            systemLocale: systemLocale,
            selected: _draft.languagePreference == preference,
            onTap: () {
              setState(() {
                _draft = _draft.copyWith(languagePreference: preference);
              });
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildFontPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final bundledFonts = _filteredBundledFonts;
    final systemFonts = _filteredSystemFonts;
    final resultCount = bundledFonts.length + systemFonts.length + 1;
    return _SettingsPage(
      title: l10n.tr('font'),
      subtitle: l10n.tr(
        'byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts',
      ),
      children: [
        _SettingsScrollHint(
          title: l10n.tr('moreContentBelow'),
          message: l10n.tr('scrollDownForFontPreviewAndFontSizeSettings'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _fontSearchController,
          onChanged: (value) => setState(() => _fontQuery = value),
          decoration: InputDecoration(
            hintText: l10n.tr('searchFontNameOrPurposeEGInterOrNoto'),
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: _fontQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.tr('clearSearch'),
                    onPressed: () {
                      _fontSearchController.clear();
                      setState(() => _fontQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 17),
                  ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Text(
              l10n.tr('optionsFound', {'count': resultCount}),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            if (_loadingFonts)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                l10n.tr('typeANameToFilter'),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: [
              _FontGroupHeader(
                icon: Icons.inventory_2_outlined,
                label: l10n.tr('bundledUiFonts'),
                count: bundledFonts.length,
              ),
              if (bundledFonts.isEmpty)
                _FontEmptyRow(label: l10n.tr('noBundledFontMatches'))
              else
                for (final font in bundledFonts)
                  _BundledFontRow(
                    font: font,
                    selected: _draft.fontFamily == font.family,
                    onTap: () {
                      setState(() {
                        _draft = _draft.copyWith(fontFamily: font.family);
                      });
                    },
                  ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Divider(height: 1),
              ),
              _FontGroupHeader(
                icon: Icons.computer_rounded,
                label: l10n.tr('systemFonts'),
                count: systemFonts.length + 1,
              ),
              _SystemFontRow(
                label: l10n.tr('systemDefaultAutomatic'),
                detail: l10n.tr('followTheOperatingSystemWithoutAFixedFamily'),
                fontFamily: null,
                selected: _draft.fontFamily.isEmpty,
                onTap: () {
                  setState(() {
                    _draft = _draft.copyWith(fontFamily: '');
                  });
                },
              ),
              if (systemFonts.isEmpty)
                _FontEmptyRow(label: l10n.tr('noSystemFontMatches'))
              else
                for (final font in systemFonts)
                  _SystemFontRow(
                    label: font,
                    detail: l10n.tr('installedSystemFont'),
                    fontFamily: font,
                    selected: _draft.fontFamily == font,
                    onTap: () {
                      setState(() {
                        _draft = _draft.copyWith(fontFamily: font);
                      });
                    },
                  ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.tr('bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense'),
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        _SectionLabel(
          title: l10n.tr('fontPreview'),
          caption: l10n.tr(
            'theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes',
          ),
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('gitGuiExpandFileCommit'),
                style: TextStyle(
                  fontFamily: _draft.fontFamily.isEmpty
                      ? null
                      : _draft.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                l10n.tr('cutCopyRenamePushAndCommit0123456789'),
                style: TextStyle(
                  fontFamily: _draft.fontFamily.isEmpty
                      ? null
                      : _draft.fontFamily,
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(
          title: l10n.tr('fontSize'),
          caption: l10n.tr(
            'threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge',
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<double>(
            segments: const [
              ButtonSegment(
                value: AppSettings.minFontScale,
                label: Text('90%'),
                icon: Icon(Icons.text_decrease_rounded, size: 17),
              ),
              ButtonSegment(
                value: AppSettings.defaultFontScale,
                label: Text('100%'),
                icon: Icon(Icons.text_fields_rounded, size: 17),
              ),
              ButtonSegment(
                value: AppSettings.maxFontScale,
                label: Text('110%'),
                icon: Icon(Icons.text_increase_rounded, size: 17),
              ),
            ],
            selected: {_draft.fontScale},
            onSelectionChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(fontScale: value.first);
              });
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tr('allowedRange', {
            'min': (AppSettings.minFontScale * 100).round(),
            'max': (AppSettings.maxFontScale * 100).round(),
          }),
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAppearancePage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return _SettingsPage(
      title: l10n.tr('appearanceSettings'),
      subtitle: l10n.tr(
        'chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors',
      ),
      children: [
        _SectionLabel(
          title: l10n.tr('displayMode'),
          caption: l10n.tr(
            'followSystemSwitchesWithTheDeviceLightOrDarkAppearance',
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppThemePreference>(
            segments: [
              ButtonSegment(
                value: AppThemePreference.system,
                label: Text(l10n.tr('followSystem')),
                icon: const Icon(Icons.brightness_auto_rounded, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.light,
                label: Text(l10n.tr('light')),
                icon: const Icon(Icons.light_mode_outlined, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                label: Text(l10n.tr('dark')),
                icon: const Icon(Icons.dark_mode_outlined, size: 18),
              ),
            ],
            selected: {_draft.themePreference},
            onSelectionChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(themePreference: value.first);
              });
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 20),
        _SettingsCard(
          child: Row(
            children: [
              _ThemeSwatch(
                icon: Icons.light_mode_rounded,
                label: l10n.tr('light'),
                background: Colors.white,
                foreground: const Color(0xFF17211E),
                border: const Color(0xFFDDE4E0),
              ),
              const SizedBox(width: 12),
              _ThemeSwatch(
                icon: Icons.dark_mode_rounded,
                label: l10n.tr('dark'),
                background: const Color(0xFF171E1B),
                foreground: const Color(0xFFE8EFEA),
                border: const Color(0xFF33413B),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.tr('currentSelection', {
                    'theme': _themeLabel(l10n, _draft.themePreference),
                  }),
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(
          title: l10n.tr('colorScheme'),
          caption: l10n.tr(
            'theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText',
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final preference in AppColorSchemePreference.values)
              _ColorSchemeOption(
                preference: preference,
                label: _colorSchemeLabel(l10n, preference),
                selected: _draft.colorSchemePreference == preference,
                onTap: () {
                  setState(() {
                    _draft = _draft.copyWith(colorSchemePreference: preference);
                  });
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitsPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final dataPath = const AppStorageService().dataDirectory.path;
    return _SettingsPage(
      title: l10n.tr('units'),
      subtitle: l10n.tr('controlHowProjectAndIndividualFileSizesAreDisplayed'),
      children: [
        _SectionLabel(
          title: l10n.tr('sizeUnitSystem'),
          caption: l10n.tr('binaryUses1024StepsDecimalUses1000'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SizeUnitSystem>(
            segments: [
              ButtonSegment(
                value: SizeUnitSystem.binary,
                label: Text(l10n.tr('iecBinary')),
                icon: const Icon(Icons.memory_rounded, size: 17),
              ),
              ButtonSegment(
                value: SizeUnitSystem.decimal,
                label: Text(l10n.tr('siDecimal')),
                icon: const Icon(Icons.straighten_rounded, size: 17),
              ),
            ],
            selected: {_draft.unitSystem},
            onSelectionChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(unitSystem: value.first);
              });
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 22),
        _SectionLabel(
          title: l10n.tr('baseUnit'),
          caption: l10n.tr('byteDisplaysBKibOrKbBitIsMultipliedBy8First'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SizeBaseUnit>(
            segments: [
              ButtonSegment(
                value: SizeBaseUnit.byte,
                label: Text(l10n.tr('byteB')),
              ),
              ButtonSegment(
                value: SizeBaseUnit.bit,
                label: Text(l10n.tr('bitB')),
              ),
            ],
            selected: {_draft.baseUnit},
            onSelectionChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(baseUnit: value.first);
              });
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 22),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    l10n.tr('unitPreview'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  _PreviewValue(
                    label: l10n.tr('smallFile'),
                    value: formatFileSize(1536, _draft),
                  ),
                  _PreviewValue(
                    label: l10n.tr('mediumFile'),
                    value: formatFileSize(1572864, _draft),
                  ),
                  _PreviewValue(
                    label: l10n.tr('largeFile'),
                    value: formatFileSize(1610612736, _draft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(sizeUnitDescription(_draft)),
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.tr('settingsDataDirectory'),
          style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        SelectableText(
          dataPath,
          style: TextStyle(fontSize: 11, color: colors.primary),
        ),
      ],
    );
  }

  Widget _buildAboutPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return _SettingsPage(
      title: l10n.tr('about'),
      subtitle: l10n.tr('aWindowsFirstFlutterGraphicalFileWorkspaceForGit'),
      children: [
        _SettingsCard(
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppInfo.englishName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.tr('versionV', {'version': AppInfo.version}),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          l10n.tr(
                            'browseMoveCopyDeleteCommitAndPushThroughTheGitCli',
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _externalLinks.openExternalUrl(AppInfo.repositoryUrl),
                    icon: const Icon(Icons.code_rounded, size: 16),
                    label: Text(l10n.tr('openRepository2')),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: colors.outlineVariant),
              const SizedBox(height: 12),
              _ExecutableVersionRow(
                name: 'git_gui_expand',
                version:
                    _executableVersions?.applicationVersion ??
                    '${AppInfo.version}+…',
                path: _executableVersions?.applicationPath ?? '',
              ),
              const SizedBox(height: 8),
              _ExecutableVersionRow(
                name: 'GitGuiExpandLauncher',
                version: (_executableVersions?.launcherVersion ?? '').isEmpty
                    ? l10n.tr('versionNotFoundOrUnreadable')
                    : _executableVersions!.launcherVersion,
                path: _executableVersions?.launcherPath ?? '',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('desktopShortcut'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.tr(
                  'createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher',
                ),
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 11),
              Wrap(
                spacing: 9,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    onPressed: _creatingShortcut
                        ? null
                        : _createDesktopShortcut,
                    icon: _creatingShortcut
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_to_drive_rounded, size: 17),
                    label: Text(
                      l10n.tr(
                        _creatingShortcut
                            ? 'creatingShortcut'
                            : 'oneClickSendToDesktop',
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openInstallationCleanup,
                    icon: const Icon(
                      Icons.cleaning_services_outlined,
                      size: 17,
                    ),
                    label: Text(l10n.tr('scanOldVersionsAndInstallers')),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.tr('acknowledgements'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(
                  'thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject',
                ),
                style: const TextStyle(fontSize: 11.5, height: 1.65),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _AboutTag(label: 'Flutter'),
                  _AboutTag(label: 'Dart'),
                  _AboutTag(label: 'Git CLI'),
                  _AboutTag(label: 'Windows'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.tr('thisProjectIsLicensedUnderTheMitLicense'),
          style: TextStyle(
            fontSize: 11.5,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemePreference preference) {
    final label = switch (preference) {
      AppThemePreference.system => 'followSystem',
      AppThemePreference.light => 'light',
      AppThemePreference.dark => 'dark',
    };
    return l10n.tr(label);
  }

  String _colorSchemeLabel(
    AppLocalizations l10n,
    AppColorSchemePreference preference,
  ) {
    final label = switch (preference) {
      AppColorSchemePreference.emerald => 'classicGreen',
      AppColorSchemePreference.ocean => 'oceanBlue',
      AppColorSchemePreference.violet => 'starryViolet',
      AppColorSchemePreference.amber => 'amberGold',
      AppColorSchemePreference.rose => 'roseRed',
    };
    return l10n.tr(label);
  }

  void _selectSection(SettingsSection section) {
    if (_section == section) return;
    setState(() => _section = section);
    if (section == SettingsSection.about && !_versionsRequested) {
      _versionsRequested = true;
      _loadExecutableVersions();
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    AppLogService.instance.setLocale(
      AppLocalizations.localeForPreference(_draft.languagePreference),
    );
    final outcome = await widget.controller.updateSettings(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (outcome.isSuccess) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outcome.message.resolve(context.l10n)),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _createDesktopShortcut() async {
    setState(() => _creatingShortcut = true);
    final result = await _desktopShortcuts.create();
    if (!mounted) return;
    setState(() => _creatingShortcut = false);
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message.resolve(context.l10n)),
        backgroundColor: result.isSuccess ? colors.primary : colors.error,
        closeIconColor: result.isSuccess ? colors.onPrimary : colors.onError,
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
      ),
    );
  }

  Future<void> _openInstallationCleanup() async {
    await showDialog<void>(
      context: context,
      builder: (context) => const InstallationCleanupDialog(),
    );
  }
}

class _FontGroupHeader extends StatelessWidget {
  const _FontGroupHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BundledFontRow extends StatelessWidget {
  const _BundledFontRow({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final BundledFontOption font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      fontFamily: font.family,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              font.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: font.family,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.tr('bundledLabel'),
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.tr(_fontDescriptionKey(font.family)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _fontDescriptionKey(String family) {
    return switch (family) {
      'Inter UI' => 'interUiDescription',
      'Noto Sans SC' => 'notoSansScDescription',
      'IBM Plex Sans' => 'ibmPlexSansDescription',
      _ => 'fontDescription',
    };
  }
}

class _SystemFontRow extends StatelessWidget {
  const _SystemFontRow({
    required this.label,
    required this.detail,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final String? fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 17, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontEmptyRow extends StatelessWidget {
  const _FontEmptyRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}

class _SettingsScrollHint extends StatelessWidget {
  const _SettingsScrollHint({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.keyboard_double_arrow_down_rounded,
            size: 21,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
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

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.preference,
    required this.systemLocale,
    required this.selected,
    required this.onTap,
  });

  final AppLanguagePreference preference;
  final Locale systemLocale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surfaceContainerLow.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  preference == AppLanguagePreference.system
                      ? Icons.computer_rounded
                      : Icons.language_rounded,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.languageOptionLabel(
                        preference,
                        systemLocale: systemLocale,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.languageOptionDescription(
                        preference,
                        systemLocale: systemLocale,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  const _SettingsNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: selected ? colors.primary : colors.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          caption,
          style: TextStyle(
            fontSize: 11.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PreviewValue extends StatelessWidget {
  const _PreviewValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorSchemeOption extends StatelessWidget {
  const _ColorSchemeOption({
    required this.preference,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final AppColorSchemePreference preference;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = AppTheme.palette(preference);
    final accent = dark ? palette.darkAccent : palette.lightSeed;
    return SizedBox(
      width: 162,
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.1)
            : colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(Icons.palette_outlined, size: 19, color: accent),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: selected ? colors.primary : colors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutTag extends StatelessWidget {
  const _AboutTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GitDetailRow extends StatelessWidget {
  const _GitDetailRow({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final valueStyle = TextStyle(
      fontSize: 12,
      height: 1.45,
      color: colors.onSurface,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: selectable
                ? SelectableText(value, style: valueStyle)
                : Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }
}

class _ExecutableVersionRow extends StatelessWidget {
  const _ExecutableVersionRow({
    required this.name,
    required this.version,
    required this.path,
  });

  final String name;
  final String version;
  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          name == 'git_gui_expand'
              ? Icons.terminal_rounded
              : Icons.launch_rounded,
          size: 17,
          color: colors.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (path.isNotEmpty)
                Text(
                  path,
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
        const SizedBox(width: 10),
        SelectableText(
          version,
          style: TextStyle(
            color: colors.primary,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
