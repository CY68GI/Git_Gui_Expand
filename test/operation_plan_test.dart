import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

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
    expect(opened.isSuccess, isTrue, reason: opened.message);
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

  test('queued file changes allow a following commit step', () async {
    controller.setActiveSide(ExplorerSide.left);
    controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
    final rename = await controller.renameSelection('renamed.txt');
    expect(rename.isSuccess, isTrue);
    expect(controller.changedFiles, isEmpty);

    final commit = await controller.commitAll('Rename from execution plan');
    expect(commit.isSuccess, isTrue, reason: commit.message);
    expect(controller.pendingOperations, hasLength(2));

    final result = await controller.executePendingOperations(
      confirmedDangerous: true,
    );
    expect(result.isSuccess, isTrue, reason: result.message);
    expect(await _commitCount(repository), 2);
    expect(
      await File('${repository.path}${Platform.pathSeparator}renamed.txt')
          .exists(),
      isTrue,
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
      expect(inspection.isSuccess, isTrue, reason: inspection.message);
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
      expect(executed.isSuccess, isTrue, reason: executed.message);
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

  test(
    'execution stops after a failed step and preserves remaining steps',
    () async {
      var runCount = 0;
      controller.pendingOperations = [
        PlannedRepositoryOperation(
          id: 'first',
          kind: PlannedOperationKind.stageAll,
          title: '第一步',
          description: '成功步骤',
          run: () async {
            runCount += 1;
            return const OperationOutcome.success('first');
          },
        ),
        PlannedRepositoryOperation(
          id: 'second',
          kind: PlannedOperationKind.commit,
          title: '第二步',
          description: '失败步骤',
          run: () async {
            runCount += 1;
            return const OperationOutcome.failure('simulated failure');
          },
        ),
        PlannedRepositoryOperation(
          id: 'third',
          kind: PlannedOperationKind.pushCurrentBranch,
          title: '第三步',
          description: '不应执行的步骤',
          run: () async {
            runCount += 1;
            return const OperationOutcome.success('third');
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
