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
      setState(() => _error = context.l10n.tr(outcome.message));
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
      title: Text(l10n.tr('清除 Git 元数据')),
      content: SizedBox(
        width: 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SelectableText(
              l10n.tr('仓库：{path}', {
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
                    l10n.tr('此操作会删除仓库根目录中的 .git 文件夹。'),
                    style: TextStyle(
                      color: colors.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      '工作文件不会被删除，但以下 Git 内容会永久丢失：\n'
                      '• 全部提交历史和 reflog\n'
                      '• 本地分支、标签和当前分支状态\n'
                      '• 暂存索引、Stash、未被工作文件保留的已提交内容\n'
                      '• 引用、远端配置以及仓库级 Git 配置和 hooks',
                    ),
                    style: const TextStyle(fontSize: 12, height: 1.55),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr(
                      '清理后该文件夹会变成普通目录，仍可用“打开空白文件夹”重新执行 git init。'
                      '现在只加入清除计划；还需要在操作计划中输入 CLEAR GIT 并确认执行。',
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
                l10n.tr('远端检查'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                hasRemotes
                    ? l10n.tr('检测到远端仓库，已禁止清除：{remotes}', {
                        'remotes': inspection!.remotes
                            .map((remote) => remote.name)
                            .join('、'),
                      })
                    : inspection?.isSuccess == true
                    ? l10n.tr('未检测到任何远端仓库。')
                    : l10n.tr(inspection?.message ?? '无法检查仓库。'),
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
                l10n.tr('当前有待执行操作计划，请先清空或执行后再清除 Git。'),
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
          child: Text(l10n.tr('取消')),
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
          label: Text(l10n.tr('加入清除计划')),
          style: FilledButton.styleFrom(backgroundColor: colors.error),
        ),
      ],
    );
  }
}
