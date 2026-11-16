import 'package:flutter/material.dart';

import '../../core/constants/app_info.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/bundled_font.dart';
import '../../core/models/settings_models.dart';
import '../../core/services/app_log_service.dart';
import '../../core/services/app_storage_service.dart';
import '../../core/services/desktop_shortcut_service.dart';
import '../../core/services/font_catalog_service.dart';
import '../../core/services/update_service.dart';
import '../../core/utils/size_formatter.dart';
import '../repository/repository_controller.dart';

enum _SettingsSection { font, language, appearance, units, about }

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({
    super.key,
    required this.controller,
    this.fontCatalogService,
    this.desktopShortcutService,
  });

  final RepositoryController controller;
  final FontCatalogService? fontCatalogService;
  final DesktopShortcutService? desktopShortcutService;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late AppSettings _draft = widget.controller.settings;
  late final FontCatalogService _fontCatalog =
      widget.fontCatalogService ?? FontCatalogService();
  late final DesktopShortcutService _desktopShortcuts =
      widget.desktopShortcutService ?? const DesktopShortcutService();
  final UpdateService _externalLinks = const UpdateService();
  final TextEditingController _fontSearchController = TextEditingController();
  List<String> _fontFamilies = const [];
  bool _loadingFonts = true;
  bool _saving = false;
  bool _creatingShortcut = false;
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
        constraints: BoxConstraints(
          maxWidth: 1000,
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
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
                  Text(
                    context.l10n.tr('设置'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _saving ? null : () => Navigator.pop(context),
                    tooltip: context.l10n.tr('关闭'),
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
                          label: context.l10n.tr('字体'),
                          selected: _section == _SettingsSection.font,
                          onTap: () => _selectSection(_SettingsSection.font),
                        ),
                        _SettingsNavItem(
                          icon: Icons.translate_rounded,
                          label: context.l10n.tr('语言'),
                          selected: _section == _SettingsSection.language,
                          onTap: () =>
                              _selectSection(_SettingsSection.language),
                        ),
                        _SettingsNavItem(
                          icon: Icons.brightness_6_outlined,
                          label: context.l10n.tr('外观模式'),
                          selected: _section == _SettingsSection.appearance,
                          onTap: () =>
                              _selectSection(_SettingsSection.appearance),
                        ),
                        _SettingsNavItem(
                          icon: Icons.straighten_rounded,
                          label: context.l10n.tr('单位设置'),
                          selected: _section == _SettingsSection.units,
                          onTap: () => _selectSection(_SettingsSection.units),
                        ),
                        _SettingsNavItem(
                          icon: Icons.info_outline_rounded,
                          label: context.l10n.tr('关于'),
                          selected: _section == _SettingsSection.about,
                          onTap: () => _selectSection(_SettingsSection.about),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'Git GUI Expand\nv${AppInfo.version}',
                            style: TextStyle(
                              fontSize: 11,
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
                                    ? context.l10n.tr('关于信息不会修改设置')
                                    : context.l10n.tr('设置将在点击保存后应用到整个软件'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(context.l10n.tr('取消')),
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
                                label: Text(context.l10n.tr('保存设置')),
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
      _SettingsSection.language => _buildLanguagePage(context),
      _SettingsSection.appearance => _buildAppearancePage(context),
      _SettingsSection.units => _buildUnitsPage(context),
      _SettingsSection.about => _buildAboutPage(context),
    };
  }

  Widget _buildLanguagePage(BuildContext context) {
    final l10n = context.l10n;
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _SettingsPage(
      title: l10n.tr('语言设置'),
      subtitle: l10n.tr('选择软件显示语言。默认跟随操作系统语言。'),
      children: [
        _SectionLabel(
          title: l10n.tr('界面语言'),
          caption: l10n.tr('语言更改会在保存设置后立即生效。'),
        ),
        const SizedBox(height: 12),
        for (final preference in AppLanguagePreference.values) ...[
          _LanguageOptionCard(
            preference: preference,
            systemLocale: systemLocale,
            selected: _draft.languagePreference == preference,
            onTap: () {
              setState(() {
                _draft = _draft.copyWith(languagePreference: preference);
              });
            },
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildFontPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final bundledFonts = _filteredBundledFonts;
    final systemFonts = _filteredSystemFonts;
    final resultCount = bundledFonts.length + systemFonts.length + 1;
    return _SettingsPage(
      title: l10n.tr('字体'),
      subtitle: l10n.tr('默认使用内置的 Noto Sans SC / 思源黑体，也可搜索系统字体或其他内置字体。'),
      children: [
        _SettingsScrollHint(
          title: l10n.tr('此页还有下方内容'),
          message: l10n.tr('向下滚动可查看字体预览和字体大小设置。'),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _fontSearchController,
          onChanged: (value) => setState(() => _fontQuery = value),
          decoration: InputDecoration(
            hintText: l10n.tr('搜索字体名称或用途，例如 Inter、思源、中文'),
            prefixIcon: const Icon(Icons.search_rounded, size: 19),
            suffixIcon: _fontQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: l10n.tr('清除搜索'),
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
              l10n.tr('找到 {count} 个选项', {'count': resultCount}),
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
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
                l10n.tr('输入名称可快速筛选'),
                style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
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
                label: l10n.tr('软件内置 UI 字体'),
                count: bundledFonts.length,
              ),
              if (bundledFonts.isEmpty)
                _FontEmptyRow(label: l10n.tr('没有匹配的内置字体'))
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
                label: l10n.tr('系统自带'),
                count: systemFonts.length + 1,
              ),
              _SystemFontRow(
                label: l10n.tr('系统默认（自动适配）'),
                detail: l10n.tr('跟随当前操作系统，不固定字体族'),
                fontFamily: null,
                selected: _draft.fontFamily.isEmpty,
                onTap: () {
                  setState(() {
                    _draft = _draft.copyWith(fontFamily: '');
                  });
                },
              ),
              if (systemFonts.isEmpty)
                _FontEmptyRow(label: l10n.tr('没有匹配的系统字体'))
              else
                for (final font in systemFonts)
                  _SystemFontRow(
                    label: font,
                    detail: l10n.tr('系统已安装字体'),
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
          l10n.tr('内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。'),
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        _SectionLabel(
          title: l10n.tr('字体预览'),
          caption: l10n.tr('保存后会应用到菜单、资源面板、对话框和提交说明。'),
        ),
        const SizedBox(height: 10),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('Git GUI Expand · 文件提交'),
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
                l10n.tr('剪切、复制、重命名、推送与提交   0123456789'),
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
        const SizedBox(height: 22),
        _SectionLabel(
          title: l10n.tr('字体大小'),
          caption: l10n.tr('仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<double>(
            segments: const [
              ButtonSegment(
                value: AppSettings.minFontScale,
                label: Text('90%'),
                icon: Icon(Icons.text_decrease_rounded, size: 17),
              ),
              ButtonSegment(
                value: AppSettings.defaultFontScale,
                label: Text('100%'),
                icon: Icon(Icons.text_fields_rounded, size: 17),
              ),
              ButtonSegment(
                value: AppSettings.maxFontScale,
                label: Text('110%'),
                icon: Icon(Icons.text_increase_rounded, size: 17),
              ),
            ],
            selected: {_draft.fontScale},
            onSelectionChanged: (value) {
              setState(() {
                _draft = _draft.copyWith(fontScale: value.first);
              });
            },
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.tr('允许范围：{min}%–{max}%', {
            'min': (AppSettings.minFontScale * 100).round(),
            'max': (AppSettings.maxFontScale * 100).round(),
          }),
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAppearancePage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return _SettingsPage(
      title: l10n.tr('外观模式'),
      subtitle: l10n.tr('跟随系统会根据设备当前的深色或浅色外观自动切换。'),
      children: [
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<AppThemePreference>(
            segments: [
              ButtonSegment(
                value: AppThemePreference.system,
                label: Text(l10n.tr('跟随系统')),
                icon: const Icon(Icons.brightness_auto_rounded, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.light,
                label: Text(l10n.tr('浅色')),
                icon: const Icon(Icons.light_mode_outlined, size: 18),
              ),
              ButtonSegment(
                value: AppThemePreference.dark,
                label: Text(l10n.tr('深色')),
                icon: const Icon(Icons.dark_mode_outlined, size: 18),
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
                label: l10n.tr('浅色'),
                background: Colors.white,
                foreground: const Color(0xFF17211E),
                border: const Color(0xFFDDE4E0),
              ),
              const SizedBox(width: 12),
              _ThemeSwatch(
                icon: Icons.dark_mode_rounded,
                label: l10n.tr('深色'),
                background: const Color(0xFF171E1B),
                foreground: const Color(0xFFE8EFEA),
                border: const Color(0xFF33413B),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.tr('当前选择：{theme}', {
                    'theme': _themeLabel(l10n, _draft.themePreference),
                  }),
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
    final l10n = context.l10n;
    final dataPath = const AppStorageService().dataDirectory.path;
    return _SettingsPage(
      title: l10n.tr('单位设置'),
      subtitle: l10n.tr('控制项目大小和每个文件大小的显示方式。'),
      children: [
        _SectionLabel(
          title: l10n.tr('容量单位制'),
          caption: l10n.tr('二进制使用 1024 进位，十进制使用 1000 进位。'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SizeUnitSystem>(
            segments: [
              ButtonSegment(
                value: SizeUnitSystem.binary,
                label: Text(l10n.tr('IEC 二进制')),
                icon: const Icon(Icons.memory_rounded, size: 17),
              ),
              ButtonSegment(
                value: SizeUnitSystem.decimal,
                label: Text(l10n.tr('SI 十进制')),
                icon: const Icon(Icons.straighten_rounded, size: 17),
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
        _SectionLabel(
          title: l10n.tr('基础单位'),
          caption: l10n.tr('Byte 显示 B、KiB 或 KB；bit 会先乘以 8。'),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<SizeBaseUnit>(
            segments: [
              ButtonSegment(
                value: SizeBaseUnit.byte,
                label: Text(l10n.tr('Byte（B）')),
              ),
              ButtonSegment(
                value: SizeBaseUnit.bit,
                label: Text(l10n.tr('bit（b）')),
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
                    l10n.tr('单位预览'),
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
                    label: l10n.tr('小文件'),
                    value: formatFileSize(1536, _draft),
                  ),
                  _PreviewValue(
                    label: l10n.tr('中文件'),
                    value: formatFileSize(1572864, _draft),
                  ),
                  _PreviewValue(
                    label: l10n.tr('大文件'),
                    value: formatFileSize(1610612736, _draft),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(sizeUnitDescription(_draft)),
                style: TextStyle(
                  fontSize: 11.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.tr('设置数据目录'),
          style: TextStyle(fontSize: 11.5, color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 3),
        SelectableText(
          dataPath,
          style: TextStyle(fontSize: 11, color: colors.primary),
        ),
      ],
    );
  }

  Widget _buildAboutPage(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return _SettingsPage(
      title: l10n.tr('关于'),
      subtitle: l10n.tr('Windows 优先的 Flutter Git 图形化文件工作区。'),
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
                      l10n.tr('版本 v{version}', {'version': AppInfo.version}),
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n.tr('通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。'),
                      style: TextStyle(
                        fontSize: 12,
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
                label: Text(l10n.tr('打开仓库')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _SettingsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.tr('桌面快捷方式'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                l10n.tr('在当前用户桌面创建 Git GUI Expand 快捷方式，并通过稳定 Launcher 启动。'),
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 11),
              FilledButton.tonalIcon(
                onPressed: _creatingShortcut ? null : _createDesktopShortcut,
                icon: _creatingShortcut
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_to_drive_rounded, size: 17),
                label: Text(
                  l10n.tr(_creatingShortcut ? '正在创建快捷方式…' : '一键发送到桌面'),
                ),
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
                  Text(
                    l10n.tr('致谢'),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                l10n.tr(
                  '感谢 DeepSeek 人工智能和 ChatGPT Codex，'
                  '两者合力创建、编写、修改此项目。',
                ),
                style: const TextStyle(fontSize: 11.5, height: 1.65),
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
          l10n.tr('本项目为开源项目，未附带许可证；分发或商用前请由项目所有者补充许可证。'),
          style: TextStyle(
            fontSize: 11.5,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemePreference preference) {
    final label = switch (preference) {
      AppThemePreference.system => '跟随系统',
      AppThemePreference.light => '浅色',
      AppThemePreference.dark => '深色',
    };
    return l10n.tr(label);
  }

  void _selectSection(_SettingsSection section) {
    if (_section == section) return;
    setState(() => _section = section);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    AppLogService.instance.setLocale(
      AppLocalizations.localeForPreference(_draft.languagePreference),
    );
    final outcome = await widget.controller.updateSettings(_draft);
    if (!mounted) return;
    setState(() => _saving = false);
    if (outcome.isSuccess) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.tr(outcome.message)),
        backgroundColor: const Color(0xFF7B3434),
      ),
    );
  }

  Future<void> _createDesktopShortcut() async {
    setState(() => _creatingShortcut = true);
    final result = await _desktopShortcuts.create();
    if (!mounted) return;
    setState(() => _creatingShortcut = false);
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.tr(result.message)),
        backgroundColor: result.isSuccess
            ? const Color(0xFF1C3D35)
            : colors.error,
        duration: const Duration(seconds: 5),
        showCloseIcon: true,
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
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
                fontSize: 10,
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
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.tr(font.description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 10.5,
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
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsPage extends StatefulWidget {
  const _SettingsPage({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  State<_SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<_SettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 5),
            Text(
              widget.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ...widget.children,
          ],
        ),
      ),
    );
  }
}

class _SettingsScrollHint extends StatelessWidget {
  const _SettingsScrollHint({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.keyboard_double_arrow_down_rounded,
            size: 21,
            color: colors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
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
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.preference,
    required this.systemLocale,
    required this.selected,
    required this.onTap,
  });

  final AppLanguagePreference preference;
  final Locale systemLocale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.08)
          : colors.surfaceContainerLow.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  preference == AppLanguagePreference.system
                      ? Icons.computer_rounded
                      : Icons.language_rounded,
                  size: 19,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.languageOptionLabel(
                        preference,
                        systemLocale: systemLocale,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.languageOptionDescription(
                        preference,
                        systemLocale: systemLocale,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 20,
                color: selected ? colors.primary : colors.outline,
              ),
            ],
          ),
        ),
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
            fontSize: 11.5,
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
            fontSize: 11,
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
          fontSize: 10.5,
          color: colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
