import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';
import 'package:git_gui_expand/features/dialogs/repository_sync_dialog.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  testWidgets('sync dialog explains a missing upstream', (tester) async {
    final controller = _controller(
      const BranchSyncState.noUpstream(branch: 'main', worktreeClean: true),
    );
    addTearDown(controller.dispose);
    await _pump(tester, controller);

    expect(find.text('未配置'), findsOneWidget);
    expect(find.textContaining('当前分支没有 upstream'), findsOneWidget);
    expect(_buttonEnabled(tester, '获取当前 upstream'), isFalse);
    expect(_buttonEnabled(tester, '获取全部远端'), isTrue);
    expect(_pullEnabled(tester), isFalse);
  });

  testWidgets('sync dialog disables actions for detached and dirty states', (
    tester,
  ) async {
    final controller = _controller(
      const BranchSyncState.detached(worktreeClean: false),
    );
    addTearDown(controller.dispose);
    await _pump(tester, controller);

    expect(find.text('detached HEAD'), findsWidgets);
    expect(find.textContaining('不能 Fetch 当前 upstream 或 Pull'), findsOneWidget);
    expect(_pullEnabled(tester), isFalse);
  });

  testWidgets('sync dialog distinguishes behind ahead and diverged states', (
    tester,
  ) async {
    final controller = _controller(_tracked(ahead: 0, behind: 3));
    addTearDown(controller.dispose);
    await _pump(tester, controller);
    expect(find.text('3'), findsOneWidget);
    expect(_pullEnabled(tester), isTrue);

    controller.syncState = _tracked(ahead: 2, behind: 0);
    await tester.pumpWidget(_app(controller));
    expect(find.textContaining('未推送提交'), findsOneWidget);
    expect(_pullEnabled(tester), isFalse);

    controller.syncState = _tracked(ahead: 1, behind: 2);
    await tester.pumpWidget(_app(controller));
    expect(find.textContaining('不会自动 Merge 或 Rebase'), findsOneWidget);
    expect(_pullEnabled(tester), isFalse);
  });
}

RepositoryController _controller(BranchSyncState state) {
  final controller = RepositoryController();
  controller.branch = state.branch;
  controller.syncState = state;
  controller.remotes = const [
    GitRemote(
      name: 'origin',
      fetchUrl: 'https://example.com/repo.git',
      pushUrl: 'https://example.com/repo.git',
      platform: GitRemotePlatform.generic,
    ),
  ];
  return controller;
}

BranchSyncState _tracked({required int ahead, required int behind}) {
  return BranchSyncState(
    kind: BranchSyncKind.tracked,
    branch: 'main',
    upstreamRef: 'origin/main',
    upstreamRemote: 'origin',
    upstreamBranch: 'main',
    ahead: ahead,
    behind: behind,
    worktreeClean: true,
  );
}

Future<void> _pump(WidgetTester tester, RepositoryController controller) async {
  tester.view.physicalSize = const Size(1000, 850);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(_app(controller));
  await tester.pump();
}

Widget _app(RepositoryController controller) {
  return MaterialApp(
    home: Scaffold(
      body: Center(child: RepositorySyncDialog(controller: controller)),
    ),
  );
}

bool _buttonEnabled(WidgetTester tester, String label) {
  final key = switch (label) {
    '获取当前 upstream' => const Key('repository-sync-fetch-current'),
    '获取全部远端' => const Key('repository-sync-fetch-all'),
    _ => throw ArgumentError.value(label),
  };
  final button = tester.widget<OutlinedButton>(find.byKey(key));
  return button.onPressed != null;
}

bool _pullEnabled(WidgetTester tester) {
  final button = tester.widget<FilledButton>(
    find.byKey(const Key('repository-sync-pull')),
  );
  return button.onPressed != null;
}
