import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_service.dart';

void main() {
  late Directory repository;
  late GitService service;

  setUp(() async {
    repository = await Directory.systemTemp.createTemp('git_gui_expand_test_');
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', 'Git GUI Expand Test']);
    await _git(repository, ['config', 'user.email', 'test@example.invalid']);
    await Directory('${repository.path}${Platform.pathSeparator}docs').create();
    await Directory('${repository.path}${Platform.pathSeparator}src').create();
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('alpha');
    await File(
      '${repository.path}${Platform.pathSeparator}docs'
      '${Platform.pathSeparator}readme.md',
    ).writeAsString('# Test');
    await File(
      '${repository.path}${Platform.pathSeparator}src'
      '${Platform.pathSeparator}main.dart',
    ).writeAsString('void main() {}');
    await File('${repository.path}${Platform.pathSeparator}.gitignore')
        .writeAsString('build/\n');
    await _git(repository, ['add', '-A']);
    await _git(repository, ['commit', '-m', 'initial']);
    service = GitService(repository.path);
  });

  tearDown(() async {
    if (await repository.exists()) {
      await repository.delete(recursive: true);
    }
  });

  test('lists tracked directories and files with status', () async {
    final entries = await service.listDirectory('');

    expect(entries.map((entry) => entry.name), containsAll(['docs', 'src']));
    expect(
      entries.singleWhere((entry) => entry.name == 'alpha.txt').kind,
      EntryKind.file,
    );
    expect((await service.status()), isEmpty);
  });

  test(
    'captures normalized repository state and selected path types',
    () async {
      final first = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );
      final repeated = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );

      expect(first, repeated);
      expect(first.rootPath, contains('git_gui_expand_test_'));
      expect(first.branch, 'main');
      expect(first.head, isNot('UNBORN'));
      expect(first.pathTypes['alpha.txt'], 'file');

      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .writeAsString('changed');
      final changedStatus = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );
      expect(changedStatus.statusFingerprint, isNot(first.statusFingerprint));

      await _git(repository, ['switch', '-c', 'snapshot-branch']);
      final changedBranch = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );
      expect(changedBranch.branch, isNot(first.branch));

      await service.addRemote('snapshot', 'https://example.com/repo.git');
      final changedRemote = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );
      expect(
        changedRemote.remoteUrls,
        containsPair('snapshot', 'https://example.com/repo.git'),
      );

      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .delete();
      final changedPath = await service.stateSnapshot(
        selectedPaths: const ['alpha.txt'],
      );
      expect(changedPath.pathTypes['alpha.txt'], 'notFound');
    },
  );

  test(
    'reports upstream ahead behind detached and unborn sync states',
    () async {
      final noUpstream = await service.syncState();
      expect(noUpstream.kind, BranchSyncKind.noUpstream);
      expect(noUpstream.branch, 'main');
      expect(noUpstream.worktreeClean, isTrue);

      final untracked = File(
        '${repository.path}${Platform.pathSeparator}sync-untracked.txt',
      );
      await untracked.writeAsString('dirty');
      expect((await service.syncState()).worktreeClean, isFalse);
      await untracked.delete();

      final remote = await Directory.systemTemp.createTemp(
        'git_gui_sync_remote_',
      );
      final second = await Directory.systemTemp.createTemp(
        'git_gui_sync_second_',
      );
      addTearDown(() async {
        if (await remote.exists()) await remote.delete(recursive: true);
        if (await second.exists()) await second.delete(recursive: true);
      });
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);
      await service.pushCurrentBranch();

      final current = await service.syncState();
      expect(current.kind, BranchSyncKind.tracked);
      expect(current.upstreamRef, 'origin/main');
      expect(current.relation, BranchSyncRelation.upToDate);

      await _git(repository, ['commit', '--allow-empty', '-m', 'local ahead']);
      expect((await service.syncState()).relation, BranchSyncRelation.ahead);
      await _git(repository, ['reset', '--hard', 'origin/main']);

      await _git(second, ['clone', remote.path, second.path]);
      await _git(second, ['config', 'user.name', 'Sync Test']);
      await _git(second, ['config', 'user.email', 'sync@example.invalid']);
      await _git(second, ['commit', '--allow-empty', '-m', 'remote ahead']);
      await _git(second, ['push', 'origin', 'main']);
      await _git(repository, ['fetch', 'origin']);
      expect((await service.syncState()).relation, BranchSyncRelation.behind);

      await _git(repository, ['commit', '--allow-empty', '-m', 'diverged']);
      expect((await service.syncState()).relation, BranchSyncRelation.diverged);

      await _git(repository, ['switch', '--detach']);
      expect((await service.syncState()).kind, BranchSyncKind.detachedHead);

      final unborn = await Directory.systemTemp.createTemp(
        'git_gui_sync_unborn_',
      );
      addTearDown(() async {
        if (await unborn.exists()) await unborn.delete(recursive: true);
      });
      await _git(unborn, ['init', '-b', 'main']);
      expect(
        (await GitService(unborn.path).syncState()).kind,
        BranchSyncKind.unborn,
      );
    },
  );

  test('renames, moves and copies files through Git', () async {
    await service.renamePath('docs/readme.md', 'guide.md');
    expect(
      await File(
        '${repository.path}${Platform.pathSeparator}docs'
        '${Platform.pathSeparator}guide.md',
      ).exists(),
      isTrue,
    );
    final renameStatus = (await service.status()).singleWhere(
      (status) => status.path == 'docs/guide.md',
    );
    expect(renameStatus.originalPath, 'docs/readme.md');

    await service.movePaths(['alpha.txt'], 'src');
    expect(
      await File(
        '${repository.path}${Platform.pathSeparator}src'
        '${Platform.pathSeparator}alpha.txt',
      ).exists(),
      isTrue,
    );

    await service.copyPaths(['src'], 'docs');
    final copied = File(
      '${repository.path}${Platform.pathSeparator}docs'
      '${Platform.pathSeparator}src${Platform.pathSeparator}main.dart',
    );
    expect(await copied.exists(), isTrue);
    expect(await copied.readAsString(), 'void main() {}');

    final statuses = await service.status();
    expect(statuses.any((status) => status.indexCode == 'A'), isTrue);
  });

  test('stages and commits all changes', () async {
    final extra = File(
      '${repository.path}${Platform.pathSeparator}src'
      '${Platform.pathSeparator}extra.dart',
    );
    await extra.writeAsString('// extra');

    await service.stageAll();
    expect((await service.status()).isNotEmpty, isTrue);
    await service.commit('Add extra file');

    expect(await service.status(), isEmpty);
    expect(await service.currentBranch(), isNot('尚未提交'));
  });

  test('creates, switches, renames and deletes local branches', () async {
    expect(await service.localBranches(), contains('main'));

    await service.createBranch('feature/test');
    expect(await service.localBranches(), contains('feature/test'));

    await service.switchBranch('feature/test');
    expect(await service.currentBranch(), 'feature/test');

    await service.renameBranch('feature/test', 'feature/renamed');
    expect(await service.currentBranch(), 'feature/renamed');

    await service.switchBranch('main');
    await service.deleteBranch('feature/renamed');
    expect(await service.localBranches(), isNot(contains('feature/renamed')));
  });

  test('initializes and clones repositories', () async {
    final parent = await Directory.systemTemp.createTemp('git_gui_clone_test_');
    addTearDown(() async {
      if (await parent.exists()) await parent.delete(recursive: true);
    });
    final empty = Directory('${parent.path}${Platform.pathSeparator}empty');
    await empty.create();
    await GitService.initializeRepository(empty.path);
    expect(
      await GitService.resolveRepositoryRoot(empty.path),
      endsWith('empty'),
    );

    final destination = Directory(
      '${parent.path}${Platform.pathSeparator}cloned',
    );
    await GitService.cloneRepository(repository.path, destination.path);
    expect(await destination.exists(), isTrue);
    expect(
      await GitService.resolveRepositoryRoot(destination.path),
      await destination.resolveSymbolicLinks(),
    );
  });

  test('clears Git metadata only when no remote is configured', () async {
    final original = File(
      '${repository.path}${Platform.pathSeparator}alpha.txt',
    );
    await GitService.clearRepositoryMetadata(repository.path);
    expect(
      await Directory('${repository.path}${Platform.pathSeparator}.git')
          .exists(),
      isFalse,
    );
    expect(await original.readAsString(), 'alpha');

    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['remote', 'add', 'origin', repository.path]);
    await expectLater(
      GitService.clearRepositoryMetadata(repository.path),
      throwsA(isA<GitException>()),
    );
    expect(
      await Directory('${repository.path}${Platform.pathSeparator}.git')
          .exists(),
      isTrue,
    );
  });

  test('creates, applies and drops git stashes', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('changed');
    final untracked = File(
      '${repository.path}${Platform.pathSeparator}stash-untracked.txt',
    );
    await untracked.writeAsString('untracked');

    await service.createStash(message: 'work in progress');
    final stashes = await service.listStashes();
    expect(stashes, hasLength(1));
    expect(stashes.first.message, contains('work in progress'));
    expect(await untracked.exists(), isFalse);

    await service.popStash(stashes.first.selector);
    expect(await untracked.readAsString(), 'untracked');
    expect(await service.listStashes(), isEmpty);

    await service.createStash(message: 'drop me');
    final second = (await service.listStashes()).first;
    await service.dropStash(second.selector);
    expect(await service.listStashes(), isEmpty);
  });

  test('stages and unstages modified files', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('alpha changed');
    await service.stageAll();
    expect((await service.status()).any((status) => status.isStaged), isTrue);

    await service.unstageAll();
    final statuses = await service.status();
    expect(statuses.any((status) => status.isStaged), isFalse);
    expect(statuses.any((status) => status.path == 'alpha.txt'), isTrue);
  });

  test('deletes tracked and untracked items through Git', () async {
    final untracked = File(
      '${repository.path}${Platform.pathSeparator}scratch.tmp',
    );
    await untracked.writeAsString('temporary');

    await service.deletePaths(['alpha.txt', 'scratch.tmp']);

    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .exists(),
      isFalse,
    );
    expect(await untracked.exists(), isFalse);
    final statuses = await service.status();
    expect(
      statuses.any(
        (status) => status.path == 'alpha.txt' && status.indexCode == 'D',
      ),
      isTrue,
    );
  });

  test('pushes the current branch to a configured remote', () async {
    final remote = await Directory.systemTemp.createTemp(
      'git_gui_bare_remote_',
    );
    addTearDown(() async {
      if (await remote.exists()) {
        await remote.delete(recursive: true);
      }
    });
    await _git(remote, ['init', '--bare']);
    await _git(repository, ['remote', 'add', 'origin', remote.path]);
    final branch = await service.currentBranch();

    await service.pushCurrentBranch();

    final ref = await Process.run(
      'git',
      ['show-ref', '--verify', 'refs/heads/$branch'],
      workingDirectory: remote.path,
      runInShell: false,
    );
    expect(ref.exitCode, 0);
  });

  test('manages remotes from multiple platforms', () async {
    expect(
      GitRemote.maskRemoteUrl('https://user:secret@github.com/CY68GI/repo.git'),
      isNot(contains('secret')),
    );
    expect(
      GitRemote.repositorySlug('git@github.com:CY68GI/Git_Gui_Expand.git'),
      'CY68GI/Git_Gui_Expand',
    );
    expect(
      GitRemote.repositorySlug(
        'https://gitee.com/CY68EWZRY/Git_Gui_Expand.git',
      ),
      'CY68EWZRY/Git_Gui_Expand',
    );
    expect(
      GitRemote.emptyHistoryCommitMessage(
        timestamp: DateTime(2026, 11, 16, 1, 2, 3),
        projectSlug: 'CY68GI/Self_learning_to_code',
        branch: 'main',
      ),
      '2026-11-16 01:02:03 仓库已清除，这是第一次空提交'
      '(CY68GI/Self_learning_to_code/main)，来自软件Git GUI Expand的功能',
    );
    await service.addRemote(
      'gitee',
      'git@gitee.com:CY68EWZRY/Git_Gui_Expand.git',
    );
    await service.addRemote(
      'gitlab',
      'https://gitlab.com/example/Git_Gui_Expand.git',
    );

    var remotes = await service.remotes();
    expect(
      remotes.singleWhere((remote) => remote.name == 'gitee').platform,
      GitRemotePlatform.gitee,
    );
    expect(
      remotes.singleWhere((remote) => remote.name == 'gitlab').platform,
      GitRemotePlatform.gitlab,
    );

    await service.setRemoteUrl(
      'gitee',
      'https://gitee.com/CY68EWZRY/Git_Gui_Expand.git',
    );
    remotes = await service.remotes();
    expect(
      remotes.singleWhere((remote) => remote.name == 'gitee').pushUrl,
      'https://gitee.com/CY68EWZRY/Git_Gui_Expand.git',
    );

    await service.removeRemote('gitlab');
    remotes = await service.remotes();
    expect(remotes.map((remote) => remote.name), isNot(contains('gitlab')));
  });

  test('backs up and atomically clears all remote branches and tags', () async {
    final remote = await Directory.systemTemp.createTemp(
      'git_gui_clear_remote_success_',
    );
    addTearDown(() async {
      if (await remote.exists()) {
        await remote.delete(recursive: true);
      }
    });
    await _git(remote, ['init', '--bare']);
    await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
    await _git(remote, ['config', 'receive.denyDeleteCurrent', 'ignore']);
    await _git(remote, ['config', 'receive.denyNonFastForwards', 'false']);
    await _git(repository, ['remote', 'add', 'origin', remote.path]);
    await _git(repository, ['branch', 'second']);
    await _git(repository, ['tag', 'v1']);
    final branch = await service.currentBranch();
    await _git(repository, [
      'push',
      'origin',
      'refs/heads/$branch',
      'refs/heads/second',
      'refs/tags/v1',
    ]);

    final preview = await service.previewClearRemote('origin');
    expect(preview.branchCount, 2);
    expect(preview.tagCount, 1);
    expect(preview.targetBranch, branch);
    expect(
      preview.confirmationText,
      '${repository.path.split(Platform.pathSeparator).last}/$branch',
    );
    expect(preview.emptyCommitMessage, contains('仓库已清除，这是第一次空提交'));
    expect(preview.emptyCommitMessage, contains('来自软件Git GUI Expand的功能'));
    expect(preview.refs, containsAll(['refs/heads/$branch', 'refs/tags/v1']));
    expect(preview.refHashes, contains('refs/heads/$branch'));
    expect(preview.refHashes, contains('refs/tags/v1'));

    final logRoot = await Directory.systemTemp.createTemp(
      'git_gui_remote_clear_logs_',
    );
    addTearDown(() async {
      if (await logRoot.exists()) await logRoot.delete(recursive: true);
    });
    final logger = AppLogService(
      storage: AppStorageService(softwareDirectoryOverride: logRoot.path),
    );
    final loggedService = GitService(repository.path, logService: logger);
    final result = await loggedService.clearRemote('origin', preview: preview);
    await logger.flush();
    final detailedLog = await logger.readRecent(AppLogType.detailed);
    expect(detailedLog, contains('--atomic'));
    expect(detailedLog, contains('--force-with-lease=refs/heads/$branch:'));
    expect(detailedLog, contains('--force-with-lease=refs/heads/second:'));
    expect(detailedLog, contains('--force-with-lease=refs/tags/v1:'));
    expect(result.deletedRefs.length, 3);
    expect(result.targetBranch, branch);
    expect(result.emptyCommitHash, isNotEmpty);
    final remaining = await service.previewClearRemote('origin');
    expect(remaining.refs, ['refs/heads/$branch']);
    final remoteHead = await Process.run('git', [
      '--git-dir=${remote.path}',
      'rev-parse',
      'refs/heads/$branch',
    ], runInShell: false);
    expect((remoteHead.stdout as String).trim(), result.emptyCommitHash);
    final commitObject = await Process.run(
      'git',
      ['cat-file', '-p', result.emptyCommitHash],
      workingDirectory: repository.path,
      runInShell: false,
      stdoutEncoding: utf8,
    );
    expect(commitObject.stdout, contains('仓库已清除，这是第一次空提交'));
    expect(commitObject.stdout, contains('来自软件Git GUI Expand的功能'));
    expect(commitObject.stdout, isNot(contains('parent ')));
    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .readAsString(),
      'alpha',
    );
    final localHead = await Process.run(
      'git',
      ['rev-parse', 'HEAD'],
      workingDirectory: repository.path,
      runInShell: false,
    );
    expect((localHead.stdout as String).trim(), result.emptyCommitHash);
    final localIndex = await Process.run(
      'git',
      ['ls-files', '--cached'],
      workingDirectory: repository.path,
      runInShell: false,
    );
    expect((localIndex.stdout as String).trim(), isEmpty);
    final localStatus = await Process.run(
      'git',
      ['status', '--porcelain=v1'],
      workingDirectory: repository.path,
      runInShell: false,
    );
    expect(localStatus.stdout, contains('?? alpha.txt'));

    final backup = await Process.run(
      'git',
      [
        'for-each-ref',
        '--format=%(refname)',
        'refs/gitgui-expand/backup/origin',
      ],
      workingDirectory: repository.path,
      runInShell: false,
    );
    expect(backup.exitCode, 0);
    expect(backup.stdout, contains('refs/gitgui-expand/backup/origin'));

    final recovery = await Directory.systemTemp.createTemp(
      'git_gui_remote_clear_recovery_',
    );
    addTearDown(() async {
      if (await recovery.exists()) await recovery.delete(recursive: true);
    });
    await _git(recovery, ['init', '--bare']);
    final backupRefs = await Process.run(
      'git',
      [
        'for-each-ref',
        '--format=%(refname)',
        'refs/gitgui-expand/backup/origin/heads',
        'refs/gitgui-expand/backup/origin/tags',
      ],
      workingDirectory: repository.path,
      runInShell: false,
    );
    final refsToRestore = (backupRefs.stdout as String)
        .split(RegExp(r'[\r\n]+'))
        .where((ref) => ref.isNotEmpty)
        .map((ref) {
          final marker = ref.contains('/heads/') ? '/heads/' : '/tags/';
          final name = ref.substring(ref.indexOf(marker) + marker.length);
          final target = marker == '/heads/'
              ? 'refs/heads/$name'
              : 'refs/tags/$name';
          return '$ref:$target';
        })
        .toList(growable: false);
    await _git(repository, ['push', recovery.path, ...refsToRestore]);
    final recoveredRefs = await _gitOutput(recovery, [
      'for-each-ref',
      '--format=%(refname)',
      'refs/heads',
      'refs/tags',
    ]);
    expect(recoveredRefs, contains('refs/heads/$branch'));
    expect(recoveredRefs, contains('refs/heads/second'));
    expect(recoveredRefs, contains('refs/tags/v1'));
  });

  test(
    'rejects remote clearing when remote refs drift after preview',
    () async {
      final remote = await Directory.systemTemp.createTemp(
        'git_gui_clear_remote_drift_',
      );
      addTearDown(() async {
        if (await remote.exists()) await remote.delete(recursive: true);
      });
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(remote, ['config', 'receive.denyDeleteCurrent', 'ignore']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);
      final branch = await service.currentBranch();
      await _git(repository, ['push', '-u', 'origin', branch]);
      final preview = await service.previewClearRemote('origin');
      final originalHash = preview.refHashes['refs/heads/$branch'];

      await _git(repository, ['branch', 'remote-added-after-preview']);
      await _git(repository, ['push', 'origin', 'remote-added-after-preview']);

      await expectLater(
        service.clearRemote('origin', preview: preview),
        throwsA(
          isA<GitException>().having(
            (error) => error.message,
            'message',
            contains('远端引用在确认后发生了变化'),
          ),
        ),
      );
      final refsAfter = await _gitOutput(repository, [
        'ls-remote',
        '--refs',
        'origin',
      ]);
      expect(refsAfter, contains('refs/heads/remote-added-after-preview'));
      expect(refsAfter, contains('$originalHash\trefs/heads/$branch'));
    },
  );

  test('does not partially clear a protected remote', () async {
    final remote = await Directory.systemTemp.createTemp(
      'git_gui_clear_remote_protected_',
    );
    addTearDown(() async {
      if (await remote.exists()) {
        await remote.delete(recursive: true);
      }
    });
    await _git(remote, ['init', '--bare']);
    await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
    await _git(remote, ['config', 'receive.denyDeleteCurrent', 'refuse']);
    await _git(remote, ['config', 'receive.denyNonFastForwards', 'true']);
    await _git(repository, ['remote', 'add', 'origin', remote.path]);
    await _git(repository, ['tag', 'v1']);
    final branch = await service.currentBranch();
    await _git(repository, [
      'push',
      'origin',
      'refs/heads/$branch',
      'refs/tags/v1',
    ]);

    final preview = await service.previewClearRemote('origin');
    await expectLater(
      service.clearRemote('origin', preview: preview),
      throwsA(
        isA<GitException>().having(
          (error) => error.message,
          'message',
          contains('解除保护'),
        ),
      ),
    );
    final remaining = await service.previewClearRemote('origin');
    expect(remaining.refs, containsAll(['refs/heads/$branch', 'refs/tags/v1']));
  });

  test(
    'initializes an already empty remote with the first empty commit',
    () async {
      final remote = await Directory.systemTemp.createTemp(
        'git_gui_clear_remote_empty_',
      );
      addTearDown(() async {
        if (await remote.exists()) {
          await remote.delete(recursive: true);
        }
      });
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);

      final preview = await service.previewClearRemote('origin');
      expect(preview.refs, isEmpty);
      expect(preview.targetBranch, 'main');
      final result = await service.clearRemote('origin', preview: preview);
      final refs = await service.previewClearRemote('origin');

      expect(refs.refs, ['refs/heads/main']);
      final remoteHead = await Process.run('git', [
        '--git-dir=${remote.path}',
        'rev-parse',
        'refs/heads/main',
      ], runInShell: false);
      expect((remoteHead.stdout as String).trim(), result.emptyCommitHash);
    },
  );

  test(
    'refuses to clear when local and remote target branches differ',
    () async {
      final remote = await Directory.systemTemp.createTemp(
        'git_gui_clear_remote_branch_mismatch_',
      );
      addTearDown(() async {
        if (await remote.exists()) {
          await remote.delete(recursive: true);
        }
      });
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);
      await _git(repository, ['push', 'origin', 'main']);
      await _git(repository, ['checkout', '-b', 'feature']);

      final preview = await service.previewClearRemote('origin');
      expect(preview.targetBranch, 'main');
      await expectLater(
        service.clearRemote('origin', preview: preview),
        throwsA(
          isA<GitException>().having(
            (error) => error.message,
            'message',
            contains('请先切换到目标分支'),
          ),
        ),
      );
      final refs = await Process.run(
        'git',
        ['ls-remote', '--heads', '--refs', remote.path],
        workingDirectory: repository.path,
        runInShell: false,
      );
      expect(refs.stdout, contains('refs/heads/main'));
    },
  );
}

Future<void> _git(Directory directory, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'git ${arguments.join(' ')} failed:\n${result.stdout}\n${result.stderr}',
    );
  }
}

Future<String> _gitOutput(Directory directory, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'git ${arguments.join(' ')} failed:\n'
      '${result.stdout}\n${result.stderr}',
    );
  }
  return result.stdout as String? ?? '';
}
