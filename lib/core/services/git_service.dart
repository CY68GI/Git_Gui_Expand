import 'dart:convert';
import 'dart:io';

import '../models/app_models.dart';
import '../models/git_identity.dart';
import '../models/git_remote.dart';
import '../models/operation_safety.dart';
import '../models/repository_sync.dart';
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
    final rootRaw = _normalizeAbsolutePath(result.stdout.trim());
    final root = await _canonicalDirectoryPath(rootRaw);
    final normalizedSelected = await _canonicalDirectoryPath(selected);
    final samePath = Platform.isWindows
        ? normalizedSelected.toLowerCase() == root.toLowerCase()
        : normalizedSelected == root;
    if (!samePath) {
      throw GitException('请选择仓库根目录：$root');
    }
    return root;
  }

  static Future<void> initializeRepository(String folderPath) async {
    final folder = Directory(folderPath).absolute.path;
    if (!await Directory(folder).exists()) {
      throw const GitException('要初始化的文件夹不存在。');
    }
    final gitType = await FileSystemEntity.type(
      '$folder${Platform.pathSeparator}.git',
      followLinks: false,
    );
    if (gitType != FileSystemEntityType.notFound) {
      throw const GitException('目标文件夹已经包含 Git 元数据，已拒绝重复初始化。');
    }
    final result = await _runStandaloneGit(['init'], folder);
    if (!result.success) {
      throw GitException('git init 初始化失败。', commandOutput: result.output);
    }
    AppLogService.instance.info('repository', '已初始化 Git 仓库：$folder');
  }

  static Future<BootstrapTargetSnapshot> inspectInitializationTarget(
    String folderPath,
  ) async {
    final target = Directory(folderPath).absolute;
    final targetExists = await target.exists();
    final parent = target.parent;
    final gitType = await FileSystemEntity.type(
      '${target.path}${Platform.pathSeparator}.git',
      followLinks: false,
    );
    return BootstrapTargetSnapshot(
      contextKind: OperationContextKind.bootstrap,
      targetPath: target.path,
      parentPath: parent.absolute.path,
      targetExists: targetExists,
      targetIsEmpty: targetExists
          ? (await target.list(followLinks: false).take(1).toList()).isEmpty
          : true,
      gitMetadataType: _fileSystemEntityTypeName(gitType),
      source: 'git init',
    );
  }

  static Future<void> cloneRepository(
    String remoteUrl,
    String destinationPath,
  ) async {
    _validateCloneUrl(remoteUrl);
    final destination = Directory(destinationPath).absolute;
    final parent = destination.parent;
    if (!await parent.exists()) {
      throw GitException('克隆目标父目录不存在：${parent.path}');
    }
    if (await destination.exists()) {
      final entries = await destination
          .list(followLinks: false)
          .take(1)
          .toList();
      if (entries.isNotEmpty) {
        throw GitException('克隆目标目录不是空目录：${destination.path}');
      }
    }
    final result = await _runStandaloneGit([
      'clone',
      '--',
      remoteUrl.trim(),
      destination.path,
    ], parent.path);
    if (!result.success) {
      throw GitException('git clone 克隆失败。', commandOutput: result.output);
    }
    AppLogService.instance.info(
      'repository',
      '已克隆 Git 仓库：${remoteUrl.trim()} -> ${destination.path}',
    );
  }

  static Future<BootstrapTargetSnapshot> inspectCloneTarget(
    String remoteUrl,
    String destinationPath,
  ) async {
    _validateCloneUrl(remoteUrl);
    final destination = Directory(destinationPath).absolute;
    final targetExists = await destination.exists();
    final gitType = await FileSystemEntity.type(
      '${destination.path}${Platform.pathSeparator}.git',
      followLinks: false,
    );
    return BootstrapTargetSnapshot(
      contextKind: OperationContextKind.bootstrap,
      targetPath: destination.path,
      parentPath: destination.parent.absolute.path,
      targetExists: targetExists,
      targetIsEmpty: targetExists
          ? (await destination.list(followLinks: false).take(1).toList())
                .isEmpty
          : true,
      gitMetadataType: _fileSystemEntityTypeName(gitType),
      source: remoteUrl.trim(),
    );
  }

  static Future<void> clearRepositoryMetadata(String folderPath) async {
    final root = Directory(folderPath).absolute.path;
    final gitPath = '$root${Platform.pathSeparator}.git';
    final type = await FileSystemEntity.type(gitPath, followLinks: false);
    if (type == FileSystemEntityType.notFound) {
      throw const GitException('当前文件夹没有 Git 元数据。');
    }
    if (type != FileSystemEntityType.directory) {
      throw const GitException('当前 `.git` 不是普通目录，可能是 worktree 或子模块，已拒绝清理。');
    }
    final remotes = await _runStandaloneGit(['remote'], root);
    if (!remotes.success) {
      throw const GitException('无法检查仓库远端，已拒绝清理。');
    }
    if (remotes.stdout.trim().isNotEmpty) {
      throw const GitException('当前仓库已经连接远程仓库，不能清除 Git 元数据。');
    }
    await Directory(gitPath).delete(recursive: true);
    AppLogService.instance.warning(
      'repository',
      '已清除未连接远端的 Git 元数据，工作文件保留：$root',
    );
  }

  static String repositoryNameFromRemote(String remoteUrl) {
    var value = remoteUrl.trim();
    if (value.endsWith('/') || value.endsWith('\\')) {
      value = value.substring(0, value.length - 1);
    }
    final slash = value.lastIndexOf(RegExp(r'[/:\\\\]'));
    final name = slash >= 0 ? value.substring(slash + 1) : value;
    return name.endsWith('.git') ? name.substring(0, name.length - 4) : name;
  }

  static void _validateCloneUrl(String remoteUrl) {
    final value = remoteUrl.trim();
    if (value.isEmpty) {
      throw const GitException('克隆地址不能为空。');
    }
    final uri = Uri.tryParse(value);
    final scpStyle = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+:.+')
        .hasMatch(value);
    final supportedScheme =
        uri != null &&
        const {'https', 'ssh', 'git', 'file'}.contains(uri.scheme);
    final localPath =
        !value.contains('://') &&
        !scpStyle &&
        (value.contains('\\') ||
            value.startsWith('.') ||
            value.startsWith('/'));
    if (!scpStyle && !supportedScheme && !localPath) {
      throw const GitException(
        '克隆地址仅支持 HTTPS、SSH、git@host:path、file:// 或本地路径。',
      );
    }
  }

  static Future<GitCommandResult> _runStandaloneGit(
    List<String> arguments,
    String workingDirectory,
  ) {
    return _runProcess(arguments, workingDirectory: workingDirectory);
  }

  static Future<String> _canonicalDirectoryPath(String path) async {
    final absolute = Directory(path).absolute.path;
    try {
      return _normalizeAbsolutePath(
        await Directory(absolute).resolveSymbolicLinks(),
      );
    } on FileSystemException {
      return _normalizeAbsolutePath(absolute);
    }
  }

  Future<GitCommandResult> _run(
    List<String> arguments, {
    bool allowFailure = false,
    String? stdin,
  }) async {
    final displayCommand = 'git ${arguments.map(_quoteArgument).join(' ')}';
    _log.detail('git', 'cwd=$rootPath command=$displayCommand');
    try {
      final result = await _runProcess(
        arguments,
        workingDirectory: rootPath,
        stdin: stdin,
      );
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
    String? stdin,
  }) async {
    try {
      if (stdin != null) {
        final process = await Process.start(
          'git',
          arguments,
          workingDirectory: workingDirectory,
          environment: const {
            'GIT_TERMINAL_PROMPT': '0',
            'LC_ALL': 'C.UTF-8',
            'LANG': 'C.UTF-8',
          },
          includeParentEnvironment: true,
          runInShell: false,
        );
        final stdoutFuture = process.stdout.transform(utf8.decoder).join();
        final stderrFuture = process.stderr.transform(utf8.decoder).join();
        process.stdin.encoding = utf8;
        process.stdin.write(stdin);
        await process.stdin.close();
        final exitCode = await process.exitCode;
        return GitCommandResult(
          success: exitCode == 0,
          exitCode: exitCode,
          stdout: await stdoutFuture,
          stderr: await stderrFuture,
        );
      }
      final process = await Process.run(
        'git',
        arguments,
        workingDirectory: workingDirectory,
        environment: const {
          'GIT_TERMINAL_PROMPT': '0',
          'LC_ALL': 'C.UTF-8',
          'LANG': 'C.UTF-8',
        },
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

  Future<RepositoryStateSnapshot> stateSnapshot({
    Iterable<String> selectedPaths = const [],
  }) async {
    final root = await _canonicalDirectoryPath(rootPath);
    final branch = await currentBranch();
    final headResult = await _run([
      'rev-parse',
      '--verify',
      'HEAD',
    ], allowFailure: true);
    final head = headResult.success ? headResult.stdout.trim() : 'UNBORN';
    final statusResult = await _run([
      'status',
      '--porcelain=v1',
      '-z',
      '--untracked-files=all',
    ]);
    final remoteList = await remotes();
    final remoteUrls = <String, String>{
      for (final remote in remoteList) remote.name: remote.effectiveUrl,
    };
    final pathTypes = await pathTypeSnapshot(selectedPaths);
    final snapshot = RepositoryStateSnapshot(
      rootPath: root,
      branch: branch,
      head: head,
      statusFingerprint: statusResult.stdout,
      remoteUrls: Map.unmodifiable(remoteUrls),
      pathTypes: Map.unmodifiable(pathTypes),
    );
    _log.detail(
      'safety',
      '已采集仓库状态快照：branch=$branch head=$head '
          'statusBytes=${statusResult.stdout.length} '
          'remotes=${remoteUrls.length} paths=${pathTypes.length}',
    );
    return snapshot;
  }

  Future<Map<String, String>> pathTypeSnapshot(
    Iterable<String> selectedPaths,
  ) async {
    final normalizedPaths = _validateRepositoryPaths(
      selectedPaths.toList(growable: false),
    );
    final pathTypes = <String, String>{};
    for (final path in normalizedPaths) {
      final type = await FileSystemEntity.type(
        absoluteRepositoryPath(rootPath, path),
        followLinks: false,
      );
      pathTypes[path] = _fileSystemEntityTypeName(type);
    }
    return Map.unmodifiable(pathTypes);
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

  Future<BranchSyncState> syncState() async {
    final branchResult = await _run([
      'branch',
      '--show-current',
    ], allowFailure: true);
    final branch = branchResult.stdout.trim();
    final statusResult = await _run([
      'status',
      '--porcelain=v1',
      '-z',
      '--untracked-files=all',
    ]);
    final clean = statusResult.stdout.isEmpty;

    if (branch.isEmpty) {
      final head = await _run([
        'rev-parse',
        '--verify',
        'HEAD',
      ], allowFailure: true);
      return head.success
          ? BranchSyncState.detached(worktreeClean: clean)
          : BranchSyncState.unborn(worktreeClean: clean);
    }

    final head = await _run([
      'rev-parse',
      '--verify',
      'HEAD',
    ], allowFailure: true);
    if (!head.success) {
      return BranchSyncState.unborn(worktreeClean: clean);
    }

    final upstreamResult = await _run([
      'rev-parse',
      '--abbrev-ref',
      '--symbolic-full-name',
      '@{u}',
    ], allowFailure: true);
    final upstreamRef = upstreamResult.stdout.trim();
    if (!upstreamResult.success || upstreamRef.isEmpty) {
      return BranchSyncState.noUpstream(branch: branch, worktreeClean: clean);
    }
    final separator = upstreamRef.indexOf('/');
    if (separator <= 0 || separator == upstreamRef.length - 1) {
      throw GitException('无法解析当前分支的 upstream：$upstreamRef');
    }
    final counts = await _run([
      'rev-list',
      '--left-right',
      '--count',
      'HEAD...@{u}',
    ]);
    final parts = counts.stdout.trim().split(RegExp(r'\s+'));
    if (parts.length != 2) {
      throw GitException(
        '无法解析当前分支与 upstream 的 ahead/behind 数量。',
        commandOutput: counts.output,
      );
    }
    final ahead = int.tryParse(parts[0]);
    final behind = int.tryParse(parts[1]);
    if (ahead == null || behind == null) {
      throw GitException(
        '当前分支与 upstream 的 ahead/behind 数量无效。',
        commandOutput: counts.output,
      );
    }
    final state = BranchSyncState(
      kind: BranchSyncKind.tracked,
      branch: branch,
      upstreamRef: upstreamRef,
      upstreamRemote: upstreamRef.substring(0, separator),
      upstreamBranch: upstreamRef.substring(separator + 1),
      ahead: ahead,
      behind: behind,
      worktreeClean: clean,
    );
    _log.detail(
      'sync',
      '同步状态：branch=${state.branch} upstream=${state.upstreamRef} '
          'ahead=${state.ahead} behind=${state.behind} clean=${state.worktreeClean}',
    );
    return state;
  }

  Future<GitIdentityState> identityState() async {
    final authorResult = await _run([
      'var',
      'GIT_AUTHOR_IDENT',
    ], allowFailure: true);
    final committerResult = await _run([
      'var',
      'GIT_COMMITTER_IDENT',
    ], allowFailure: true);
    final author = authorResult.success
        ? GitIdentityPerson.tryParse(authorResult.stdout)
        : null;
    final committer = committerResult.success
        ? GitIdentityPerson.tryParse(committerResult.stdout)
        : null;
    if (author != null && committer != null) {
      _log.detail(
        'identity',
        'Git 提交身份有效：author=${author.name}; '
            'committer=${committer.name}',
      );
      return GitIdentityState(
        isReady: true,
        author: author,
        committer: committer,
      );
    }
    final details = [
      if (!authorResult.success) authorResult.output.trim(),
      if (!committerResult.success) committerResult.output.trim(),
      if (authorResult.success && author == null) 'GIT_AUTHOR_IDENT 输出无法解析',
      if (committerResult.success && committer == null)
        'GIT_COMMITTER_IDENT 输出无法解析',
    ].where((line) => line.isNotEmpty).join('\n');
    _log.warning('identity', 'Git 提交身份不可用：$details');
    return GitIdentityState.unavailable(details);
  }

  Future<List<String>> localBranches() async {
    final result = await _run([
      'for-each-ref',
      '--format=%(refname:short)',
      'refs/heads',
    ]);
    return result.stdout
        .split(RegExp(r'[\r\n]+'))
        .map((branch) => branch.trim())
        .where((branch) => branch.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> validateBranchName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.startsWith('-')) {
      throw const GitException('分支名称不能为空或以 - 开头。');
    }
    final result = await _run([
      'check-ref-format',
      '--branch',
      trimmed,
    ], allowFailure: true);
    if (!result.success) {
      throw GitException('分支名称无效。', commandOutput: result.stderr);
    }
  }

  Future<void> createBranch(String name) async {
    await validateBranchName(name);
    await _run(['branch', '--', name.trim()]);
  }

  Future<void> switchBranch(String name) async {
    await validateBranchName(name);
    await _run(['switch', name.trim()]);
  }

  Future<void> renameBranch(String oldName, String newName) async {
    await validateBranchName(oldName);
    await validateBranchName(newName);
    await _run(['branch', '-m', oldName.trim(), newName.trim()]);
  }

  Future<void> deleteBranch(String name, {bool force = false}) async {
    await validateBranchName(name);
    await _run(['branch', force ? '-D' : '-d', name.trim()]);
  }

  Future<void> createStash({
    String? message,
    bool includeUntracked = true,
  }) async {
    final args = ['stash', 'push'];
    if (includeUntracked) {
      args.add('--include-untracked');
    }
    final trimmed = message?.trim() ?? '';
    if (trimmed.isNotEmpty) {
      args
        ..add('-m')
        ..add(trimmed);
    }
    final result = await _run(args);
    if (result.output.toLowerCase().contains('no local changes')) {
      throw const GitException('当前没有可暂存的更改。');
    }
  }

  Future<List<GitStashEntry>> listStashes() async {
    final result = await _run([
      'stash',
      'list',
      '--format=%gd%x1f%gs%x1f%ci%x1e',
    ], allowFailure: true);
    if (!result.success) return const [];
    final entries = <GitStashEntry>[];
    for (final record in result.stdout.split('\x1e')) {
      final trimmed = record.trim();
      if (trimmed.isEmpty) continue;
      final parts = trimmed.split('\x1f');
      if (parts.length < 2) continue;
      entries.add(
        GitStashEntry(
          selector: parts[0].trim(),
          message: parts[1].trim(),
          createdAt: parts.length > 2 ? parts[2].trim() : '',
        ),
      );
    }
    return entries;
  }

  Future<void> applyStash(String selector) async {
    _validateStashSelector(selector);
    await _run(['stash', 'apply', selector]);
  }

  Future<void> popStash(String selector) async {
    _validateStashSelector(selector);
    await _run(['stash', 'pop', selector]);
  }

  Future<void> dropStash(String selector) async {
    _validateStashSelector(selector);
    await _run(['stash', 'drop', selector]);
  }

  void _validateStashSelector(String selector) {
    if (!RegExp(r'^stash@\{\d+\}$').hasMatch(selector.trim())) {
      throw const GitException('Stash 选择器无效。');
    }
  }

  Future<String> pushCurrentBranch() async {
    final branchResult = await _run([
      'branch',
      '--show-current',
    ], allowFailure: true);
    final branch = branchResult.stdout.trim();
    if (branch.isEmpty) {
      throw const GitException('当前为分离 HEAD，无法直接推送分支。');
    }
    final upstream = await _run([
      'rev-parse',
      '--abbrev-ref',
      '--symbolic-full-name',
      '@{u}',
    ], allowFailure: true);
    _log.info(
      'push',
      upstream.success
          ? '推送分支 $branch 到 ${upstream.stdout.trim()}'
          : '推送分支 $branch 并设置远程 upstream',
    );
    if (upstream.success) {
      final result = await _run(['push']);
      return result.output.trim().isEmpty ? '已推送 $branch' : result.output;
    }

    final remotesResult = await _run(['remote'], allowFailure: true);
    final remotes = remotesResult.stdout
        .split(RegExp(r'[\r\n]+'))
        .map((remote) => remote.trim())
        .where((remote) => remote.isNotEmpty)
        .toList(growable: false);
    if (remotes.isEmpty) {
      throw const GitException('仓库没有配置远程地址，无法推送。');
    }
    final remote = remotes.contains('origin') ? 'origin' : remotes.first;
    final result = await _run(['push', '-u', remote, branch]);
    return result.output.trim().isEmpty
        ? '已推送 $branch 到 $remote'
        : result.output;
  }

  Future<String> fetchRemote(String remoteName) async {
    _validateRemoteName(remoteName);
    final result = await _run(['fetch', '--prune', remoteName]);
    _log.info('sync', '已从远端 $remoteName 获取更新');
    return result.output.trim();
  }

  Future<SafePullResult> pullFastForward() async {
    final initial = await syncState();
    _validatePullState(initial);
    await fetchRemote(initial.upstreamRemote);
    final refreshed = await syncState();
    _validatePullState(refreshed, rejectDiverged: false);
    if (refreshed.relation == BranchSyncRelation.upToDate ||
        refreshed.relation == BranchSyncRelation.ahead) {
      return SafePullResult(
        updated: false,
        state: refreshed,
        output: refreshed.relation == BranchSyncRelation.ahead
            ? '当前分支包含 upstream 的全部提交，但仍有本地提交未推送。'
            : '当前分支已经与 upstream 同步。',
      );
    }
    if (refreshed.relation == BranchSyncRelation.diverged) {
      throw const GitException(
        '本地分支与 upstream 已分叉，已拒绝快进 Pull。'
        '远端跟踪引用已更新，当前分支和工作区未改变；'
        '请先使用外部 Git 执行 Merge 或 Rebase。',
      );
    }
    final result = await _run(['merge', '--ff-only', refreshed.upstreamRef]);
    final completed = await syncState();
    _log.info(
      'sync',
      '快进 Pull 完成：${completed.branch} behind=${completed.behind}',
    );
    return SafePullResult(
      updated: true,
      state: completed,
      output: result.output.trim(),
    );
  }

  void _validatePullState(BranchSyncState state, {bool rejectDiverged = true}) {
    if (state.isDetached) {
      throw const GitException('当前处于 detached HEAD，不能 Pull 分支。');
    }
    if (state.isUnborn) {
      throw const GitException('当前分支尚无提交，不能 Pull。');
    }
    if (!state.hasUpstream) {
      throw const GitException('当前分支没有可用的 upstream。');
    }
    if (!state.worktreeClean) {
      throw const GitException('工作区或索引不干净，已拒绝 Pull。请先提交或 Stash 更改。');
    }
    if (rejectDiverged && state.relation == BranchSyncRelation.diverged) {
      throw const GitException(
        '本地分支与 upstream 已分叉，已拒绝快进 Pull。'
        '请使用外部 Git 执行 Merge 或 Rebase。',
      );
    }
  }

  Future<List<GitRemote>> remotes() async {
    final namesResult = await _run(['remote'], allowFailure: true);
    final names = namesResult.stdout
        .split(RegExp(r'[\r\n]+'))
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList(growable: false);
    final remotes = <GitRemote>[];
    for (final name in names) {
      final fetch = await _run(['remote', 'get-url', name], allowFailure: true);
      final push = await _run([
        'remote',
        'get-url',
        '--push',
        name,
      ], allowFailure: true);
      final fetchUrl = fetch.stdout.trim();
      final pushUrl = push.stdout.trim();
      final effectiveUrl = pushUrl.isNotEmpty ? pushUrl : fetchUrl;
      if (effectiveUrl.isEmpty) continue;
      remotes.add(
        GitRemote(
          name: name,
          fetchUrl: fetchUrl,
          pushUrl: pushUrl,
          platform: GitRemote.detectPlatform(effectiveUrl),
        ),
      );
    }
    remotes.sort((left, right) {
      if (left.name == 'origin') return -1;
      if (right.name == 'origin') return 1;
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return remotes;
  }

  Future<void> addRemote(String name, String url) async {
    _validateRemoteName(name);
    _validateRemoteUrl(url);
    await _run(['remote', 'add', name, url]);
    _log.info('remote', '新增远端 $name -> ${GitRemote.maskRemoteUrl(url)}');
  }

  Future<void> setRemoteUrl(String name, String url) async {
    _validateRemoteName(name);
    _validateRemoteUrl(url);
    await _run(['remote', 'set-url', name, url]);
    _log.info('remote', '更新远端 $name -> ${GitRemote.maskRemoteUrl(url)}');
  }

  Future<void> removeRemote(String name) async {
    _validateRemoteName(name);
    await _run(['remote', 'remove', name]);
    _log.info('remote', '删除远端 $name');
  }

  Future<String> pushToRemote(String remoteName) async {
    _validateRemoteName(remoteName);
    final branch = await _run(['branch', '--show-current']);
    final name = branch.stdout.trim();
    if (name.isEmpty) {
      throw const GitException('当前为分离 HEAD，无法推送分支。');
    }
    final result = await _run(['push', remoteName, name]);
    _log.info('remote', '已推送 $name 到远端 $remoteName');
    return result.output.trim();
  }

  Future<RemoteClearPreview> previewClearRemote(String remoteName) async {
    _validateRemoteName(remoteName);
    final refHashes = await _readRemoteRefHashes(remoteName);
    final sortedRefs = refHashes.keys.toList(growable: false)..sort();
    final projectName = await _remoteProjectName(remoteName);
    final targetBranch = await _remoteHeadBranch(remoteName);
    final emptyCommitMessage = _buildEmptyCommitMessage(
      projectName: projectName,
      targetBranch: targetBranch,
    );
    final backupRefspecs = [
      '+refs/heads/*:refs/gitgui-expand/backup/$remoteName/heads/*',
      '+refs/tags/*:refs/gitgui-expand/backup/$remoteName/tags/*',
    ];
    _log.info(
      'remote-clear',
      '清空远端预览：remote=$remoteName refs=${sortedRefs.length} '
          'project=$projectName branch=$targetBranch '
          'refs=${sortedRefs.join(' | ')}',
    );
    return RemoteClearPreview(
      remoteName: remoteName,
      projectName: projectName,
      targetBranch: targetBranch,
      emptyCommitMessage: emptyCommitMessage,
      refs: List.unmodifiable(sortedRefs),
      refHashes: Map.unmodifiable(refHashes),
      backupRefspecs: List.unmodifiable(backupRefspecs),
    );
  }

  Future<RemoteClearResult> clearRemote(
    String remoteName, {
    RemoteClearPreview? preview,
  }) async {
    _validateRemoteName(remoteName);
    final inspected = preview ?? await previewClearRemote(remoteName);
    if (inspected.remoteName != remoteName) {
      throw const GitException('远端清空预览与实际远端不一致。');
    }
    final localBranch = (await currentBranch()).trim();
    if (localBranch.isEmpty ||
        localBranch == '尚未提交' ||
        localBranch.startsWith('detached@')) {
      throw const GitException('当前没有可用于同步清空历史的本地分支。');
    }
    if (localBranch != inspected.targetBranch) {
      throw GitException(
        '当前本地分支为 $localBranch，但远端目标分支为 '
        '${inspected.targetBranch}。请先切换到目标分支再执行。',
      );
    }
    final localHeadBefore = await _run([
      'rev-parse',
      '--verify',
      'HEAD',
    ], allowFailure: true);
    if (!localHeadBefore.success) {
      throw const GitException('当前本地分支没有可备份的提交。');
    }

    final currentTargetBranch = await _remoteHeadBranch(remoteName);
    final currentRefHashes = await _readRemoteRefHashes(remoteName);
    if (currentTargetBranch != inspected.targetBranch ||
        !_remoteRefMapsEqual(inspected.refHashes, currentRefHashes)) {
      final drift = _remoteRefDiff(
        expected: inspected.refHashes,
        actual: currentRefHashes,
      );
      _log.warning('remote-clear', '远端引用在确认后发生变化：$drift');
      throw GitException(
        '远端引用在确认后发生了变化，已拒绝清空。请刷新远端预览后重新确认。',
        commandOutput: drift,
      );
    }

    _log.warning(
      'remote-clear',
      '即将备份并清空远端 $remoteName 的 ${inspected.refs.length} 个引用；'
          '保留空分支 ${inspected.targetBranch}',
    );
    if (inspected.refs.isNotEmpty) {
      await _run([
        'fetch',
        '--no-tags',
        '--prune',
        remoteName,
        ...inspected.backupRefspecs,
      ]);
      _log.info(
        'remote-clear',
        '远端 $remoteName 引用已备份到 refs/gitgui-expand/backup/$remoteName',
      );
    }

    final emptyTreeResult = await _run(['mktree'], stdin: '');
    final emptyTree = emptyTreeResult.stdout.trim();
    if (emptyTree.isEmpty) {
      throw const GitException('无法创建空目录树。');
    }
    final emptyCommitResult = await _run([
      '-c',
      'i18n.commitEncoding=UTF-8',
      'commit-tree',
      emptyTree,
      '-F',
      '-',
    ], stdin: inspected.emptyCommitMessage);
    final emptyCommit = emptyCommitResult.stdout.trim();
    if (emptyCommit.isEmpty) {
      throw const GitException('无法创建第一个空提交。');
    }

    final targetRef = 'refs/heads/${inspected.targetBranch}';
    final refsToDelete =
        currentRefHashes.keys
            .where((ref) => ref != targetRef)
            .toList(growable: false)
          ..sort();
    final pushArguments = <String>[
      'push',
      '--atomic',
      '--force-with-lease=$targetRef:'
          '${currentRefHashes[targetRef] ?? ''}',
      for (final ref in refsToDelete)
        '--force-with-lease=$ref:${currentRefHashes[ref]}',
      remoteName,
      '$emptyCommit:$targetRef',
      ...refsToDelete.map((ref) => ':$ref'),
    ];
    final pushResult = await _run(pushArguments, allowFailure: true);
    if (!pushResult.success) {
      final output = pushResult.output.trim();
      final protectedHint =
          output.toLowerCase().contains('protected') || output.contains('保护')
          ? '目标分支或受保护引用拒绝强制更新或删除。请先在托管平台临时解除保护，再重新执行计划。'
          : '远端未完成原子替换。服务器必须支持 atomic push，且目标分支必须允许强制更新。';
      throw GitException(
        '清空远端 $remoteName 失败。$protectedHint',
        commandOutput: output,
      );
    }

    final remaining = await _readRemoteRefHashes(remoteName);
    final expectedRefs = {targetRef};
    if (remaining.keys.toSet().difference(expectedRefs).isNotEmpty ||
        remaining[targetRef] != emptyCommit) {
      final backupRoot = 'refs/gitgui-expand/backup/$remoteName';
      throw GitException(
        '清空远端后验证失败，远端未达到预期的单个空提交状态。'
        '原始引用已备份到 $backupRoot，软件不会自动再次修改远端。',
        commandOutput: remaining.entries
            .map((entry) => '${entry.key} ${entry.value}')
            .join('\n'),
      );
    }
    final localBackupRef =
        'refs/gitgui-expand/backup/local/$remoteName/heads/'
        '${inspected.targetBranch}';
    await _run(['update-ref', localBackupRef, localHeadBefore.stdout.trim()]);
    await _run(['reset', '--mixed', emptyCommit]);
    final localHeadAfter = await _run(['rev-parse', '--verify', 'HEAD']);
    if (localHeadAfter.stdout.trim() != emptyCommit) {
      throw const GitException('本地分支未能同步到新的空提交。');
    }
    final localIndex = await _run(['ls-files', '--cached']);
    if (localIndex.stdout.trim().isNotEmpty) {
      throw const GitException('本地索引未能重置为空；工作区文件仍然保留。');
    }
    final fetchResult = await _run([
      'fetch',
      '--prune',
      remoteName,
    ], allowFailure: true);
    if (!fetchResult.success) {
      _log.warning(
        'remote-clear',
        '远端已清空，但更新本地 remote-tracking 引用失败：'
            '${fetchResult.output.trim()}',
      );
    }
    _log.warning(
      'remote-clear',
      '远端 $remoteName 历史已替换为空提交 $emptyCommit，'
          '本地 ${inspected.targetBranch} 已同步，原提交备份到 $localBackupRef',
    );
    return RemoteClearResult(
      remoteName: remoteName,
      deletedRefs: inspected.refs,
      backupRefspecs: inspected.backupRefspecs,
      emptyCommitHash: emptyCommit,
      targetBranch: inspected.targetBranch,
      commitMessage: inspected.emptyCommitMessage,
    );
  }

  Future<Map<String, String>> _readRemoteRefHashes(String remoteName) async {
    final refsResult = await _run(['ls-remote', '--refs', remoteName]);
    final refs = <String, String>{};
    for (final line in const LineSplitter().convert(refsResult.stdout)) {
      final separator = line.indexOf('\t');
      if (separator < 0) continue;
      final hash = line.substring(0, separator).trim();
      final ref = line.substring(separator + 1).trim();
      if (ref.startsWith('refs/heads/') || ref.startsWith('refs/tags/')) {
        refs[ref] = hash;
      }
    }
    return refs;
  }

  bool _remoteRefMapsEqual(
    Map<String, String> expected,
    Map<String, String> actual,
  ) {
    if (expected.length != actual.length) return false;
    for (final entry in expected.entries) {
      if (actual[entry.key] != entry.value) return false;
    }
    return true;
  }

  String _remoteRefDiff({
    required Map<String, String> expected,
    required Map<String, String> actual,
  }) {
    final lines = <String>[];
    for (final ref in expected.keys.toSet().union(actual.keys.toSet())) {
      final before = expected[ref];
      final after = actual[ref];
      if (before == after) continue;
      if (before == null) {
        lines.add('added $ref $after');
      } else if (after == null) {
        lines.add('removed $ref $before');
      } else {
        lines.add('changed $ref $before -> $after');
      }
    }
    lines.sort();
    return lines.join('\n');
  }

  Future<String> _remoteHeadBranch(String remoteName) async {
    final headResult = await _run([
      'ls-remote',
      '--symref',
      remoteName,
      'HEAD',
    ], allowFailure: true);
    if (headResult.success) {
      for (final line in const LineSplitter().convert(headResult.stdout)) {
        final parts = line.split('\t');
        if (parts.length == 2 &&
            parts[1] == 'HEAD' &&
            parts[0].startsWith('ref: refs/heads/')) {
          final branch = parts[0].substring('ref: refs/heads/'.length).trim();
          if (branch.isNotEmpty) return branch;
        }
      }
    }
    final current = (await currentBranch()).trim();
    if (current.isEmpty ||
        current == '尚未提交' ||
        current.startsWith('detached@')) {
      throw const GitException('无法确定要保留的远端分支名称。');
    }
    return current;
  }

  Future<String> _remoteProjectName(String remoteName) async {
    final urlResult = await _run([
      'remote',
      'get-url',
      '--push',
      remoteName,
    ], allowFailure: true);
    final slug = GitRemote.repositorySlug(urlResult.stdout.trim());
    return slug ?? repositoryBasename(rootPath);
  }

  String _buildEmptyCommitMessage({
    required String projectName,
    required String targetBranch,
  }) {
    return GitRemote.emptyHistoryCommitMessage(
      timestamp: DateTime.now(),
      projectSlug: projectName,
      branch: targetBranch,
    );
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

  Future<void> deletePaths(List<String> paths) async {
    final safePaths = _minimalSelection(_validateRepositoryPaths(paths));
    if (safePaths.isEmpty) {
      throw const GitException('没有选择要删除的项目。');
    }
    _log.info('delete', '删除 ${safePaths.length} 项：${safePaths.join(' | ')}');
    for (final path in safePaths) {
      final type = await FileSystemEntity.type(
        absoluteRepositoryPath(rootPath, path),
        followLinks: false,
      );
      if (type == FileSystemEntityType.notFound) {
        throw GitException('要删除的项目不存在：$path');
      }
    }

    for (final path in safePaths) {
      if (await _isTracked(path)) {
        await _run(['rm', '-r', '-f', '--', path]);
      }
      if (await FileSystemEntity.type(
            absoluteRepositoryPath(rootPath, path),
            followLinks: false,
          ) !=
          FileSystemEntityType.notFound) {
        await _run(['clean', '-f', '-d', '-x', '--', path]);
      }
    }

    for (final path in safePaths) {
      if (await FileSystemEntity.type(
            absoluteRepositoryPath(rootPath, path),
            followLinks: false,
          ) !=
          FileSystemEntityType.notFound) {
        throw GitException('部分内容未能删除，可能被占用或受 Git 保护：$path');
      }
    }
    _log.info('delete', '删除完成：${safePaths.length} 项');
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

  Future<bool> _isTracked(String path) async {
    final result = await _run([
      'ls-files',
      '--error-unmatch',
      '--',
      path,
    ], allowFailure: true);
    return result.success;
  }

  List<String> _minimalSelection(List<String> paths) {
    final sorted = paths.toSet().toList(growable: false)
      ..sort((left, right) => left.length.compareTo(right.length));
    final result = <String>[];
    for (final path in sorted) {
      final covered = result.any(
        (selected) =>
            selected == path || isSameOrDescendantPath(path, selected),
      );
      if (!covered) {
        result.add(path);
      }
    }
    return result;
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

  void _validateRemoteName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.startsWith('-') ||
        RegExp(r'[\s~^:?*\[\]\\]').hasMatch(trimmed)) {
      throw const GitException('远端名称不能为空、不能以 - 开头或包含空格及 Git 保留字符。');
    }
  }

  void _validateRemoteUrl(String url) {
    final trimmed = url.trim();
    final uri = Uri.tryParse(trimmed);
    final scpStyle = RegExp(r'^[A-Za-z0-9._-]+@[A-Za-z0-9.-]+:.+')
        .hasMatch(trimmed);
    final allowedScheme =
        uri != null && const {'https', 'ssh', 'git'}.contains(uri.scheme);
    if (!scpStyle && !allowedScheme) {
      throw const GitException('远端 URL 仅支持 HTTPS、SSH 或 git@host:path 格式。');
    }
  }

  static String _normalizeAbsolutePath(String path) {
    var normalized = toPosixPath(path);
    while (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return Platform.isWindows ? normalized.replaceAll('/', '\\') : normalized;
  }

  static String _fileSystemEntityTypeName(FileSystemEntityType type) {
    if (type == FileSystemEntityType.file) return 'file';
    if (type == FileSystemEntityType.directory) return 'directory';
    if (type == FileSystemEntityType.link) return 'link';
    if (type == FileSystemEntityType.notFound) return 'notFound';
    return 'unknown';
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
