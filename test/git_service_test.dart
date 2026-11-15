import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/models/git_remote.dart';
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

    final result = await service.clearRemote('origin', preview: preview);
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
  });

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
      throwsA(isA<GitException>()),
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
