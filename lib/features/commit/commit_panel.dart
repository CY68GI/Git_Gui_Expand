import 'package:flutter/material.dart';

import '../../core/models/app_models.dart';
import '../repository/repository_controller.dart';

class CommitPanel extends StatefulWidget {
  const CommitPanel({
    super.key,
    required this.controller,
    required this.showOutcome,
    required this.onTextEditingChanged,
    required this.onPushRequested,
    required this.onManageRemotes,
    required this.onPlanRequested,
  });

  final RepositoryController controller;
  final ValueChanged<OperationOutcome> showOutcome;
  final ValueChanged<bool> onTextEditingChanged;
  final VoidCallback onPushRequested;
  final VoidCallback onManageRemotes;
  final Future<void> Function() onPlanRequested;

  @override
  State<CommitPanel> createState() => _CommitPanelState();
}

class _CommitPanelState extends State<CommitPanel> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final changes = controller.changedFiles;
    final hasChanges = changes.isNotEmpty;
    final stagedCount = changes.where((item) => item.isStaged).length;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    Icons.commit_rounded,
                    size: 16,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 9),
                const Text(
                  '提交工作区',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                _CountBadge(
                  text: '${changes.length} 项变更',
                  color: hasChanges
                      ? (isDark
                            ? const Color(0xFFFFD27A)
                            : const Color(0xFF9A7116))
                      : colors.onSurfaceVariant,
                ),
                if (stagedCount > 0) ...[
                  const SizedBox(width: 6),
                  _CountBadge(text: '$stagedCount 项已暂存', color: colors.primary),
                ],
                const Spacer(),
                Tooltip(
                  message: '查看和管理全部远端仓库',
                  child: TextButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : widget.onManageRemotes,
                    icon: const Icon(Icons.hub_outlined, size: 15),
                    label: Text('远端 ${controller.remotes.length}'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 6,
                      ),
                      textStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Tooltip(
                  message: '推送当前分支 (Ctrl+Shift+U)',
                  child: TextButton.icon(
                    onPressed: controller.isBusy
                        ? null
                        : widget.onPushRequested,
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('推送'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      textStyle: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (controller.branch.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_tree_outlined,
                        size: 14,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        controller.branch,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildChangeList(context)),
                Container(width: 1, color: colors.outlineVariant),
                SizedBox(width: 460, child: _buildComposer(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeList(BuildContext context) {
    final changes = widget.controller.changedFiles;
    if (changes.isEmpty) {
      if (widget.controller.hasPendingFileChanges) {
        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.playlist_add_check_circle_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '文件变更尚未执行，请在待执行操作计划中确认',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: 19,
              color: Color(0xFF16836C),
            ),
            const SizedBox(width: 8),
            Text(
              '工作区干净，没有待提交的更改',
              style: TextStyle(
                fontSize: 11.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: changes.length,
      itemBuilder: (context, index) {
        return _ChangeRow(status: changes[index]);
      },
    );
  }

  Widget _buildComposer(BuildContext context) {
    final hasChanges = widget.controller.changedFiles.isNotEmpty;
    final canQueueCommit =
        hasChanges || widget.controller.hasPendingFileChanges;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Focus(
            onFocusChange: widget.onTextEditingChanged,
            child: TextField(
              controller: _messageController,
              minLines: 2,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                hintText: '填写本次提交说明…',
                labelText: '提交说明',
                alignLabelWithHint: true,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      canQueueCommit &&
                          !widget.controller.isBusy &&
                          !widget.controller.localOperationsLocked
                      ? () async {
                          final outcome = await widget.controller
                              .stageAllChanges();
                          widget.showOutcome(outcome);
                        }
                      : null,
                  icon: const Icon(Icons.add_task_rounded, size: 16),
                  label: const Text('暂存全部'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      hasChanges &&
                          !widget.controller.isBusy &&
                          !widget.controller.localOperationsLocked
                      ? () async {
                          final outcome = await widget.controller
                              .unstageAllChanges();
                          widget.showOutcome(outcome);
                        }
                      : null,
                  icon: const Icon(Icons.remove_done_rounded, size: 16),
                  label: const Text('取消暂存'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed:
                      hasChanges &&
                          !widget.controller.isBusy &&
                          !widget.controller.localOperationsLocked
                      ? () async {
                          final outcome = await widget.controller.commitAll(
                            _messageController.text,
                          );
                          if (outcome.isSuccess) {
                            _messageController.clear();
                          }
                          widget.showOutcome(outcome);
                          if (outcome.isSuccess) {
                            await widget.onPlanRequested();
                          }
                        }
                      : null,
                  icon: widget.controller.isBusy
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 17),
                  label: const Text('加入提交计划'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。',
            style: TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({required this.status});

  final GitFileStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final code = status.isStaged
        ? status.indexCode
        : status.worktreeCode.trim().isEmpty
        ? status.indexCode
        : status.worktreeCode;
    final normalized = code.replaceAll(' ', '');
    final label = normalized.isEmpty ? '?' : normalized.substring(0, 1);
    final color = switch (label) {
      'A' || '?' => isDark ? const Color(0xFF6FE7C3) : const Color(0xFF16836C),
      'D' => isDark ? const Color(0xFFFF9B8E) : const Color(0xFFC04E4E),
      'U' => isDark ? const Color(0xFFFFC56B) : const Color(0xFFC97914),
      'R' || 'C' => isDark ? const Color(0xFF9BB9FF) : const Color(0xFF466FBF),
      _ => isDark ? const Color(0xFFFFD27A) : const Color(0xFF9A7116),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: Container(
        height: 27,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: status.isStaged
              ? Theme.of(context).colorScheme.surfaceContainerLow
              : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                status.path,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: status.isStaged
                    ? const Color(0xFF16836C)
                    : const Color(0xFFD5B262),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
