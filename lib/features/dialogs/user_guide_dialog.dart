import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/markdown/guide_document.dart';
import '../../core/markdown/guide_link.dart';
import '../../core/services/external_link_service.dart';
import 'widgets/markdown_guide_view.dart';

class UserGuideDialog extends StatefulWidget {
  const UserGuideDialog({super.key, this.documentLoader, this.externalLinks});

  static const String defaultAssetPath = GuideAssets.english;

  final GuideDocumentLoader? documentLoader;
  final ExternalLinkService? externalLinks;

  static String assetPathFor(String languageCode) {
    return GuideAssets.forLanguageCode(languageCode);
  }

  @override
  State<UserGuideDialog> createState() => _UserGuideDialogState();
}

class _UserGuideDialogState extends State<UserGuideDialog> {
  late final GuideDocumentLoader _loader =
      widget.documentLoader ??
      GuideDocumentLoader(readText: rootBundle.loadString);
  late final ExternalLinkService _externalLinks =
      widget.externalLinks ?? ExternalLinkService();

  String? _assetPath;
  String? _localeLanguageCode;
  Future<GuideDocument>? _document;
  String? _pendingAnchor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final languageCode = context.l10n.languageCode;
    if (_assetPath == null || _localeLanguageCode != languageCode) {
      _localeLanguageCode = languageCode;
      _selectAsset(UserGuideDialog.assetPathFor(languageCode), notify: false);
    }
  }

  void _selectAsset(String assetPath, {String? fragment, bool notify = true}) {
    void apply() {
      _assetPath = assetPath;
      _pendingAnchor = fragment;
      _document = _loader.load(assetPath);
    }

    if (notify && mounted) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _retry() {
    final path = _assetPath;
    if (path == null) return;
    _loader.invalidate(path);
    setState(() {
      _document = _loader.load(path);
    });
  }

  Future<void> _handleLink(GuideLinkTarget target) async {
    switch (target.kind) {
      case GuideLinkKind.guide:
        final path = target.assetPath;
        if (path != null) {
          _selectAsset(path, fragment: target.fragment);
        }
      case GuideLinkKind.external:
        final uri = target.uri;
        if (uri == null) return;
        try {
          await _externalLinks.openExternalUrl(uri.toString());
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.tr('unableToOpenGuideLink', {'error': '$error'}),
              ),
            ),
          );
        }
      case GuideLinkKind.anchor:
      case GuideLinkKind.unsafe:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final assetPath =
        _assetPath ?? UserGuideDialog.assetPathFor(l10n.languageCode);
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
                          '${l10n.tr('gitGuiExpandUserGuide')} · '
                          '${_guideLanguageLabel(l10n, assetPath)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.tr(
                            'importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation',
                          ),
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    tooltip: l10n.tr('closeUserGuide'),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<GuideDocument>(
                future: _document,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    );
                  }
                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SelectableText(
                              l10n.tr('unableToReadUserGuide', {
                                'error': snapshot.error ?? 'empty document',
                              }),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: colors.error,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.tonalIcon(
                              onPressed: _retry,
                              icon: const Icon(Icons.refresh_rounded, size: 17),
                              label: Text(l10n.tr('refresh')),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return MarkdownGuideView(
                    key: ValueKey(snapshot.data!.sourcePath),
                    document: snapshot.data!,
                    initialAnchor: _pendingAnchor,
                    onOpenLink: (target) => unawaited(_handleLink(target)),
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
                      l10n.tr(
                        'textCanBeSelectedAndCopiedHereTheFullGuideIsIn',
                        {'path': assetPath},
                      ),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.tr('gotIt')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _guideLanguageLabel(AppLocalizations l10n, String assetPath) {
    return switch (GuideAssets.languageForAsset(assetPath)) {
      'zh' => l10n.tr('guideLanguageSimplifiedChinese'),
      'zh_Hant' => l10n.tr('guideLanguageTraditionalChinese'),
      _ => l10n.tr('guideLanguageEnglish'),
    };
  }
}
