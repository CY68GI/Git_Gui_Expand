import 'dart:convert';
import 'dart:io';

import '../constants/app_info.dart';
import 'app_log_service.dart';

enum UpdateCheckStatus { updateAvailable, upToDate, unavailable }

class UpdateCheckResult {
  const UpdateCheckResult({
    required this.status,
    required this.message,
    this.latestVersion = '',
    this.releaseName = '',
    this.releaseNotes = '',
    this.releaseUrl = '',
    this.publishedAt = '',
  });

  final UpdateCheckStatus status;
  final String message;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String releaseUrl;
  final String publishedAt;
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
      final result = UpdateCheckResult(
        status: comparison > 0
            ? UpdateCheckStatus.updateAvailable
            : UpdateCheckStatus.upToDate,
        message: comparison > 0
            ? '发现可用的新版本，请前往发布页面获取安装包。'
            : '当前版本 v${AppInfo.version} 已是线上最新版本。',
        latestVersion: resultBase.latestVersion,
        releaseName: resultBase.releaseName,
        releaseNotes: resultBase.releaseNotes,
        releaseUrl: resultBase.releaseUrl,
        publishedAt: resultBase.publishedAt,
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
