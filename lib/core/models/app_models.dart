enum EntryKind { file, directory }

class RepositoryEntry {
  const RepositoryEntry({
    required this.relativePath,
    required this.name,
    required this.kind,
    this.size,
    this.statusCode = '',
  });

  final String relativePath;
  final String name;
  final EntryKind kind;
  final int? size;
  final String statusCode;

  bool get isDirectory => kind == EntryKind.directory;
}

class GitStashEntry {
  const GitStashEntry({
    required this.selector,
    required this.message,
    required this.createdAt,
  });

  final String selector;
  final String message;
  final String createdAt;
}

class GitFileStatus {
  const GitFileStatus({
    required this.path,
    required this.indexCode,
    required this.worktreeCode,
    this.originalPath,
  });

  final String path;
  final String indexCode;
  final String worktreeCode;
  final String? originalPath;

  bool get isStaged => indexCode != ' ' && indexCode != '?';
  bool get hasWorktreeChange => worktreeCode != ' ' && worktreeCode != '?';

  String get displayCode {
    final worktree = worktreeCode.trim();
    if (worktree.isNotEmpty) return worktree;
    final staged = indexCode.trim();
    return staged.isEmpty ? '?' : staged;
  }

  String get label {
    if (indexCode == '?' && worktreeCode == '?') return '未跟踪';
    return '${indexCode.trim()}${worktreeCode.trim()}'.isEmpty
        ? '未知'
        : '${indexCode.trim()}${worktreeCode.trim()}';
  }
}

class RepositoryStats {
  const RepositoryStats({
    required this.totalBytes,
    required this.fileCount,
    required this.directoryCount,
  });

  final int totalBytes;
  final int fileCount;
  final int directoryCount;
}

class GitCommandResult {
  const GitCommandResult({
    required this.success,
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });

  final bool success;
  final int exitCode;
  final String stdout;
  final String stderr;

  String get output {
    final out = stdout.trim();
    final err = stderr.trim();
    if (out.isEmpty) return err;
    if (err.isEmpty) return out;
    return '$out\n$err';
  }
}

class GitException implements Exception {
  const GitException(this.message, {this.commandOutput = ''});

  final String message;
  final String commandOutput;

  @override
  String toString() {
    final detail = commandOutput.trim();
    return detail.isEmpty ? message : '$message\n$detail';
  }
}
