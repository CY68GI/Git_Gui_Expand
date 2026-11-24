import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/runtime_messages.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/models/operation_safety.dart';
import 'package:git_gui_expand/core/models/recent_repository.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';
import 'package:git_gui_expand/core/services/font_catalog_service.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';
import 'package:git_gui_expand/features/dialogs/remote_management_dialog.dart';
import 'package:git_gui_expand/features/dialogs/repository_sync_dialog.dart';
import 'package:git_gui_expand/features/dialogs/settings_dialog.dart';
import 'package:git_gui_expand/features/explorer/file_explorer_panel.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';
import 'package:git_gui_expand/features/start/start_view.dart';

import 'support/localized_message_fixture.dart';

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
        title: RuntimeMessages.messageFor(
          'planTitleRename',
          parameters: {'source': 'docs/这是一个很长很长的说明文档文件名.md'},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionRename',
          parameters: {
            'source': 'docs/这是一个很长很长的说明文档文件名.md',
            'newName': 'README-完整使用说明与操作计划.md',
          },
        ),
        run: () async => OperationOutcome.success(fixtureMessage('renamed')),
      ),
      PlannedRepositoryOperation(
        id: 'delete',
        kind: PlannedOperationKind.delete,
        title: RuntimeMessages.messageFor(
          'planTitleDelete',
          parameters: {'count': 2},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionDelete',
          parameters: {
            'count': 2,
            'paths':
                'docs/这是一个很长很长的说明文档文件名.md | '
                'src/another/deeply/nested/example.dart',
          },
        ),
        isDangerous: true,
        run: () async => OperationOutcome.success(fixtureMessage('deleted')),
      ),
      PlannedRepositoryOperation(
        id: 'clear',
        kind: PlannedOperationKind.clearRemote,
        title: RuntimeMessages.messageFor(
          'planTitleClearRemote',
          parameters: {'remote': 'origin'},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionClearRemote',
          parameters: {
            'project': 'Git_Gui_Expand',
            'branch': 'main',
            'branches': 1,
            'tags': 0,
            'message': '仓库已清除',
          },
        ),
        isDangerous: true,
        strongConfirmationText: 'CY68GI/Git_Gui_Expand/main',
        run: () async => OperationOutcome.success(fixtureMessage('cleared')),
      ),
    ];

    await tester.pumpWidget(
      _visualApp(OperationPlanDialog(planHost: controller)),
    );
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/operation_plan_dark_110.png'),
    );
  });

  testWidgets('start page screenshot in dark 110 percent layout', (
    WidgetTester tester,
  ) async {
    await _setViewport(tester);
    final today = DateTime.now();
    await tester.pumpWidget(
      _visualApp(
        StartView(
          onOpenRepository: () {},
          onOpenEmptyFolder: () {},
          onCloneRepository: () {},
          isOpening: false,
          recentRepositories: [
            RecentRepository(
              path: 'C:\\Projects\\Git_Gui_Expand_Test_Repository',
              lastOpened: DateTime(today.year, today.month, today.day, 10, 30),
            ),
          ],
          onOpenRecent: (_) async {},
          onRemoveRecent: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/start_page_dark_110.png'),
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
        title: RuntimeMessages.messageFor('planTitleCommitAll'),
        description: RuntimeMessages.messageFor(
          'planDescriptionCommitAll',
          parameters: {'message': '完善文件操作计划、危险确认、长文本显示和用户指南。'},
        ),
        run: () async => OperationOutcome.success(fixtureMessage('committed')),
      ),
      PlannedRepositoryOperation(
        id: 'push',
        kind: PlannedOperationKind.pushAllRemotes,
        title: RuntimeMessages.messageFor(
          'planTitlePushAllRemotes',
          parameters: {'count': 2},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionPushAllRemotes',
          parameters: {'remotes': 'origin | gitee'},
        ),
        run: () async => OperationOutcome.success(fixtureMessage('pushed')),
      ),
    ];

    await tester.pumpWidget(
      _visualApp(
        OperationPlanDialog(planHost: controller),
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

  testWidgets('operation plan drift recovery is readable at 90 percent', (
    WidgetTester tester,
  ) async {
    await _pumpDriftPlan(
      tester,
      textScale: 0.9,
      themeMode: ThemeMode.light,
      golden: 'goldens/operation_plan_drift_light_90.png',
    );
  });

  testWidgets('operation plan drift recovery is readable at 100 percent', (
    WidgetTester tester,
  ) async {
    await _pumpDriftPlan(
      tester,
      textScale: 1,
      themeMode: ThemeMode.dark,
      golden: 'goldens/operation_plan_drift_dark_100.png',
    );
  });

  testWidgets('operation plan drift recovery is readable at 110 percent', (
    WidgetTester tester,
  ) async {
    await _pumpDriftPlan(
      tester,
      textScale: 1.1,
      themeMode: ThemeMode.dark,
      golden: 'goldens/operation_plan_drift_dark_110.png',
    );
  });

  testWidgets('repository sync dialog is readable at 90 percent', (
    WidgetTester tester,
  ) async {
    await _pumpSyncDialog(
      tester,
      textScale: 0.9,
      themeMode: ThemeMode.light,
      golden: 'goldens/repository_sync_light_90.png',
    );
  });

  testWidgets('repository sync dialog is readable at 100 percent', (
    WidgetTester tester,
  ) async {
    await _pumpSyncDialog(
      tester,
      textScale: 1,
      themeMode: ThemeMode.dark,
      golden: 'goldens/repository_sync_dark_100.png',
    );
  });

  testWidgets('repository sync dialog is readable at 110 percent', (
    WidgetTester tester,
  ) async {
    await _pumpSyncDialog(
      tester,
      textScale: 1.1,
      themeMode: ThemeMode.dark,
      golden: 'goldens/repository_sync_dark_110.png',
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

Future<void> _pumpDriftPlan(
  WidgetTester tester, {
  required double textScale,
  required ThemeMode themeMode,
  required String golden,
}) async {
  await _setViewport(tester);
  final host = _DriftPlanHost();
  addTearDown(host.dispose);
  await tester.pumpWidget(
    _visualApp(
      OperationPlanDialog(planHost: host),
      textScale: textScale,
      themeMode: themeMode,
    ),
  );
  await tester.tap(find.text('确认并逐步执行'));
  await tester.pumpAndSettle();

  expect(find.text('执行前状态已变化'), findsOneWidget);
  expect(find.text('状态变化详情'), findsOneWidget);
  expect(find.text('刷新仓库并重建计划'), findsOneWidget);
  expect(tester.takeException(), isNull);
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
}

class _DriftPlanHost extends ChangeNotifier implements OperationPlanHost {
  _DriftPlanHost()
    : pendingOperations = [
        PlannedRepositoryOperation(
          id: 'drift',
          kind: PlannedOperationKind.rename,
          title: RuntimeMessages.messageFor(
            'planTitleRename',
            parameters: {'source': 'docs/这是用于验证漂移提示的长文件名.md'},
          ),
          description: RuntimeMessages.messageFor(
            'planDescriptionRename',
            parameters: {
              'source': 'docs/这是用于验证漂移提示的长文件名.md',
              'newName': 'README.md',
            },
          ),
          run: () async => OperationOutcome.success(fixtureMessage('not run')),
        ),
      ];

  @override
  List<PlannedRepositoryOperation> pendingOperations;

  @override
  bool get canExecutePlan => pendingOperations.isNotEmpty && !isBusy;

  @override
  bool get isBusy => false;

  @override
  OperationOutcome clearPendingOperations() {
    pendingOperations = const [];
    notifyListeners();
    return OperationOutcome.success(fixtureMessage('Cleared'));
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    return OperationPlanResult(
      isSuccess: false,
      message: RuntimeMessages.messageFor('planStateChanged'),
      completed: 0,
      total: pendingOperations.length,
      remaining: pendingOperations,
      validation: const OperationValidationResult.failure([
        OperationDrift(
          kind: OperationDriftKind.branch,
          label: 'branch',
          expected: 'main',
          actual: 'feature/repository-operation-safety-with-a-very-long-name',
        ),
        OperationDrift(
          kind: OperationDriftKind.status,
          label: 'status',
          expected: '(clean)',
          actual: ' M docs/一个很长的文件名称.md',
        ),
      ]),
    );
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    pendingOperations = pendingOperations
        .where((operation) => operation.id != id)
        .toList(growable: false);
    notifyListeners();
    return OperationOutcome.success(fixtureMessage('Removed'));
  }

  @override
  Future<void> recoverFromSafetyRejection() async {
    pendingOperations = const [];
    notifyListeners();
  }
}

Future<void> _pumpSyncDialog(
  WidgetTester tester, {
  required double textScale,
  required ThemeMode themeMode,
  required String golden,
}) async {
  await _setViewport(tester);
  final controller = RepositoryController()
    ..branch = 'feature/repository-synchronization-with-a-long-name'
    ..syncState = const BranchSyncState(
      kind: BranchSyncKind.tracked,
      branch: 'feature/repository-synchronization-with-a-long-name',
      upstreamRef: 'origin/feature/repository-synchronization-with-a-long-name',
      upstreamRemote: 'origin',
      upstreamBranch: 'feature/repository-synchronization-with-a-long-name',
      ahead: 2,
      behind: 11,
      worktreeClean: true,
    )
    ..remotes = const [
      GitRemote(
        name: 'origin',
        fetchUrl: 'git@github.com:CY68GI/Git_Gui_Expand.git',
        pushUrl: 'git@github.com:CY68GI/Git_Gui_Expand.git',
        platform: GitRemotePlatform.github,
      ),
    ];
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    _visualApp(
      RepositorySyncDialog(controller: controller),
      textScale: textScale,
      themeMode: themeMode,
    ),
  );
  await tester.pump();

  expect(find.text('分支同步'), findsOneWidget);
  expect(find.textContaining('不会自动 Merge 或 Rebase'), findsOneWidget);
  expect(tester.takeException(), isNull);
  await expectLater(find.byType(MaterialApp), matchesGoldenFile(golden));
}
