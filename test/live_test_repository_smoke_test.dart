import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/git_service.dart';

void main() {
  test('live test repository exercises core Git services', () async {
    final source = Platform.environment['GIT_GUI_LIVE_TEST_REPOSITORY'];
    if (source == null || source.trim().isEmpty) {
      return;
    }
    final temp = await Directory.systemTemp.createTemp('git_gui_live_smoke_');
    final destination = Directory('${temp.path}${Platform.pathSeparator}clone');
    try {
      await GitService.cloneRepository(source, destination.path);
      final service = GitService(destination.path);
      await _git(destination, ['config', 'user.name', 'Live Smoke Test']);
      await _git(destination, [
        'config',
        'user.email',
        'live-smoke@example.invalid',
      ]);
      expect(
        (await service.remotes()).map((remote) => remote.name),
        contains('origin'),
      );
      await _git(destination, ['remote', 'remove', 'origin']);

      expect(await service.currentBranch(), 'main');
      expect(
        (await service.listDirectory('')).map((item) => item.name),
        containsAll(['README.md', 'docs', 'src']),
      );
      expect((await service.repositoryStats()).fileCount, greaterThan(0));

      await service.addRemote(
        'backup',
        'https://example.com/git-gui-expand-test.git',
      );
      expect(
        (await service.remotes()).map((remote) => remote.name),
        contains('backup'),
      );
      await service.removeRemote('backup');

      await service.copyPaths(['README.md'], 'docs');
      await service.movePaths(['docs/README.md'], 'src');
      await service.renamePath('src/README.md', 'README-copy.md');
      await service.stageAll();
      await service.commit('test: live Git service smoke');

      await service.createBranch('smoke/test');
      await service.switchBranch('smoke/test');
      await service.renameBranch('smoke/test', 'smoke/renamed');
      await service.switchBranch('main');
      await service.deleteBranch('smoke/renamed');
      expect(await service.localBranches(), isNot(contains('smoke/renamed')));

      await File(
        '${destination.path}${Platform.pathSeparator}src'
        '${Platform.pathSeparator}sample.txt',
      ).writeAsString('changed for stash', flush: true);
      final untracked = File(
        '${destination.path}${Platform.pathSeparator}'
        'stash-untracked.txt',
      );
      await untracked.writeAsString('untracked', flush: true);
      await service.createStash(message: 'live stash', includeUntracked: true);
      final stashes = await service.listStashes();
      expect(stashes, hasLength(1));
      await service.popStash(stashes.first.selector);
      expect(await untracked.exists(), isTrue);

      await GitService.clearRepositoryMetadata(destination.path);
      expect(
        await Directory('${destination.path}${Platform.pathSeparator}.git')
            .exists(),
        isFalse,
      );
      expect(
        await File('${destination.path}${Platform.pathSeparator}README.md')
            .exists(),
        isTrue,
      );
    } finally {
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

Future<void> _git(Directory repository, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: repository.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
}
