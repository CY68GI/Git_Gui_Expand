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
    await _git(repository, ['init']);
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
