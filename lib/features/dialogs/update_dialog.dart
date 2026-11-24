import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/changelog.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localized_message.dart';
import '../../core/localization/runtime_messages.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/update_installer_service.dart';
import '../../core/services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    this.showChangelogFirst = false,
    this.updateService,
    this.installerService,
  });

  final bool showChangelogFirst;
  final UpdateService? updateService;
  final UpdateInstallerService? installerService;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  late final UpdateService _service =
      widget.updateService ?? const UpdateService();
  late final UpdateInstallerService _installer =
      widget.installerService ?? UpdateInstallerService();
  UpdateCheckResult? _result;
  bool _isChecking = false;
  bool _isInstalling = false;
  bool _installFailed = false;
  double? _installPercent;
  LocalizedMessage? _installMessage;
  UpdateSource _source = UpdateSource.github;

  @override
  void initState() {
    super.initState();
    if (!widget.showChangelogFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final currentEntries = builtInChangelog.where(
      (entry) => entry.version == AppInfo.version,
    );
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      content: SizedBox(
        width: 680,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 590),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.12),
                        colors.primary.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          color: colors.onPrimary,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isInstalling
                                  ? l10n.tr('updatingAutomatically')
                                  : _isChecking
                                  ? l10n.tr('checkingForUpdates')
                                  : l10n.tr('updatesAndReleaseNotes'),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${AppInfo.englishName} · ${l10n.tr('currentV', {'version': AppInfo.version})}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isChecking || _isInstalling
                            ? null
                            : _checkForUpdates,
                        icon: _isChecking || _isInstalling
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          _isInstalling
                              ? l10n.tr('updating')
                              : _isChecking
                              ? l10n.tr('checking')
                              : l10n.tr('checkForUpdates'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.tr('updateSource'),
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SegmentedButton<UpdateSource>(
                            segments: [
                              ButtonSegment(
                                value: UpdateSource.github,
                                label: Text(l10n.tr('github')),
                                icon: const Icon(Icons.code_rounded, size: 16),
                              ),
                              ButtonSegment(
                                value: UpdateSource.gitee,
                                label: Text(l10n.tr('gitee')),
                                icon: const Icon(
                                  Icons.cloud_outlined,
                                  size: 16,
                                ),
                              ),
                            ],
                            selected: {_source},
                            showSelectedIcon: false,
                            onSelectionChanged: _isChecking || _isInstalling
                                ? null
                                : (selected) {
                                    setState(() {
                                      _source = selected.first;
                                      _result = null;
                                    });
                                    _checkForUpdates();
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _source == UpdateSource.gitee
                            ? l10n.tr(
                                'theGiteeSourceIsSuitedToMainlandChinaNetworks',
                              )
                            : l10n.tr(
                                'githubUsuallyProvidesTheInternationalReleaseBuild',
                              ),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_result != null) ...[
                        _buildResult(context, _result!),
                        const SizedBox(height: 18),
                      ],
                      if (_installMessage != null) ...[
                        _buildInstallProgress(context),
                        const SizedBox(height: 18),
                      ],
                      _SectionTitle(
                        icon: Icons.auto_awesome_rounded,
                        title: l10n.tr('currentReleaseHighlights'),
                      ),
                      const SizedBox(height: 9),
                      ...currentEntries.map(_buildChangelogCard),
                      if (_result?.releaseNotes.isNotEmpty == true) ...[
                        const SizedBox(height: 18),
                        _SectionTitle(
                          icon: Icons.receipt_long_outlined,
                          title: l10n.tr('onlineReleaseNotes'),
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: SelectableText(
                            _result!.releaseNotes,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        l10n.tr(
                          'automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved',
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _isInstalling
              ? null
              : () => _service.openExternalUrl(
                  _source == UpdateSource.gitee
                      ? AppInfo.giteeRepositoryUrl
                      : AppInfo.repositoryUrl,
                ),
          icon: const Icon(Icons.code_rounded, size: 16),
          label: Text(l10n.tr('openRepository2')),
        ),
        if (_result?.releaseUrl.isNotEmpty == true)
          TextButton.icon(
            onPressed: _isInstalling
                ? null
                : () => _service.openExternalUrl(_result!.releaseUrl),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(l10n.tr('openReleasePage')),
          ),
        if (_result?.status == UpdateCheckStatus.updateAvailable)
          FilledButton.icon(
            onPressed: _isInstalling ? null : _installUpdate,
            icon: _isInstalling
                ? SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.rocket_launch_outlined, size: 17),
            label: Text(
              _isInstalling
                  ? l10n.tr('installing')
                  : l10n.tr('updateAndRestartNow'),
            ),
          ),
        TextButton(
          onPressed: _isInstalling ? null : () => Navigator.pop(context),
          child: Text(l10n.tr('close')),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, UpdateCheckResult result) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final (title, message, icon, color) = switch (result.status) {
      UpdateCheckStatus.updateAvailable => (
        l10n.tr('versionVIsAvailable', {'version': result.latestVersion}),
        result.releaseName.isEmpty
            ? result.message.resolve(l10n)
            : result.releaseName,
        Icons.new_releases_rounded,
        colors.primary,
      ),
      UpdateCheckStatus.upToDate => (
        l10n.tr('youAreUpToDate'),
        result.message.resolve(l10n),
        Icons.check_circle_outline_rounded,
        colors.primary,
      ),
      UpdateCheckStatus.unavailable => (
        l10n.tr('unableToRetrieveTheOnlineVersion'),
        result.message.resolve(l10n),
        Icons.cloud_off_outlined,
        colors.tertiary,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
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

  Widget _buildInstallProgress(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final color = _installFailed ? colors.error : colors.primary;
    final percent = _installPercent;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                _installFailed
                    ? Icons.error_outline_rounded
                    : Icons.system_update_alt_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _installMessage?.resolve(l10n) ?? l10n.tr('preparingUpdate'),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (percent != null && !_installFailed)
                Text(
                  '${(percent * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (!_installFailed) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: percent,
              minHeight: 4,
              borderRadius: BorderRadius.circular(99),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChangelogCard(ChangelogEntry entry) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'v${entry.version}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.date,
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            entry.titleKey.isEmpty
                ? entry.title
                : context.l10n.tr(entry.titleKey),
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: colors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...entry.items.indexed.map(
            (indexedItem) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      indexedItem.$1 < entry.itemKeys.length
                          ? context.l10n.tr(entry.itemKeys[indexedItem.$1])
                          : indexedItem.$2,
                      style: const TextStyle(fontSize: 12, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isChecking = true;
      _installFailed = false;
      _installMessage = null;
      _installPercent = null;
    });
    final result = await _service.checkForUpdates(source: _source);
    if (!mounted) return;
    setState(() {
      _result = result;
      _isChecking = false;
    });
  }

  Future<void> _installUpdate() async {
    final release = _result;
    if (release == null || _isInstalling) return;
    setState(() {
      _isInstalling = true;
      _installFailed = false;
      _installPercent = 0;
      _installMessage = RuntimeMessages.messageFor('updateProgressPreparing');
    });
    final outcome = await _installer.install(
      release,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _installPercent = progress.percent ?? _installPercent;
          _installMessage = progress.message;
        });
      },
    );
    if (!mounted) return;
    if (!outcome.success) {
      setState(() {
        _isInstalling = false;
        _installFailed = true;
        _installMessage = outcome.message;
      });
      return;
    }
    setState(() {
      _installPercent = 1;
      _installMessage = outcome.message;
    });
    await AppLogService.instance.flush();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    exit(0);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
