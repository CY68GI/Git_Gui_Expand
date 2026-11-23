import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/app_models.dart';
import '../repository/repository_controller.dart';
import 'operation_plan_dialog.dart';

class StashManagementDialog extends StatefulWidget {
  const StashManagementDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<StashManagementDialog> createState() => _StashManagementDialogState();
}

class _StashManagementDialogState extends State<StashManagementDialog> {
  final TextEditingController _messageController = TextEditingController();
  List<GitStashEntry> _stashes = const [];
  GitStashEntry? _selected;
  bool _loading = true;
  bool _busy = false;
  bool _includeUntracked = true;

  @override
  void initState() {
    super.initState();
    _loadStashes();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadStashes() async {
    setState(() => _loading = true);
    try {
      final stashes = await widget.controller.listStashes();
      if (!mounted) return;
      final selectedSelector = _selected?.selector;
      GitStashEntry? nextSelected;
      for (final stash in stashes) {
        if (stash.selector == selectedSelector) {
          nextSelected = stash;
          break;
        }
      }
      setState(() {
        _stashes = stashes;
        _selected = stashes.isEmpty ? null : nextSelected ?? stashes.first;
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
    await showDialog<void>(
      context: context,
      builder: (context) => OperationPlanDialog(planHost: widget.controller),
    );
    if (mounted) {
      _messageController.clear();
      await _loadStashes();
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
          Icon(Icons.inventory_2_outlined, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(child: Text(l10n.tr('Stash 管理'))),
          IconButton(
            onPressed: _loading || _busy ? null : _loadStashes,
            tooltip: l10n.tr('刷新 Stash'),
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
            TextField(
              controller: _messageController,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.tr('Stash 说明（可选）'),
                hintText: l10n.tr('例如 临时保存未完成修改'),
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _includeUntracked,
              onChanged: _busy
                  ? null
                  : (value) =>
                        setState(() => _includeUntracked = value ?? true),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                l10n.tr('同时保存未跟踪文件（git stash --include-untracked）'),
                style: const TextStyle(fontSize: 11.5),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _busy
                    ? null
                    : () => _runAction(
                        () => widget.controller.createStash(
                          message: _messageController.text,
                          includeUntracked: _includeUntracked,
                        ),
                      ),
                icon: const Icon(Icons.add_box_outlined, size: 17),
                label: Text(l10n.tr('创建 Stash')),
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 270),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: _stashes.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          l10n.tr('当前仓库没有 Stash。'),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _stashes.length,
                        itemBuilder: (context, index) {
                          final stash = _stashes[index];
                          return ListTile(
                            dense: true,
                            selected: stash.selector == selected?.selector,
                            selectedTileColor: colors.primary.withValues(
                              alpha: 0.08,
                            ),
                            leading: Icon(
                              Icons.inventory_2_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            title: Text(
                              stash.selector,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              '${stash.message}${stash.createdAt.isEmpty ? '' : ' · ${stash.createdAt}'}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10.5),
                            ),
                            onTap: () => setState(() => _selected = stash),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.applyStash(selected.selector),
                        ),
                  icon: const Icon(Icons.merge_type_rounded, size: 17),
                  label: Text(l10n.tr('应用 Stash')),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.popStash(selected.selector),
                        ),
                  icon: const Icon(Icons.unarchive_outlined, size: 17),
                  label: Text(l10n.tr('弹出 Stash')),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || selected == null
                      ? null
                      : () => _runAction(
                          () => widget.controller.dropStash(selected.selector),
                        ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 17),
                  label: Text(l10n.tr('删除 Stash')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                  ),
                ),
              ],
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
