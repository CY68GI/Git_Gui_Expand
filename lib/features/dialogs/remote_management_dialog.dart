import 'package:flutter/material.dart';

import '../../core/models/git_remote.dart';
import '../repository/repository_controller.dart';
import 'operation_plan_dialog.dart';

class RemoteManagementDialog extends StatefulWidget {
  const RemoteManagementDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<RemoteManagementDialog> createState() => _RemoteManagementDialogState();
}

class _RemoteManagementDialogState extends State<RemoteManagementDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  String? _editingName;
  String? _message;
  bool _messageIsError = false;
  bool _inspectingClear = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final outcome = await widget.controller.refreshRemotes();
      if (!mounted) return;
      setState(() {
        _message = outcome.isSuccess ? null : outcome.message;
        _messageIsError = !outcome.isSuccess;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = widget.controller;
    return Dialog(
      insetPadding: const EdgeInsets.all(28),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.hub_outlined,
                      color: colors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '远端仓库',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Tooltip(
                          message:
                              '当前分支：${controller.branch.isEmpty ? '无' : controller.branch}',
                          child: Text(
                            '当前分支：${controller.branch.isEmpty ? '无' : controller.branch}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: controller.isBusy || _inspectingClear
                        ? null
                        : _showOperationPlan,
                    icon: const Icon(
                      Icons.playlist_add_check_rounded,
                      size: 16,
                    ),
                    label: Text('待执行 ${controller.pendingOperations.length}'),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed:
                        controller.isBusy ||
                            _inspectingClear ||
                            controller.remotes.isEmpty
                        ? null
                        : _confirmPushAll,
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text('全部推送'),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    onPressed: controller.isBusy
                        ? null
                        : () async {
                            final outcome = await controller.refreshRemotes();
                            if (!mounted) return;
                            setState(() {
                              _message = outcome.message;
                              _messageIsError = !outcome.isSuccess;
                            });
                          },
                    tooltip: '刷新远端',
                    icon: const Icon(Icons.refresh_rounded, size: 19),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: '关闭',
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
                ],
              ),
            ),
            if (controller.isBusy)
              const LinearProgressIndicator(minHeight: 2)
            else
              const SizedBox(height: 2),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: controller.remotes.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                '尚未配置远端仓库。请在右侧添加 GitHub、Gitee、GitLab 或其他 Git 远端。',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.45,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.remotes.length,
                            itemBuilder: (context, index) {
                              final remote = controller.remotes[index];
                              return _RemoteCard(
                                remote: remote,
                                busy: controller.isBusy || _inspectingClear,
                                onPush: () => _confirmPush(remote),
                                onEdit: () => _startEdit(remote),
                                onRemove: () => _confirmRemove(remote),
                                onClear: () => _confirmClearRemote(remote),
                              );
                            },
                          ),
                  ),
                  Container(width: 1, color: colors.outlineVariant),
                  SizedBox(
                    width: 330,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _editingName == null ? '添加远端' : '编辑远端',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '支持 GitHub、Gitee、GitLab、Bitbucket 和任意标准 Git 远端。'
                            '所有修改会先加入待执行计划。远端右侧红色垃圾桶用于'
                            '清空该远端全部分支和标签。',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _nameController,
                            readOnly: _editingName != null,
                            decoration: const InputDecoration(
                              labelText: '远端名称',
                              hintText: '例如 origin、gitee、gitlab',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _urlController,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: '远端 URL',
                              hintText: 'https://... 或 git@host:owner/repo.git',
                              alignLabelWithHint: true,
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: controller.isBusy ? null : _saveRemote,
                            icon: Icon(
                              _editingName == null
                                  ? Icons.add_rounded
                                  : Icons.save_outlined,
                              size: 17,
                            ),
                            label: Text(
                              _editingName == null ? '加入添加计划' : '加入修改计划',
                            ),
                          ),
                          if (_editingName != null) ...[
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: controller.isBusy
                                  ? null
                                  : () {
                                      setState(() {
                                        _editingName = null;
                                        _nameController.clear();
                                        _urlController.clear();
                                      });
                                    },
                              child: const Text('取消编辑'),
                            ),
                          ],
                          if (_message != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    (_messageIsError
                                            ? colors.error
                                            : colors.primary)
                                        .withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                _message!,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: _messageIsError
                                      ? colors.error
                                      : colors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
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

  Future<void> _showOperationPlan() async {
    await showDialog<void>(
      context: context,
      builder: (context) => OperationPlanDialog(controller: widget.controller),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _startEdit(GitRemote remote) {
    setState(() {
      _editingName = remote.name;
      _nameController.text = remote.name;
      _urlController.text = remote.effectiveUrl;
      _message = null;
    });
  }

  Future<void> _confirmClearRemote(GitRemote remote) async {
    setState(() {
      _inspectingClear = true;
      _message = '正在读取远端 ${remote.name} 的分支和标签…';
      _messageIsError = false;
    });
    final inspection = await widget.controller.inspectRemoteForClear(
      remote.name,
    );
    if (!mounted) return;
    final preview = inspection.preview;
    if (!inspection.isSuccess || preview == null) {
      setState(() {
        _inspectingClear = false;
        _message = inspection.message;
        _messageIsError = true;
      });
      return;
    }
    setState(() {
      _inspectingClear = false;
      _message = inspection.message;
      _messageIsError = false;
    });
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.delete_forever_rounded, color: colors.error),
          title: Text('清空远端历史 ${remote.name}？'),
          content: SizedBox(
            width: 600,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '这是不可撤销的高风险操作。软件会先备份远端引用，然后把 '
                  '${preview.targetBranch} 强制替换为一个不含文件的空根提交，'
                  '删除其他分支和标签，并把本地同名分支与索引同步到该空提交。'
                  '本地文件不会删除，刷新后会显示为未跟踪。',
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  '项目：${preview.projectName}\n'
                  '目标分支：${preview.targetBranch}\n'
                  '空提交说明：${preview.emptyCommitMessage}\n'
                  '计划执行确认：${preview.confirmationText}',
                  style: const TextStyle(fontSize: 12.5, height: 1.55),
                ),
                const SizedBox(height: 10),
                Text(
                  '${remote.platformLabel} 的默认分支通常受保护。'
                  '如果服务器拒绝强制更新或删除，整个原子操作不会删除任何引用；'
                  '需要先在托管平台临时解除默认分支保护。',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.5,
                    color: colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 210,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.22),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      preview.refs.isEmpty
                          ? '远端当前没有分支或标签，将直接创建第一个空提交。'
                          : preview.refs.join('\n'),
                      style: const TextStyle(fontSize: 12, height: 1.45),
                    ),
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
              icon: const Icon(Icons.playlist_add_rounded, size: 18),
              label: const Text('加入清空计划'),
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
    final outcome = await widget.controller.queueClearRemote(preview);
    if (!mounted) return;
    setState(() {
      _message = outcome.message;
      _messageIsError = !outcome.isSuccess;
    });
    if (outcome.isSuccess) {
      await _showOperationPlan();
    }
  }

  Future<void> _saveRemote() async {
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    final editing = _editingName != null;
    final outcome = await widget.controller.saveRemote(
      name: name,
      url: url,
      updateExisting: editing,
    );
    if (!mounted) return;
    setState(() {
      _message = outcome.message;
      _messageIsError = !outcome.isSuccess;
      if (outcome.isSuccess) {
        _editingName = null;
        _nameController.clear();
        _urlController.clear();
      }
    });
  }

  Future<void> _confirmPush(GitRemote remote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('将推送到 ${remote.name} 加入计划'),
        content: Text(
          '现在不会联网推送。执行计划时，将当前分支 '
          '${widget.controller.branch} 推送到 ${remote.platformLabel}。\n'
          '${remote.maskedUrl}',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('加入推送计划'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final outcome = await widget.controller.pushToRemote(remote.name);
    if (!mounted) return;
    setState(() {
      _message = outcome.message;
      _messageIsError = !outcome.isSuccess;
    });
    if (outcome.isSuccess) {
      await _showOperationPlan();
    }
  }

  Future<void> _confirmPushAll() async {
    final names = widget.controller.remotes
        .map((remote) => remote.name)
        .join('、');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('将全部推送加入计划'),
        content: Text(
          '执行计划时，当前分支 ${widget.controller.branch} 将依次推送到：\n$names',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('加入全部推送计划'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final outcome = await widget.controller.pushToAllRemotes();
    if (!mounted) return;
    setState(() {
      _message = outcome.message;
      _messageIsError = !outcome.isSuccess;
    });
    if (outcome.isSuccess) {
      await _showOperationPlan();
    }
  }

  Future<void> _confirmRemove(GitRemote remote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('将移除远端配置 ${remote.name} 加入计划'),
        content: const Text(
          '执行计划时只删除本地 Git remote 配置，不会删除远端平台上的仓库。',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('加入移除计划'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final outcome = await widget.controller.removeRemote(remote.name);
    if (!mounted) return;
    setState(() {
      _message = outcome.message;
      _messageIsError = !outcome.isSuccess;
      if (outcome.isSuccess && _editingName == remote.name) {
        _editingName = null;
        _nameController.clear();
        _urlController.clear();
      }
    });
  }
}

class _RemoteCard extends StatelessWidget {
  const _RemoteCard({
    required this.remote,
    required this.busy,
    required this.onPush,
    required this.onEdit,
    required this.onRemove,
    required this.onClear,
  });

  final GitRemote remote;
  final bool busy;
  final VoidCallback onPush;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final platformColor = _platformColor(remote.platform);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 11, 8, 11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: platformColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _platformIcon(remote.platform),
              color: platformColor,
              size: 18,
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
                      child: Tooltip(
                        message: remote.name,
                        child: Text(
                          remote.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: platformColor.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        remote.platformLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colors.onSurface
                              : platformColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Tooltip(
                  message: remote.maskedUrl,
                  child: Text(
                    remote.maskedUrl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.4,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: busy ? null : onPush,
            icon: const Icon(Icons.cloud_upload_outlined, size: 15),
            label: const Text('推送'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 7),
            ),
          ),
          IconButton(
            onPressed: busy ? null : onEdit,
            tooltip: '编辑 URL',
            icon: const Icon(Icons.edit_outlined, size: 16),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: busy ? null : onRemove,
            tooltip: '移除本地远端配置',
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            onPressed: busy ? null : onClear,
            tooltip: '清空远端全部分支和标签（危险）',
            icon: Icon(
              Icons.delete_forever_rounded,
              size: 18,
              color: colors.error,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Color _platformColor(GitRemotePlatform platform) {
    return switch (platform) {
      GitRemotePlatform.github => const Color(0xFF24292F),
      GitRemotePlatform.gitee => const Color(0xFFC71D23),
      GitRemotePlatform.gitlab => const Color(0xFFFC6D26),
      GitRemotePlatform.bitbucket => const Color(0xFF2684FF),
      GitRemotePlatform.generic => const Color(0xFF087C68),
    };
  }

  IconData _platformIcon(GitRemotePlatform platform) {
    return switch (platform) {
      GitRemotePlatform.github => Icons.code_rounded,
      GitRemotePlatform.gitee => Icons.cloud_outlined,
      GitRemotePlatform.gitlab => Icons.change_history_rounded,
      GitRemotePlatform.bitbucket => Icons.hive_outlined,
      GitRemotePlatform.generic => Icons.hub_outlined,
    };
  }
}
