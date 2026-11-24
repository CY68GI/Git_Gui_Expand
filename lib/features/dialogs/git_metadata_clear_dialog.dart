import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../repository/repository_controller.dart';

class GitMetadataClearDialog extends StatefulWidget {
  const GitMetadataClearDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<GitMetadataClearDialog> createState() => _GitMetadataClearDialogState();
}

class _GitMetadataClearDialogState extends State<GitMetadataClearDialog> {
  GitMetadataClearInspection? _inspection;
  bool _loading = true;
  bool _clearing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _inspect();
  }

  Future<void> _inspect() async {
    setState(() => _loading = true);
    final inspection = await widget.controller.inspectGitMetadataForClear();
    if (!mounted) return;
    setState(() {
      _inspection = inspection;
      _loading = false;
    });
  }

  Future<void> _clear() async {
    if (_clearing) return;
    setState(() {
      _clearing = true;
      _error = null;
    });
    final outcome = await widget.controller.clearGitMetadata();
    if (!mounted) return;
    setState(() => _clearing = false);
    if (!outcome.isSuccess) {
      setState(() => _error = outcome.message.resolve(context.l10n));
      return;
    }
    Navigator.pop(context, outcome);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final inspection = _inspection;
    final hasRemotes = inspection?.remotes.isNotEmpty == true;
    final hasPending = widget.controller.hasPendingOperations;
    final canClear =
        !_loading &&
        !_clearing &&
        inspection?.isSuccess == true &&
        !hasRemotes &&
        !hasPending;
    return AlertDialog(
      icon: Icon(Icons.warning_amber_rounded, color: colors.error, size: 30),
      title: Text(l10n.tr('clearGitMetadata')),
      content: SizedBox(
        width: 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(
              l10n.tr('repository', {
                'path': widget.controller.repositoryPath ?? '',
              }),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colors.error.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr(
                      'thisOperationDeletesTheGitFolderInTheRepositoryRoot',
                    ),
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      'workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks',
                    ),
                    style: const TextStyle(fontSize: 12, height: 1.55),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      'afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution',
                    ),
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.5,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                l10n.tr('remoteCheck'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                hasRemotes
                    ? l10n.tr(
                        'remoteRepositoriesWereDetectedSoClearingIsDisabled',
                        {
                          'remotes': inspection!.remotes
                              .map((remote) => remote.name)
                              .join('、'),
                        },
                      )
                    : inspection?.isSuccess == true
                    ? l10n.tr('noRemoteRepositoryWasDetected')
                    : inspection?.message.resolve(l10n) ??
                          l10n.tr('unableToInspectRepository'),
                style: TextStyle(
                  color: hasRemotes ? colors.error : colors.onSurfaceVariant,
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
            if (hasPending) ...[
              const SizedBox(height: 10),
              Text(
                l10n.tr(
                  'aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata',
                ),
                style: TextStyle(color: colors.error, fontSize: 11.5),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 10),
              SelectableText(
                _error!,
                style: TextStyle(color: colors.error, fontSize: 11.5),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _clearing ? null : () => Navigator.pop(context),
          child: Text(l10n.tr('cancel2')),
        ),
        FilledButton.icon(
          onPressed: canClear ? _clear : null,
          icon: _clearing
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_forever_rounded, size: 18),
          label: Text(l10n.tr('addClearOperationToPlan')),
          style: FilledButton.styleFrom(backgroundColor: colors.error),
        ),
      ],
    );
  }
}
