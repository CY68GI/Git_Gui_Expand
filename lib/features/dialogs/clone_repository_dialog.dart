import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/folder_picker_service.dart';
import '../../core/services/git_service.dart';

class CloneRepositoryDialog extends StatefulWidget {
  const CloneRepositoryDialog({
    super.key,
    this.folderPickerService = const FolderPickerService(),
  });

  final FolderPickerService folderPickerService;

  @override
  State<CloneRepositoryDialog> createState() => _CloneRepositoryDialogState();
}

class _CloneRepositoryDialogState extends State<CloneRepositoryDialog> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _parentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _cloning = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    _parentController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickParent() async {
    final path = await widget.folderPickerService.pickFolder(
      initialDirectory: _parentController.text.trim().isEmpty
          ? null
          : _parentController.text.trim(),
      title: context.l10n.tr('选择克隆父目录'),
    );
    if (path != null && mounted) {
      _parentController.text = path;
    }
  }

  void _updateRepositoryName(String value) {
    final name = GitService.repositoryNameFromRemote(value);
    if (name.isNotEmpty) {
      _nameController.text = name;
    }
    setState(() {});
  }

  Future<void> _clone() async {
    if (_cloning) return;
    final parent = _parentController.text.trim();
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (parent.isEmpty || name.isEmpty || url.isEmpty) {
      setState(() => _error = context.l10n.tr('请填写克隆地址、父目录和项目名称。'));
      return;
    }
    final destination = '$parent${Platform.pathSeparator}$name';
    setState(() {
      _cloning = true;
      _error = null;
    });
    try {
      await GitService.cloneRepository(url, destination);
      if (mounted) {
        Navigator.pop(context, destination);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _cloning = false;
          _error = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final parent = _parentController.text.trim();
    final name = _nameController.text.trim();
    final destination = parent.isEmpty || name.isEmpty
        ? ''
        : '$parent${Platform.pathSeparator}$name';
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.download_rounded, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(child: Text(l10n.tr('克隆 Git 仓库'))),
        ],
      ),
      content: SizedBox(
        width: 620,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              enabled: !_cloning,
              onChanged: _updateRepositoryName,
              decoration: InputDecoration(
                labelText: l10n.tr('远程仓库地址'),
                hintText: 'git@github.com:owner/repository.git',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _parentController,
              enabled: !_cloning,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.tr('克隆到父目录'),
                suffixIcon: IconButton(
                  onPressed: _cloning ? null : _pickParent,
                  tooltip: l10n.tr('选择文件夹'),
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              enabled: !_cloning,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.tr('项目文件夹名称')),
            ),
            if (destination.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText(
                l10n.tr('目标目录：{path}', {'path': destination}),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.tr('克隆会创建新的本地 Git 仓库，并保留远端已有的提交和分支。'),
              style: TextStyle(
                fontSize: 11.5,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
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
          onPressed: _cloning ? null : () => Navigator.pop(context),
          child: Text(l10n.tr('取消')),
        ),
        FilledButton.icon(
          onPressed: _cloning ? null : _clone,
          icon: _cloning
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(_cloning ? l10n.tr('正在克隆…') : l10n.tr('开始克隆')),
        ),
      ],
    );
  }
}
