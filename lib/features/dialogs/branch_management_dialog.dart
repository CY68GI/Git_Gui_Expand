import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../repository/repository_controller.dart';
import 'operation_plan_dialog.dart';

class BranchManagementDialog extends StatefulWidget {
  const BranchManagementDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<BranchManagementDialog> createState() => _BranchManagementDialogState();
}

class _BranchManagementDialogState extends State<BranchManagementDialog> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _branches = const [];
  String? _selected;
  bool _loading = true;
  bool _busy = false;
  bool _forceDelete = false;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    setState(() => _loading = true);
    try {
      final branches = await widget.controller.localBranches();
      if (!mounted) return;
      setState(() {
        _branches = branches;
        _selected = branches.contains(_selected)
            ? _selected
            : branches.contains(widget.controller.branch)
            ? widget.controller.branch
            : branches.isEmpty
            ? null
            : branches.first;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showMessage(error.toString(), isError: true);
    }
  }

  Future<void> _runAction(Future<OperationOutcome> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    final outcome = await action();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!outcome.isSuccess) {
      _showMessage(context.l10n.tr(outcome.message), isError: true);
      return;
    }
    _nameController.clear();
    await showDialog<void>(
      context: context,
      builder: (context) => OperationPlanDialog(controller: widget.controller),
    );
    if (mounted) {
      await _loadBranches();
    }
  }

  void _showMessage(String message, {required bool isError}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        closeIconColor: isError ? colors.onError : colors.onPrimary,
        showCloseIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final selected = _selected;
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.account_tree_outlined, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(child: Text(l10n.tr('分支管理'))),
          IconButton(
            onPressed: _loading || _busy ? null : _loadBranches,
            tooltip: l10n.tr('刷新分支'),
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
      content: SizedBox(
        width: 610,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tr('当前分支：{branch}', {'branch': widget.controller.branch}),
              style: TextStyle(
                color: colors.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: _branches.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(18),
                        child: Text(
                          l10n.tr('当前没有可显示的本地分支。'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _branches.length,
                        itemBuilder: (context, index) {
                          final branch = _branches[index];
                          final isCurrent = branch == widget.controller.branch;
                          return ListTile(
                            dense: true,
                            selected: branch == selected,
                            selectedTileColor: colors.primary.withValues(
                              alpha: 0.08,
                            ),
                            leading: Icon(
                              isCurrent
                                  ? Icons.check_circle_rounded
                                  : Icons.account_tree_outlined,
                              size: 18,
                              color: isCurrent
                                  ? colors.primary
                                  : colors.onSurfaceVariant,
                            ),
                            title: Text(
                              branch,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isCurrent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            trailing: isCurrent
                                ? Text(
                                    l10n.tr('当前'),
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                : null,
                            onTap: () => setState(() => _selected = branch),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.tr('新分支名称或重命名后的名称'),
                hintText: l10n.tr('例如 feature/login'),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _runAction(
                          () => widget.controller.createBranch(
                            _nameController.text,
                          ),
                        ),
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(l10n.tr('创建分支')),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.switchBranch(selected),
                        ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 17),
                  label: Text(l10n.tr('切换分支')),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.renameBranch(
                            selected,
                            _nameController.text,
                          ),
                        ),
                  icon: const Icon(
                    Icons.drive_file_rename_outline_rounded,
                    size: 17,
                  ),
                  label: Text(l10n.tr('重命名分支')),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.deleteBranch(
                            selected,
                            force: _forceDelete,
                          ),
                        ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  label: Text(l10n.tr('删除分支')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _forceDelete,
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _forceDelete = value ?? false),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                l10n.tr('删除未合并分支时强制使用 git branch -D'),
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(l10n.tr('关闭')),
        ),
      ],
    );
  }
}
