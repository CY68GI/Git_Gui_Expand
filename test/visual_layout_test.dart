import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';
import 'package:git_gui_expand/core/services/font_catalog_service.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';
import 'package:git_gui_expand/features/dialogs/remote_management_dialog.dart';
import 'package:git_gui_expand/features/dialogs/settings_dialog.dart';
import 'package:git_gui_expand/features/explorer/file_explorer_panel.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('Noto Sans SC')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC-Variable.ttf'));
    await loader.load();
    final interLoader = FontLoader('Inter UI')
      ..addFont(rootBundle.load('assets/fonts/Inter-Variable.ttf'));
    await interLoader.load();
    final plexLoader = FontLoader('IBM Plex Sans')
      ..addFont(rootBundle.load('assets/fonts/IBMPlexSans-Variable.ttf'));
    await plexLoader.load();
    final flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      final iconFont = File(
        '$flutterRoot${Platform.pathSeparator}bin'
        '${Platform.pathSeparator}cache${Platform.pathSeparator}artifacts'
        '${Platform.pathSeparator}material_fonts'
        '${Platform.pathSeparator}materialicons-regular.otf',
      );
      if (await iconFont.exists()) {
        final iconLoader = FontLoader('MaterialIcons')
          ..addFont(iconFont.readAsBytes().then(ByteData.sublistView));
        await iconLoader.load();
      }
    }
  });

  testWidgets('operation plan remains readable in dark 110 percent layout', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.pendingOperations = [
      PlannedRepositoryOperation(
        id: 'rename',
        kind: PlannedOperationKind.rename,
        title: '重命名 docs/这是一个很长很长的说明文档文件名.md',
        description:
            '将 docs/这是一个很长很长的说明文档文件名.md 的新名称设为'
            ' README-完整使用说明与操作计划.md。',
        run: () async => const OperationOutcome.success('renamed'),
      ),
      PlannedRepositoryOperation(
        id: 'delete',
        kind: PlannedOperationKind.delete,
        title: '删除 2 个项目',
        description:
            '将永久删除 docs/这是一个很长很长的说明文档文件名.md、'
            'src/another/deeply/nested/example.dart。',
        isDangerous: true,
        run: () async => const OperationOutcome.success('deleted'),
      ),
      PlannedRepositoryOperation(
        id: 'clear',
        kind: PlannedOperationKind.clearRemote,
        title: '清空远端历史 origin',
        description: '项目 Git_Gui_Expand，目标分支 main。将保留一个空提交，删除其它分支和标签，本地内容不变。',
        isDangerous: true,
        strongConfirmationText: 'CY68GI/Git_Gui_Expand/main',
        run: () async => const OperationOutcome.success('cleared'),
      ),
    ];

    await tester.pumpWidget(
      _visualApp(OperationPlanDialog(controller: controller)),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/operation_plan_dark_110.png'),
    );
  });

  testWidgets('operation plan remains readable in light 90 percent layout', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.pendingOperations = [
      PlannedRepositoryOperation(
        id: 'commit',
        kind: PlannedOperationKind.commit,
        title: '提交全部更改',
        description:
            '提交说明：完善文件操作计划、危险确认、长文本显示和用户指南。'
            '执行时先运行 git add -A，再运行 git commit。',
        run: () async => const OperationOutcome.success('committed'),
      ),
      PlannedRepositoryOperation(
        id: 'push',
        kind: PlannedOperationKind.pushAllRemotes,
        title: '推送到全部 2 个远端',
        description: '依次推送当前分支到：origin、gitee。',
        run: () async => const OperationOutcome.success('pushed'),
      ),
    ];

    await tester.pumpWidget(
      _visualApp(
        OperationPlanDialog(controller: controller),
        themeMode: ThemeMode.light,
        textScale: 0.9,
      ),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/operation_plan_light_90.png'),
    );
  });

  testWidgets('remote manager handles long names in dark 110 percent layout', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.branch = 'feature/a-very-long-branch-name-for-layout-validation';
    controller.remotes = const [
      GitRemote(
        name: 'origin-with-a-very-long-remote-name',
        fetchUrl:
            'git@github.com:an-organization-with-a-long-name/'
            'a-repository-with-a-very-long-name.git',
        pushUrl:
            'git@github.com:an-organization-with-a-long-name/'
            'a-repository-with-a-very-long-name.git',
        platform: GitRemotePlatform.github,
      ),
      GitRemote(
        name: 'gitee',
        fetchUrl:
            'https://gitee.com/an-organization-with-a-long-name/'
            'a-repository-with-a-very-long-name.git',
        pushUrl:
            'https://gitee.com/an-organization-with-a-long-name/'
            'a-repository-with-a-very-long-name.git',
        platform: GitRemotePlatform.gitee,
      ),
    ];

    await tester.pumpWidget(
      _visualApp(RemoteManagementDialog(controller: controller)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/remote_manager_dark_110.png'),
    );
  });

  testWidgets('font settings expose the scroll hint in dark 110 percent', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _visualApp(
        SettingsDialog(
          controller: controller,
          fontCatalogService: _FakeFontCatalogService(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('此页还有下方内容'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings_font_dark_110.png'),
    );
  });

  testWidgets('language settings describe every option in its own language', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _visualApp(
        SettingsDialog(
          controller: controller,
          fontCatalogService: _FakeFontCatalogService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('语言'));
    await tester.pumpAndSettle();

    expect(find.text('English'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(
      find.text('Use English for the application interface.'),
      findsOneWidget,
    );
    expect(find.text('使用简体中文显示软件界面。'), findsOneWidget);
    expect(find.text('使用繁體中文顯示軟體介面。'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings_language_dark_110.png'),
    );
  });

  testWidgets('appearance settings expose all color schemes without clipping', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _visualApp(
        SettingsDialog(
          controller: controller,
          fontCatalogService: _FakeFontCatalogService(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('外观设置'));
    await tester.pumpAndSettle();

    expect(find.text('配色方案'), findsWidgets);
    expect(find.text('经典绿'), findsOneWidget);
    expect(find.text('海洋蓝'), findsOneWidget);
    expect(find.text('星夜紫'), findsOneWidget);
    expect(find.text('琥珀金'), findsOneWidget);
    expect(find.text('玫瑰红'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/settings_appearance_dark_110.png'),
    );
  });

  testWidgets('file context menu stays readable in dark 110 percent', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.leftPanel = const ExplorerPanelState(
      entries: [
        RepositoryEntry(
          relativePath: 'docs/一个很长很长的使用说明文件名称.md',
          name: '一个很长很长的使用说明文件名称.md',
          kind: EntryKind.file,
          size: 2048,
        ),
      ],
    );
    await tester.pumpWidget(
      _visualApp(
        SizedBox(
          width: 900,
          height: 560,
          child: FileExplorerPanel(
            side: ExplorerSide.left,
            state: controller.leftPanel,
            rootPath: 'C:\\Projects\\Git_Gui_Expand',
            settings: const AppSettings(),
            isActive: true,
            controller: controller,
            showOutcome: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('一个很长很长的使用说明文件名称.md')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('用文件资源打开'), findsOneWidget);
    expect(find.text('用默认打开方式打开'), findsOneWidget);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/file_context_menu_dark_110.png'),
    );
  });
}

Future<void> _setViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _visualApp(
  Widget child, {
  ThemeMode themeMode = ThemeMode.dark,
  double textScale = 1.1,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light(fontFamily: 'Noto Sans SC'),
    darkTheme: AppTheme.dark(fontFamily: 'Noto Sans SC'),
    themeMode: themeMode,
    builder: (context, appChild) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(textScaler: TextScaler.linear(textScale)),
        child: appChild ?? const SizedBox.shrink(),
      );
    },
    home: Scaffold(body: Center(child: child)),
  );
}

class _FakeFontCatalogService extends FontCatalogService {
  @override
  Future<List<String>> loadInstalledFonts() async => const [
    'Segoe UI',
    'Microsoft YaHei UI',
    'SimSun',
  ];
}
