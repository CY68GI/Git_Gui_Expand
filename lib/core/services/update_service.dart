import 'dart:convert';
import 'dart:io';

import '../constants/app_info.dart';
import '../localization/localized_message.dart';
import '../localization/runtime_messages.dart';
import 'app_log_service.dart';
import 'external_link_service.dart';

enum UpdateCheckStatus { updateAvailable, upToDate, unavailable }

enum UpdateSource { github, gitee }

class UpdateAsset {
  const UpdateAsset({
    required this.name,
    required this.downloadUrl,
    required this.sha256,
    required this.size,
  });

  final String name;
  final String downloadUrl;
  final String sha256;
  final int size;
}

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.status,
    required this.message,
    this.latestVersion = '',
    this.releaseName = '',
    this.releaseNotes = '',
    this.releaseUrl = '',
    this.publishedAt = '',
    this.assetName = '',
    this.downloadUrl = '',
    this.sha256 = '',
    this.assetSize = 0,
    this.source = UpdateSource.github,
  });

  final UpdateCheckStatus status;
  final LocalizedMessage message;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String releaseUrl;
  final String publishedAt;
  final String assetName;
  final String downloadUrl;
  final String sha256;
  final int assetSize;
  final UpdateSource source;
}

class UpdateService {
  const UpdateService({this.logService});

  final AppLogService? logService;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<UpdateCheckResult> checkForUpdates({
    UpdateSource source = UpdateSource.github,
  }) {
    return switch (source) {
      UpdateSource.github => _checkGitHub(),
      UpdateSource.gitee => _checkGitee(),
    };
  }

  Future<UpdateCheckResult> _checkGitHub() async {
    _log.infoEvent('update', 'update.github.check.started');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..userAgent = 'GitGUIExpand/${AppInfo.version}';
    try {
      final request = await client
          .getUrl(Uri.parse(AppInfo.latestReleaseApi))
          .timeout(const Duration(seconds: 8));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set('X-GitHub-Api-Version', '2022-11-28');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode == HttpStatus.notFound) {
        _log.warningEvent('update', 'update.github.noRelease');
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateGithubNoRelease'),
          releaseUrl: AppInfo.releasesUrl,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _log.warningEvent(
          'update',
          'update.github.httpFailed',
          details: {'status': '${response.statusCode}'},
        );
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor(
            'updateHttpError',
            parameters: {'platform': 'GitHub', 'status': response.statusCode},
          ),
          releaseUrl: AppInfo.releasesUrl,
        );
      }

      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateInvalidResponseGithub'),
        );
      }
      final tag = (decoded['tag_name'] as String? ?? '').trim();
      final latestVersion = _normalizeVersion(tag);
      final releaseUrl = decoded['html_url'] as String? ?? AppInfo.releasesUrl;
      final resultBase = (
        latestVersion: latestVersion,
        releaseName: decoded['name'] as String? ?? '',
        releaseNotes: decoded['body'] as String? ?? '',
        releaseUrl: releaseUrl,
        publishedAt: decoded['published_at'] as String? ?? '',
      );
      if (latestVersion.isEmpty) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateVersionMissingGithub'),
          releaseUrl: resultBase.releaseUrl,
        );
      }

      final comparison = compareVersions(latestVersion, AppInfo.version);
      var windowsAsset = comparison > 0
          ? selectWindowsAsset(decoded['assets'])
          : null;
      if (comparison > 0 &&
          windowsAsset != null &&
          windowsAsset.sha256.isEmpty) {
        windowsAsset = await _resolveDigestFromReleasePage(
          client,
          tag,
          windowsAsset,
        );
      }
      if (comparison > 0 &&
          (windowsAsset == null || windowsAsset.sha256.isEmpty)) {
        _log.warningEvent('update', 'update.github.assetMissing');
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateAssetMissingGithub'),
          latestVersion: resultBase.latestVersion,
          releaseName: resultBase.releaseName,
          releaseNotes: resultBase.releaseNotes,
          releaseUrl: resultBase.releaseUrl,
          publishedAt: resultBase.publishedAt,
        );
      }
      final result = UpdateCheckResult(
        status: comparison > 0
            ? UpdateCheckStatus.updateAvailable
            : UpdateCheckStatus.upToDate,
        message: comparison > 0
            ? RuntimeMessages.messageFor('updateAvailableGithub')
            : RuntimeMessages.messageFor(
                'updateUpToDate',
                parameters: {'version': AppInfo.version},
              ),
        latestVersion: resultBase.latestVersion,
        releaseName: resultBase.releaseName,
        releaseNotes: resultBase.releaseNotes,
        releaseUrl: resultBase.releaseUrl,
        publishedAt: resultBase.publishedAt,
        assetName: windowsAsset?.name ?? '',
        downloadUrl: windowsAsset?.downloadUrl ?? '',
        sha256: windowsAsset?.sha256 ?? '',
        assetSize: windowsAsset?.size ?? 0,
      );
      _log.infoEvent(
        'update',
        'update.github.check.completed',
        details: {'status': result.status.name, 'latest': latestVersion},
      );
      return result;
    } on SocketException {
      _log.warningEvent('update', 'update.github.networkUnavailable');
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.messageFor('updateNetworkUnavailableGithub'),
      );
    } on HttpException {
      _log.warningEvent('update', 'update.github.requestFailed');
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.messageFor('updateRequestFailed'),
      );
    } catch (error) {
      _log.errorEvent(
        'update',
        'update.github.check.failed',
        details: {'error': '$error'},
      );
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.operationFailed(
          error,
          eventId: 'update.github.check.failed',
        ),
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<UpdateCheckResult> _checkGitee() async {
    _log.infoEvent('update', 'update.gitee.check.started');
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 8)
      ..userAgent = 'GitGUIExpand/${AppInfo.version}';
    try {
      final request = await client
          .getUrl(Uri.parse(AppInfo.giteeLatestReleaseApi))
          .timeout(const Duration(seconds: 8));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      final text = await response.transform(utf8.decoder).join();
      if (response.statusCode == HttpStatus.notFound) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateGiteeNoRelease'),
          releaseUrl: AppInfo.giteeReleasesUrl,
          source: UpdateSource.gitee,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor(
            'updateHttpError',
            parameters: {'platform': 'Gitee', 'status': response.statusCode},
          ),
          releaseUrl: AppInfo.giteeReleasesUrl,
          source: UpdateSource.gitee,
        );
      }
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateInvalidResponseGitee'),
          source: UpdateSource.gitee,
        );
      }
      final tag = (decoded['tag_name'] as String? ?? '').trim();
      final latestVersion = _normalizeVersion(tag);
      final releaseUrl = tag.isEmpty
          ? AppInfo.giteeReleasesUrl
          : '${AppInfo.giteeReleasesUrl}/tag/$tag';
      if (latestVersion.isEmpty) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateVersionMissingGitee'),
          releaseUrl: releaseUrl,
          source: UpdateSource.gitee,
        );
      }
      final comparison = compareVersions(latestVersion, AppInfo.version);
      var windowsAsset = comparison > 0
          ? selectWindowsAsset(decoded['assets'], source: UpdateSource.gitee)
          : null;
      if (comparison > 0 &&
          windowsAsset != null &&
          windowsAsset.sha256.isEmpty) {
        windowsAsset = await _resolveGitHubDigestForAsset(
          client,
          tag,
          windowsAsset,
        );
      }
      if (comparison > 0 &&
          (windowsAsset == null || windowsAsset.sha256.isEmpty)) {
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: RuntimeMessages.messageFor('updateGiteeDigestMissing'),
          latestVersion: latestVersion,
          releaseName: decoded['name'] as String? ?? '',
          releaseNotes: decoded['body'] as String? ?? '',
          releaseUrl: releaseUrl,
          publishedAt: decoded['created_at'] as String? ?? '',
          source: UpdateSource.gitee,
        );
      }
      final result = UpdateCheckResult(
        status: comparison > 0
            ? UpdateCheckStatus.updateAvailable
            : UpdateCheckStatus.upToDate,
        message: comparison > 0
            ? RuntimeMessages.messageFor('updateAvailableGitee')
            : RuntimeMessages.messageFor(
                'updateGiteeUpToDate',
                parameters: {'version': AppInfo.version},
              ),
        latestVersion: latestVersion,
        releaseName: decoded['name'] as String? ?? '',
        releaseNotes: decoded['body'] as String? ?? '',
        releaseUrl: releaseUrl,
        publishedAt: decoded['created_at'] as String? ?? '',
        assetName: windowsAsset?.name ?? '',
        downloadUrl: windowsAsset?.downloadUrl ?? '',
        sha256: windowsAsset?.sha256 ?? '',
        assetSize: windowsAsset?.size ?? 0,
        source: UpdateSource.gitee,
      );
      _log.infoEvent(
        'update',
        'update.gitee.check.completed',
        details: {'status': result.status.name, 'latest': latestVersion},
      );
      return result;
    } on SocketException {
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.messageFor('updateNetworkUnavailableGitee'),
        releaseUrl: AppInfo.giteeReleasesUrl,
        source: UpdateSource.gitee,
      );
    } on HttpException {
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.messageFor('updateGiteeRequestFailed'),
        releaseUrl: AppInfo.giteeReleasesUrl,
        source: UpdateSource.gitee,
      );
    } catch (error) {
      _log.errorEvent(
        'update',
        'update.gitee.check.failed',
        details: {'error': '$error'},
      );
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: RuntimeMessages.operationFailed(
          error,
          eventId: 'update.gitee.check.failed',
          target: 'Gitee',
        ),
        releaseUrl: AppInfo.giteeReleasesUrl,
        source: UpdateSource.gitee,
      );
    } finally {
      client.close(force: true);
    }
  }

  Future<UpdateAsset?> _resolveGitHubDigestForAsset(
    HttpClient client,
    String tag,
    UpdateAsset windowsAsset,
  ) async {
    if (tag.isEmpty) return windowsAsset;
    try {
      final uri = Uri.parse(
        'https://api.github.com/repos/${AppInfo.owner}/'
        '${AppInfo.repository}/releases/tags/${Uri.encodeComponent(tag)}',
      );
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set('X-GitHub-Api-Version', '2022-11-28');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return windowsAsset;
      }
      final decoded = jsonDecode(await response.transform(utf8.decoder).join());
      if (decoded is! Map<String, dynamic>) return windowsAsset;
      final digest = extractSha256ForAsset(
        decoded['assets'],
        windowsAsset.name,
      );
      if (digest.isEmpty) return windowsAsset;
      return UpdateAsset(
        name: windowsAsset.name,
        downloadUrl: windowsAsset.downloadUrl,
        sha256: digest,
        size: windowsAsset.size,
      );
    } catch (_) {
      return windowsAsset;
    }
  }

  String extractSha256ForAsset(Object? rawAssets, String assetName) {
    if (rawAssets is! List) return '';
    for (final raw in rawAssets) {
      if (raw is! Map) continue;
      if ((raw['name'] as String? ?? '').trim() != assetName) continue;
      final digest = (raw['digest'] as String? ?? '').trim().toLowerCase();
      if (digest.startsWith('sha256:') &&
          RegExp(r'^[a-f0-9]{64}$')
              .hasMatch(digest.substring('sha256:'.length))) {
        return digest.substring('sha256:'.length);
      }
    }
    return '';
  }

  String? extractSha256FromChecksumText(String text) {
    final match = RegExp(r'\b([a-fA-F0-9]{64})\b').firstMatch(text);
    return match?.group(1)?.toLowerCase();
  }

  UpdateAsset? selectWindowsAsset(
    Object? rawAssets, {
    UpdateSource source = UpdateSource.github,
  }) {
    if (rawAssets is! List) return null;
    UpdateAsset? preferred;
    UpdateAsset? portableFallback;
    UpdateAsset? fallback;
    for (final raw in rawAssets) {
      if (raw is! Map) continue;
      final name = (raw['name'] as String? ?? '').trim();
      final urlText = (raw['browser_download_url'] as String? ?? '').trim();
      if (!name.toLowerCase().endsWith('.zip') ||
          !name.toLowerCase().contains('windows') ||
          !name.toLowerCase().contains('x64')) {
        continue;
      }
      final uri = Uri.tryParse(urlText);
      final allowedHosts = source == UpdateSource.github
          ? const {'github.com', 'objects.githubusercontent.com'}
          : const {'gitee.com'};
      if (uri == null ||
          uri.scheme != 'https' ||
          !allowedHosts.contains(uri.host)) {
        continue;
      }
      final digest = (raw['digest'] as String? ?? '').trim().toLowerCase();
      final sha256 = digest.startsWith('sha256:')
          ? digest.substring('sha256:'.length)
          : '';
      final asset = UpdateAsset(
        name: name,
        downloadUrl: urlText,
        sha256: sha256,
        size: (raw['size'] as num?)?.toInt() ?? 0,
      );
      final lowerName = name.toLowerCase();
      if (lowerName.startsWith('git_gui_expand-v')) {
        if (!lowerName.contains('portablegit')) {
          preferred ??= asset;
        } else {
          portableFallback ??= asset;
        }
      }
      fallback ??= asset;
    }
    return preferred ?? portableFallback ?? fallback;
  }

  Future<UpdateAsset?> _resolveDigestFromReleasePage(
    HttpClient client,
    String tag,
    UpdateAsset asset,
  ) async {
    try {
      final uri = Uri.parse(
        'https://github.com/${AppInfo.owner}/${AppInfo.repository}'
        '/releases/expanded_assets/${Uri.encodeComponent(tag)}',
      );
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.headers.set(HttpHeaders.acceptHeader, 'text/html');
      final response = await request.close().timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode != HttpStatus.ok) return asset;
      final html = await response.transform(utf8.decoder).join();
      final digest = extractSha256FromReleasePage(html, assetName: asset.name);
      if (digest == null) {
        _log.warningEvent('update', 'update.release.digest.missing');
        return asset;
      }
      _log.detailEvent(
        'update',
        'update.release.digest.resolved',
        details: {'digest': digest},
      );
      return UpdateAsset(
        name: asset.name,
        downloadUrl: asset.downloadUrl,
        sha256: digest,
        size: asset.size,
      );
    } catch (error) {
      _log.warningEvent(
        'update',
        'update.release.digest.failed',
        details: {'error': '$error'},
      );
      return asset;
    }
  }

  String? extractSha256FromReleasePage(String html, {String? assetName}) {
    var searchable = html;
    if (assetName != null && assetName.isNotEmpty) {
      final assetIndex = html.indexOf(assetName);
      if (assetIndex >= 0) {
        final end = assetIndex + 5000 < html.length
            ? assetIndex + 5000
            : html.length;
        searchable = html.substring(assetIndex, end);
      }
    }
    final match = RegExp(
      r'sha256:([a-fA-F0-9]{64})',
      caseSensitive: false,
    ).firstMatch(searchable);
    return match?.group(1)?.toLowerCase();
  }

  Future<void> openExternalUrl(String url) async {
    await ExternalLinkService(logService: _log).openExternalUrl(url);
  }

  int compareVersions(String left, String right) {
    final leftParts = _versionParts(left);
    final rightParts = _versionParts(right);
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftValue = index < leftParts.length ? leftParts[index] : 0;
      final rightValue = index < rightParts.length ? rightParts[index] : 0;
      if (leftValue != rightValue) {
        return leftValue.compareTo(rightValue);
      }
    }
    return 0;
  }

  String _normalizeVersion(String raw) {
    var value = raw.trim();
    if (value.startsWith('v') || value.startsWith('V')) {
      value = value.substring(1);
    }
    final match = RegExp(r'^\d+(?:\.\d+){0,3}').firstMatch(value);
    return match?.group(0) ?? '';
  }

  List<int> _versionParts(String version) {
    return _normalizeVersion(version)
        .split('.')
        .where((part) => part.isNotEmpty)
        .map((part) => int.tryParse(part) ?? 0)
        .toList(growable: false);
  }
}
