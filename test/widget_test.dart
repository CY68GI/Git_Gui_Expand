import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/app.dart';
import 'package:git_gui_expand/core/models/recent_repository.dart';
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
    expect(find.text('v0.4.0'), findsOneWidget);
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
}
