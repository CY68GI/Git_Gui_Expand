import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/markdown/guide_document.dart';
import 'package:git_gui_expand/core/markdown/guide_link.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  test('Markdown dependency is pinned and empty input parses safely', () async {
    final pubspec = await File('pubspec.yaml').readAsString();
    expect(pubspec, contains('markdown: 7.3.1'));
    final document = GuideMarkdownParser.parse(
      '',
      sourcePath: GuideAssets.english,
    );
    expect(document.nodes, isEmpty);
    expect(document.plainText, isEmpty);
  });

  test(
    'representative fixture produces every supported semantic node',
    () async {
      final source = await File(
        'test/fixtures/markdown/representative_guide.md',
      ).readAsString();
      final document = GuideMarkdownParser.parse(
        source,
        sourcePath: GuideAssets.english,
      );
      final tags = _tags(document.nodes);

      expect(
        tags,
        containsAll(<String>{
          'a',
          'blockquote',
          'code',
          'del',
          'em',
          'h1',
          'h2',
          'hr',
          'img',
          'li',
          'ol',
          'p',
          'pre',
          'strong',
          'table',
          'td',
          'th',
          'tr',
          'ul',
        }),
      );
      expect(document.anchors, contains('nested-lists'));
      expect(document.anchors, contains('code-block'));
      expect(document.plainText, contains('"multi-line code block'));
      expect(document.plainText, isNot(contains('&quot;')));
      expect(document.plainText, isNot(contains('**strong text**')));
      expect(document.plainText, isNot(contains('`inline code`')));
    },
  );

  test('raw HTML and unsafe protocols remain inert', () async {
    final source = await File('test/fixtures/markdown/representative_guide.md')
        .readAsString();
    final document = GuideMarkdownParser.parse(
      source,
      sourcePath: GuideAssets.english,
    );
    final tags = _tags(document.nodes);

    expect(tags, isNot(contains('script')));
    expect(tags, isNot(contains('iframe')));
    for (final href in [
      "javascript:alert('blocked')",
      'data:text/html;base64,PHNjcmlwdD4=',
      'file:///C:/Windows/System32/drivers/etc/hosts',
      'http://example.com',
      r'C:\Windows\notepad.exe',
      '../secret.md',
    ]) {
      final target = GuideLinkResolver.resolve(
        href,
        currentAssetPath: GuideAssets.english,
      );
      expect(target.kind, GuideLinkKind.unsafe, reason: href);
    }
  });

  test('approved links and images resolve within bundled assets', () {
    expect(
      GuideLinkResolver.resolve(
        'https://example.com/docs',
        currentAssetPath: GuideAssets.english,
      ).kind,
      GuideLinkKind.external,
    );
    final guide = GuideLinkResolver.resolve(
      'USER_GUIDE.zh-CN.md#4-常见文件操作',
      currentAssetPath: GuideAssets.english,
    );
    expect(guide.kind, GuideLinkKind.guide);
    expect(guide.assetPath, GuideAssets.simplifiedChinese);
    expect(guide.fragment, '4-常见文件操作');
    expect(
      GuideLinkResolver.resolve(
        '#code-block',
        currentAssetPath: GuideAssets.english,
      ).kind,
      GuideLinkKind.anchor,
    );
    expect(
      GuideLinkResolver.resolveImage(
        'images/operation-plan.png',
        currentAssetPath: GuideAssets.english,
      ),
      'docs/images/operation-plan.png',
    );
    expect(
      GuideLinkResolver.resolveImage(
        '../../README.md',
        currentAssetPath: GuideAssets.english,
      ),
      isNull,
    );
  });

  test('loader caches success and retries a failed read', () async {
    var calls = 0;
    final loader = GuideDocumentLoader(
      readText: (path) async {
        calls += 1;
        if (calls == 1) throw const FileSystemException('temporary failure');
        return '# Loaded';
      },
    );

    await expectLater(
      loader.load(GuideAssets.english),
      throwsA(isA<FileSystemException>()),
    );
    final first = await loader.load(GuideAssets.english);
    final second = await loader.load(GuideAssets.english);

    expect(first, same(second));
    expect(calls, 2);
  });

  test('authoring documentation examples match supported fixtures', () async {
    final docs = await File('docs/MARKDOWN_GUIDES.md').readAsString();
    final guide = await File('docs/USER_GUIDE.md').readAsString();
    expect(docs, contains('[Return to planning](#1-plan-before-execution)'));
    expect(
      docs,
      contains('![Pending operation plan](images/operation-plan.png)'),
    );
    expect(docs, contains('[Simplified guide](USER_GUIDE.zh-CN.md)'));
    expect(
      guide,
      contains('[Back to the commit workspace](#4-commit-workspace)'),
    );
    expect(guide, contains('images/operation-plan.png'));
    expect(
      GuideLinkResolver.resolve(
        '#1-plan-before-execution',
        currentAssetPath: GuideAssets.english,
      ).kind,
      GuideLinkKind.anchor,
    );
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
