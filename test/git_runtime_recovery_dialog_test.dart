import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/external_link_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';
import 'package:git_gui_expand/features/dialogs/git_runtime_recovery_dialog.dart';

void main() {
  testWidgets('missing-Git dialog exposes download and re-detect actions', (
    tester,
  ) async {
    final runtime = GitRuntimeManager();
    final opened = <String>[];
    final links = ExternalLinkService(launcher: (url) async => opened.add(url));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GitRuntimeRecoveryDialog(
            runtimeManager: runtime,
            externalLinks: links,
          ),
        ),
      ),
    );

    expect(find.text('未检测到 Git'), findsOneWidget);
    expect(find.text('下载 Git'), findsOneWidget);
    expect(find.text('重新检测'), findsOneWidget);
    await tester.tap(find.text('下载 Git'));
    await tester.pump();
    expect(opened, ['https://git-scm.com/download/win']);
  });
}
