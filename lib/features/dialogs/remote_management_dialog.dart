import 'package:flutter/material.dart';

import '../../core/models/git_remote.dart';
import '../repository/repository_controller.dart';

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
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 650),
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
                  Column(
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
                      Text(
                        '当前分支：${controller.branch.isEmpty ? '无' : controller.branch}',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: controller.isBusy || controller.remotes.isEmpty
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
                                  fontSize: 11,
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
                                busy: controller.isBusy,
                                onPush: () => _confirmPush(remote),
                                onEdit: () => _startEdit(remote),
                                onRemove: () => _confirmRemove(remote),
                              );
                            },
                          ),
                  ),
                  Container(width: 1, color: colors.outlineVariant),
                  SizedBox(
                    width: 300,
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
                            '支持 GitHub、Gitee、GitLab、Bitbucket 和任意标准 Git 远端。',
                            style: TextStyle(
                              fontSize: 9.5,
                              height: 1.45,
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
                              _editingName == null ? '添加远端' : '保存 URL',
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
                                  fontSize: 9.5,
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

  void _startEdit(GitRemote remote) {
    setState(() {
      _editingName = remote.name;
      _nameController.text = remote.name;
      _urlController.text = remote.effectiveUrl;
      _message = null;
    });
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
        title: Text('推送到 ${remote.name}？'),
        content: Text(
          '将当前分支 ${widget.controller.branch} 推送到 ${remote.platformLabel}。\n'
          '${remote.maskedUrl}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('推送'),
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
  }

  Future<void> _confirmPushAll() async {
    final names = widget.controller.remotes
        .map((remote) => remote.name)
        .join('、');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('推送到全部远端？'),
        content: Text('当前分支 ${widget.controller.branch} 将依次推送到：\n$names'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('全部推送'),
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
  }

  Future<void> _confirmRemove(GitRemote remote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除远端 ${remote.name}？'),
        content: const Text('只删除本地 Git remote 配置，不会删除远端平台上的仓库。'),
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
            child: const Text('删除'),
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
  });

  final GitRemote remote;
  final bool busy;
  final VoidCallback onPush;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

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
                    Text(
                      remote.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
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
                          fontSize: 8.5,
                          color: platformColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  remote.maskedUrl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    color: colors.onSurfaceVariant,
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
            tooltip: '删除远端',
            icon: const Icon(Icons.delete_outline_rounded, size: 16),
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
