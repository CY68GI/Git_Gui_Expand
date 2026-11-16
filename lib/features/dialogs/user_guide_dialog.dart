import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';

class UserGuideDialog extends StatelessWidget {
  const UserGuideDialog({super.key});

  static const String defaultAssetPath = 'docs/USER_GUIDE.md';

  static String assetPathFor(String languageCode) {
    return switch (languageCode) {
      'zh' => 'docs/USER_GUIDE.zh-CN.md',
      'zh_Hant' => 'docs/USER_GUIDE.zh-TW.md',
      _ => defaultAssetPath,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final assetPath = assetPathFor(l10n.languageCode);
    final screen = MediaQuery.sizeOf(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 860,
        height: (screen.height * 0.88).clamp(520.0, 820.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 14, 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book_outlined,
                      color: colors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.tr('Git GUI Expand 使用指南'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.tr('重点：所有 Git 修改先进入执行计划，确认后才运行'),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: l10n.tr('关闭使用指南'),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<String>(
                future: rootBundle.loadString(assetPath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: SelectableText(
                          l10n.tr('无法读取使用指南：{error}', {
                            'error': snapshot.error,
                          }),
                          style: TextStyle(fontSize: 13, color: colors.error),
                        ),
                      ),
                    );
                  }
                  return SelectionArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(28, 22, 28, 30),
                      child: _GuideContent(text: snapshot.data ?? ''),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 13),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tr('可在本窗口中选中并复制文字。完整指南保存在 {path}。', {
                        'path': assetPath,
                      }),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.tr('我知道了')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideContent extends StatelessWidget {
  const _GuideContent({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lines = text.replaceAll('\r\n', '\n').split('\n');
    var inCodeBlock = false;
    final widgets = <Widget>[];
    for (final rawLine in lines) {
      if (rawLine.trimLeft().startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        widgets.add(
          _GuideLine(
            text: rawLine,
            style: TextStyle(
              fontFamily: 'Consolas',
              fontSize: 12,
              height: 1.45,
              color: colors.onSurface,
            ),
            background: colors.surfaceContainerLow,
          ),
        );
      } else {
        widgets.add(_buildLine(context, rawLine));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildLine(BuildContext context, String rawLine) {
    final colors = Theme.of(context).colorScheme;
    final line = rawLine.trimRight();
    if (line.isEmpty) return const SizedBox(height: 8);
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          line.substring(2),
          style: const TextStyle(
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    if (line.startsWith('## ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 8),
        child: Text(
          line.substring(3),
          style: const TextStyle(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    if (line.startsWith('### ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          line.substring(4),
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if (line.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Expanded(
              child: Text(
                line.substring(2),
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
          ],
        ),
      );
    }
    if (RegExp(r'^\d+\.\s').hasMatch(line)) {
      return Padding(
        padding: const EdgeInsets.only(left: 6, bottom: 5),
        child: Text(
          line,
          style: const TextStyle(
            fontSize: 13,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        line.replaceAll('`', ''),
        style: const TextStyle(fontSize: 13, height: 1.65),
      ),
    );
  }
}

class _GuideLine extends StatelessWidget {
  const _GuideLine({
    required this.text,
    required this.style,
    required this.background,
  });

  final String text;
  final TextStyle style;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: style),
    );
  }
}
