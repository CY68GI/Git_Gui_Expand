import 'package:markdown/markdown.dart' as md;

class GuideDocument {
  const GuideDocument({
    required this.sourcePath,
    required this.languageCode,
    required this.nodes,
    required this.plainText,
    required this.anchors,
  });

  final String sourcePath;
  final String languageCode;
  final List<md.Node> nodes;
  final String plainText;
  final Map<String, String> anchors;
}

abstract final class GuideAssets {
  static const String english = 'docs/USER_GUIDE.md';
  static const String simplifiedChinese = 'docs/USER_GUIDE.zh-CN.md';
  static const String traditionalChinese = 'docs/USER_GUIDE.zh-TW.md';

  static const Map<String, String> languageByAsset = {
    english: 'en',
    simplifiedChinese: 'zh',
    traditionalChinese: 'zh_Hant',
  };

  static const Map<String, String> assetByLanguage = {
    'en': english,
    'zh': simplifiedChinese,
    'zh_Hant': traditionalChinese,
  };

  static String forLanguageCode(String languageCode) {
    return assetByLanguage[languageCode] ?? english;
  }

  static String languageForAsset(String assetPath) {
    return languageByAsset[assetPath] ?? 'en';
  }

  static bool isApprovedGuide(String assetPath) {
    return languageByAsset.containsKey(assetPath);
  }
}

abstract final class GuideMarkdownParser {
  static const Set<String> _allowedTags = {
    'a',
    'blockquote',
    'br',
    'code',
    'del',
    'em',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'hr',
    'img',
    'li',
    'ol',
    'p',
    'pre',
    'section',
    'span',
    'strong',
    'table',
    'tbody',
    'td',
    'th',
    'thead',
    'tr',
    'ul',
  };
  static const Set<String> _blockedTags = {
    'applet',
    'audio',
    'embed',
    'iframe',
    'object',
    'script',
    'style',
    'svg',
    'video',
  };

  static GuideDocument parse(String source, {required String sourcePath}) {
    final parser = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final parsed = parser.parse(_normalizeNewlines(source));
    final nodes = List<md.Node>.unmodifiable(_sanitizeNodes(parsed));
    final anchors = _collectAnchors(nodes);
    return GuideDocument(
      sourcePath: sourcePath,
      languageCode: GuideAssets.languageForAsset(sourcePath),
      nodes: nodes,
      plainText: _plainText(nodes),
      anchors: Map.unmodifiable(anchors),
    );
  }

  static List<md.Node> _sanitizeNodes(List<md.Node> nodes) {
    final result = <md.Node>[];
    for (final node in nodes) {
      final sanitized = _sanitizeNode(node);
      if (sanitized != null) result.add(sanitized);
    }
    return result;
  }

  static md.Node? _sanitizeNode(md.Node node) {
    if (node is md.Text) return md.Text(node.text);
    if (node is md.UnparsedContent) return md.Text(node.textContent);
    if (node is! md.Element) return null;
    if (_blockedTags.contains(node.tag)) return null;
    final children = node.children == null
        ? null
        : List<md.Node>.unmodifiable(_sanitizeNodes(node.children!));
    if (_allowedTags.contains(node.tag)) {
      final copy = node.isEmpty
          ? md.Element.empty(node.tag)
          : md.Element(node.tag, children ?? const []);
      copy.attributes.addAll(node.attributes);
      return copy;
    }
    if (children == null || children.isEmpty) return null;
    if (children.length == 1) return children.single;
    return md.Element('span', children);
  }

  static Map<String, String> _collectAnchors(List<md.Node> nodes) {
    final anchors = <String, String>{};
    final counts = <String, int>{};
    void visit(md.Node node) {
      if (node is! md.Element) return;
      if (RegExp(r'^h[1-6]$').hasMatch(node.tag)) {
        final text = node.textContent.trim();
        final base = explicitId(node) ?? headingSlug(text);
        final count = counts.update(
          base,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        final id = count == 1 ? base : '$base-$count';
        anchors[id] = text;
        return;
      }
      final children = node.children;
      if (children != null) {
        for (final child in children) {
          visit(child);
        }
      }
    }

    for (final node in nodes) {
      visit(node);
    }
    return anchors;
  }

  static String? explicitId(md.Element element) {
    final id = element.attributes['id']?.trim();
    return id?.isEmpty == false ? id : null;
  }

  static String headingSlug(String text) {
    final slug = text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^\w\u3400-\u9fff-]'), '')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return slug.isEmpty ? 'section' : slug;
  }

  static String _plainText(List<md.Node> nodes) {
    final buffer = StringBuffer();
    void append(md.Node node) {
      if (node is md.Text) {
        buffer.write(node.text);
        return;
      }
      if (node is! md.Element) return;
      final children = node.children;
      if (children != null) {
        for (final child in children) {
          append(child);
        }
      }
      if (const {
        'p',
        'li',
        'pre',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
      }.contains(node.tag)) {
        buffer.writeln();
      }
    }

    for (final node in nodes) {
      append(node);
    }
    return buffer.toString().trim();
  }

  static String _normalizeNewlines(String value) {
    return value.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }
}

typedef GuideTextReader = Future<String> Function(String assetPath);

class GuideDocumentLoader {
  GuideDocumentLoader({required this.readText});

  final GuideTextReader readText;
  final Map<String, Future<GuideDocument>> _cache = {};

  Future<GuideDocument> load(String assetPath) {
    if (!GuideAssets.isApprovedGuide(assetPath)) {
      return Future<GuideDocument>.error(
        ArgumentError.value(assetPath, 'assetPath', 'Unapproved guide asset'),
      );
    }
    return _cache.putIfAbsent(assetPath, () => _load(assetPath));
  }

  Future<GuideDocument> _load(String assetPath) async {
    try {
      final source = await readText(assetPath);
      return GuideMarkdownParser.parse(source, sourcePath: assetPath);
    } catch (_) {
      _cache.remove(assetPath);
      rethrow;
    }
  }

  void invalidate(String assetPath) {
    _cache.remove(assetPath);
  }
}
