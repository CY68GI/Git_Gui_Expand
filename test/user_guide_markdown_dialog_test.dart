import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/markdown/guide_document.dart';
import 'package:git_gui_expand/core/services/external_link_service.dart';
import 'package:git_gui_expand/features/dialogs/user_guide_dialog.dart';
import 'package:git_gui_expand/l10n/app_l10n.dart';

void main() {
  testWidgets('guide dialog loads and caches each locale document', (
    tester,
  ) async {
    final reads = <String, int>{};
    final loader = GuideDocumentLoader(
      readText: (path) async {
        reads.update(path, (value) => value + 1, ifAbsent: () => 1);
        return switch (path) {
          GuideAssets.english => '# English guide\n\nEnglish body.',
          GuideAssets.simplifiedChinese => '# 中文指南\n\n简体正文。',
          GuideAssets.traditionalChinese => '# 中文指南\n\n繁體正文。',
          _ => throw StateError('unexpected asset $path'),
        };
      },
    );

    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        _localizedApp(
          locale,
          Scaffold(body: UserGuideDialog(documentLoader: loader)),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations(locale);
      expect(
        find.textContaining(l10n.tr('gitGuiExpandUserGuide')),
        findsOneWidget,
      );
      expect(
        find.textContaining(UserGuideDialog.assetPathFor(l10n.languageCode)),
        findsOneWidget,
      );
    }

    expect(reads.values, everyElement(1));
    expect(reads, hasLength(3));
  });

  testWidgets('load errors show retry and never expose a partial document', (
    tester,
  ) async {
    var attempts = 0;
    final loader = GuideDocumentLoader(
      readText: (path) async {
        attempts += 1;
        if (attempts == 1) throw StateError('missing fixture');
        return '# Recovered guide\n\nVisible after retry.';
      },
    );
    await tester.pumpWidget(
      _localizedApp(
        AppLocalizations.english,
        Scaffold(body: UserGuideDialog(documentLoader: loader)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Unable to read user guide'), findsOneWidget);
    expect(find.textContaining('missing fixture'), findsOneWidget);
    expect(find.text('Recovered guide'), findsNothing);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered guide'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('locale switch shows progress instead of stale guide content', (
    tester,
  ) async {
    final chinese = Completer<String>();
    final loader = GuideDocumentLoader(
      readText: (path) async {
        if (path == GuideAssets.english) return '# English guide';
        if (path == GuideAssets.simplifiedChinese) return chinese.future;
        return '# Traditional guide';
      },
    );
    final locale = ValueNotifier<Locale>(AppLocalizations.english);
    addTearDown(locale.dispose);
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, _) => _localizedApp(
          value,
          Scaffold(body: UserGuideDialog(documentLoader: loader)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('English guide'), findsOneWidget);

    locale.value = AppLocalizations.simplifiedChinese;
    await tester.pump();
    expect(find.text('English guide'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    chinese.complete('# 中文指南');
    await tester.pumpAndSettle();
    expect(find.text('中文指南'), findsOneWidget);
    expect(find.text('English guide'), findsNothing);
  });

  testWidgets('safe links open once and relative guides switch documents', (
    tester,
  ) async {
    var opened = 0;
    final loader = GuideDocumentLoader(
      readText: (path) async {
        if (path == GuideAssets.english) {
          return '# English guide\n\n'
              '[HTTPS link](https://example.com/docs)\n\n'
              '[Chinese guide](USER_GUIDE.zh-CN.md)\n\n'
              '[Unsafe](javascript:alert(1))';
        }
        return '# 中文指南\n\n已切换。';
      },
    );
    final external = ExternalLinkService(
      launcher: (url) async {
        expect(url, 'https://example.com/docs');
        opened += 1;
      },
    );
    await tester.pumpWidget(
      _localizedApp(
        AppLocalizations.english,
        Scaffold(
          body: UserGuideDialog(
            documentLoader: loader,
            externalLinks: external,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('guide-link-HTTPS link')));
    await tester.pump();
    expect(opened, 1);
    expect(find.byKey(const ValueKey('guide-link-Unsafe')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('guide-link-Chinese guide')));
    await tester.pumpAndSettle();
    expect(find.text('中文指南'), findsOneWidget);
    expect(find.textContaining('docs/USER_GUIDE.zh-CN.md'), findsOneWidget);
  });

  testWidgets('heading anchors scroll within the current document', (
    tester,
  ) async {
    final body = StringBuffer('# Anchor guide\n\n[Jump](#second-section)\n\n');
    for (var index = 0; index < 18; index++) {
      body.writeln('Paragraph $index with enough content to scroll.\n');
    }
    body.writeln('## Second section\n\nReached the target.');
    final loader = GuideDocumentLoader(readText: (_) async => body.toString());
    await tester.binding.setSurfaceSize(const Size(900, 520));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _localizedApp(
        AppLocalizations.english,
        Scaffold(body: UserGuideDialog(documentLoader: loader)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('guide-link-Jump')));
    await tester.pumpAndSettle();

    final vertical = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((state) => state.axisDirection == AxisDirection.down);
    expect(vertical.position.pixels, greaterThan(0));
  });
}

Widget _localizedApp(Locale locale, Widget home) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppL10n.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: home,
  );
}
