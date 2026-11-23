import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/repository_sync.dart';
import '../repository/repository_controller.dart';
import 'operation_plan_dialog.dart';

class RepositorySyncDialog extends StatefulWidget {
  const RepositorySyncDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<RepositorySyncDialog> createState() => _RepositorySyncDialogState();
}

class _RepositorySyncDialogState extends State<RepositorySyncDialog> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final colors = Theme.of(context).colorScheme;
        final l10n = context.l10n;
        final state = controller.syncState;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.sync_rounded, color: colors.primary),
              const SizedBox(width: 9),
              Expanded(child: Text(l10n.tr('分支同步'))),
              IconButton(
                onPressed: controller.isBusy || _busy
                    ? null
                    : () async {
                        await controller.refresh();
                        if (mounted) setState(() {});
                      },
                tooltip: l10n.tr('刷新同步状态'),
                icon: const Icon(Icons.refresh_rounded, size: 18),
              ),
            ],
          ),
          content: SizedBox(
            width: 650,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SyncStatusCard(state: state),
                const SizedBox(height: 14),
                if (_guidance(state) != null) ...[
                  _SyncGuidance(
                    text: _guidance(state)!,
                    isError: state?.relation == BranchSyncRelation.diverged,
                  ),
                  const SizedBox(height: 14),
                ],
                Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('repository-sync-fetch-current'),
                      onPressed:
                          controller.isBusy ||
                              _busy ||
                              state?.canFetchCurrent != true
                          ? null
                          : () => _run(() => controller.fetchCurrentUpstream()),
                      icon: const Icon(Icons.download_rounded, size: 17),
                      label: Text(l10n.tr('获取当前 upstream')),
                    ),
                    OutlinedButton.icon(
                      key: const Key('repository-sync-fetch-all'),
                      onPressed:
                          controller.isBusy ||
                              _busy ||
                              controller.remotes.isEmpty
                          ? null
                          : () => _run(controller.fetchAllRemotes),
                      icon: const Icon(Icons.cloud_download_outlined, size: 17),
                      label: Text(l10n.tr('获取全部远端')),
                    ),
                    FilledButton.icon(
                      key: const Key('repository-sync-pull'),
                      onPressed:
                          controller.isBusy || _busy || state?.canPull != true
                          ? null
                          : () => _run(controller.pullCurrentBranchFastForward),
                      icon: const Icon(Icons.merge_type_rounded, size: 17),
                      label: Text(l10n.tr('安全快进 Pull')),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.tr(
                    'Pull 会先 Fetch 并重新检查 ahead/behind，只允许快进，'
                    '不会自动创建 Merge 提交；工作区或索引不干净时禁止 Pull。',
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
          actions: [
            TextButton(
              onPressed: controller.isBusy || _busy
                  ? null
                  : () => Navigator.pop(context),
              child: Text(l10n.tr('关闭')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _run(Future<OperationOutcome> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.tr(outcome.message)),
        backgroundColor: outcome.isSuccess ? colors.primary : colors.error,
        closeIconColor: outcome.isSuccess ? colors.onPrimary : colors.onError,
        showCloseIcon: true,
      ),
    );
    if (!outcome.isSuccess || !mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => OperationPlanDialog(planHost: widget.controller),
    );
  }

  String? _guidance(BranchSyncState? state) {
    final l10n = context.l10n;
    if (state == null) {
      return l10n.tr('无法读取分支同步状态。请刷新后重试。');
    }
    if (state.isDetached) {
      return l10n.tr('当前处于 detached HEAD，不能 Fetch 当前 upstream 或 Pull。');
    }
    if (state.isUnborn) {
      return l10n.tr('当前分支尚无提交，不能 Pull。');
    }
    if (!state.hasUpstream) {
      return l10n.tr('当前分支没有 upstream。可获取全部远端，但 Pull 前需要配置跟踪分支。');
    }
    if (!state.worktreeClean) {
      return l10n.tr('工作区或索引不干净。请先提交或 Stash 更改，再执行安全 Pull。');
    }
    if (state.relation == BranchSyncRelation.diverged) {
      return l10n.tr(
        '本地分支与 upstream 已分叉。软件不会自动 Merge 或 Rebase，'
        '请先使用外部 Git 处理分叉。',
      );
    }
    if (state.relation == BranchSyncRelation.ahead) {
      return l10n.tr('本地分支有未推送提交，当前不需要 Pull。');
    }
    if (state.relation == BranchSyncRelation.upToDate) {
      return l10n.tr('当前分支已经与 upstream 同步。');
    }
    return null;
  }
}

class _SyncStatusCard extends StatelessWidget {
  const _SyncStatusCard({required this.state});

  final BranchSyncState? state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final sync = state;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: sync == null
          ? Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text(l10n.tr('正在读取同步状态…')),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatusValue(
                        label: l10n.tr('当前分支'),
                        value: sync.isDetached
                            ? l10n.tr('detached HEAD')
                            : sync.branch.isEmpty
                            ? l10n.tr('尚无可提交分支')
                            : sync.branch,
                      ),
                    ),
                    Expanded(
                      child: _StatusValue(
                        label: l10n.tr('upstream'),
                        value: sync.hasUpstream
                            ? sync.upstreamRef
                            : l10n.tr('未配置'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _CountTile(
                      icon: Icons.arrow_upward_rounded,
                      label: l10n.tr('待推送'),
                      value: '${sync.ahead}',
                      color: colors.tertiary,
                    ),
                    const SizedBox(width: 10),
                    _CountTile(
                      icon: Icons.arrow_downward_rounded,
                      label: l10n.tr('待拉取'),
                      value: '${sync.behind}',
                      color: colors.primary,
                    ),
                    const SizedBox(width: 10),
                    _CountTile(
                      icon: sync.worktreeClean
                          ? Icons.check_circle_outline_rounded
                          : Icons.warning_amber_rounded,
                      label: l10n.tr('工作区'),
                      value: sync.worktreeClean
                          ? l10n.tr('干净')
                          : l10n.tr('有更改'),
                      color: sync.worktreeClean ? colors.primary : colors.error,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _StatusValue extends StatelessWidget {
  const _StatusValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
}

class _SyncGuidance extends StatelessWidget {
  const _SyncGuidance({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isError ? colors.error : colors.tertiary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, height: 1.5, color: color),
      ),
    );
  }
}
