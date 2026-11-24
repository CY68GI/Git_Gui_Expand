import 'guide_document.dart';

enum GuideLinkKind { external, guide, anchor, unsafe }

class GuideLinkTarget {
  const GuideLinkTarget._({
    required this.kind,
    this.uri,
    this.assetPath,
    this.fragment,
  });

  const GuideLinkTarget.external(Uri uri)
    : this._(kind: GuideLinkKind.external, uri: uri);

  const GuideLinkTarget.guide(String assetPath, {String? fragment})
    : this._(
        kind: GuideLinkKind.guide,
        assetPath: assetPath,
        fragment: fragment,
      );

  const GuideLinkTarget.anchor(String fragment)
    : this._(kind: GuideLinkKind.anchor, fragment: fragment);

  const GuideLinkTarget.unsafe() : this._(kind: GuideLinkKind.unsafe);

  final GuideLinkKind kind;
  final Uri? uri;
  final String? assetPath;
  final String? fragment;
}

abstract final class GuideLinkResolver {
  static final RegExp _imageExtension = RegExp(
    r'\.(?:png|jpe?g|gif|webp)$',
    caseSensitive: false,
  );

  static GuideLinkTarget resolve(
    String href, {
    required String currentAssetPath,
  }) {
    final value = href.trim();
    if (value.isEmpty) return const GuideLinkTarget.unsafe();
    final uri = Uri.tryParse(value);
    if (uri == null) return const GuideLinkTarget.unsafe();
    if (uri.scheme.toLowerCase() == 'https' && uri.host.isNotEmpty) {
      return GuideLinkTarget.external(uri);
    }
    if (value.startsWith('#')) {
      final fragment = _decodeFragment(value.substring(1).trim());
      return fragment.isEmpty
          ? const GuideLinkTarget.unsafe()
          : GuideLinkTarget.anchor(fragment);
    }
    if (uri.hasScheme ||
        value.startsWith('/') ||
        value.startsWith(r'\') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value) ||
        value.contains(r'\')) {
      return const GuideLinkTarget.unsafe();
    }
    final resolved = Uri.parse(currentAssetPath).resolve(value);
    final path = resolved.path.replaceFirst(RegExp(r'^/+'), '');
    if (_containsParentTraversal(path) || !GuideAssets.isApprovedGuide(path)) {
      return const GuideLinkTarget.unsafe();
    }
    final fragment = _decodeFragment(resolved.fragment.trim());
    return GuideLinkTarget.guide(
      path,
      fragment: fragment.isEmpty ? null : fragment,
    );
  }

  static String? resolveImage(String href, {required String currentAssetPath}) {
    final value = href.trim();
    if (value.isEmpty ||
        value.contains(r'\') ||
        value.startsWith('/') ||
        RegExp(r'^[A-Za-z]:[\\/]').hasMatch(value)) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || uri.hasScheme || uri.hasAuthority) return null;
    final resolved = Uri.parse(currentAssetPath).resolve(value);
    final path = resolved.path.replaceFirst(RegExp(r'^/+'), '');
    if (_containsParentTraversal(path) ||
        !path.startsWith('docs/') ||
        !_imageExtension.hasMatch(path)) {
      return null;
    }
    return path;
  }

  static bool _containsParentTraversal(String path) {
    return path.split('/').any((segment) => segment == '..' || segment == '.');
  }

  static String _decodeFragment(String value) {
    try {
      return Uri.decodeComponent(value);
    } on FormatException {
      return '';
    }
  }
}
