import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/markdown/guide_document.dart';
import 'package:git_gui_expand/core/markdown/guide_link.dart';
import 'package:git_gui_expand/features/dialogs/widgets/markdown_guide_view.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';

void main() {
  late GuideDocument document;

  setUpAll(() async {
    final source = await File('test/fixtures/markdown/representative_guide.md')
        .readAsString();
    document = GuideMarkdownParser.parse(
      source,
      sourcePath: GuideAssets.english,
    );
  });

  testWidgets('renders every supported block and inline element', (
    tester,
  ) async {
    final targets = <GuideLinkTarget>[];
    await tester.pumpWidget(
      _guideApp(MarkdownGuideView(document: document, onOpenLink: targets.add)),
    );
    await tester.pump();

    expect(find.text('Representative Guide'), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
    expect(find.byType(Divider), findsWidgets);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-link-HTTPS link')), findsOneWidget);
    expect(find.textContaining('git status'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('guide-link-HTTPS link')));
    expect(targets, hasLength(1));
    expect(targets.single.kind, GuideLinkKind.external);
  });

  testWidgets('mixed inline text copies without Markdown delimiters', (
    tester,
  ) async {
    await tester.pumpWidget(
      _guideApp(MarkdownGuideView(document: document, onOpenLink: (_) {})),
    );
    await tester.pump();
    final copied = <String>[];
    for (final richText in tester.widgetList<RichText>(find.byType(RichText))) {
      copied.add(richText.text.toPlainText());
    }
    for (final text in tester.widgetList<SelectableText>(
      find.byType(SelectableText),
    )) {
      copied.add(text.data ?? text.textSpan?.toPlainText() ?? '');
    }
    final plain = copied.join('\n');
    expect(plain, contains('strong text'));
    expect(plain, contains('inline code'));
    expect(plain, isNot(contains('**strong text**')));
    expect(plain, isNot(contains('~~strikethrough~~')));
    expect(plain, isNot(contains('`inline code`')));
  });

  testWidgets('links are keyboard focusable and activatable', (tester) async {
    final targets = <GuideLinkTarget>[];
    await tester.pumpWidget(
      _guideApp(MarkdownGuideView(document: document, onOpenLink: targets.add)),
    );
    await tester.pump();
    for (var index = 0; index < 8; index++) {
      if (FocusManager.instance.primaryFocus?.debugLabel ==
          'markdown-guide-link') {
        break;
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
    }
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      'markdown-guide-link',
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(targets, hasLength(1));
  });

  testWidgets('unsafe links have no action and render as inert text', (
    tester,
  ) async {
    final targets = <GuideLinkTarget>[];
    await tester.pumpWidget(
      _guideApp(MarkdownGuideView(document: document, onOpenLink: targets.add)),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('guide-link-JavaScript')), findsNothing);
    expect(find.byKey(const ValueKey('guide-link-Data')), findsNothing);
    expect(find.byKey(const ValueKey('guide-link-File')), findsNothing);
    expect(targets, isEmpty);
  });

  testWidgets('constrained layout keeps wide tables and code scrollable', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(520, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _guideApp(MarkdownGuideView(document: document, onOpenLink: (_) {})),
    );
    await tester.pump();

    final horizontalScrollViews = tester
        .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .where((widget) => widget.scrollDirection == Axis.horizontal);
    expect(horizontalScrollViews, hasLength(greaterThanOrEqualTo(2)));
    expect(tester.takeException(), isNull);
  });

  testWidgets('selected application font applies to prose and code uses mono', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(fontFamily: 'Noto Sans SC'),
        home: Scaffold(
          body: MarkdownGuideView(document: document, onOpenLink: (_) {}),
        ),
      ),
    );
    await tester.pump();

    final heading = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.textSpan?.toPlainText() == 'Representative Guide',
      ),
    );
    expect(heading.textSpan?.style?.fontFamily, 'Noto Sans SC');
    final code = tester.widget<SelectableText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is SelectableText &&
            widget.data?.contains('git status') == true,
      ),
    );
    expect(code.style?.fontFamily, 'Consolas');
  });

  testWidgets('light minimum font layout has no overflow', (tester) async {
    await _pumpGuideAtScale(
      tester,
      document: document,
      theme: AppTheme.light(fontFamily: 'Noto Sans SC'),
      scale: 0.9,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/markdown_guide_light_90.png'),
    );
  });

  testWidgets('dark maximum font layout has no overflow', (tester) async {
    await _pumpGuideAtScale(
      tester,
      document: document,
      theme: AppTheme.dark(fontFamily: 'Noto Sans SC'),
      scale: 1.1,
    );
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/markdown_guide_dark_110.png'),
    );
  });
}

Future<void> _pumpGuideAtScale(
  WidgetTester tester, {
  required GuideDocument document,
  required ThemeData theme,
  required double scale,
}) async {
  await tester.binding.setSurfaceSize(const Size(1100, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Scaffold(
        body: MarkdownGuideView(document: document, onOpenLink: (_) {}),
      ),
    ),
  );
  await tester.pump();
}

Widget _guideApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.light(fontFamily: 'Noto Sans SC'),
    home: Scaffold(body: child),
  );
}
