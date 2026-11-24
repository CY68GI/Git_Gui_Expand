import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/services/folder_picker_service.dart';
import '../../core/services/git_service.dart';

class CloneRepositoryRequest {
  const CloneRepositoryRequest({
    required this.remoteUrl,
    required this.parentPath,
    required this.repositoryName,
  });

  final String remoteUrl;
  final String parentPath;
  final String repositoryName;

  String get destinationPath =>
      '$parentPath${Platform.pathSeparator}$repositoryName';
}

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
      title: context.l10n.tr('chooseCloneParentFolder'),
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

  Future<void> _previewClone() async {
    if (_cloning) return;
    final parent = _parentController.text.trim();
    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    if (parent.isEmpty || name.isEmpty || url.isEmpty) {
      setState(
        () => _error = context.l10n.tr(
          'enterACloneUrlParentFolderAndProjectName',
        ),
      );
      return;
    }
    setState(() {
      _cloning = true;
      _error = null;
    });
    try {
      final snapshot = await GitService.inspectCloneTarget(
        url,
        '$parent${Platform.pathSeparator}$name',
      );
      if (!await Directory(snapshot.parentPath).exists()) {
        throw const FileSystemException('克隆目标父目录不存在。');
      }
      if (snapshot.targetExists && !snapshot.targetIsEmpty) {
        throw const FileSystemException('克隆目标目录不是空目录。');
      }
      if (!mounted) return;
      Navigator.pop(
        context,
        CloneRepositoryRequest(
          remoteUrl: url,
          parentPath: parent,
          repositoryName: name,
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _cloning = false;
          _error = error
              .toString()
              .replaceFirst('FileSystemException: ', '')
              .replaceFirst('GitException: ', '');
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
          Expanded(child: Text(l10n.tr('cloneGitRepository'))),
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
                labelText: l10n.tr('remoteRepositoryUrl'),
                hintText: 'git@github.com:owner/repository.git',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _parentController,
              enabled: !_cloning,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.tr('cloneIntoParentFolder'),
                suffixIcon: IconButton(
                  onPressed: _cloning ? null : _pickParent,
                  tooltip: l10n.tr('chooseFolder'),
                  icon: const Icon(Icons.folder_open_rounded, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              enabled: !_cloning,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.tr('projectFolderName'),
              ),
            ),
            if (destination.isNotEmpty) ...[
              const SizedBox(height: 10),
              SelectableText(
                l10n.tr('destinationFolder', {'path': destination}),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.tr(
                'theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone',
              ),
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
          child: Text(l10n.tr('cancel2')),
        ),
        FilledButton.icon(
          onPressed: _cloning ? null : _previewClone,
          icon: _cloning
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(
            _cloning ? l10n.tr('checking2') : l10n.tr('addCloneToPlan'),
          ),
        ),
      ],
    );
  }
}
