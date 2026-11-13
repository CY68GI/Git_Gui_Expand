import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/constants/changelog.dart';
import '../../core/services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({super.key, this.showChangelogFirst = false});

  final bool showChangelogFirst;

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final UpdateService _service = UpdateService();
  UpdateCheckResult? _result;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    if (!widget.showChangelogFirst) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdates());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      content: SizedBox(
        width: 680,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 590),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.primary.withValues(alpha: 0.12),
                        colors.primary.withValues(alpha: 0.03),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.system_update_alt_rounded,
                          color: colors.onPrimary,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isChecking ? '正在检查更新' : '更新与发布日志',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${AppInfo.englishName} · 当前 v${AppInfo.version}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isChecking ? null : _checkForUpdates,
                        icon: _isChecking
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(_isChecking ? '检查中' : '检查更新'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_result != null) ...[
                        _buildResult(context, _result!),
                        const SizedBox(height: 18),
                      ],
                      const _SectionTitle(
                        icon: Icons.auto_awesome_rounded,
                        title: '当前版本亮点',
                      ),
                      const SizedBox(height: 9),
                      ...builtInChangelog.map(_buildChangelogCard),
                      if (_result?.releaseNotes.isNotEmpty == true) ...[
                        const SizedBox(height: 18),
                        const _SectionTitle(
                          icon: Icons.receipt_long_outlined,
                          title: '线上发布说明',
                        ),
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: SelectableText(
                            _result!.releaseNotes,
                            style: const TextStyle(
                              fontSize: 11.5,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        '更新检查通过 GitHub Releases 获取公开版本信息，不会自动下载或替换正在运行的程序。',
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _service.openExternalUrl(AppInfo.repositoryUrl),
          icon: const Icon(Icons.code_rounded, size: 16),
          label: const Text('打开仓库'),
        ),
        if (_result?.releaseUrl.isNotEmpty == true)
          FilledButton.icon(
            onPressed: () => _service.openExternalUrl(_result!.releaseUrl),
            icon: const Icon(Icons.download_rounded, size: 17),
            label: const Text('打开下载页面'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context, UpdateCheckResult result) {
    final colors = Theme.of(context).colorScheme;
    final (title, message, icon, color) = switch (result.status) {
      UpdateCheckStatus.updateAvailable => (
        '发现新版本 v${result.latestVersion}',
        result.releaseName.isEmpty ? result.message : result.releaseName,
        Icons.new_releases_rounded,
        colors.primary,
      ),
      UpdateCheckStatus.upToDate => (
        '已经是最新版本',
        result.message,
        Icons.check_circle_outline_rounded,
        const Color(0xFF16836C),
      ),
      UpdateCheckStatus.unavailable => (
        '暂时无法获取线上版本',
        result.message,
        Icons.cloud_off_outlined,
        const Color(0xFF9A7116),
      ),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangelogCard(ChangelogEntry entry) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'v${entry.version}',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.date,
                style: TextStyle(fontSize: 9.5, color: colors.onSurfaceVariant),
              ),
              const Spacer(),
              Text(
                entry.title,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...entry.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 11, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates() async {
    setState(() => _isChecking = true);
    final result = await _service.checkForUpdates();
    if (!mounted) return;
    setState(() {
      _result = result;
      _isChecking = false;
    });
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
