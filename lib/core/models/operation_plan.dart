import '../localization/localized_message.dart';
import 'operation_safety.dart';

class OperationOutcome {
  const OperationOutcome.success(this.message) : isSuccess = true;
  const OperationOutcome.failure(this.message) : isSuccess = false;

  final bool isSuccess;
  final LocalizedMessage message;
}

enum PlannedOperationKind {
  initializeRepository,
  cloneRepository,
  move,
  copy,
  rename,
  delete,
  clearGitMetadata,
  stageAll,
  unstageAll,
  commit,
  fetchCurrentRemote,
  fetchAllRemotes,
  pullFastForward,
  pushCurrentBranch,
  pushRemote,
  pushAllRemotes,
  addRemote,
  updateRemote,
  removeRemoteConfig,
  clearRemote,
  createBranch,
  switchBranch,
  renameBranch,
  deleteBranch,
  createStash,
  applyStash,
  popStash,
  dropStash,
}

class PlannedRepositoryOperation {
  const PlannedRepositoryOperation({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.run,
    this.isDangerous = false,
    this.isExclusive = false,
    this.strongConfirmationText,
    this.precondition,
    this.affectedPaths = const [],
  });

  final String id;
  final PlannedOperationKind kind;
  final LocalizedMessage title;
  final LocalizedMessage description;
  final bool isDangerous;
  final bool isExclusive;
  final String? strongConfirmationText;
  final OperationPrecondition? precondition;
  final List<String> affectedPaths;
  final Future<OperationOutcome> Function() run;

  bool get requiresStrongConfirmation =>
      isDangerous || strongConfirmationText != null;

  PlannedRepositoryOperation copyWith({
    String? id,
    LocalizedMessage? title,
    LocalizedMessage? description,
    bool? isDangerous,
    bool? isExclusive,
    String? strongConfirmationText,
    OperationPrecondition? precondition,
    List<String>? affectedPaths,
    Future<OperationOutcome> Function()? run,
  }) {
    return PlannedRepositoryOperation(
      id: id ?? this.id,
      kind: kind,
      title: title ?? this.title,
      description: description ?? this.description,
      run: run ?? this.run,
      isDangerous: isDangerous ?? this.isDangerous,
      isExclusive: isExclusive ?? this.isExclusive,
      strongConfirmationText:
          strongConfirmationText ?? this.strongConfirmationText,
      precondition: precondition ?? this.precondition,
      affectedPaths: affectedPaths ?? this.affectedPaths,
    );
  }
}

class OperationPlanProgress {
  const OperationPlanProgress({
    required this.step,
    required this.total,
    required this.title,
  });

  final int step;
  final int total;
  final LocalizedMessage title;
}

class OperationPlanResult {
  const OperationPlanResult({
    required this.isSuccess,
    required this.message,
    required this.completed,
    required this.total,
    required this.remaining,
    this.validation,
  });

  final bool isSuccess;
  final LocalizedMessage message;
  final int completed;
  final int total;
  final List<PlannedRepositoryOperation> remaining;
  final OperationValidationResult? validation;
}

abstract interface class OperationPlanHost {
  List<PlannedRepositoryOperation> get pendingOperations;
  bool get isBusy;
  bool get canExecutePlan;

  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  });

  OperationOutcome removePendingOperation(String id);
  OperationOutcome clearPendingOperations();
  Future<void> recoverFromSafetyRejection();
}
