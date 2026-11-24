import 'package:flutter/foundation.dart';

import '../../core/localization/localized_message.dart';
import '../../core/localization/runtime_messages.dart';
import '../../core/models/operation_plan.dart';
import '../../core/models/operation_safety.dart';
import '../../core/services/app_log_service.dart';

class RepositoryBootstrapPlanController extends ChangeNotifier
    implements OperationPlanHost {
  RepositoryBootstrapPlanController({
    required PlannedRepositoryOperation operation,
    required OperationPrecondition precondition,
    required this.validate,
    required this.refreshPrecondition,
    AppLogService? logService,
  }) : _operation = operation.copyWith(precondition: precondition),
       _precondition = precondition,
       _log = logService ?? AppLogService.instance {
    pendingOperations = [_operation];
    _log.infoEvent(
      'bootstrap',
      'bootstrap.plan.preview.created',
      details: {
        'kind': _operation.kind.name,
        'titleKey': _operation.title.key,
        'descriptionKey': _operation.description.key,
      },
    );
  }

  PlannedRepositoryOperation _operation;
  OperationPrecondition _precondition;
  final Future<OperationValidationResult> Function(
    OperationPrecondition precondition,
  )
  validate;
  final Future<OperationPrecondition> Function() refreshPrecondition;
  final AppLogService _log;

  @override
  List<PlannedRepositoryOperation> pendingOperations = const [];
  bool _isRunning = false;
  bool _used = false;
  OperationPlanResult? lastResult;

  @override
  bool get canExecutePlan =>
      pendingOperations.isNotEmpty && !_isRunning && !_used;

  @override
  bool get isBusy => _isRunning;

  @override
  OperationOutcome clearPendingOperations() {
    if (_isRunning) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    final count = pendingOperations.length;
    pendingOperations = const [];
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.messageFor(
        'planCleared',
        parameters: {'count': count},
        eventId: 'bootstrap.plan.clear.succeeded',
      ),
    );
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    if (_isRunning || _used) {
      return _failure(RuntimeMessages.messageFor('bootstrapPlanAlreadyUsed'));
    }
    if (pendingOperations.isEmpty) {
      return _failure(RuntimeMessages.messageFor('emptyOperationPlan'));
    }
    final operation = pendingOperations.single;
    if (operation.strongConfirmationText != null &&
        strongConfirmationText != operation.strongConfirmationText) {
      return _failure(
        RuntimeMessages.messageFor(
          'planStrongConfirmationRequired',
          parameters: {'confirmation': operation.strongConfirmationText ?? ''},
        ),
      );
    }
    if (operation.isDangerous && !confirmedDangerous) {
      return _failure(
        RuntimeMessages.messageFor('planDangerousAcknowledgmentRequired'),
      );
    }

    _isRunning = true;
    notifyListeners();
    try {
      final validation = await validate(_precondition);
      if (!validation.isSuccess) {
        _log.warningEvent(
          'bootstrap',
          'bootstrap.preflight.state.changed',
          details: {'validation': validation.summary.replaceAll('\n', ' | ')},
        );
        final result = OperationPlanResult(
          isSuccess: false,
          message: RuntimeMessages.messageFor('bootstrapStateChanged'),
          completed: 0,
          total: 1,
          remaining: pendingOperations,
          validation: validation,
        );
        lastResult = result;
        return result;
      }
      _used = true;
      onProgress?.call(
        OperationPlanProgress(step: 1, total: 1, title: operation.title),
      );
      _log.infoEvent(
        'bootstrap',
        'bootstrap.execute.started',
        details: {'kind': operation.kind.name},
      );
      final outcome = await operation.run();
      if (!outcome.isSuccess) {
        _log.errorEvent(
          'bootstrap',
          'bootstrap.execute.failed',
          details: {
            'kind': operation.kind.name,
            'outcomeKey': outcome.message.key,
          },
        );
        final result = OperationPlanResult(
          isSuccess: false,
          message: outcome.message,
          completed: 0,
          total: 1,
          remaining: pendingOperations,
        );
        lastResult = result;
        return result;
      }
      pendingOperations = const [];
      final result = OperationPlanResult(
        isSuccess: true,
        message: outcome.message,
        completed: 1,
        total: 1,
        remaining: const [],
      );
      lastResult = result;
      _log.infoEvent(
        'bootstrap',
        'bootstrap.execute.completed',
        details: {'kind': operation.kind.name},
      );
      return result;
    } catch (error) {
      _log.errorEvent(
        'bootstrap',
        'bootstrap.execute.exception',
        details: {'kind': operation.kind.name, 'error': '$error'},
      );
      final result = OperationPlanResult(
        isSuccess: false,
        message: RuntimeMessages.operationFailed(
          error,
          eventId: 'bootstrap.execute.exception',
        ),
        completed: 0,
        total: 1,
        remaining: pendingOperations,
      );
      lastResult = result;
      return result;
    } finally {
      _isRunning = false;
      notifyListeners();
    }
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    if (_isRunning) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('operationInProgress'),
      );
    }
    if (pendingOperations.every((operation) => operation.id != id)) {
      return OperationOutcome.failure(
        RuntimeMessages.messageFor('planOperationMissing'),
      );
    }
    pendingOperations = const [];
    notifyListeners();
    return OperationOutcome.success(
      RuntimeMessages.messageFor('planOperationRemoved'),
    );
  }

  @override
  Future<void> recoverFromSafetyRejection() async {
    if (_isRunning || _used) return;
    _precondition = await refreshPrecondition();
    _operation = _operation.copyWith(precondition: _precondition);
    pendingOperations = [_operation];
    lastResult = null;
    notifyListeners();
  }

  OperationPlanResult _failure(LocalizedMessage message) {
    final result = OperationPlanResult(
      isSuccess: false,
      message: message,
      completed: 0,
      total: pendingOperations.length,
      remaining: pendingOperations,
    );
    lastResult = result;
    return result;
  }
}
