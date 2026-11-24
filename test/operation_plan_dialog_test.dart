import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/runtime_messages.dart';
import 'package:git_gui_expand/core/models/operation_plan.dart';
import 'package:git_gui_expand/core/models/operation_safety.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';

import 'support/localized_message_fixture.dart';

void main() {
  testWidgets('operation plan presenter can cancel without executing', (
    tester,
  ) async {
    final host = _FakePlanHost([_operation()]);
    await tester.pumpWidget(_DialogLauncher(host: host));

    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();
    expect(find.text('暂存全部更改'), findsOneWidget);

    await tester.tap(find.text('关闭'));
    await tester.pumpAndSettle();

    expect(host.executeCount, 0);
    expect(find.byType(OperationPlanDialog), findsNothing);
  });

  testWidgets('operation plan presenter confirms once', (tester) async {
    final host = _FakePlanHost([_operation()]);
    await tester.pumpWidget(_DialogLauncher(host: host));

    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认并逐步执行'));
    await tester.pumpAndSettle();

    expect(host.executeCount, 1);
    expect(find.text('完成'), findsOneWidget);
  });

  testWidgets('operation plan presenter shows drift details', (tester) async {
    final operation = _operation();
    final host = _FakePlanHost(
      [operation],
      nextResult: OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.messageFor('planStateChanged'),
        completed: 0,
        total: 1,
        remaining: [operation],
        validation: const OperationValidationResult.failure([
          OperationDrift(
            kind: OperationDriftKind.branch,
            label: 'branch',
            expected: 'main',
            actual: 'feature',
          ),
        ]),
      ),
    );
    await tester.pumpWidget(_DialogLauncher(host: host));

    await tester.tap(find.text('Open plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认并逐步执行'));
    await tester.pumpAndSettle();

    expect(find.text('状态变化详情'), findsOneWidget);
    expect(find.textContaining('main -> feature'), findsOneWidget);
  });
}

class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher({required this.host});

  final OperationPlanHost host;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => OperationPlanDialog(planHost: host),
              ),
              child: const Text('Open plan'),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakePlanHost implements OperationPlanHost {
  _FakePlanHost(List<PlannedRepositoryOperation> operations, {this.nextResult})
    : pendingOperations = operations;

  @override
  List<PlannedRepositoryOperation> pendingOperations;

  final OperationPlanResult? nextResult;
  int executeCount = 0;

  @override
  bool get canExecutePlan => pendingOperations.isNotEmpty && !isBusy;

  @override
  bool get isBusy => false;

  @override
  OperationOutcome clearPendingOperations() {
    final count = pendingOperations.length;
    pendingOperations = const [];
    return OperationOutcome.success(fixtureMessage('Cleared $count'));
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    executeCount += 1;
    final result = nextResult;
    if (result != null) {
      pendingOperations = result.remaining;
      return result;
    }
    final total = pendingOperations.length;
    pendingOperations = const [];
    return OperationPlanResult(
      isSuccess: true,
      message: fixtureMessage('Executed $total'),
      completed: total,
      total: total,
      remaining: const [],
    );
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    pendingOperations = pendingOperations
        .where((operation) => operation.id != id)
        .toList(growable: false);
    return OperationOutcome.success(fixtureMessage('Removed'));
  }

  @override
  Future<void> recoverFromSafetyRejection() async {
    pendingOperations = const [];
  }
}

PlannedRepositoryOperation _operation() {
  return PlannedRepositoryOperation(
    id: 'demo',
    kind: PlannedOperationKind.stageAll,
    title: RuntimeMessages.messageFor('planTitleStageAll'),
    description: RuntimeMessages.messageFor('planDescriptionStageAll'),
    run: () async => OperationOutcome.success(fixtureMessage('Done')),
  );
}
