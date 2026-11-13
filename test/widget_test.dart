import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/app.dart';
import 'package:git_gui_expand/core/models/recent_repository.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/services/font_catalog_service.dart';
import 'package:git_gui_expand/core/services/update_service.dart';
import 'package:git_gui_expand/features/dialogs/settings_dialog.dart';
import 'package:git_gui_expand/features/dialogs/remote_management_dialog.dart';
import 'package:git_gui_expand/features/dialogs/update_dialog.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';
import 'package:git_gui_expand/features/start/start_view.dart';

void main() {
  testWidgets('start screen presents repository opening workflow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GitGuiExpandApp());
    await tester.pumpAndSettle();

    expect(find.text('Git GUI Expand'), findsOneWidget);
    expect(find.text('打开 Git 仓库'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsWidgets);
    expect(find.textContaining('左右双栏'), findsOneWidget);
    expect(find.text('v0.8.2'), findsOneWidget);
  });

  testWidgets('recent Git repository can be opened from the start screen', (
    WidgetTester tester,
  ) async {
    String? openedPath;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StartView(
            onOpenRepository: () {},
            isOpening: false,
            recentRepositories: [
              RecentRepository(
                path: 'C:\\Projects\\sample_repo',
                lastOpened: DateTime(2026, 11, 13, 20, 30),
              ),
            ],
            onOpenRecent: (path) async {
              openedPath = path;
            },
            onRemoveRecent: (_) async {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.text('sample_repo'));
    await tester.pump();
    await tester.tap(find.text('sample_repo'));
    await tester.pump();
    expect(openedPath, 'C:\\Projects\\sample_repo');
    expect(find.text('最近打开'), findsOneWidget);
  });

  testWidgets(
    'update dialog offers automatic install without manual download',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UpdateDialog(updateService: _FakeUpdateService()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('立即更新并重启'), findsOneWidget);
      expect(find.text('打开发布页'), findsOneWidget);
      expect(find.text('打开下载页面'), findsNothing);
    },
  );

  testWidgets('settings page exposes all sections and attribution', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RepositoryController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingsDialog(
            controller: controller,
            fontCatalogService: _FakeFontCatalogService(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('字体'), findsWidgets);
    expect(find.text('软件内置 UI 字体'), findsOneWidget);
    expect(find.text('系统自带'), findsOneWidget);
    expect(find.text('Inter UI'), findsOneWidget);
    expect(find.text('Noto Sans SC / 思源黑体'), findsOneWidget);
    expect(find.text('字体大小'), findsOneWidget);
    expect(find.text('90%'), findsOneWidget);
    expect(find.text('110%'), findsOneWidget);
    expect(find.text('外观模式'), findsOneWidget);
    expect(find.text('单位设置'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '思源');
    await tester.pump();
    expect(find.text('Noto Sans SC / 思源黑体'), findsOneWidget);
    expect(find.text('Inter UI'), findsNothing);

    await tester.tap(find.text('关于'));
    await tester.pump();
    expect(
      find.text('感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。'),
      findsOneWidget,
    );
  });

  testWidgets('remote manager displays multiple repository platforms', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.remotes = const [
      GitRemote(
        name: 'origin',
        fetchUrl: 'git@github.com:CY68GI/Git_Gui_Expand.git',
        pushUrl: 'git@github.com:CY68GI/Git_Gui_Expand.git',
        platform: GitRemotePlatform.github,
      ),
      GitRemote(
        name: 'gitee',
        fetchUrl: 'git@gitee.com:CY68EWZRY/Git_Gui_Expand.git',
        pushUrl: 'git@gitee.com:CY68EWZRY/Git_Gui_Expand.git',
        platform: GitRemotePlatform.gitee,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RemoteManagementDialog(controller: controller)),
      ),
    );
    await tester.pump();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Gitee'), findsOneWidget);
    expect(find.text('全部推送'), findsOneWidget);
    expect(find.text('添加远端'), findsWidgets);
  });
}

class _FakeUpdateService extends UpdateService {
  @override
  Future<UpdateCheckResult> checkForUpdates() async {
    return const UpdateCheckResult(
      status: UpdateCheckStatus.updateAvailable,
      message: '测试更新',
      latestVersion: '0.5.1',
      releaseUrl:
          'https://github.com/CY68GI/Git_Gui_Expand/releases/tag/v0.5.1',
      assetName: 'Git_Gui_Expand-v0.5.1-windows-x64.zip',
      downloadUrl: 'https://github.com/CY68GI/Git_Gui_Expand/releases/download/v0.5.1/update.zip',
      sha256:
          '0000000000000000000000000000000000000000000000000000000000000000',
    );
  }
}

class _FakeFontCatalogService extends FontCatalogService {
  @override
  Future<List<String>> loadInstalledFonts() async => const ['Segoe UI'];
}
