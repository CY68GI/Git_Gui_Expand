import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/external_link_service.dart';
import '../../core/services/git_runtime_service.dart';

class GitRuntimeRecoveryDialog extends StatefulWidget {
  const GitRuntimeRecoveryDialog({
    super.key,
    required this.runtimeManager,
    this.externalLinks,
  });

  final GitRuntimeManager runtimeManager;
  final ExternalLinkService? externalLinks;

  @override
  State<GitRuntimeRecoveryDialog> createState() =>
      _GitRuntimeRecoveryDialogState();
}

class _GitRuntimeRecoveryDialogState extends State<GitRuntimeRecoveryDialog> {
  late final ExternalLinkService _links =
      widget.externalLinks ?? ExternalLinkService();
  bool _checking = false;
  bool _openingDownload = false;
  String? _lastError;

  Future<void> _recheck() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _lastError = null;
    });
    try {
      final status = await widget.runtimeManager.refresh();
      if (!mounted) return;
      if (status.isAvailable) {
        Navigator.pop(context, true);
        return;
      }
      setState(() => _lastError = status.error);
    } catch (error) {
      if (mounted) setState(() => _lastError = error.toString());
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _downloadGit() async {
    if (_openingDownload) return;
    setState(() => _openingDownload = true);
    try {
      await _links.openExternalUrl(AppInfo.gitForWindowsDownloadUrl);
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
    } finally {
      if (mounted) setState(() => _openingDownload = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final error = _lastError ?? widget.runtimeManager.status.error;
    return AlertDialog(
      icon: Icon(Icons.developer_mode_rounded, color: colors.error, size: 30),
      title: Text(l10n.tr('gitNotDetected')),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tr(
                'gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain',
              ),
              style: const TextStyle(fontSize: 13, height: 1.55),
            ),
            if (error != null && error.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: SelectableText(
                  l10n.tr('detectionDetails', {'error': error.trim()}),
                  maxLines: 6,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _checking ? null : () => Navigator.pop(context, false),
          child: Text(l10n.tr('close')),
        ),
        OutlinedButton.icon(
          onPressed: _openingDownload ? null : _downloadGit,
          icon: const Icon(Icons.download_rounded, size: 17),
          label: Text(l10n.tr('downloadGit')),
        ),
        FilledButton.icon(
          onPressed: _checking ? null : _recheck,
          icon: _checking
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh_rounded, size: 17),
          label: Text(
            _checking ? l10n.tr('checkingForGit') : l10n.tr('checkAgain'),
          ),
        ),
      ],
    );
  }
}
