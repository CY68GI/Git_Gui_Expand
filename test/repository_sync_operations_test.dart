import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  late Directory root;
  late Directory repository;
  late Directory remote;
  late AppLogService logger;
  late RepositoryController controller;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_gui_sync_ops_');
    repository = Directory('${root.path}${Platform.pathSeparator}repository');
    remote = Directory('${root.path}${Platform.pathSeparator}origin.git');
    await repository.create();
    await remote.create();
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', 'Sync Operations']);
    await _git(repository, ['config', 'user.email', 'sync@example.invalid']);
    await File('${repository.path}${Platform.pathSeparator}README.md')
        .writeAsString('# sync');
    await _git(repository, ['add', '-A']);
    await _git(repository, ['commit', '-m', 'initial']);
    await _git(remote, ['init', '--bare']);
    await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
    await _git(repository, ['remote', 'add', 'origin', remote.path]);
    await _git(repository, ['push', '-u', 'origin', 'main']);

    final storage = AppStorageService(softwareDirectoryOverride: root.path);
    logger = AppLogService(storage: storage)
      ..setLocale(AppLocalizations.english);
    controller = RepositoryController(
      settingsService: SettingsService(storage: storage, logService: logger),
      logService: logger,
      recentRepositoriesService: RecentRepositoriesService(
        storage: storage,
        logService: logger,
      ),
    );
    await controller.initialize();
    final opened = await controller.openRepository(repository.path);
    expect(opened.isSuccess, isTrue, reason: opened.message);
  });

  tearDown(() async {
    controller.dispose();
    await logger.flush();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('fetch current upstream is planned and updates tracking refs', () async {
    final publisher = await Directory.systemTemp.createTemp(
      'git_gui_sync_publisher_',
    );
    addTearDown(() async {
      if (await publisher.exists()) await publisher.delete(recursive: true);
    });
    await _git(publisher, ['clone', remote.path, publisher.path]);
    await _git(publisher, ['config', 'user.name', 'Sync Publisher']);
    await _git(publisher, [
      'config',
      'user.email',
      'publisher@example.invalid',
    ]);
    await _git(publisher, ['switch', '-c', 'remote-added']);
    await _git(publisher, ['commit', '--allow-empty', '-m', 'remote branch']);
    await _git(publisher, ['push', 'origin', 'remote-added']);
    expect(
      await _remoteTrackingRefs(repository),
      isNot(contains('remote-added')),
    );

    final queued = await controller.fetchCurrentUpstream();
    expect(queued.isSuccess, isTrue);
    expect(controller.pendingOperations, hasLength(1));
    expect(
      await _remoteTrackingRefs(repository),
      isNot(contains('remote-added')),
    );

    final executed = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(executed.isSuccess, isTrue, reason: executed.message);
    expect(await _remoteTrackingRefs(repository), contains('remote-added'));
    expect(controller.syncState?.kind, BranchSyncKind.tracked);
    await logger.flush();
    final normalLog = await logger.readRecent(AppLogType.normal);
    final detailedLog = await logger.readRecent(AppLogType.detailed);
    expect(normalLog, contains('Fetched updates from remote origin'));
    expect(detailedLog, contains('command=git fetch --prune origin'));
  });

  test('fetch all prunes deleted refs and reports partial failure', () async {
    await _git(repository, ['branch', 'remote-all']);
    await _git(repository, ['push', 'origin', 'remote-all']);
    expect((await controller.fetchCurrentUpstream()).isSuccess, isTrue);
    expect(
      (await controller.executePendingOperations(confirmedDangerous: true))
          .isSuccess,
      isTrue,
    );
    expect(await _remoteTrackingRefs(repository), contains('remote-all'));

    await _git(repository, ['push', 'origin', '--delete', 'remote-all']);
    await _git(repository, [
      'remote',
      'add',
      'broken',
      '${root.path}${Platform.pathSeparator}missing.git',
    ]);
    expect((await controller.refreshRemotes()).isSuccess, isTrue);

    final queued = await controller.fetchAllRemotes();
    expect(queued.isSuccess, isTrue);
    final executed = await controller.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(executed.isSuccess, isFalse);
    expect(executed.message, contains('成功 1 个，失败 1 个'));
    expect(
      await _remoteTrackingRefs(repository),
      isNot(contains('remote-all')),
    );
  });

  test('safe pull fast-forwards a clean behind branch', () async {
    final publisher = await _publisherClone(remote);
    await File('${publisher.path}${Platform.pathSeparator}remote-update.txt')
        .writeAsString('remote update');
    await _git(publisher, ['add', '-A']);
    await _git(publisher, ['commit', '-m', 'remote update']);
    await _git(publisher, ['push', 'origin', 'main']);

    expect((await controller.fetchCurrentUpstream()).isSuccess, isTrue);
    expect(
      (await controller.executePendingOperations(confirmedDangerous: true))
          .isSuccess,
      isTrue,
    );
    expect(controller.syncState?.relation, BranchSyncRelation.behind);
    expect(
      await File('${repository.path}${Platform.pathSeparator}remote-update.txt')
          .exists(),
      isFalse,
    );

    final queued = await controller.pullCurrentBranchFastForward();
    expect(queued.isSuccess, isTrue, reason: queued.message);
    expect(
      await File('${repository.path}${Platform.pathSeparator}remote-update.txt')
          .exists(),
      isFalse,
    );
    final pulled = await controller.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(pulled.isSuccess, isTrue, reason: pulled.message);
    expect(
      await File('${repository.path}${Platform.pathSeparator}remote-update.txt')
          .readAsString(),
      'remote update',
    );
    expect(controller.syncState?.relation, BranchSyncRelation.upToDate);
    expect(
      (await _gitOutput(repository, [
        'rev-list',
        '--merges',
        '--count',
        'HEAD',
      ])).trim(),
      '0',
    );
  });

  test('safe pull rejects up-to-date ahead and diverged branches', () async {
    expect(
      (await controller.pullCurrentBranchFastForward()).isSuccess,
      isFalse,
    );

    await _git(repository, ['commit', '--allow-empty', '-m', 'local only']);
    await controller.refresh(refreshStats: false);
    expect(controller.syncState?.relation, BranchSyncRelation.ahead);
    expect(
      (await controller.pullCurrentBranchFastForward()).isSuccess,
      isFalse,
    );
    await _git(repository, ['reset', '--hard', 'origin/main']);

    final publisher = await _publisherClone(remote);
    await _git(publisher, ['commit', '--allow-empty', '-m', 'remote only']);
    await _git(publisher, ['push', 'origin', 'main']);
    await _git(repository, ['fetch', 'origin']);
    await _git(repository, ['commit', '--allow-empty', '-m', 'local diverged']);
    await controller.refresh(refreshStats: false);

    expect(controller.syncState?.relation, BranchSyncRelation.diverged);
    expect(
      (await controller.pullCurrentBranchFastForward()).isSuccess,
      isFalse,
    );
    expect(controller.pendingOperations, isEmpty);
  });

  test(
    'safe pull rejects dirty detached and missing upstream states',
    () async {
      final dirty = File(
        '${repository.path}${Platform.pathSeparator}dirty.txt',
      );
      await dirty.writeAsString('dirty');
      await controller.refresh(refreshStats: false);
      expect(
        (await controller.pullCurrentBranchFastForward()).isSuccess,
        isFalse,
      );
      await dirty.delete();

      await _git(repository, ['branch', '--unset-upstream']);
      await controller.refresh(refreshStats: false);
      expect(
        (await controller.pullCurrentBranchFastForward()).isSuccess,
        isFalse,
      );

      await _git(repository, ['push', '-u', 'origin', 'main']);
      await _git(repository, ['switch', '--detach']);
      await controller.refresh(refreshStats: false);
      expect(controller.syncState?.isDetached, isTrue);
      expect(
        (await controller.pullCurrentBranchFastForward()).isSuccess,
        isFalse,
      );
    },
  );

  test(
    'pull reports divergence after fetch without changing the branch',
    () async {
      final publisher = await _publisherClone(remote);
      await _git(publisher, ['commit', '--allow-empty', '-m', 'behind first']);
      await _git(publisher, ['push', 'origin', 'main']);
      expect((await controller.fetchCurrentUpstream()).isSuccess, isTrue);
      expect(
        (await controller.executePendingOperations(confirmedDangerous: true))
            .isSuccess,
        isTrue,
      );
      expect(
        (await controller.pullCurrentBranchFastForward()).isSuccess,
        isTrue,
      );
      final headBefore = (await _gitOutput(repository, [
        'rev-parse',
        'HEAD',
      ])).trim();
      final fileBefore = await File(
        '${repository.path}${Platform.pathSeparator}README.md',
      ).readAsString();

      await _git(publisher, ['checkout', '--orphan', 'replacement']);
      await _git(publisher, ['rm', '-rf', '.']);
      await File('${publisher.path}${Platform.pathSeparator}replacement.txt')
          .writeAsString('replacement');
      await _git(publisher, ['add', '-A']);
      await _git(publisher, ['commit', '-m', 'replacement history']);
      await _git(publisher, ['push', '--force', 'origin', 'replacement:main']);

      final result = await controller.executePendingOperations(
        confirmedDangerous: true,
      );

      expect(result.isSuccess, isFalse);
      expect(result.message, contains('远端跟踪引用已更新，当前分支和工作区未改变'));
      expect(
        (await _gitOutput(repository, ['rev-parse', 'HEAD'])).trim(),
        headBefore,
      );
      expect(
        await File('${repository.path}${Platform.pathSeparator}README.md')
            .readAsString(),
        fileBefore,
      );
      expect(controller.syncState?.relation, BranchSyncRelation.diverged);
    },
  );
}

Future<Directory> _publisherClone(Directory remote) async {
  final publisher = Directory(
    '${remote.parent.path}${Platform.pathSeparator}'
    'publisher-${DateTime.now().microsecondsSinceEpoch}',
  );
  await publisher.create();
  await _git(publisher, ['clone', remote.path, publisher.path]);
  await _git(publisher, ['config', 'user.name', 'Sync Publisher']);
  await _git(publisher, ['config', 'user.email', 'publisher@example.invalid']);
  return publisher;
}

Future<Set<String>> _remoteTrackingRefs(Directory repository) async {
  final output = await _gitOutput(repository, [
    'for-each-ref',
    '--format=%(refname:short)',
    'refs/remotes/origin',
  ]);
  return output
      .split(RegExp(r'[\r\n]+'))
      .map((ref) => ref.replaceFirst('origin/', '').trim())
      .where((ref) => ref.isNotEmpty)
      .toSet();
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
