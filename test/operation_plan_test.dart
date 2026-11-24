import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

import 'support/localized_message_fixture.dart';

void main() {
  late Directory temporaryRoot;
  late Directory repository;
  late AppLogService logService;
  late RepositoryController controller;

  setUp(() async {
    temporaryRoot = await Directory.systemTemp.createTemp('git_gui_plan_test_');
    repository = Directory(
      '${temporaryRoot.path}${Platform.pathSeparator}repository',
    );
    await repository.create();
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', 'Git GUI Expand Test']);
    await _git(repository, ['config', 'user.email', 'test@example.invalid']);
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('alpha');
    await _git(repository, ['add', '-A']);
    await _git(repository, ['commit', '-m', 'initial']);

    final storage = AppStorageService(
      softwareDirectoryOverride: temporaryRoot.path,
    );
    logService = AppLogService(storage: storage);
    controller = RepositoryController(
      settingsService: SettingsService(
        storage: storage,
        logService: logService,
      ),
      logService: logService,
      recentRepositoriesService: RecentRepositoriesService(
        storage: storage,
        logService: logService,
      ),
    );
    await controller.initialize();
    final opened = await controller.openRepository(repository.path);
    expect(opened.isSuccess, isTrue, reason: fixtureText(opened.message));
  });

  tearDown(() async {
    controller.dispose();
    await logService.flush();
    if (await temporaryRoot.exists()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test(
    'rename is recorded without changing the file before confirmation',
    () async {
      controller.setActiveSide(ExplorerSide.left);
      controller.toggleSelection(ExplorerSide.left, 'alpha.txt');

      final queued = await controller.renameSelection('renamed.txt');

      expect(queued.isSuccess, isTrue);
      expect(controller.pendingOperations, hasLength(1));
      final original = File(
        '${repository.path}${Platform.pathSeparator}alpha.txt',
      );
      final renamed = File(
        '${repository.path}${Platform.pathSeparator}renamed.txt',
      );
      expect(await original.exists(), isTrue);
      expect(await renamed.exists(), isFalse);

      final result = await controller.executePendingOperations(
        confirmedDangerous: true,
      );

      expect(result.isSuccess, isTrue);
      expect(await original.exists(), isFalse);
      expect(await renamed.exists(), isTrue);
    },
  );

  test('dangerous delete requires explicit confirmation', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    final queued = await controller.deleteSelectedPaths();
    expect(queued.isSuccess, isTrue);

    final blocked = await controller.executePendingOperations(
      confirmedDangerous: false,
    );
    expect(blocked.isSuccess, isFalse);
    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .exists(),
      isTrue,
    );

    final executed = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(executed.isSuccess, isTrue);
    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .exists(),
      isFalse,
    );
  });

  test('external file changes block a queued rename before mutation', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    final queued = await controller.renameSelection('renamed.txt');
    expect(queued.isSuccess, isTrue);

    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('externally changed');
    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(result.isSuccess, isFalse);
    expect(result.validation?.drifts, isNotEmpty);
    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .readAsString(),
      'externally changed',
    );
    expect(
      await File('${repository.path}${Platform.pathSeparator}renamed.txt')
          .exists(),
      isFalse,
    );
  });

  test('an external branch switch blocks the queued plan', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    expect((await controller.renameSelection('renamed.txt')).isSuccess, isTrue);

    await _git(repository, ['switch', '-c', 'external-branch']);
    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(result.isSuccess, isFalse);
    expect(
      result.validation!.drifts.any((drift) => drift.kind.name == 'branch'),
      isTrue,
    );
    expect(
      await File('${repository.path}${Platform.pathSeparator}renamed.txt')
          .exists(),
      isFalse,
    );
  });

  test(
    'Git metadata removal is exclusive and requires plan confirmation',
    () async {
      expect(
        (await controller.createBranch('metadata-guard')).isSuccess,
        isTrue,
      );
      final blocked = await controller.clearGitMetadata();
      expect(blocked.isSuccess, isFalse);
      expect(
        controller.pendingOperations.single.kind,
        PlannedOperationKind.createBranch,
      );
      controller.clearPendingOperations();

      final queued = await controller.clearGitMetadata();
      expect(queued.isSuccess, isTrue);
      expect(controller.pendingOperations.single.isExclusive, isTrue);
      final wrongConfirmation = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: 'wrong',
      );
      expect(wrongConfirmation.isSuccess, isFalse);
      expect(
        await Directory('${repository.path}${Platform.pathSeparator}.git')
            .exists(),
        isTrue,
      );

      final cleared = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: 'CLEAR GIT',
      );
      expect(cleared.isSuccess, isTrue, reason: fixtureText(cleared.message));
      expect(controller.hasRepository, isFalse);
      expect(
        await Directory('${repository.path}${Platform.pathSeparator}.git')
            .exists(),
        isFalse,
      );
      expect(
        await File('${repository.path}${Platform.pathSeparator}alpha.txt')
            .exists(),
        isTrue,
      );
    },
  );

  test('branch operations are queued before Git executes them', () async {
    final queuedCreate = await controller.createBranch('feature/plan');
    expect(queuedCreate.isSuccess, isTrue);
    expect(
      controller.pendingOperations.single.kind,
      PlannedOperationKind.createBranch,
    );
    expect(await controller.localBranches(), isNot(contains('feature/plan')));

    final created = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(created.isSuccess, isTrue);
    expect(await controller.localBranches(), contains('feature/plan'));

    await controller.switchBranch('feature/plan');
    await controller.executePendingOperations(confirmedDangerous: true);
    expect(controller.branch, 'feature/plan');

    await controller.renameBranch('feature/plan', 'feature/renamed');
    await controller.executePendingOperations(confirmedDangerous: true);
    expect(controller.branch, 'feature/renamed');

    await controller.switchBranch('main');
    await controller.executePendingOperations(confirmedDangerous: true);
    await controller.deleteBranch('feature/renamed');
    final deleted = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(deleted.isSuccess, isTrue);
    expect(
      await controller.localBranches(),
      isNot(contains('feature/renamed')),
    );
  });

  test(
    'controller refreshes and clears branch synchronization state',
    () async {
      expect(controller.syncState?.kind, BranchSyncKind.noUpstream);

      final remote = Directory(
        '${temporaryRoot.path}${Platform.pathSeparator}sync-remote.git',
      );
      await remote.create();
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);

      expect((await controller.pushCurrentBranch()).isSuccess, isTrue);
      expect(
        (await controller.executePendingOperations(confirmedDangerous: true))
            .isSuccess,
        isTrue,
      );
      expect(controller.syncState?.kind, BranchSyncKind.tracked);
      expect(controller.syncState?.relation, BranchSyncRelation.upToDate);

      final dirty = File(
        '${repository.path}${Platform.pathSeparator}sync-dirty.txt',
      );
      await dirty.writeAsString('dirty');
      await controller.refresh(refreshStats: false);
      expect(controller.syncState?.worktreeClean, isFalse);

      await dirty.delete();
      controller.closeRepository();
      expect(controller.syncState, isNull);
    },
  );

  test('stash creation is queued before changing the worktree', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('stash me');

    final queued = await controller.createStash(
      message: 'planned stash',
      includeUntracked: true,
    );
    expect(queued.isSuccess, isTrue);
    expect(
      controller.pendingOperations.single.kind,
      PlannedOperationKind.createStash,
    );
    expect(
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .readAsString(),
      'stash me',
    );
    expect(await controller.listStashes(), isEmpty);

    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(result.isSuccess, isTrue);
    expect(await controller.listStashes(), hasLength(1));
  });

  test('commit is not run until the plan is executed', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('changed');
    await controller.refresh(refreshStats: false);

    final queued = await controller.commitAll('Plan commit');
    expect(queued.isSuccess, isTrue);
    expect(controller.pendingOperations, hasLength(1));
    expect(await _commitCount(repository), 1);

    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(result.isSuccess, isTrue);
    expect(await _commitCount(repository), 2);
  });

  test('missing Git identity blocks commit planning', () async {
    await _git(repository, ['config', 'user.name', '']);
    await _git(repository, ['config', 'user.email', '']);
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('identity missing');
    await controller.refresh(refreshStats: false);

    final queued = await controller.commitAll('Should not be queued');

    expect(queued.isSuccess, isFalse);
    expect(fixtureText(queued.message), contains('user.name and user.email'));
    expect(controller.pendingOperations, isEmpty);
  });

  test('identity is rechecked before staging a queued commit', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('identity changes later');
    await controller.refresh(refreshStats: false);
    final commitsBefore = await _commitCount(repository);
    expect(
      (await controller.commitAll('Queued with valid identity')).isSuccess,
      isTrue,
    );

    await _git(repository, ['config', 'user.name', '']);
    await _git(repository, ['config', 'user.email', '']);
    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(result.isSuccess, isFalse);
    expect(fixtureText(result.message).toLowerCase(), contains('identity'));
    expect(await _commitCount(repository), commitsBefore);
    final staged = await _gitOutput(repository, [
      'diff',
      '--cached',
      '--name-only',
    ]);
    expect(staged.trim(), isEmpty);
  });

  test('queued file changes allow a following commit step', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    final rename = await controller.renameSelection('renamed.txt');
    expect(rename.isSuccess, isTrue);
    expect(controller.changedFiles, isEmpty);

    final commit = await controller.commitAll('Rename from execution plan');
    expect(commit.isSuccess, isTrue, reason: fixtureText(commit.message));
    expect(controller.pendingOperations, hasLength(2));

    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(result.isSuccess, isTrue, reason: fixtureText(result.message));
    expect(await _commitCount(repository), 2);
    expect(
      await File('${repository.path}${Platform.pathSeparator}renamed.txt')
          .exists(),
      isTrue,
    );
  });

  test('external change before a later step stops execution', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    expect((await controller.renameSelection('renamed.txt')).isSuccess, isTrue);
    expect(
      (await controller.createBranch('planned-after-rename')).isSuccess,
      isTrue,
    );

    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
      onProgress: (progress) {
        if (progress.step == 2) {
          File(
            '${repository.path}${Platform.pathSeparator}external-between.txt',
          ).writeAsStringSync('external');
        }
      },
    );

    expect(result.isSuccess, isFalse);
    expect(result.completed, 1);
    expect(result.remaining.single.kind, PlannedOperationKind.createBranch);
    expect(
      await File('${repository.path}${Platform.pathSeparator}renamed.txt')
          .exists(),
      isTrue,
    );
    expect(
      await controller.localBranches(),
      isNot(contains('planned-after-rename')),
    );
  });

  test('new local work is rejected after a commit step is queued', () async {
    await File('${repository.path}${Platform.pathSeparator}alpha.txt')
        .writeAsString('changed');
    await controller.refresh(refreshStats: false);
    final commit = await controller.commitAll('Queued commit');
    expect(commit.isSuccess, isTrue);

    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    final rename = await controller.renameSelection('blocked.txt');
    expect(rename.isSuccess, isFalse);
    expect(controller.pendingOperations, hasLength(1));
  });

  test(
    'clear remote requires the exact project and branch confirmation',
    () async {
      final remote = Directory(
        '${temporaryRoot.path}${Platform.pathSeparator}remote.git',
      );
      await remote.create();
      await _git(remote, ['init', '--bare']);
      await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
      await _git(remote, ['config', 'receive.denyDeleteCurrent', 'ignore']);
      await _git(repository, ['remote', 'add', 'origin', remote.path]);
      await _git(repository, ['push', '-u', 'origin', 'main']);

      final inspection = await controller.inspectRemoteForClear('origin');
      expect(
        inspection.isSuccess,
        isTrue,
        reason: fixtureText(inspection.message),
      );
      expect(inspection.preview, isNotNull);
      final queued = await controller.queueClearRemote(inspection.preview!);
      expect(queued.isSuccess, isTrue);

      final blocked = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: 'wrong',
      );
      expect(blocked.isSuccess, isFalse);
      final before = await Process.run(
        'git',
        ['ls-remote', '--refs', remote.path],
        workingDirectory: repository.path,
        runInShell: false,
      );
      expect(before.stdout, isNotEmpty);

      final executed = await controller.executePendingOperations(
        confirmedDangerous: true,
        strongConfirmationText: inspection.preview!.confirmationText,
      );
      expect(executed.isSuccess, isTrue, reason: fixtureText(executed.message));
      final after = await Process.run(
        'git',
        ['ls-remote', '--heads', '--refs', remote.path],
        workingDirectory: repository.path,
        runInShell: false,
      );
      expect(after.stdout, contains('refs/heads/main'));
      expect(
        await File('${repository.path}${Platform.pathSeparator}alpha.txt')
            .readAsString(),
        'alpha',
      );
      expect(controller.changedFiles, isNotEmpty);
      expect(
        controller.changedFiles.any(
          (status) =>
              status.path == 'alpha.txt' &&
              status.indexCode == '?' &&
              status.worktreeCode == '?',
        ),
        isTrue,
      );
    },
  );

  test('remote drift returns a refreshed preview and preserves refs', () async {
    final remote = Directory(
      '${temporaryRoot.path}${Platform.pathSeparator}remote-drift.git',
    );
    await remote.create();
    await _git(remote, ['init', '--bare']);
    await _git(remote, ['symbolic-ref', 'HEAD', 'refs/heads/main']);
    await _git(remote, ['config', 'receive.denyDeleteCurrent', 'ignore']);
    await _git(repository, ['remote', 'add', 'origin', remote.path]);
    await _git(repository, ['push', '-u', 'origin', 'main']);

    final inspection = await controller.inspectRemoteForClear('origin');
    expect(inspection.preview, isNotNull);
    final preview = inspection.preview!;
    expect((await controller.queueClearRemote(preview)).isSuccess, isTrue);

    await _git(repository, ['branch', 'added-after-preview']);
    await _git(repository, ['push', 'origin', 'added-after-preview']);
    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
      strongConfirmationText: preview.confirmationText,
    );

    expect(result.isSuccess, isFalse);
    expect(fixtureText(result.message), contains('added-after-preview'));
    final refs = await Process.run(
      'git',
      ['ls-remote', '--refs', remote.path],
      workingDirectory: repository.path,
      runInShell: false,
    );
    expect(refs.stdout, contains('refs/heads/main'));
    expect(refs.stdout, contains('refs/heads/added-after-preview'));
  });

  test(
    'execution stops after a failed step and preserves remaining steps',
    () async {
      var runCount = 0;
      controller.pendingOperations = [
        PlannedRepositoryOperation(
          id: 'first',
          kind: PlannedOperationKind.stageAll,
          title: fixturePlanTitle('First step'),
          description: fixturePlanDescription('Successful step'),
          run: () async {
            runCount += 1;
            return OperationOutcome.success(fixtureMessage('first'));
          },
        ),
        PlannedRepositoryOperation(
          id: 'second',
          kind: PlannedOperationKind.commit,
          title: fixturePlanTitle('Second step'),
          description: fixturePlanDescription('Failing step'),
          run: () async {
            runCount += 1;
            return OperationOutcome.failure(
              fixtureMessage('simulated failure'),
            );
          },
        ),
        PlannedRepositoryOperation(
          id: 'third',
          kind: PlannedOperationKind.pushCurrentBranch,
          title: fixturePlanTitle('Third step'),
          description: fixturePlanDescription('Step that must not run'),
          run: () async {
            runCount += 1;
            return OperationOutcome.success(fixtureMessage('third'));
          },
        ),
      ];

      final result = await controller.executePendingOperations(
        confirmedDangerous: true,
      );

      expect(result.isSuccess, isFalse);
      expect(result.completed, 1);
      expect(runCount, 2);
      expect(result.remaining.map((operation) => operation.id), [
        'second',
        'third',
      ]);
      expect(controller.pendingOperations, hasLength(2));
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

Future<int> _commitCount(Directory directory) async {
  final result = await Process.run(
    'git',
    ['rev-list', '--count', 'HEAD'],
    workingDirectory: directory.path,
    runInShell: false,
  );
  return int.parse((result.stdout as String).trim());
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
