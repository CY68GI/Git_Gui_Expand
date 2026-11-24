import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/app.dart';
import 'package:git_gui_expand/core/constants/app_info.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/localization/runtime_messages.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/models/recent_repository.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';
import 'package:git_gui_expand/core/services/font_catalog_service.dart';
import 'package:git_gui_expand/core/services/executable_version_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';
import 'package:git_gui_expand/core/services/installation_maintenance_service.dart';
import 'package:git_gui_expand/core/services/update_service.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';
import 'package:git_gui_expand/features/dialogs/settings_dialog.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';
import 'package:git_gui_expand/features/dialogs/installation_cleanup_dialog.dart';
import 'package:git_gui_expand/features/dialogs/clone_repository_dialog.dart';
import 'package:git_gui_expand/features/dialogs/git_metadata_clear_dialog.dart';
import 'package:git_gui_expand/features/dialogs/remote_management_dialog.dart';
import 'package:git_gui_expand/features/dialogs/update_dialog.dart';
import 'package:git_gui_expand/features/dialogs/stash_management_dialog.dart';
import 'package:git_gui_expand/features/dialogs/user_guide_dialog.dart';
import 'package:git_gui_expand/features/explorer/file_explorer_panel.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';
import 'package:git_gui_expand/features/start/start_view.dart';

import 'support/localized_message_fixture.dart';

import 'package:git_gui_expand/features/project/widgets/app_outcome_snack_bar.dart';
import 'package:git_gui_expand/l10n/app_l10n.dart';

void main() {
  testWidgets('start screen presents repository opening workflow', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'zh',
      'CN',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(
      const GitGuiExpandApp(
        initialLanguagePreference: AppLanguagePreference.simplifiedChinese,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Git GUI Expand'), findsOneWidget);
    expect(find.text('打开 Git 仓库'), findsOneWidget);
    expect(find.text('打开空白文件夹'), findsOneWidget);
    expect(find.text('克隆 Git 仓库'), findsOneWidget);
    expect(find.byIcon(Icons.folder_open_rounded), findsWidgets);
    expect(find.textContaining('左右双栏'), findsOneWidget);
    expect(find.text('v${AppInfo.version}'), findsOneWidget);
  });

  testWidgets('system language defaults to the operating-system locale', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'en',
      'US',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);

    await tester.pumpWidget(const GitGuiExpandApp());
    await tester.pumpAndSettle();

    expect(find.text('Open Git repository'), findsOneWidget);
    expect(find.text('Dual-pane operations'), findsOneWidget);
    expect(find.text('打开 Git 仓库'), findsNothing);
  });

  testWidgets('explicit Traditional Chinese locale renders Traditional UI', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const GitGuiExpandApp(
        initialLanguagePreference: AppLanguagePreference.traditionalChinese,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('開啟 Git 儲存庫'), findsOneWidget);
    expect(find.text('雙欄批次操作'), findsOneWidget);
    expect(find.text('打开 Git 仓库'), findsNothing);
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
            onOpenEmptyFolder: () {},
            onCloneRepository: () {},
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
      expect(find.text('Gitee'), findsOneWidget);
      expect(find.text('更新源'), findsOneWidget);
    },
  );

  testWidgets('update dialog shows the current changelog in English', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: AppLocalizations.english,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const Scaffold(body: UpdateDialog(showChangelogFirst: true)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Structured runtime messages, Markdown guides, and safe links'),
      findsOneWidget,
    );
    expect(find.text('v0.9.6'), findsNothing);
    expect(find.text('空白目录初始化、克隆与 Stash 管理'), findsNothing);
  });

  testWidgets('settings page exposes all sections and attribution', (
    WidgetTester tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'en',
      'US',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
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
            versionInfoService: _FakeExecutableVersionService(),
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
    expect(find.text('此页还有下方内容'), findsOneWidget);
    expect(find.text('向下滚动可查看字体预览和字体大小设置。'), findsOneWidget);
    expect(find.byType(Scrollbar), findsWidgets);
    expect(find.text('外观设置'), findsOneWidget);
    expect(find.text('单位设置'), findsOneWidget);
    expect(find.text('Git'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '思源');
    await tester.pump();
    expect(find.text('Noto Sans SC / 思源黑体'), findsOneWidget);
    expect(find.text('Inter UI'), findsNothing);

    await tester.tap(find.text('外观设置'));
    await tester.pump();
    expect(find.text('配色方案'), findsWidgets);
    expect(find.text('经典绿'), findsOneWidget);
    expect(find.text('海洋蓝'), findsOneWidget);
    expect(find.text('星夜紫'), findsOneWidget);
    expect(find.text('琥珀金'), findsOneWidget);
    expect(find.text('玫瑰红'), findsOneWidget);

    await tester.tap(find.text('语言'));
    await tester.pump();
    expect(find.text('English'), findsOneWidget);
    expect(find.text('简体中文'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);
    expect(find.text('Follow system'), findsOneWidget);
    expect(find.textContaining('Follow system /'), findsNothing);
    expect(
      find.text('Use the language selected in the operating system.'),
      findsOneWidget,
    );
    expect(find.text('使用操作系统设置的语言。'), findsNothing);
    expect(
      find.text('Use English for the application interface.'),
      findsOneWidget,
    );
    expect(find.text('使用简体中文显示软件界面。'), findsOneWidget);
    expect(find.text('使用繁體中文顯示軟體介面。'), findsOneWidget);

    await tester.tap(find.text('关于'));
    await tester.pumpAndSettle();
    expect(
      find.text('感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。'),
      findsOneWidget,
    );
    expect(find.text('一键发送到桌面'), findsOneWidget);
    expect(find.text('扫描旧版本与安装包'), findsOneWidget);
    expect(find.text('0.10.0+23'), findsOneWidget);
    expect(find.text('0.10.0.23'), findsOneWidget);
    expect(find.text('本项目使用 MIT License 开源许可证。'), findsOneWidget);
  });

  testWidgets(
    'Settings Git page shows system, bundled and unavailable states',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1100, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final checkedAt = DateTime.utc(2026, 11, 23, 8, 30);

      Future<void> pumpStatus(GitRuntimeStatus status) async {
        final controller = RepositoryController(
          runtimeManager: GitRuntimeManager(initialStatus: status),
        );
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SettingsDialog(
                controller: controller,
                fontCatalogService: _FakeFontCatalogService(),
                initialSection: SettingsSection.git,
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await pumpStatus(
        GitRuntimeStatus.available(
          source: GitRuntimeSource.system,
          executablePath: r'C:\Program Files\Git\cmd\git.exe',
          version: '2.56.1.windows.1',
          checkedAt: checkedAt,
        ),
      );
      expect(find.text('Git 可用'), findsOneWidget);
      expect(find.text('系统 Git'), findsOneWidget);
      expect(find.text('2.56.1.windows.1'), findsOneWidget);
      expect(find.text(r'C:\Program Files\Git\cmd\git.exe'), findsOneWidget);
      expect(find.text('加入用户 PATH'), findsNothing);

      await pumpStatus(
        GitRuntimeStatus.available(
          source: GitRuntimeSource.bundled,
          executablePath: r'C:\Software\runtime\git\current\cmd\git.exe',
          version: '2.50.0',
          checkedAt: checkedAt,
        ),
      );
      expect(find.text('内置 PortableGit'), findsOneWidget);
      expect(find.text('2.50.0'), findsOneWidget);
      expect(find.text('加入用户 PATH'), findsOneWidget);
      expect(find.text('加入系统 PATH'), findsOneWidget);
      expect(find.text('从用户 PATH 移除'), findsOneWidget);
      expect(find.text('从系统 PATH 移除'), findsOneWidget);

      await pumpStatus(
        GitRuntimeStatus.unavailable(
          checkedAt: checkedAt,
          error: 'No Git executable was found.',
        ),
      );
      expect(find.text('Git 不可用'), findsOneWidget);
      expect(find.text('下载 Git'), findsOneWidget);
      expect(find.text('重新检测'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Git status page stays readable in all supported languages', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1100, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final status = GitRuntimeStatus.unavailable(
      checkedAt: DateTime.utc(2026, 11, 23),
      error: 'No Git executable was found.',
    );

    for (final locale in AppLocalizations.supportedLocales) {
      final controller = RepositoryController(
        runtimeManager: GitRuntimeManager(initialStatus: status),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SettingsDialog(
              controller: controller,
              fontCatalogService: _FakeFontCatalogService(),
              initialSection: SettingsSection.git,
            ),
          ),
        ),
      );
      await tester.pump();
      final pageException = tester.takeException();
      if (pageException is FlutterError) {
        debugPrint(pageException.toStringDeep());
      }
      expect(pageException, isNull, reason: 'locale=${locale.toString()}');
      final expectedAction = locale.languageCode == 'en'
          ? 'Check again'
          : locale.scriptCode == 'Hant'
          ? '重新偵測'
          : '重新检测';
      expect(find.text(expectedAction), findsWidgets);
    }
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
    expect(find.text('待执行 0'), findsOneWidget);
  });

  testWidgets('operation plan lists dangerous steps before execution', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    controller.pendingOperations = [
      PlannedRepositoryOperation(
        id: 'delete-1',
        kind: PlannedOperationKind.delete,
        title: RuntimeMessages.messageFor(
          'planTitleDelete',
          parameters: {'count': 2},
        ),
        description: RuntimeMessages.messageFor(
          'planDescriptionDelete',
          parameters: {'count': 2, 'paths': 'docs/readme.md | src/main.dart'},
        ),
        isDangerous: true,
        run: () async => OperationOutcome.success(fixtureMessage('deleted')),
      ),
      PlannedRepositoryOperation(
        id: 'clear-1',
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
            'branches': 3,
            'tags': 2,
            'message': '仓库已清除',
          },
        ),
        isDangerous: true,
        strongConfirmationText: 'CY68GI/Git_Gui_Expand/main',
        run: () async => OperationOutcome.success(fixtureMessage('cleared')),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OperationPlanDialog(planHost: controller)),
      ),
    );
    await tester.pump();

    expect(find.text('待执行操作计划'), findsOneWidget);
    expect(find.text('确认前仓库不会发生任何改变'), findsNothing);
    expect(find.textContaining('确认前仓库不会发生任何改变'), findsOneWidget);
    expect(find.text('删除 2 个项目'), findsOneWidget);
    expect(find.text('清空远端历史 origin'), findsOneWidget);
    expect(find.text('危险操作确认'), findsOneWidget);
    expect(find.textContaining('CY68GI/Git_Gui_Expand/main'), findsNWidgets(2));
  });

  testWidgets('user guide explains the staged operation workflow', (
    WidgetTester tester,
  ) async {
    expect(UserGuideDialog.assetPathFor('en'), 'docs/USER_GUIDE.md');
    expect(UserGuideDialog.assetPathFor('zh'), 'docs/USER_GUIDE.zh-CN.md');
    expect(UserGuideDialog.assetPathFor('zh_Hant'), 'docs/USER_GUIDE.zh-TW.md');
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: UserGuideDialog())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Git GUI Expand 使用指南'), findsOneWidget);
    expect(find.textContaining('所有操作先进入计划'), findsOneWidget);
    expect(find.textContaining('清空远端仓库'), findsWidgets);
  });

  testWidgets('commit result snackbar stays readable in dark theme', (
    WidgetTester tester,
  ) async {
    final theme = AppTheme.dark(fontFamily: 'Noto Sans SC');
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showAppOutcomeSnackBar(
                  context,
                  OperationOutcome.success(
                    RuntimeMessages.messageFor(
                      'commitSucceeded',
                      eventId: 'test.commit.succeeded',
                    ),
                  ),
                ),
                child: const Text('显示结果'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('显示结果'));
    await tester.pump();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    final message = tester.widget<Text>(find.text('提交已创建。'));
    expect(snackBar.duration, const Duration(seconds: 5));
    expect(snackBar.showCloseIcon, isTrue);
    expect(snackBar.backgroundColor, theme.colorScheme.primary);
    expect(message.style?.color, theme.colorScheme.onPrimary);
    expect(message.style?.fontSize, greaterThanOrEqualTo(13));
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('file row secondary click opens the requested context menu', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    const entries = [
      RepositoryEntry(
        relativePath: 'README.md',
        name: 'README.md',
        kind: EntryKind.file,
        size: 128,
      ),
    ];
    controller.leftPanel = const ExplorerPanelState(entries: entries);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 700,
            height: 500,
            child: FileExplorerPanel(
              side: ExplorerSide.left,
              state: controller.leftPanel,
              rootPath: 'C:\\Projects\\sample_repo',
              settings: const AppSettings(),
              isActive: true,
              controller: controller,
              showOutcome: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('README.md')),
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('用文件资源打开'), findsOneWidget);
    expect(find.text('用默认打开方式打开'), findsOneWidget);
  });

  testWidgets('maintenance dialog lists artifacts and supports cleanup', (
    WidgetTester tester,
  ) async {
    final service = _FakeMaintenanceService();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: InstallationCleanupDialog(service: service)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('旧版本与安装包清理'), findsOneWidget);
    expect(find.text('old-version.zip'), findsOneWidget);
    expect(find.text('一键清除'), findsOneWidget);

    await tester.tap(find.text('一键清除'));
    await tester.pumpAndSettle();

    expect(find.textContaining('已清除 1 项'), findsOneWidget);
    expect(service.cleanupCalls, 1);
  });

  testWidgets('clone dialog exposes URL, parent folder, and project name', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CloneRepositoryDialog())),
    );
    await tester.pump();

    expect(find.text('克隆 Git 仓库'), findsOneWidget);
    expect(find.text('远程仓库地址'), findsOneWidget);
    expect(find.text('克隆到父目录'), findsOneWidget);
    expect(find.text('项目文件夹名称'), findsOneWidget);
    expect(find.text('加入克隆计划'), findsOneWidget);
    expect(find.textContaining('下一步只创建克隆操作预览'), findsOneWidget);
  });

  testWidgets('stash dialog exposes create and restore workflow', (
    WidgetTester tester,
  ) async {
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: StashManagementDialog(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stash 管理'), findsOneWidget);
    expect(find.text('创建 Stash'), findsOneWidget);
    expect(find.text('应用 Stash'), findsOneWidget);
    expect(find.text('弹出 Stash'), findsOneWidget);
    expect(find.text('删除 Stash'), findsOneWidget);
  });

  testWidgets('Git metadata dialog explains destructive consequences', (
    WidgetTester tester,
  ) async {
    final controller = RepositoryController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GitMetadataClearDialog(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('清除 Git 元数据'), findsOneWidget);
    expect(find.text('此操作会删除仓库根目录中的 .git 文件夹。'), findsOneWidget);
    expect(find.textContaining('全部提交历史和 reflog'), findsOneWidget);
    expect(find.text('加入清除计划'), findsOneWidget);
  });
}

class _FakeUpdateService extends UpdateService {
  @override
  Future<UpdateCheckResult> checkForUpdates({
    UpdateSource source = UpdateSource.github,
  }) async {
    return UpdateCheckResult(
      status: UpdateCheckStatus.updateAvailable,
      message: RuntimeMessages.messageFor('updateAvailableGithub'),
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

class _FakeMaintenanceService extends InstallationMaintenanceService {
  int cleanupCalls = 0;

  @override
  Future<MaintenanceScanResult> scan() async {
    return const MaintenanceScanResult(
      softwareDirectory: 'C:\\Software',
      currentVersion: '0.9.6',
      items: [
        MaintenanceItem(
          path: 'C:\\Software\\userdata\\updates\\old-version.zip',
          kind: MaintenanceItemKind.updateArchive,
          size: 1024,
        ),
      ],
    );
  }

  @override
  Future<MaintenanceCleanupResult> cleanup(MaintenanceScanResult scan) async {
    cleanupCalls += 1;
    return MaintenanceCleanupResult(
      removed: scan.items,
      failed: const [],
      removedBytes: scan.totalBytes,
    );
  }
}

class _FakeExecutableVersionService extends ExecutableVersionService {
  @override
  Future<ExecutableVersionInfo> load() async {
    return const ExecutableVersionInfo(
      applicationVersion: '0.10.0+23',
      launcherVersion: '0.10.0.23',
      applicationPath: 'C:\\Software\\versions\\0.10.0\\git_gui_expand.exe',
      launcherPath: 'C:\\Software\\GitGuiExpandLauncher.exe',
    );
  }
}
