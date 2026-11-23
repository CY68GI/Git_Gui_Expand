import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/operation_plan.dart';
import 'package:git_gui_expand/core/models/operation_safety.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_service.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';
import 'package:git_gui_expand/features/start/repository_bootstrap_plan_controller.dart';

void main() {
  late Directory root;
  late AppLogService logger;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_gui_bootstrap_plan_');
    logger = AppLogService(
      storage: AppStorageService(softwareDirectoryOverride: root.path),
    );
  });

  tearDown(() async {
    await logger.flush();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test(
    'initialization plan executes once and creates the repository',
    () async {
      final target = Directory('${root.path}${Platform.pathSeparator}empty');
      await target.create();
      final snapshot = await GitService.inspectInitializationTarget(
        target.path,
      );
      var runCount = 0;
      final plan = _initializationPlan(
        target: target,
        snapshot: snapshot,
        logService: logger,
        onRun: () => runCount += 1,
      );

      final first = await plan.executePendingOperations(
        confirmedDangerous: true,
      );
      final second = await plan.executePendingOperations(
        confirmedDangerous: true,
      );

      expect(first.isSuccess, isTrue, reason: first.message);
      expect(second.isSuccess, isFalse);
      expect(runCount, 1);
      expect(
        await Directory('${target.path}${Platform.pathSeparator}.git').exists(),
        isTrue,
      );
      plan.dispose();
    },
  );

  test(
    'initialization rejects a destination that gains .git after preview',
    () async {
      final target = Directory('${root.path}${Platform.pathSeparator}stale');
      await target.create();
      final snapshot = await GitService.inspectInitializationTarget(
        target.path,
      );
      var runCount = 0;
      final plan = _initializationPlan(
        target: target,
        snapshot: snapshot,
        logService: logger,
        onRun: () => runCount += 1,
      );
      await Directory('${target.path}${Platform.pathSeparator}.git').create();

      final result = await plan.executePendingOperations(
        confirmedDangerous: true,
      );

      expect(result.isSuccess, isFalse);
      expect(result.validation?.drifts, isNotEmpty);
      expect(runCount, 0);
      expect(
        await Directory('${target.path}${Platform.pathSeparator}.git').exists(),
        isTrue,
      );
      plan.dispose();
    },
  );

  testWidgets('cancelling a bootstrap preview creates no repository', (
    tester,
  ) async {
    final target = Directory('${root.path}${Platform.pathSeparator}cancelled');
    late BootstrapTargetSnapshot snapshot;
    await tester.runAsync(() async {
      await target.create();
      snapshot = await GitService.inspectInitializationTarget(target.path);
    });
    var runCount = 0;
    final plan = _initializationPlan(
      target: target,
      snapshot: snapshot,
      logService: _SilentLogService(),
      onRun: () => runCount += 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => OperationPlanDialog(planHost: plan),
              ),
              child: const Text('Open bootstrap plan'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open bootstrap plan'));
    await tester.pumpAndSettle();
    expect(find.text('Initialize'), findsOneWidget);
    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    expect(runCount, 0);
    expect(
      Directory('${target.path}${Platform.pathSeparator}.git').existsSync(),
      isFalse,
    );
    plan.dispose();
  });

  test('clone plan rejects a destination populated after preview', () async {
    final source = Directory('${root.path}${Platform.pathSeparator}source');
    await source.create();
    await _git(source, ['init', '-b', 'main']);
    await _git(source, ['config', 'user.name', 'Bootstrap Test']);
    await _git(source, ['config', 'user.email', 'bootstrap@example.invalid']);
    await File('${source.path}${Platform.pathSeparator}README.md')
        .writeAsString('# source');
    await _git(source, ['add', '-A']);
    await _git(source, ['commit', '-m', 'initial']);
    final destination = Directory('${root.path}${Platform.pathSeparator}clone');
    final snapshot = await GitService.inspectCloneTarget(
      source.path,
      destination.path,
    );
    var runCount = 0;
    final plan = RepositoryBootstrapPlanController(
      operation: PlannedRepositoryOperation(
        id: 'bootstrap-clone',
        kind: PlannedOperationKind.cloneRepository,
        title: 'Clone',
        description: 'Clone the local source.',
        run: () async {
          runCount += 1;
          await GitService.cloneRepository(source.path, destination.path);
          return const OperationOutcome.success('cloned');
        },
      ),
      precondition: OperationPrecondition(bootstrap: snapshot),
      validate: (expected) async {
        final current = await GitService.inspectCloneTarget(
          source.path,
          destination.path,
        );
        return compareBootstrapSnapshots(
          expected: expected.bootstrap!,
          actual: current,
        );
      },
      refreshPrecondition: () async => OperationPrecondition(
        bootstrap: await GitService.inspectCloneTarget(
          source.path,
          destination.path,
        ),
      ),
      logService: logger,
    );
    await destination.create();
    await File('${destination.path}${Platform.pathSeparator}existing.txt')
        .writeAsString('keep');

    final result = await plan.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(result.isSuccess, isFalse);
    expect(result.validation?.drifts, isNotEmpty);
    expect(runCount, 0);
    expect(
      await File('${destination.path}${Platform.pathSeparator}existing.txt')
          .readAsString(),
      'keep',
    );
    plan.dispose();
  });

  test('clone plan creates the repository once after confirmation', () async {
    final source = Directory(
      '${root.path}${Platform.pathSeparator}clone-source',
    );
    await source.create();
    await _git(source, ['init', '-b', 'main']);
    await _git(source, ['config', 'user.name', 'Bootstrap Test']);
    await _git(source, ['config', 'user.email', 'bootstrap@example.invalid']);
    await File('${source.path}${Platform.pathSeparator}README.md')
        .writeAsString('# source');
    await _git(source, ['add', '-A']);
    await _git(source, ['commit', '-m', 'initial']);
    final destination = Directory(
      '${root.path}${Platform.pathSeparator}clone-success',
    );
    final snapshot = await GitService.inspectCloneTarget(
      source.path,
      destination.path,
    );
    var runCount = 0;
    final plan = RepositoryBootstrapPlanController(
      operation: PlannedRepositoryOperation(
        id: 'bootstrap-clone',
        kind: PlannedOperationKind.cloneRepository,
        title: 'Clone',
        description: 'Clone the local source.',
        run: () async {
          runCount += 1;
          await GitService.cloneRepository(source.path, destination.path);
          return const OperationOutcome.success('cloned');
        },
      ),
      precondition: OperationPrecondition(bootstrap: snapshot),
      validate: (expected) async {
        final current = await GitService.inspectCloneTarget(
          source.path,
          destination.path,
        );
        return compareBootstrapSnapshots(
          expected: expected.bootstrap!,
          actual: current,
        );
      },
      refreshPrecondition: () async => OperationPrecondition(
        bootstrap: await GitService.inspectCloneTarget(
          source.path,
          destination.path,
        ),
      ),
      logService: logger,
    );

    final result = await plan.executePendingOperations(
      confirmedDangerous: true,
    );

    expect(result.isSuccess, isTrue, reason: result.message);
    expect(runCount, 1);
    expect(
      await Directory('${destination.path}${Platform.pathSeparator}.git')
          .exists(),
      isTrue,
    );
    plan.dispose();
  });
}

RepositoryBootstrapPlanController _initializationPlan({
  required Directory target,
  required BootstrapTargetSnapshot snapshot,
  required AppLogService logService,
  required void Function() onRun,
}) {
  return RepositoryBootstrapPlanController(
    operation: PlannedRepositoryOperation(
      id: 'bootstrap-init',
      kind: PlannedOperationKind.initializeRepository,
      title: 'Initialize',
      description: 'Initialize the selected folder.',
      run: () async {
        onRun();
        await GitService.initializeRepository(target.path);
        return const OperationOutcome.success('initialized');
      },
    ),
    precondition: OperationPrecondition(bootstrap: snapshot),
    validate: (expected) async {
      final current = await GitService.inspectInitializationTarget(target.path);
      return compareBootstrapSnapshots(
        expected: expected.bootstrap!,
        actual: current,
      );
    },
    refreshPrecondition: () async => OperationPrecondition(
      bootstrap: await GitService.inspectInitializationTarget(target.path),
    ),
    logService: logService,
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
    throw StateError('${result.stdout}\n${result.stderr}');
  }
}

class _SilentLogService extends AppLogService {
  @override
  void info(String area, String message) {}

  @override
  void detail(String area, String message) {}

  @override
  void warning(String area, String message) {}

  @override
  void error(String area, String message) {}

  @override
  Future<void> flush() async {}
}
