import 'dart:convert';
import 'dart:io';

import '../models/app_models.dart';
import '../utils/path_utils.dart';
import 'app_log_service.dart';

class GitService {
  GitService(this.rootPath, {AppLogService? logService})
    : _log = logService ?? AppLogService.instance;

  final String rootPath;
  final AppLogService _log;

  static Future<String> resolveRepositoryRoot(String selectedPath) async {
    AppLogService.instance.detail(
      'git',
      '验证仓库根目录：${Directory(selectedPath).absolute.path}',
    );
    final selected = Directory(selectedPath).absolute.path;
    if (!await Directory(selected).exists()) {
      throw const GitException('所选文件夹不存在。');
    }
    final result = await _runProcess([
      '-C',
      selected,
      'rev-parse',
      '--show-toplevel',
    ], workingDirectory: selected);
    if (!result.success) {
      throw GitException(
        '所选文件夹不是 Git 仓库根目录，请先执行 git init。',
        commandOutput: result.stderr,
      );
    }
    final root = _normalizeAbsolutePath(result.stdout.trim());
    final normalizedSelected = _normalizeAbsolutePath(selected);
    final samePath = Platform.isWindows
        ? normalizedSelected.toLowerCase() == root.toLowerCase()
        : normalizedSelected == root;
    if (!samePath) {
      throw GitException('请选择仓库根目录：$root');
    }
    return root;
  }

  Future<GitCommandResult> _run(
    List<String> arguments, {
    bool allowFailure = false,
  }) async {
    final displayCommand = 'git ${arguments.map(_quoteArgument).join(' ')}';
    _log.detail('git', 'cwd=$rootPath command=$displayCommand');
    try {
      final result = await _runProcess(arguments, workingDirectory: rootPath);
      _log.detail(
        'git',
        'exit=${result.exitCode} command=$displayCommand\n'
            'stdout=${result.stdout.trim()}\n'
            'stderr=${result.stderr.trim()}',
      );
      if (!allowFailure && !result.success) {
        throw GitException(
          'Git 命令执行失败：$displayCommand',
          commandOutput: result.output,
        );
      }
      return result;
    } catch (error) {
      _log.error('git', 'command=$displayCommand error=$error');
      rethrow;
    }
  }

  static String _quoteArgument(String argument) {
    if (argument.isEmpty) return '""';
    if (RegExp(r'[\s"]').hasMatch(argument)) {
      return '"${argument.replaceAll('"', '\\"')}"';
    }
    return argument;
  }

  static Future<GitCommandResult> _runProcess(
    List<String> arguments, {
    required String workingDirectory,
  }) async {
    try {
      final process = await Process.run(
        'git',
        arguments,
        workingDirectory: workingDirectory,
        environment: const {'GIT_TERMINAL_PROMPT': '0', 'LC_ALL': 'C.UTF-8'},
        includeParentEnvironment: true,
        runInShell: false,
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
      return GitCommandResult(
        success: process.exitCode == 0,
        exitCode: process.exitCode,
        stdout: process.stdout as String? ?? '',
        stderr: process.stderr as String? ?? '',
      );
    } on ProcessException catch (error) {
      throw GitException(
        '无法启动 Git。请确认 git 已安装并加入 PATH。',
        commandOutput: error.message,
      );
    }
  }

  Future<List<RepositoryEntry>> listDirectory(String relativeDirectory) async {
    final directory = normalizeRepositoryPath(relativeDirectory);
    final prefix = directory.isEmpty ? '' : '$directory/';
    final filesResult = await _run([
      'ls-files',
      '-z',
      '--cached',
      '--others',
      '--exclude-standard',
      '--',
      directory.isEmpty ? '.' : '$directory/',
    ]);
    final statuses = await status();
    final statusByPath = {for (final item in statuses) item.path: item};
    final entries = <String, RepositoryEntry>{};
    final seenPaths = <String>{};

    for (final rawPath in filesResult.stdout.split('\u0000')) {
      if (rawPath.isEmpty || !seenPaths.add(rawPath)) {
        continue;
      }
      final path = normalizeRepositoryPath(rawPath);
      if (path.isEmpty || !path.startsWith(prefix)) {
        continue;
      }
      if (path == '.git' || path.startsWith('.git/')) {
        continue;
      }
      final remaining = path.substring(prefix.length);
      if (remaining.isEmpty) {
        continue;
      }
      final slashIndex = remaining.indexOf('/');
      if (slashIndex >= 0) {
        final name = remaining.substring(0, slashIndex);
        final directoryPath = joinRepositoryPath(directory, name);
        final status = statusByPath[path];
        final existing = entries[name];
        entries[name] = RepositoryEntry(
          relativePath: directoryPath,
          name: name,
          kind: EntryKind.directory,
          statusCode: existing?.statusCode.isNotEmpty == true
              ? existing!.statusCode
              : status?.displayCode ?? '',
        );
        continue;
      }

      final absolutePath = absoluteRepositoryPath(rootPath, path);
      final type = await FileSystemEntity.type(absolutePath);
      if (type == FileSystemEntityType.notFound ||
          type == FileSystemEntityType.directory) {
        continue;
      }
      var size = 0;
      try {
        size = await File(absolutePath).length();
      } catch (_) {
        size = 0;
      }
      final status = statusByPath[path];
      entries[remaining] = RepositoryEntry(
        relativePath: path,
        name: remaining,
        kind: EntryKind.file,
        size: size,
        statusCode: status?.displayCode ?? '',
      );
    }

    final result = entries.values.toList(growable: false);
    result.sort((left, right) {
      if (left.isDirectory != right.isDirectory) {
        return left.isDirectory ? -1 : 1;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return result;
  }

  Future<List<GitFileStatus>> status() async {
    final result = await _run([
      'status',
      '--porcelain=v1',
      '-z',
      '--untracked-files=all',
    ]);
    final tokens = result.stdout.split('\u0000');
    final statuses = <GitFileStatus>[];
    var index = 0;
    while (index < tokens.length) {
      final token = tokens[index++];
      if (token.isEmpty || token.length < 3) {
        continue;
      }
      final code = token.substring(0, 2);
      final path = normalizeRepositoryPath(token.substring(3));
      String? originalPath;
      if (code.contains('R') || code.contains('C')) {
        if (index < tokens.length && tokens[index].isNotEmpty) {
          originalPath = normalizeRepositoryPath(tokens[index++]);
        }
      }
      statuses.add(
        GitFileStatus(
          path: path,
          indexCode: code.substring(0, 1),
          worktreeCode: code.substring(1, 2),
          originalPath: originalPath,
        ),
      );
    }
    statuses.sort((left, right) => left.path.compareTo(right.path));
    return statuses;
  }

  Future<String> currentBranch() async {
    final branch = await _run(['branch', '--show-current'], allowFailure: true);
    final name = branch.stdout.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final commit = await _run([
      'rev-parse',
      '--short',
      'HEAD',
    ], allowFailure: true);
    final hash = commit.stdout.trim();
    return hash.isEmpty ? '尚未提交' : 'detached@$hash';
  }

  Future<void> stageAll() async {
    await _run(['add', '-A']);
  }

  Future<void> stagePaths(List<String> paths) async {
    final safePaths = _validateRepositoryPaths(paths);
    if (safePaths.isEmpty) return;
    await _run(['add', '-A', '--', ...safePaths]);
  }

  Future<void> unstageAll() async {
    final head = await _run([
      'rev-parse',
      '--verify',
      'HEAD',
    ], allowFailure: true);
    if (head.success) {
      await _run(['reset', '--', '.']);
    } else {
      await _run([
        'rm',
        '--cached',
        '-r',
        '--ignore-unmatch',
        '--',
        '.',
      ], allowFailure: true);
    }
  }

  Future<void> unstagePaths(List<String> paths) async {
    final safePaths = _validateRepositoryPaths(paths);
    if (safePaths.isEmpty) return;
    final head = await _run([
      'rev-parse',
      '--verify',
      'HEAD',
    ], allowFailure: true);
    if (head.success) {
      await _run(['reset', '--', ...safePaths]);
    } else {
      await _run([
        'rm',
        '--cached',
        '-r',
        '--ignore-unmatch',
        '--',
        ...safePaths,
      ], allowFailure: true);
    }
  }

  Future<void> commit(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw const GitException('提交说明不能为空。');
    }
    await _run(['commit', '-m', trimmed]);
  }

  Future<void> movePaths(
    List<String> sourcePaths,
    String destinationDirectory,
  ) async {
    final destination = normalizeRepositoryPath(destinationDirectory);
    await _ensureDirectory(destination);
    final sources = _validateRepositoryPaths(sourcePaths);
    if (sources.isEmpty) {
      throw const GitException('没有选择要移动的项目。');
    }

    final targets = <String, String>{};
    final seenTargets = <String>{};
    for (final source in sources) {
      final sourceType = await FileSystemEntity.type(
        absoluteRepositoryPath(rootPath, source),
      );
      if (sourceType == FileSystemEntityType.notFound) {
        throw GitException('源项目不存在：$source');
      }
      if (sourceType == FileSystemEntityType.directory &&
          isSameOrDescendantPath(destination, source)) {
        throw GitException('不能把文件夹移动到它自身或其子目录：$source');
      }
      final target = joinRepositoryPath(destination, repositoryName(source));
      if (target == source) {
        throw GitException('目标目录与来源相同：$source');
      }
      final targetKey = Platform.isWindows ? target.toLowerCase() : target;
      if (!seenTargets.add(targetKey)) {
        throw GitException('多个项目将落到同一目标：$target');
      }
      if (await FileSystemEntity.type(
            absoluteRepositoryPath(rootPath, target),
          ) !=
          FileSystemEntityType.notFound) {
        throw GitException('目标位置已存在同名项目：$target');
      }
      targets[source] = target;
    }

    for (final source in sources) {
      await _ensureTracked(source);
    }
    for (final source in sources) {
      await _run(['mv', '--', source, targets[source]!]);
    }
  }

  Future<void> copyPaths(
    List<String> sourcePaths,
    String destinationDirectory,
  ) async {
    final destination = normalizeRepositoryPath(destinationDirectory);
    await _ensureDirectory(destination);
    final sources = _validateRepositoryPaths(sourcePaths);
    if (sources.isEmpty) {
      throw const GitException('没有选择要复制的项目。');
    }

    final files = <_CopyFile>[];
    final seenTargets = <String>{};
    for (final source in sources) {
      if (isSameOrDescendantPath(destination, source)) {
        throw GitException('不能把项目复制到它自身或其子目录：$source');
      }
      final sourceType = await FileSystemEntity.type(
        absoluteRepositoryPath(rootPath, source),
      );
      final targetRoot = joinRepositoryPath(
        destination,
        repositoryName(source),
      );
      if (sourceType == FileSystemEntityType.file ||
          sourceType == FileSystemEntityType.link) {
        _registerCopyTarget(targetRoot, seenTargets);
        files.add(
          _CopyFile(
            sourcePath: source,
            targetPath: targetRoot,
            sourceAbsolutePath: absoluteRepositoryPath(rootPath, source),
          ),
        );
        continue;
      }
      if (sourceType == FileSystemEntityType.directory) {
        if (await FileSystemEntity.type(
              absoluteRepositoryPath(rootPath, targetRoot),
            ) !=
            FileSystemEntityType.notFound) {
          throw GitException('目标位置已存在同名文件夹：$targetRoot');
        }
        final childResult = await _run([
          'ls-files',
          '-z',
          '--cached',
          '--others',
          '--exclude-standard',
          '--',
          '$source/',
        ]);
        var foundFile = false;
        for (final raw in childResult.stdout.split('\u0000')) {
          if (raw.isEmpty) continue;
          final child = normalizeRepositoryPath(raw);
          if (!child.startsWith('$source/')) continue;
          final absoluteChild = absoluteRepositoryPath(rootPath, child);
          if (await FileSystemEntity.type(absoluteChild) ==
              FileSystemEntityType.notFound) {
            continue;
          }
          final suffix = child.substring(source.length + 1);
          final target = '$targetRoot/$suffix';
          _registerCopyTarget(target, seenTargets);
          files.add(
            _CopyFile(
              sourcePath: child,
              targetPath: target,
              sourceAbsolutePath: absoluteChild,
            ),
          );
          foundFile = true;
        }
        if (!foundFile) {
          throw GitException('文件夹中没有可复制的 Git 文件：$source');
        }
        continue;
      }
      throw GitException('源项目不存在：$source');
    }

    if (files.isEmpty) {
      throw const GitException('没有可复制的文件。');
    }

    final prepared = <_PreparedCopy>[];
    for (final file in files) {
      final mode = await _fileMode(file.sourcePath);
      final hashResult = await _run([
        'hash-object',
        '-w',
        '--path=${file.targetPath}',
        '--',
        file.sourceAbsolutePath,
      ]);
      final hash = hashResult.stdout.trim();
      if (hash.isEmpty) {
        throw GitException('无法读取源文件内容：${file.sourcePath}');
      }
      prepared.add(_PreparedCopy(file: file, mode: mode, hash: hash));
    }

    final written = <String>[];
    try {
      for (final item in prepared) {
        await _run([
          'update-index',
          '--add',
          '--cacheinfo',
          '${item.mode},${item.hash},${item.file.targetPath}',
        ]);
        written.add(item.file.targetPath);
      }
      for (final item in prepared) {
        await _run(['checkout-index', '-f', '--', item.file.targetPath]);
      }
    } catch (error) {
      for (final path in written) {
        await _run([
          'update-index',
          '--force-remove',
          '--',
          path,
        ], allowFailure: true);
      }
      rethrow;
    }
  }

  Future<void> renamePath(String sourcePath, String newName) async {
    final source = normalizeRepositoryPath(sourcePath);
    if (source.isEmpty) {
      throw const GitException('不能重命名仓库根目录。');
    }
    _validateSegment(newName);
    final target = joinRepositoryPath(repositoryParent(source), newName);
    if (source == target) {
      return;
    }
    if (await FileSystemEntity.type(absoluteRepositoryPath(rootPath, target)) !=
        FileSystemEntityType.notFound) {
      throw GitException('目标位置已存在同名项目：$target');
    }
    await _ensureTracked(source);
    await _run(['mv', '--', source, target]);
  }

  Future<RepositoryStats> repositoryStats() async {
    _log.detail('storage', '开始统计仓库大小：$rootPath');
    var totalBytes = 0;
    var fileCount = 0;
    var directoryCount = 0;
    try {
      final directory = Directory(rootPath);
      await for (final entity in directory.list(
        recursive: true,
        followLinks: false,
      )) {
        final relative = toPosixPath(entity.path.substring(rootPath.length))
            .replaceFirst(RegExp(r'^/+'), '');
        if (relative == '.git' || relative.startsWith('.git/')) {
          continue;
        }
        if (entity is Directory) {
          directoryCount += 1;
        } else if (entity is File) {
          fileCount += 1;
          try {
            totalBytes += await entity.length();
          } catch (_) {
            // A file can disappear while a recursive scan is running.
          }
        }
      }
    } catch (_) {
      // Return the successfully counted portion when a subdirectory is locked.
    }
    final stats = RepositoryStats(
      totalBytes: totalBytes,
      fileCount: fileCount,
      directoryCount: directoryCount,
    );
    _log.detail(
      'storage',
      '仓库统计完成：files=${stats.fileCount} '
          'directories=${stats.directoryCount} bytes=${stats.totalBytes}',
    );
    return stats;
  }

  Future<void> _ensureDirectory(String relativeDirectory) async {
    final type = await FileSystemEntity.type(
      absoluteRepositoryPath(rootPath, relativeDirectory),
    );
    if (type != FileSystemEntityType.directory) {
      throw GitException('目标文件夹不存在：$relativeDirectory');
    }
  }

  Future<void> _ensureTracked(String path) async {
    final tracked = await _run([
      'ls-files',
      '--error-unmatch',
      '--',
      path,
    ], allowFailure: true);
    if (!tracked.success) {
      await stagePaths([path]);
    }
  }

  Future<String> _fileMode(String sourcePath) async {
    final result = await _run([
      'ls-files',
      '-s',
      '--',
      sourcePath,
    ], allowFailure: true);
    if (!result.success) return '100644';
    final line = result.stdout.split('\n').first.trim();
    if (line.isEmpty) return '100644';
    final mode = line.split(RegExp(r'\s+')).first;
    return RegExp(r'^[0-7]{6}$').hasMatch(mode) ? mode : '100644';
  }

  void _registerCopyTarget(String target, Set<String> seenTargets) {
    final key = Platform.isWindows ? target.toLowerCase() : target;
    if (!seenTargets.add(key)) {
      throw GitException('多个项目将复制到同一目标：$target');
    }
    if (FileSystemEntity.typeSync(
          absoluteRepositoryPath(rootPath, target),
          followLinks: false,
        ) !=
        FileSystemEntityType.notFound) {
      throw GitException('目标位置已存在同名项目：$target');
    }
  }

  List<String> _validateRepositoryPaths(List<String> paths) {
    final result = <String>[];
    for (final raw in paths) {
      if (raw.startsWith('/') ||
          raw.startsWith('\\') ||
          RegExp(r'^[A-Za-z]:').hasMatch(raw)) {
        throw const GitException('路径必须是仓库内的相对路径。');
      }
      final path = normalizeRepositoryPath(raw);
      if (path.isEmpty) continue;
      if (path == '.git' || path.startsWith('.git/')) {
        throw const GitException('不能操作 .git 元数据目录。');
      }
      if (path.split('/').any((segment) => segment == '..')) {
        throw const GitException('路径不能离开仓库根目录。');
      }
      result.add(path);
    }
    return result;
  }

  void _validateSegment(String name) {
    if (name.isEmpty || name == '.' || name == '..') {
      throw const GitException('名称无效。');
    }
    if (name.contains('/') || name.contains('\\') || name.contains('\u0000')) {
      throw const GitException('新名称不能包含路径分隔符。');
    }
    if (name.endsWith('.') || name.endsWith(' ')) {
      throw const GitException('Windows 文件名不能以句点或空格结尾。');
    }
    if (Platform.isWindows && RegExp(r'[<>:"|?*]').hasMatch(name)) {
      throw const GitException('Windows 文件名不能包含 < > : " | ? *。');
    }
  }

  static String _normalizeAbsolutePath(String path) {
    var normalized = toPosixPath(path);
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return Platform.isWindows ? normalized.replaceAll('/', '\\') : normalized;
  }
}

class _CopyFile {
  const _CopyFile({
    required this.sourcePath,
    required this.targetPath,
    required this.sourceAbsolutePath,
  });

  final String sourcePath;
  final String targetPath;
  final String sourceAbsolutePath;
}

class _PreparedCopy {
  const _PreparedCopy({
    required this.file,
    required this.mode,
    required this.hash,
  });

  final _CopyFile file;
  final String mode;
  final String hash;
}
