import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/markdown/guide_document.dart';
import 'package:git_gui_expand/core/theme/app_theme.dart';
import 'package:git_gui_expand/features/dialogs/widgets/markdown_guide_view.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  test('all bundled guides parse with representative formatting', () async {
    for (final path in GuideAssets.languageByAsset.keys) {
      final source = await File(path).readAsString();
      final document = GuideMarkdownParser.parse(source, sourcePath: path);
      final tags = _tags(document.nodes);

      expect(
        tags,
        containsAll(<String>{
          'h1',
          'h2',
          'p',
          'ul',
          'table',
          'pre',
          'img',
          'blockquote',
        }),
      );
      expect(document.plainText, isNot(contains('**')));
      expect(document.plainText, isNot(contains('~~')));
      expect(document.plainText, isNot(contains('`')));
      expect(document.plainText, isNot(contains('](images/')));
      expect(document.plainText, isNot(contains('&quot;')));
      expect(document.anchors.values, isNotEmpty);
      if (path == GuideAssets.traditionalChinese) {
        expect(document.anchors, contains('3-左右雙欄檔案操作'));
      }
    }
  });

  testWidgets('all guides lay out at every supported size in both themes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(620, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    const samples = {
      GuideAssets.english: '''
# Guide

**Readable body** with [safe link](https://example.com).

| Element | Status |
| --- | --- |
| Table | Safe |

```powershell
git status
git add -A
```
''',
      GuideAssets.simplifiedChinese: '''
# 指南

**可读正文**与[安全链接](https://example.com)。

| 元素 | 状态 |
| --- | --- |
| 表格 | 安全 |

```powershell
git status
```
''',
      GuideAssets.traditionalChinese: '''
# 指南

**可讀正文**與[安全連結](https://example.com)。

| 元素 | 狀態 |
| --- | --- |
| 表格 | 安全 |

```powershell
git status
```
''',
    };
    for (final entry in samples.entries) {
      final document = GuideMarkdownParser.parse(
        entry.value,
        sourcePath: entry.key,
      );
      for (final theme in [
        AppTheme.light(fontFamily: 'Noto Sans SC'),
        AppTheme.dark(fontFamily: 'Noto Sans SC'),
      ]) {
        for (final scale in [0.9, 1.0, 1.1]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              builder: (context, child) {
                final mediaQuery = MediaQuery.of(context);
                return MediaQuery(
                  data: mediaQuery.copyWith(
                    textScaler: TextScaler.linear(scale),
                  ),
                  child: child ?? const SizedBox.shrink(),
                );
              },
              home: Scaffold(
                body: MarkdownGuideView(document: document, onOpenLink: (_) {}),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('Traditional Chinese heading anchor scrolls the real guide', (
    tester,
  ) async {
    final document = GuideMarkdownParser.parse(
      '# 指南\n\n'
      '[返回檔案操作](#3-左右雙欄檔案操作)\n\n'
      '${List.filled(20, '內容段落。').join('\n\n')}\n\n'
      '## 3. 左右雙欄檔案操作\n\n目標。',
      sourcePath: GuideAssets.traditionalChinese,
    );
    await tester.binding.setSurfaceSize(const Size(900, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkdownGuideView(document: document, onOpenLink: (_) {}),
        ),
      ),
    );
    await tester.pump();

    final link = find.byKey(const ValueKey('guide-link-返回檔案操作'));
    await tester.ensureVisible(link);
    await tester.pump();
    await tester.tap(link);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final vertical = tester
        .stateList<ScrollableState>(find.byType(Scrollable))
        .firstWhere((state) => state.axisDirection == AxisDirection.down);
    expect(vertical.position.pixels, greaterThan(0));
    expect(find.text('3. 左右雙欄檔案操作'), findsOneWidget);
  });
}

Set<String> _tags(List<md.Node> nodes) {
  final tags = <String>{};
  void visit(md.Node node) {
    if (node is! md.Element) return;
    tags.add(node.tag);
    for (final child in node.children ?? const <md.Node>[]) {
      visit(child);
    }
  }

  for (final node in nodes) {
    visit(node);
  }
  return tags;
}
