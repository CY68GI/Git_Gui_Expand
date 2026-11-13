import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/models/bundled_font.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/services/font_catalog_service.dart';
import '../../core/services/update_service.dart';
import '../../core/utils/size_formatter.dart';
import '../repository/repository_controller.dart';

enum _SettingsSection { font, appearance, units, about }

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.controller,
    this.fontCatalogService,
  });

  final RepositoryController controller;
  final FontCatalogService? fontCatalogService;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _draft = widget.controller.settings;
  late final FontCatalogService _fontCatalog =
      widget.fontCatalogService ?? FontCatalogService();
  final UpdateService _externalLinks = const UpdateService();
  final TextEditingController _fontSearchController = TextEditingController();
  List<String> _fontFamilies = const [];
  bool _loadingFonts = true;
  bool _saving = false;
  _SettingsSection _section = _SettingsSection.font;

  @override
  void initState() {
    super.initState();
    _loadFonts();
  }

  @override
  void dispose() {
    _fontSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadFonts() async {
    final fonts = await _fontCatalog.loadInstalledFonts();
    if (!mounted) return;
    setState(() {
      _fontFamilies = fonts;
      _loadingFonts = false;
    });
  }

  String _fontQuery = '';

  List<BundledFontOption> get _filteredBundledFonts {
    final query = _fontQuery.trim().toLowerCase();
    if (query.isEmpty) return bundledUiFonts;
    return bundledUiFonts
        .where(
          (font) =>
              font.label.toLowerCase().contains(query) ||
              font.family.toLowerCase().contains(query) ||
              font.description.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  List<String> get _filteredSystemFonts {
    final bundledFamilies = bundledUiFonts
        .map((font) => font.family.toLowerCase())
        .toSet();
    final query = _fontQuery.trim().toLowerCase();
    final filtered = _fontFamilies
        .where(
          (font) =>
              !bundledFamilies.contains(font.toLowerCase()) &&
              (query.isEmpty || font.toLowerCase().contains(query)),
        )
        .toList(growable: false);
    if (_draft.fontFamily.isNotEmpty &&
        !bundledFamilies.contains(_draft.fontFamily.toLowerCase()) &&
        !filtered.contains(_draft.fontFamily)) {
      return [_draft.fontFamily, ...filtered];
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: const EdgeInsets.all(28),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 650),
        child: Column(
          children: [
            Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 19,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Text(
                    '设置',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    tooltip: '关闭',
                    icon: const Icon(Icons.close_rounded, size: 19),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 190,
                    color: colors.surfaceContainerLow.withValues(alpha: 0.6),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsNavItem(
                          icon: Icons.font_download_outlined,
                          label: '字体',
                          selected: _section == _SettingsSection.font,
                          onTap: () => _selectSection(_SettingsSection.font),
                        ),
                        _SettingsNavItem(
                          icon: Icons.brightness_6_outlined,
                          label: '外观模式',
                          selected: _section == _SettingsSection.appearance,
                          onTap: () =>
                              _selectSection(_SettingsSection.appearance),
                        ),
                        _SettingsNavItem(
                          icon: Icons.straighten_rounded,
                          label: '单位设置',
                          selected: _section == _SettingsSection.units,
                          onTap: () => _selectSection(_SettingsSection.units),
                        ),
                        _SettingsNavItem(
                          icon: Icons.info_outline_rounded,
                          label: '关于',
                          selected: _section == _SettingsSection.about,
                          onTap: () => _selectSection(_SettingsSection.about),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Git GUI Expand\nv${AppInfo.version}',
                            style: TextStyle(
                              fontSize: 9.5,
                              height: 1.5,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(width: 1, color: colors.outlineVariant),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: KeyedSubtree(
                              key: ValueKey(_section),
                              child: _buildSection(context),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerLow,
                            border: Border(
                              top: BorderSide(color: colors.outlineVariant),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _section == _SettingsSection.about
                                    ? '关于信息不会修改设置'
                                    : '设置将在点击保存后应用到整个软件',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: const Text('取消'),
                              ),
                              const SizedBox(width: 4),
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
                          ),
                        ),
                      ],
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

  Widget _buildSection(BuildContext context) {
    return switch (_section) {
      _SettingsSection.font => _buildFontPage(context),
      _SettingsSection.appearance => _buildAppearancePage(context),
      _SettingsSection.units => _buildUnitsPage(context),
      _SettingsSection.about => _buildAboutPage(context),
    };
  }

  Widget _buildFontPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bundledFonts = _filteredBundledFonts;
    final systemFonts = _filteredSystemFonts;
    final resultCount = bundledFonts.length + systemFonts.length + 1;
    return _SettingsPage(
      title: '字体',
      subtitle: '默认使用内置的 Noto Sans SC / 思源黑体，也可搜索系统字体或其他内置字体。',
      children: [
        TextField(
          controller: _fontSearchController,
          onChanged: (value) => setState(() => _fontQuery = value),
          decoration: InputDecoration(
            hintText: '搜索字体名称或用途，例如 Inter、思源、中文',
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: _fontQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: '清除搜索',
                    onPressed: () {
                      _fontSearchController.clear();
                      setState(() => _fontQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 17),
                  ),
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Text(
              '找到 $resultCount 个选项',
              style: TextStyle(fontSize: 9.5, color: colors.onSurfaceVariant),
            ),
            const Spacer(),
            if (_loadingFonts)
              const SizedBox(
                width: 13,
                height: 13,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '输入名称可快速筛选',
                style: TextStyle(fontSize: 9.5, color: colors.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 320,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: [
              _FontGroupHeader(
                icon: Icons.inventory_2_outlined,
                label: '软件内置 UI 字体',
                count: bundledFonts.length,
              ),
              if (bundledFonts.isEmpty)
                const _FontEmptyRow(label: '没有匹配的内置字体')
              else
                for (final font in bundledFonts)
                  _BundledFontRow(
                    font: font,
                    selected: _draft.fontFamily == font.family,
                    onTap: () {
                      setState(() {
                        _draft = _draft.copyWith(fontFamily: font.family);
                      });
                    },
                  ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                child: Divider(height: 1),
              ),
              _FontGroupHeader(
                icon: Icons.computer_rounded,
                label: '系统自带',
                count: systemFonts.length + 1,
              ),
              _SystemFontRow(
                label: '系统默认（自动适配）',
                detail: '跟随当前操作系统，不固定字体族',
                fontFamily: null,
                selected: _draft.fontFamily.isEmpty,
                onTap: () {
                  setState(() {
                    _draft = _draft.copyWith(fontFamily: '');
                  });
                },
              ),
              if (systemFonts.isEmpty)
                const _FontEmptyRow(label: '没有匹配的系统字体')
              else
                for (final font in systemFonts)
                  _SystemFontRow(
                    label: font,
                    detail: '系统已安装字体',
                    fontFamily: font,
                    selected: _draft.fontFamily == font,
                    onTap: () {
                      setState(() {
                        _draft = _draft.copyWith(fontFamily: font);
                      });
                    },
                  ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。',
          style: TextStyle(fontSize: 9.5, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        const _SectionLabel(title: '字体预览', caption: '保存后会应用到菜单、资源面板、对话框和提交说明。'),
        const SizedBox(height: 10),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Git GUI Expand · 文件提交',
                style: TextStyle(
                  fontFamily: _draft.fontFamily.isEmpty
                      ? null
                      : _draft.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '剪切、复制、重命名、推送与提交   0123456789',
                style: TextStyle(
                  fontFamily: _draft.fontFamily.isEmpty
                      ? null
                      : _draft.fontFamily,
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearancePage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _SettingsPage(
      title: '外观模式',
      subtitle: '跟随系统会根据设备当前的深色或浅色外观自动切换。',
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppThemePreference>(
            segments: const [
              ButtonSegment(
                value: AppThemePreference.system,
                label: Text('跟随系统'),
                icon: Icon(Icons.brightness_auto_rounded, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.light,
                label: Text('浅色'),
                icon: Icon(Icons.light_mode_outlined, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                label: Text('深色'),
                icon: Icon(Icons.dark_mode_outlined, size: 18),
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
        const SizedBox(height: 20),
        _SettingsCard(
          child: Row(
            children: [
              _ThemeSwatch(
                icon: Icons.light_mode_rounded,
                label: '浅色',
                background: Colors.white,
                foreground: const Color(0xFF17211E),
                border: const Color(0xFFDDE4E0),
              ),
              const SizedBox(width: 12),
              _ThemeSwatch(
                icon: Icons.dark_mode_rounded,
                label: '深色',
                background: const Color(0xFF171E1B),
                foreground: const Color(0xFFE8EFEA),
                border: const Color(0xFF33413B),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '当前选择：${_themeLabel(_draft.themePreference)}',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dataPath = const AppStorageService().dataDirectory.path;
    return _SettingsPage(
      title: '单位设置',
      subtitle: '控制项目大小和每个文件大小的显示方式。',
      children: [
        const _SectionLabel(
          title: '容量单位制',
          caption: '二进制使用 1024 进位，十进制使用 1000 进位。',
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
          caption: 'Byte 显示 B、KiB 或 KB；bit 会先乘以 8。',
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SizeBaseUnit>(
            segments: const [
              ButtonSegment(value: SizeBaseUnit.byte, label: Text('Byte（B）')),
              ButtonSegment(value: SizeBaseUnit.bit, label: Text('bit（b）')),
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
        _SettingsCard(
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
              const SizedBox(height: 12),
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  _PreviewValue(
                    label: '小文件',
                    value: formatFileSize(1536, _draft),
                  ),
                  _PreviewValue(
                    label: '中文件',
                    value: formatFileSize(1572864, _draft),
                  ),
                  _PreviewValue(
                    label: '大文件',
                    value: formatFileSize(1610612736, _draft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                sizeUnitDescription(_draft),
                style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '设置数据目录',
          style: TextStyle(fontSize: 10, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        SelectableText(
          dataPath,
          style: TextStyle(fontSize: 9.5, color: colors.primary),
        ),
      ],
    );
  }

  Widget _buildAboutPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return _SettingsPage(
      title: '关于',
      subtitle: 'Windows 优先的 Flutter Git 图形化文件工作区。',
      children: [
        _SettingsCard(
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  'assets/icons/app_icon.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppInfo.englishName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '版本 v${AppInfo.version}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () =>
                    _externalLinks.openExternalUrl(AppInfo.repositoryUrl),
                icon: const Icon(Icons.code_rounded, size: 16),
                label: const Text('打开仓库'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '致谢',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '感谢 DeepSeek 人工智能和 ChatGPT Codex，'
                '两者合力创建、编写、修改此项目。',
                style: TextStyle(fontSize: 11.5, height: 1.65),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _AboutTag(label: 'Flutter'),
                  _AboutTag(label: 'Dart'),
                  _AboutTag(label: 'Git CLI'),
                  _AboutTag(label: 'Windows'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '本项目为开源项目，未附带许可证；分发或商用前请由项目所有者补充许可证。',
          style: TextStyle(
            fontSize: 9.5,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _themeLabel(AppThemePreference preference) {
    return switch (preference) {
      AppThemePreference.system => '跟随系统',
      AppThemePreference.light => '浅色',
      AppThemePreference.dark => '深色',
    };
  }

  void _selectSection(_SettingsSection section) {
    if (_section == section) return;
    setState(() => _section = section);
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

class _FontGroupHeader extends StatelessWidget {
  const _FontGroupHeader({
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 8.5,
                color: colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BundledFontRow extends StatelessWidget {
  const _BundledFontRow({
    required this.font,
    required this.selected,
    required this.onTap,
  });

  final BundledFontOption font;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      fontFamily: font.family,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
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
                            child: Text(
                              font.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: font.family,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '内置',
                              style: TextStyle(
                                color: colors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        font.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.2,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 17,
                    color: colors.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemFontRow extends StatelessWidget {
  const _SystemFontRow({
    required this.label,
    required this.detail,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String detail;
  final String? fontFamily;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 8.5,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, size: 17, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontEmptyRow extends StatelessWidget {
  const _FontEmptyRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10.5,
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  const _SettingsNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            height: 43,
            padding: const EdgeInsets.symmetric(horizontal: 11),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? colors.primary : colors.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: selected ? colors.primary : colors.onSurface,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
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

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.border,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      height: 72,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTag extends StatelessWidget {
  const _AboutTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
