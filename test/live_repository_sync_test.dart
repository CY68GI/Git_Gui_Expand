import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/app_models.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  test('live isolated fetch and fast-forward pull workflows', () async {
    if (Platform.environment['GIT_GUI_LIVE_SYNC_TEST'] != '1') {
      return;
    }
    final root = await Directory.systemTemp.createTemp(
      'git_gui_live_sync_',
    );
    final remote = Directory('${root.path}${Platform.pathSeparator}remote.git');
    final publisher = Directory(
      '${root.path}${Platform.pathSeparator}publisher',
    );
    final local = Directory('${root.path}${Platform.pathSeparator}local');
    final data = Directory('${root.path}${Platform.pathSeparator}data');
    RepositoryController? controller;
    AppLogService? logger;
    try {
      await remote.create();
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await publisher.create();
      await _git(publisher, ['init', '-b', 'main']);
      await _configureIdentity(publisher);
      await File(
        '${publisher.path}${Platform.pathSeparator}README.md',
      ).writeAsString('initial');
      await _git(publisher, ['add', '-A']);
      await _git(publisher, ['commit', '-m', 'initial']);
      await _git(publisher, ['remote', 'add', 'origin', remote.path]);
      await _git(publisher, ['push', '-u', 'origin', 'main']);

      await data.create();
      await _git(root, ['clone', remote.path, local.path]);
      await _configureIdentity(local);
      final storage = AppStorageService(softwareDirectoryOverride: data.path);
      logger = AppLogService(storage: storage);
      controller = RepositoryController(
        settingsService: SettingsService(storage: storage, logService: logger),
        logService: logger,
        recentRepositoriesService: RecentRepositoriesService(
          storage: storage,
          logService: logger,
        ),
      );
      await controller.initialize();
      expect((await controller.openRepository(local.path)).isSuccess, isTrue);

      await File(
        '${publisher.path}${Platform.pathSeparator}update.txt',
      ).writeAsString('remote update');
      await _git(publisher, ['add', '-A']);
      await _git(publisher, ['commit', '-m', 'remote update']);
      await _git(publisher, ['push', 'origin', 'main']);
      expect((await controller.fetchCurrentUpstream()).isSuccess, isTrue);
      expect(
        (
          await controller.executePendingOperations(
            confirmedDangerous: true,
          )
        ).isSuccess,
        isTrue,
      );
      expect(
        controller.syncState?.canPull,
        isTrue,
        reason: controller.syncState?.relation.name,
      );
      expect((await controller.pullCurrentBranchFastForward()).isSuccess, isTrue);
      final pulled = await controller.executePendingOperations(
        confirmedDangerous: true,
      );
      expect(pulled.isSuccess, isTrue, reason: pulled.message);
      expect(
        await File(
          '${local.path}${Platform.pathSeparator}update.txt',
        ).readAsString(),
        'remote update',
      );

      await File(
        '${publisher.path}${Platform.pathSeparator}second.txt',
      ).writeAsString('second');
      await _git(publisher, ['add', '-A']);
      await _git(publisher, ['commit', '-m', 'second']);
      await _git(publisher, ['push', 'origin', 'main']);
      await GitService(local.path).fetchRemote('origin');
      await File(
        '${local.path}${Platform.pathSeparator}README.md',
      ).writeAsString('dirty');
      await expectLater(
        GitService(local.path).pullFastForward(),
        throwsA(isA<GitException>()),
      );
      await logger.flush();
      final detailed = await logger.readRecent(AppLogType.detailed);
      expect(detailed, contains('command=git fetch --prune origin'));
    } finally {
      controller?.dispose();
      await logger?.flush();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (await data.exists()) {
        await data.delete(recursive: true);
      }
      if (await root.exists()) await root.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}

Future<void> _configureIdentity(Directory repository) async {
  await _git(repository, ['config', 'user.name', 'Live Sync Test']);
  await _git(repository, ['config', 'user.email', 'sync@example.invalid']);
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
      'git ${arguments.join(' ')} failed:\n'
      '${result.stdout}\n${result.stderr}',
    );
  }
}
