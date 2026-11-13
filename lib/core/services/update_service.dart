import 'dart:convert';
import 'dart:io';

import '../constants/app_info.dart';
import 'app_log_service.dart';

enum UpdateCheckStatus { updateAvailable, upToDate, unavailable }

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
  });

  final UpdateCheckStatus status;
  final String message;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String releaseUrl;
  final String publishedAt;
  final String assetName;
  final String downloadUrl;
  final String sha256;
  final int assetSize;
}

class UpdateService {
  const UpdateService({this.logService});

  final AppLogService? logService;

  AppLogService get _log => logService ?? AppLogService.instance;

  Future<UpdateCheckResult> checkForUpdates() async {
    _log.info('update', '开始检查 GitHub Release 更新');
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
        _log.warning('update', 'GitHub 暂无公开 Release');
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: '仓库暂未发布 GitHub Release，可前往发布页查看。',
          releaseUrl: AppInfo.releasesUrl,
        );
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _log.warning('update', 'GitHub 更新接口 HTTP ${response.statusCode}');
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: 'GitHub 返回 HTTP ${response.statusCode}，请稍后重试。',
          releaseUrl: AppInfo.releasesUrl,
        );
      }

      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return const UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: '更新描述格式无法识别。',
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
          message: '公开 Release 没有可识别的版本号。',
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
        _log.warning('update', '新版本缺少可验证的 Windows x64 ZIP 资产');
        return UpdateCheckResult(
          status: UpdateCheckStatus.unavailable,
          message: '发现新版本，但 Release 缺少带 SHA-256 的 Windows x64 ZIP。',
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
            ? '发现可用的新版本，可直接下载、校验并自动重启更新。'
            : '当前版本 v${AppInfo.version} 已是线上最新版本。',
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
      _log.info('update', '更新检查完成：${result.status.name} latest=$latestVersion');
      return result;
    } on SocketException {
      _log.warning('update', '检查更新失败：无法连接 GitHub');
      return const UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: '无法连接 GitHub，请检查网络后重试。',
      );
    } on HttpException {
      _log.warning('update', '检查更新失败：HTTP 异常');
      return const UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: '网络请求失败，请稍后重试。',
      );
    } catch (error) {
      _log.error('update', '检查更新异常：$error');
      return UpdateCheckResult(
        status: UpdateCheckStatus.unavailable,
        message: '检查更新失败：$error',
      );
    } finally {
      client.close(force: true);
    }
  }

  UpdateAsset? selectWindowsAsset(Object? rawAssets) {
    if (rawAssets is! List) return null;
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
      if (uri == null ||
          uri.scheme != 'https' ||
          (uri.host != 'github.com' &&
              uri.host != 'objects.githubusercontent.com')) {
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
      if (name.toLowerCase().contains('git_gui_expand-v')) {
        return asset;
      }
      fallback ??= asset;
    }
    return fallback;
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
        _log.warning('update', 'Release 页面未找到 ZIP SHA-256');
        return asset;
      }
      _log.detail('update', '从 Release 页面解析 SHA-256：$digest');
      return UpdateAsset(
        name: asset.name,
        downloadUrl: asset.downloadUrl,
        sha256: digest,
        size: asset.size,
      );
    } catch (error) {
      _log.warning('update', '从 Release 页面解析 SHA-256 失败：$error');
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
    _log.detail('browser', '打开外部 HTTPS 链接：$url');
    if (!url.startsWith('https://')) {
      throw const FormatException('只允许打开 HTTPS 链接。');
    }
    if (Platform.isWindows) {
      final escaped = url.replaceAll("'", "''");
      await Process.run('powershell.exe', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "Start-Process -FilePath '$escaped'",
      ], runInShell: false);
      return;
    }
    if (Platform.isMacOS) {
      await Process.run('open', [url], runInShell: false);
      return;
    }
    if (Platform.isLinux) {
      await Process.run('xdg-open', [url], runInShell: false);
      return;
    }
    throw UnsupportedError('当前平台不支持打开浏览器。');
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
