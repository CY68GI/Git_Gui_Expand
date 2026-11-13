enum GitRemotePlatform { github, gitee, gitlab, bitbucket, generic }

class GitRemote {
  const GitRemote({
    required this.name,
    required this.fetchUrl,
    required this.pushUrl,
    required this.platform,
  });

  final String name;
  final String fetchUrl;
  final String pushUrl;
  final GitRemotePlatform platform;

  String get effectiveUrl => pushUrl.isNotEmpty ? pushUrl : fetchUrl;

  String get platformLabel {
    return switch (platform) {
      GitRemotePlatform.github => 'GitHub',
      GitRemotePlatform.gitee => 'Gitee',
      GitRemotePlatform.gitlab => 'GitLab',
      GitRemotePlatform.bitbucket => 'Bitbucket',
      GitRemotePlatform.generic => '其他 Git',
    };
  }

  static GitRemotePlatform detectPlatform(String url) {
    final normalized = url.toLowerCase();
    if (normalized.contains('github.com')) return GitRemotePlatform.github;
    if (normalized.contains('gitee.com')) return GitRemotePlatform.gitee;
    if (normalized.contains('gitlab.com') || normalized.contains('gitlab.')) {
      return GitRemotePlatform.gitlab;
    }
    if (normalized.contains('bitbucket.org')) {
      return GitRemotePlatform.bitbucket;
    }
    return GitRemotePlatform.generic;
  }

  String get maskedUrl => maskRemoteUrl(effectiveUrl);

  static String maskRemoteUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.userInfo.isEmpty) return url;
    return url.replaceFirst(uri.userInfo, '***');
  }
}
