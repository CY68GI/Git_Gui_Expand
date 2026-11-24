import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;

import '../../../core/markdown/guide_document.dart';
import '../../../core/markdown/guide_link.dart';

class MarkdownGuideView extends StatefulWidget {
  const MarkdownGuideView({
    super.key,
    required this.document,
    required this.onOpenLink,
    this.initialAnchor,
  });

  final GuideDocument document;
  final ValueChanged<GuideLinkTarget> onOpenLink;
  final String? initialAnchor;

  @override
  State<MarkdownGuideView> createState() => _MarkdownGuideViewState();
}

class _MarkdownGuideViewState extends State<MarkdownGuideView> {
  final Map<String, GlobalKey> _headingKeys = {};
  final Map<String, int> _headingCounts = {};

  @override
  void initState() {
    super.initState();
    _prepareAnchors();
    _scheduleInitialAnchor();
  }

  @override
  void didUpdateWidget(MarkdownGuideView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _headingKeys.clear();
      _headingCounts.clear();
      _prepareAnchors();
      _scheduleInitialAnchor();
    }
  }

  void _prepareAnchors() {
    for (final heading in _headings(widget.document.nodes)) {
      _headingKeys[heading.id] = GlobalKey();
    }
  }

  void _scheduleInitialAnchor() {
    final anchor = widget.initialAnchor;
    if (anchor == null || anchor.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToAnchor(anchor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
        child: _BlockView(
          nodes: widget.document.nodes,
          document: widget.document,
          headingKeys: _headingKeys,
          headingCounts: _headingCounts,
          onOpenLink: _handleLink,
        ),
      ),
    );
  }

  void _handleLink(GuideLinkTarget target) {
    if (target.kind == GuideLinkKind.anchor) {
      _scrollToAnchor(target.fragment ?? '');
      return;
    }
    widget.onOpenLink(target);
  }

  void _scrollToAnchor(String fragment) {
    var decoded = fragment;
    try {
      decoded = Uri.decodeComponent(fragment);
    } on ArgumentError {
      // GuideLinkResolver already supplies decoded fragments.
    }
    final key = _headingKeys[decoded] ?? _headingKeys[fragment];
    final targetContext = key?.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }
}

class _BlockView extends StatelessWidget {
  const _BlockView({
    required this.nodes,
    required this.document,
    required this.headingKeys,
    required this.headingCounts,
    required this.onOpenLink,
  });

  final List<md.Node> nodes;
  final GuideDocument document;
  final Map<String, GlobalKey> headingKeys;
  final Map<String, int> headingCounts;
  final ValueChanged<GuideLinkTarget> onOpenLink;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    for (final node in nodes) {
      final widget = _block(context, node);
      if (widget != null) widgets.add(widget);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget? _block(BuildContext context, md.Node node) {
    if (node is md.Text) return _paragraph(context, [node]);
    if (node is! md.Element) return null;
    switch (node.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return _heading(context, node);
      case 'p':
        return _paragraph(context, node.children ?? const []);
      case 'ul':
      case 'ol':
        return _list(context, node);
      case 'blockquote':
        return _blockquote(context, node);
      case 'pre':
        return _codeBlock(context, node);
      case 'table':
        return _table(context, node);
      case 'hr':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(color: Theme.of(context).colorScheme.outlineVariant),
        );
      default:
        final children = node.children;
        if (children == null || children.isEmpty) return null;
        return _blockChildren(context, children);
    }
  }

  Widget _blockChildren(BuildContext context, List<md.Node> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (final child in children) ?_block(context, child)],
    );
  }

  Widget _heading(BuildContext context, md.Element element) {
    final text = element.textContent.trim();
    final base =
        GuideMarkdownParser.explicitId(element) ??
        GuideMarkdownParser.headingSlug(text);
    final count = headingCounts.update(
      base,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    final id = count == 1 ? base : '$base-$count';
    final level = int.parse(element.tag.substring(1));
    final style = _headingStyle(context, level);
    return Padding(
      key: headingKeys[id],
      padding: EdgeInsets.only(
        top: level == 1 ? 4 : 15,
        bottom: level == 1 ? 14 : 7,
      ),
      child: _richText(context, element.children ?? const [], style: style),
    );
  }

  TextStyle _headingStyle(BuildContext context, int level) {
    final textTheme = Theme.of(context).textTheme;
    final base = switch (level) {
      1 => textTheme.headlineMedium,
      2 => textTheme.headlineSmall,
      3 => textTheme.titleLarge,
      4 => textTheme.titleMedium,
      _ => textTheme.titleSmall,
    };
    return (base ?? const TextStyle()).copyWith(
      height: level <= 2 ? 1.25 : 1.35,
      fontWeight: level <= 3 ? FontWeight.w800 : FontWeight.w700,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  Widget _paragraph(BuildContext context, List<md.Node> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _richText(
        context,
        children,
        style:
            Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.65) ??
            const TextStyle(fontSize: 13, height: 1.65),
      ),
    );
  }

  Widget _list(BuildContext context, md.Element element) {
    final ordered = element.tag == 'ol';
    final children = element.children ?? const <md.Node>[];
    final items = <Widget>[];
    var number = 1;
    for (final child in children) {
      if (child is! md.Element || child.tag != 'li') continue;
      items.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: ordered ? 28 : 18,
                child: Padding(
                  padding: EdgeInsets.only(top: ordered ? 1 : 7),
                  child: ordered
                      ? Text(
                          '$number.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.only(top: 3),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _listItemContent(context, child.children ?? const []),
              ),
            ],
          ),
        ),
      );
      number += 1;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }

  Widget _listItemContent(BuildContext context, List<md.Node> children) {
    final widgets = <Widget>[];
    final inline = <md.Node>[];
    void flushInline() {
      if (inline.isEmpty) return;
      widgets.add(
        _richText(
          context,
          List<md.Node>.of(inline),
          style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.55) ??
              const TextStyle(fontSize: 13, height: 1.55),
        ),
      );
      inline.clear();
    }

    for (final child in children) {
      if (child is md.Element && (child.tag == 'ul' || child.tag == 'ol')) {
        flushInline();
        widgets.add(_list(context, child));
      } else if (child is md.Element && child.tag == 'p') {
        flushInline();
        widgets.add(_paragraph(context, child.children ?? const []));
      } else {
        inline.add(child);
      }
    }
    flushInline();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _blockquote(BuildContext context, md.Element element) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 3),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.05),
        border: Border(left: BorderSide(color: colors.primary, width: 3)),
      ),
      child: _blockChildren(context, element.children ?? const []),
    );
  }

  Widget _codeBlock(BuildContext context, md.Element element) {
    return _CodeBlock(text: element.textContent.trimRight());
  }

  Widget _table(BuildContext context, md.Element element) {
    final rows = _tableRows(element);
    if (rows.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final columnCount = rows.map((row) => row.cells.length).fold(0, _max);
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 12),
      child: Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width * 0.55,
            ),
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(color: colors.outlineVariant),
              children: [
                for (var rowIndex = 0; rowIndex < rows.length; rowIndex++)
                  TableRow(
                    decoration: rows[rowIndex].header
                        ? BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.07),
                          )
                        : null,
                    children: [
                      for (var column = 0; column < columnCount; column++)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: column < rows[rowIndex].cells.length
                              ? _richText(
                                  context,
                                  rows[rowIndex].cells[column],
                                  style: TextStyle(
                                    fontSize: 12,
                                    height: 1.45,
                                    fontWeight: rows[rowIndex].header
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _richText(
    BuildContext context,
    List<md.Node> nodes, {
    required TextStyle style,
  }) {
    return Text.rich(
      TextSpan(
        style: style,
        children: _InlineBuilder(
          context: context,
          document: document,
          onOpenLink: onOpenLink,
        ).build(nodes),
      ),
    );
  }
}

class _InlineBuilder {
  _InlineBuilder({
    required this.context,
    required this.document,
    required this.onOpenLink,
  });

  final BuildContext context;
  final GuideDocument document;
  final ValueChanged<GuideLinkTarget> onOpenLink;

  List<InlineSpan> build(List<md.Node> nodes, {TextStyle? style}) {
    final spans = <InlineSpan>[];
    for (final node in nodes) {
      if (node is md.Text) {
        spans.add(TextSpan(text: node.text, style: style));
        continue;
      }
      if (node is! md.Element) continue;
      switch (node.tag) {
        case 'strong':
          spans.addAll(
            build(
              node.children ?? const [],
              style: (style ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        case 'em':
          spans.addAll(
            build(
              node.children ?? const [],
              style: (style ?? const TextStyle()).copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        case 'del':
          spans.addAll(
            build(
              node.children ?? const [],
              style: (style ?? const TextStyle()).copyWith(
                decoration: TextDecoration.lineThrough,
              ),
            ),
          );
        case 'code':
          spans.add(
            TextSpan(
              text: node.textContent,
              style: (style ?? const TextStyle()).copyWith(
                fontFamily: 'Consolas',
                fontFamilyFallback: const ['Cascadia Mono', 'monospace'],
                fontSize: 12,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
              ),
            ),
          );
        case 'a':
          final target = GuideLinkResolver.resolve(
            node.attributes['href'] ?? '',
            currentAssetPath: document.sourcePath,
          );
          final label = node.textContent;
          if (target.kind == GuideLinkKind.unsafe) {
            spans.addAll(build(node.children ?? const [], style: style));
          } else {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: _GuideLink(
                  key: ValueKey('guide-link-$label'),
                  label: label,
                  onTap: () => onOpenLink(target),
                ),
              ),
            );
          }
        case 'br':
          spans.add(const TextSpan(text: '\n'));
        case 'img':
          final source = GuideLinkResolver.resolveImage(
            node.attributes['src'] ?? '',
            currentAssetPath: document.sourcePath,
          );
          final alt = node.attributes['alt']?.trim() ?? '';
          if (source == null) {
            if (alt.isNotEmpty) spans.add(TextSpan(text: alt, style: style));
          } else {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: _GuideImage(assetPath: source, alt: alt),
              ),
            );
          }
        default:
          spans.addAll(build(node.children ?? const [], style: style));
      }
    }
    return spans;
  }
}

class _GuideLink extends StatefulWidget {
  const _GuideLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<_GuideLink> createState() => _GuideLinkState();
}

class _GuideLinkState extends State<_GuideLink> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'markdown-guide-link');
  bool _focused = false;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      link: true,
      label: widget.label,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Material(
            color: _focused
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
            child: InkWell(
              borderRadius: BorderRadius.circular(3),
              onTap: widget.onTap,
              child: Text(
                widget.label,
                style: TextStyle(
                  color: colors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: colors.primary,
                  height: 1.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GuideImage extends StatelessWidget {
  const _GuideImage({required this.assetPath, required this.alt});

  final String assetPath;
  final String alt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 360),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            semanticLabel: alt.isEmpty ? null : alt,
            errorBuilder: (context, error, stackTrace) => Text(
              alt.isEmpty ? assetPath : alt,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeBlock extends StatefulWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  final ScrollController _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Scrollbar(
        controller: _controller,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            widget.text,
            style: TextStyle(
              fontFamily: 'Consolas',
              fontFamilyFallback: const ['Cascadia Mono', 'monospace'],
              fontSize: 12,
              height: 1.5,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeadingInfo {
  const _HeadingInfo(this.id);

  final String id;
}

List<_HeadingInfo> _headings(List<md.Node> nodes) {
  final headings = <_HeadingInfo>[];
  final counts = <String, int>{};
  void visit(md.Node node) {
    if (node is! md.Element) return;
    if (RegExp(r'^h[1-6]$').hasMatch(node.tag)) {
      final text = node.textContent.trim();
      final base =
          GuideMarkdownParser.explicitId(node) ??
          GuideMarkdownParser.headingSlug(text);
      final count = counts.update(
        base,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
      headings.add(_HeadingInfo(count == 1 ? base : '$base-$count'));
      return;
    }
    for (final child in node.children ?? const <md.Node>[]) {
      visit(child);
    }
  }

  for (final node in nodes) {
    visit(node);
  }
  return headings;
}

class _TableRowData {
  const _TableRowData({required this.header, required this.cells});

  final bool header;
  final List<List<md.Node>> cells;
}

List<_TableRowData> _tableRows(md.Element table) {
  final rows = <_TableRowData>[];
  void collect(md.Element element, {required bool header}) {
    if (element.tag == 'tr') {
      final cells = <List<md.Node>>[];
      for (final child in element.children ?? const <md.Node>[]) {
        if (child is md.Element && (child.tag == 'th' || child.tag == 'td')) {
          cells.add(child.children ?? const []);
        }
      }
      if (cells.isNotEmpty) {
        rows.add(_TableRowData(header: header, cells: cells));
      }
      return;
    }
    for (final child in element.children ?? const <md.Node>[]) {
      if (child is md.Element) {
        collect(child, header: header || child.tag == 'thead');
      }
    }
  }

  collect(table, header: false);
  return rows;
}

int _max(int left, int right) => left > right ? left : right;
