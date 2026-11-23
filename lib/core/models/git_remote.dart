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

  static String? repositorySlug(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return null;
    String? repositoryPath;
    final scpMatch = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+:(.+)$')
        .firstMatch(url);
    if (scpMatch != null) {
      repositoryPath = scpMatch.group(1);
    } else {
      final uri = Uri.tryParse(url);
      if (uri != null &&
          const {'https', 'ssh', 'git'}.contains(uri.scheme) &&
          uri.host.isNotEmpty) {
        repositoryPath = uri.path;
      }
    }
    if (repositoryPath == null) return null;
    final normalized = repositoryPath
        .replaceAll('\\', '/')
        .replaceFirst(RegExp(r'^/+'), '')
        .replaceFirst(RegExp(r'\.git$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
    final segments = normalized
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    return segments.isEmpty ? null : segments.join('/');
  }

  static String emptyHistoryCommitMessage({
    required DateTime timestamp,
    required String projectSlug,
    required String branch,
  }) {
    String two(int value) => value.toString().padLeft(2, '0');
    final formattedTimestamp =
        '${timestamp.year}-${two(timestamp.month)}-${two(timestamp.day)} '
        '${two(timestamp.hour)}:${two(timestamp.minute)}:'
        '${two(timestamp.second)}';
    return '$formattedTimestamp 仓库已清除，这是第一次空提交'
        '($projectSlug/$branch)，来自软件Git GUI Expand的功能';
  }
}

class RemoteClearPreview {
  const RemoteClearPreview({
    required this.remoteName,
    required this.projectName,
    required this.targetBranch,
    required this.emptyCommitMessage,
    required this.refs,
    required this.refHashes,
    required this.backupRefspecs,
  });

  final String remoteName;
  final String projectName;
  final String targetBranch;
  final String emptyCommitMessage;
  final List<String> refs;
  final Map<String, String> refHashes;
  final List<String> backupRefspecs;

  int get branchCount =>
      refs.where((ref) => ref.startsWith('refs/heads/')).length;
  int get tagCount => refs.where((ref) => ref.startsWith('refs/tags/')).length;
  bool get isEmpty => refs.isEmpty;
  String get confirmationText => '$projectName/$targetBranch';
}

class RemoteClearResult {
  const RemoteClearResult({
    required this.remoteName,
    required this.deletedRefs,
    required this.backupRefspecs,
    required this.emptyCommitHash,
    required this.targetBranch,
    required this.commitMessage,
  });

  final String remoteName;
  final List<String> deletedRefs;
  final List<String> backupRefspecs;
  final String emptyCommitHash;
  final String targetBranch;
  final String commitMessage;
}
