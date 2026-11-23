import 'package:flutter/foundation.dart';

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
    _log.info(
      'bootstrap',
      '已创建 ${_operation.title} 的操作预览；${_operation.description}',
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
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    final count = pendingOperations.length;
    pendingOperations = const [];
    notifyListeners();
    return OperationOutcome.success('已清空 $count 步待执行操作');
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    if (_isRunning || _used) {
      return _failure('此操作已经执行或正在执行，请重新打开预览。');
    }
    if (pendingOperations.isEmpty) {
      return _failure('执行计划为空。');
    }
    final operation = pendingOperations.single;
    if (operation.strongConfirmationText != null &&
        strongConfirmationText != operation.strongConfirmationText) {
      return _failure('请准确输入 ${operation.strongConfirmationText} 以确认危险操作。');
    }
    if (operation.isDangerous && !confirmedDangerous) {
      return _failure('请勾选危险操作确认项后再执行。');
    }

    _isRunning = true;
    notifyListeners();
    try {
      final validation = await validate(_precondition);
      if (!validation.isSuccess) {
        _log.warning(
          'bootstrap',
          '引导操作执行前状态校验失败：'
              '${validation.summary.replaceAll('\n', ' | ')}',
        );
        final result = OperationPlanResult(
          isSuccess: false,
          message: '目标状态与确认预览不一致，已停止执行。请刷新预览后重新确认。',
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
      _log.info('bootstrap', '开始执行：${operation.title}');
      final outcome = await operation.run();
      if (!outcome.isSuccess) {
        _log.error(
          'bootstrap',
          '执行失败：${operation.title}；原因=${outcome.message}',
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
      _log.info('bootstrap', '执行完成：${operation.title}；${outcome.message}');
      return result;
    } catch (error) {
      _log.error('bootstrap', '执行异常：${operation.title}；$error');
      final result = OperationPlanResult(
        isSuccess: false,
        message: '执行引导操作失败：$error',
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
      return const OperationOutcome.failure('当前操作尚未完成。');
    }
    if (pendingOperations.every((operation) => operation.id != id)) {
      return const OperationOutcome.failure('待执行操作不存在。');
    }
    pendingOperations = const [];
    notifyListeners();
    return OperationOutcome.success('已移除：${_operation.title}');
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

  OperationPlanResult _failure(String message) {
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
