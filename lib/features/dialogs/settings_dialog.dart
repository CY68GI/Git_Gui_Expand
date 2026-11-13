import 'package:flutter/material.dart';

import '../../core/models/settings_models.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/utils/size_formatter.dart';
import '../repository/repository_controller.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.controller});

  final RepositoryController controller;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _draft = widget.controller.settings;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dataPath = const AppStorageService().dataDirectory.path;
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.tune_rounded, size: 22),
          SizedBox(width: 10),
          Text('显示设置'),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel(
                title: '外观模式',
                caption: '跟随系统会根据 Windows 深色/浅色设置自动切换。',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<AppThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: AppThemePreference.system,
                      label: Text('跟随系统'),
                      icon: Icon(Icons.brightness_auto_rounded, size: 17),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.light,
                      label: Text('浅色'),
                      icon: Icon(Icons.light_mode_outlined, size: 17),
                    ),
                    ButtonSegment(
                      value: AppThemePreference.dark,
                      label: Text('深色'),
                      icon: Icon(Icons.dark_mode_outlined, size: 17),
                    ),
                  ],
                  selected: {_draft.themePreference},
                  onSelectionChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(themePreference: value.first);
                    });
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel(
                title: '容量单位制',
                caption: '选择二进制（1024）或十进制（1000）进位方式。',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SizeUnitSystem>(
                  segments: const [
                    ButtonSegment(
                      value: SizeUnitSystem.binary,
                      label: Text('IEC 二进制'),
                      icon: Icon(Icons.memory_rounded, size: 17),
                    ),
                    ButtonSegment(
                      value: SizeUnitSystem.decimal,
                      label: Text('SI 十进制'),
                      icon: Icon(Icons.straighten_rounded, size: 17),
                    ),
                  ],
                  selected: {_draft.unitSystem},
                  onSelectionChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(unitSystem: value.first);
                    });
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 22),
              const _SectionLabel(
                title: '基础单位',
                caption: 'Byte 根据系统标准显示 B、KiB 或 KB；bit 会先乘以 8。',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<SizeBaseUnit>(
                  segments: const [
                    ButtonSegment(
                      value: SizeBaseUnit.byte,
                      label: Text('Byte（B）'),
                    ),
                    ButtonSegment(
                      value: SizeBaseUnit.bit,
                      label: Text('bit（b）'),
                    ),
                  ],
                  selected: {_draft.baseUnit},
                  onSelectionChanged: (value) {
                    setState(() {
                      _draft = _draft.copyWith(baseUnit: value.first);
                    });
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '单位预览',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        _PreviewValue(
                          label: '1 项小文件',
                          value: formatFileSize(1536, _draft),
                        ),
                        _PreviewValue(
                          label: '1 项中文件',
                          value: formatFileSize(1572864, _draft),
                        ),
                        _PreviewValue(
                          label: '1 项大文件',
                          value: formatFileSize(1610612736, _draft),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      sizeUnitDescription(_draft),
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '项目总大小与每个文件的大小会立即使用此单位显示。设置保存在软件目录的 userdata 文件夹。',
                style: TextStyle(
                  fontSize: 10.5,
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 7),
              SelectableText(
                dataPath,
                style: TextStyle(
                  fontSize: 9.5,
                  color: colors.primary,
                  fontFamily: 'Consolas',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : const Icon(Icons.check_rounded, size: 17),
          label: const Text('保存设置'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final outcome = await widget.controller.updateSettings(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (outcome.isSuccess) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(outcome.message),
        backgroundColor: const Color(0xFF7B3434),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 3),
        Text(
          caption,
          style: TextStyle(
            fontSize: 10.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PreviewValue extends StatelessWidget {
  const _PreviewValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
