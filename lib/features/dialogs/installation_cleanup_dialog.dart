import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/installation_maintenance_service.dart';
import '../../core/utils/size_formatter.dart';

class InstallationCleanupDialog extends StatefulWidget {
  const InstallationCleanupDialog({super.key, this.service});

  final InstallationMaintenanceService? service;

  @override
  State<InstallationCleanupDialog> createState() =>
      _InstallationCleanupDialogState();
}

class _InstallationCleanupDialogState extends State<InstallationCleanupDialog> {
  late final InstallationMaintenanceService _service =
      widget.service ?? const InstallationMaintenanceService();
  MaintenanceScanResult? _scan;
  String? _message;
  bool _scanning = true;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _scanFiles();
  }

  Future<void> _scanFiles() async {
    setState(() {
      _scanning = true;
      _message = null;
    });
    final scan = await _service.scan();
    if (!mounted) return;
    setState(() {
      _scan = scan;
      _scanning = false;
    });
  }

  Future<void> _clearAll() async {
    final scan = _scan;
    if (scan == null || scan.items.isEmpty || _clearing) return;
    setState(() {
      _clearing = true;
      _message = null;
    });
    final result = await _service.cleanup(scan);
    final refreshed = await _service.scan();
    if (!mounted) return;
    setState(() {
      _scan = refreshed;
      _clearing = false;
      _message = result.failed.isEmpty
          ? context.l10n.tr('已清除 {count} 项，共释放 {size}。', {
              'count': result.removed.length,
              'size': formatFileSize(result.removedBytes, const AppSettings()),
            })
          : context.l10n.tr('已清除 {removed} 项；{failed} 项无法删除，请查看详细日志。', {
              'removed': result.removed.length,
              'failed': result.failed.length,
            });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final scan = _scan;
    final items = scan?.items ?? const <MaintenanceItem>[];
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cleaning_services_outlined, color: colors.primary),
          const SizedBox(width: 9),
          Expanded(child: Text(l10n.tr('旧版本与安装包清理'))),
        ],
      ),
      content: SizedBox(
        width: 680,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.tr('当前版本：{version}。只清理旧版本、旧安装包和旧平铺程序文件，不删除 userdata 数据。', {
                'version': scan?.currentVersion ?? '—',
              }),
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            if (_scanning)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 42),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        l10n.tr('未发现旧版本或旧安装包，当前目录已经是干净状态。'),
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  l10n.tr('扫描到 {count} 项，可释放 {size}。', {
                    'count': items.length,
                    'size': formatFileSize(
                      scan!.totalBytes,
                      const AppSettings(),
                    ),
                  }),
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                constraints: const BoxConstraints(maxHeight: 330),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.6),
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        _kindIcon(item.kind),
                        size: 18,
                        color: colors.primary,
                      ),
                      title: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_kindLabel(l10n, item.kind)} · ${item.path}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10.5),
                      ),
                      trailing: Text(
                        formatFileSize(item.size, const AppSettings()),
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            if (_message != null) ...[
              const SizedBox(height: 10),
              Text(
                _message!,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _scanning || _clearing ? null : _scanFiles,
          icon: const Icon(Icons.refresh_rounded, size: 17),
          label: Text(l10n.tr('重新扫描')),
        ),
        FilledButton.icon(
          onPressed: _scanning || _clearing || items.isEmpty ? null : _clearAll,
          icon: _clearing
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.delete_sweep_rounded, size: 18),
          label: Text(l10n.tr('一键清除')),
          style: FilledButton.styleFrom(backgroundColor: colors.error),
        ),
        TextButton(
          onPressed: _clearing ? null : () => Navigator.pop(context),
          child: Text(l10n.tr('关闭')),
        ),
      ],
    );
  }

  IconData _kindIcon(MaintenanceItemKind kind) {
    return switch (kind) {
      MaintenanceItemKind.oldVersion => Icons.inventory_2_outlined,
      MaintenanceItemKind.updateArchive => Icons.archive_outlined,
      MaintenanceItemKind.partialDownload => Icons.downloading_rounded,
      MaintenanceItemKind.stagingDirectory => Icons.folder_delete_outlined,
      MaintenanceItemKind.legacyUpdater => Icons.code_off_rounded,
      MaintenanceItemKind.legacyFlatFile => Icons.insert_drive_file_outlined,
      MaintenanceItemKind.legacyFlatDirectory => Icons.folder_outlined,
    };
  }

  String _kindLabel(AppLocalizations l10n, MaintenanceItemKind kind) {
    final label = switch (kind) {
      MaintenanceItemKind.oldVersion => '旧版本目录',
      MaintenanceItemKind.updateArchive => '更新安装包',
      MaintenanceItemKind.partialDownload => '未完成下载',
      MaintenanceItemKind.stagingDirectory => '临时解压目录',
      MaintenanceItemKind.legacyUpdater => '旧更新脚本',
      MaintenanceItemKind.legacyFlatFile => '旧平铺程序文件',
      MaintenanceItemKind.legacyFlatDirectory => '旧平铺程序目录',
    };
    return l10n.tr(label);
  }
}
