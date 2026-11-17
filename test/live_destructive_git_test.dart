import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  test('destructive live test of all Git GUI Expand Git workflows', () async {
    if (Platform.environment['GIT_GUI_DESTRUCTIVE_TEST'] != '1') {
      return;
    }
    final repositoryPath =
        Platform.environment['GIT_GUI_TEST_REPOSITORY']?.trim() ?? '';
    if (repositoryPath.isEmpty) {
      fail('GIT_GUI_TEST_REPOSITORY is required');
    }
    final appData = await Directory.systemTemp.createTemp(
      'git_gui_destructive_data_',
    );
    final storage = AppStorageService(softwareDirectoryOverride: appData.path);
    final logger = AppLogService(storage: storage);
    final controller = RepositoryController(
      settingsService: SettingsService(storage: storage, logService: logger),
      logService: logger,
      recentRepositoriesService: RecentRepositoriesService(
        storage: storage,
        logService: logger,
      ),
    );
    try {
      await controller.initialize();
      final opened = await controller.openRepository(repositoryPath);
      expect(opened.isSuccess, isTrue, reason: opened.message);
      final service = GitService(repositoryPath, logService: logger);

      expect(await service.currentBranch(), 'main');
      expect(controller.remotes.map((item) => item.name), contains('origin'));
      expect((await service.repositoryStats()).fileCount, greaterThan(0));

      await service.copyPaths(['README.md'], 'docs');
      await service.movePaths(['docs/README.md'], 'src');
      await service.renamePath('src/README.md', 'README-copy.md');
      await File(
        '$repositoryPath${Platform.pathSeparator}docs'
        '${Platform.pathSeparator}full-function-data.txt',
      ).writeAsString('full-function test data', flush: true);
      await service.stageAll();
      await service.commit('test: verify file operations and commit');

      await controller.createBranch('test/force-delete');
      await _execute(controller);
      await controller.switchBranch('test/force-delete');
      await _execute(controller);
      await File(
        '$repositoryPath${Platform.pathSeparator}src'
        '${Platform.pathSeparator}branch-only.txt',
      ).writeAsString('branch only', flush: true);
      await service.stageAll();
      await service.commit('test: branch-only commit');
      await controller.switchBranch('main');
      await _execute(controller);

      await controller.deleteBranch('test/force-delete');
      final safeDelete = await controller.executePendingOperations(
        confirmedDangerous: true,
      );
      expect(safeDelete.isSuccess, isFalse);
      controller.clearPendingOperations();
      await controller.deleteBranch('test/force-delete', force: true);
      await _execute(controller, dangerous: true);
      expect(
        await controller.localBranches(),
        isNot(contains('test/force-delete')),
      );

      await File('$repositoryPath${Platform.pathSeparator}README.md')
          .writeAsString('\nstash-delete-test\n', mode: FileMode.append);
      final stashUntracked = File(
        '$repositoryPath${Platform.pathSeparator}stash-delete-test.txt',
      );
      await stashUntracked.writeAsString('untracked for stash', flush: true);
      await controller.createStash(
        message: 'destructive live stash',
        includeUntracked: true,
      );
      await _execute(controller);
      final stashes = await controller.listStashes();
      expect(stashes, hasLength(1));
      await controller.dropStash(stashes.first.selector);
      await _execute(controller, dangerous: true);
      expect(await controller.listStashes(), isEmpty);

      await _git(repositoryPath, ['branch', 'remote-extra']);
      await _git(repositoryPath, ['push', 'origin', 'remote-extra']);
      await _git(repositoryPath, ['tag', 'v-full-test']);
      await _git(repositoryPath, ['push', 'origin', 'v-full-test']);

      await controller.pushCurrentBranch();
      await _execute(controller);

      await service.addRemote(
        'backup',
        'https://example.com/git-gui-expand-backup.git',
      );
      await service.setRemoteUrl(
        'backup',
        'https://example.com/git-gui-expand-backup-updated.git',
      );
      expect(
        (await service.remotes()).map((remote) => remote.name),
        containsAll(['origin', 'backup']),
      );
      await service.removeRemote('backup');

      final inspection = await controller.inspectRemoteForClear('origin');
      expect(inspection.isSuccess, isTrue, reason: inspection.message);
      expect(inspection.preview, isNotNull);
      final preview = inspection.preview!;
      expect(preview.branchCount, greaterThanOrEqualTo(2));
      expect(preview.tagCount, greaterThanOrEqualTo(1));
      await controller.queueClearRemote(preview);
      final wrongConfirmation = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: 'wrong confirmation',
      );
      expect(wrongConfirmation.isSuccess, isFalse);
      final cleared = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: preview.confirmationText,
      );
      expect(cleared.isSuccess, isTrue, reason: cleared.message);

      final remoteRefs = await _gitOutput(repositoryPath, [
        'ls-remote',
        '--refs',
        'origin',
      ]);
      expect(remoteRefs, contains('refs/heads/main'));
      expect(remoteRefs, isNot(contains('refs/heads/remote-extra')));
      expect(remoteRefs, isNot(contains('refs/tags/v-full-test')));

      final guarded = await controller.clearGitMetadata();
      expect(guarded.isSuccess, isFalse);
      expect(
        await Directory('$repositoryPath${Platform.pathSeparator}.git')
            .exists(),
        isTrue,
      );

      await controller.removeRemote('origin');
      await _execute(controller);
      final finalInspection = await controller.inspectGitMetadataForClear();
      expect(finalInspection.remotes, isEmpty);
      final metadataCleared = await controller.clearGitMetadata();
      expect(metadataCleared.isSuccess, isTrue);
      expect(
        await Directory('$repositoryPath${Platform.pathSeparator}.git')
            .exists(),
        isFalse,
      );
      expect(
        await File('$repositoryPath${Platform.pathSeparator}README.md')
            .exists(),
        isTrue,
      );
    } finally {
      controller.dispose();
      await logger.flush();
      if (await appData.exists()) {
        await appData.delete(recursive: true);
      }
    }
  }, timeout: const Timeout(Duration(minutes: 4)));
}

Future<void> _execute(
  RepositoryController controller, {
  bool dangerous = false,
}) async {
  final result = await controller.executePendingOperations(
    confirmedDangerous: dangerous,
  );
  expect(result.isSuccess, isTrue, reason: result.message);
}

Future<void> _git(String repository, List<String> arguments) async {
  final result = await Process.run('git', [
    '-c',
    'safe.directory=$repository',
    '-C',
    repository,
    ...arguments,
  ], runInShell: false);
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
}

Future<String> _gitOutput(String repository, List<String> arguments) async {
  final result = await Process.run('git', [
    '-c',
    'safe.directory=$repository',
    '-C',
    repository,
    ...arguments,
  ], runInShell: false);
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
  return result.stdout as String? ?? '';
}
