enum OperationContextKind { repository, bootstrap }

enum OperationDriftKind {
  repositoryRoot,
  branch,
  head,
  status,
  remotes,
  pathType,
  destinationParent,
  destinationExists,
  destinationEmpty,
  gitMetadata,
  source,
  remoteName,
  remoteTargetBranch,
  remoteRefs,
}

class OperationDrift {
  const OperationDrift({
    required this.kind,
    required this.label,
    required this.expected,
    required this.actual,
  });

  final OperationDriftKind kind;
  final String label;
  final String expected;
  final String actual;

  String get summary => '$label: expected "$expected", actual "$actual"';

  @override
  bool operator ==(Object other) {
    return other is OperationDrift &&
        other.kind == kind &&
        other.label == label &&
        other.expected == expected &&
        other.actual == actual;
  }

  @override
  int get hashCode => Object.hash(kind, label, expected, actual);
}

class OperationValidationResult {
  const OperationValidationResult._({
    required this.isSuccess,
    required this.drifts,
  });

  const OperationValidationResult.success()
    : this._(isSuccess: true, drifts: const []);

  const OperationValidationResult.failure(List<OperationDrift> drifts)
    : this._(isSuccess: false, drifts: drifts);

  final bool isSuccess;
  final List<OperationDrift> drifts;

  String get summary => drifts.isEmpty
      ? 'State matches the confirmed preview.'
      : drifts.map((drift) => drift.summary).join('\n');

  @override
  bool operator ==(Object other) {
    return other is OperationValidationResult &&
        other.isSuccess == isSuccess &&
        _listEquals(other.drifts, drifts);
  }

  @override
  int get hashCode => Object.hash(isSuccess, Object.hashAll(drifts));
}

class RepositoryStateSnapshot {
  const RepositoryStateSnapshot({
    required this.rootPath,
    required this.branch,
    required this.head,
    required this.statusFingerprint,
    required this.remoteUrls,
    required this.pathTypes,
  });

  final String rootPath;
  final String branch;
  final String head;
  final String statusFingerprint;
  final Map<String, String> remoteUrls;
  final Map<String, String> pathTypes;

  @override
  bool operator ==(Object other) {
    return other is RepositoryStateSnapshot &&
        other.rootPath == rootPath &&
        other.branch == branch &&
        other.head == head &&
        other.statusFingerprint == statusFingerprint &&
        _mapEquals(other.remoteUrls, remoteUrls) &&
        _mapEquals(other.pathTypes, pathTypes);
  }

  @override
  int get hashCode => Object.hash(
    rootPath,
    branch,
    head,
    statusFingerprint,
    _mapHash(remoteUrls),
    _mapHash(pathTypes),
  );
}

class BootstrapTargetSnapshot {
  const BootstrapTargetSnapshot({
    required this.contextKind,
    required this.targetPath,
    required this.parentPath,
    required this.targetExists,
    required this.targetIsEmpty,
    required this.gitMetadataType,
    required this.source,
  });

  final OperationContextKind contextKind;
  final String targetPath;
  final String parentPath;
  final bool targetExists;
  final bool targetIsEmpty;
  final String gitMetadataType;
  final String source;

  @override
  bool operator ==(Object other) {
    return other is BootstrapTargetSnapshot &&
        other.contextKind == contextKind &&
        other.targetPath == targetPath &&
        other.parentPath == parentPath &&
        other.targetExists == targetExists &&
        other.targetIsEmpty == targetIsEmpty &&
        other.gitMetadataType == gitMetadataType &&
        other.source == source;
  }

  @override
  int get hashCode => Object.hash(
    contextKind,
    targetPath,
    parentPath,
    targetExists,
    targetIsEmpty,
    gitMetadataType,
    source,
  );
}

class RemoteRefSnapshot {
  const RemoteRefSnapshot({
    required this.remoteName,
    required this.targetBranch,
    required this.refs,
  });

  final String remoteName;
  final String targetBranch;
  final Map<String, String> refs;

  String get targetRef => 'refs/heads/$targetBranch';
  String get targetOid => refs[targetRef] ?? '';

  @override
  bool operator ==(Object other) {
    return other is RemoteRefSnapshot &&
        other.remoteName == remoteName &&
        other.targetBranch == targetBranch &&
        _mapEquals(other.refs, refs);
  }

  @override
  int get hashCode => Object.hash(remoteName, targetBranch, _mapHash(refs));
}

class OperationPrecondition {
  const OperationPrecondition({this.repository, this.bootstrap, this.remote});

  final RepositoryStateSnapshot? repository;
  final BootstrapTargetSnapshot? bootstrap;
  final RemoteRefSnapshot? remote;
}

OperationValidationResult compareRepositorySnapshots({
  required RepositoryStateSnapshot expected,
  required RepositoryStateSnapshot actual,
}) {
  final drifts = <OperationDrift>[
    if (expected.rootPath != actual.rootPath)
      OperationDrift(
        kind: OperationDriftKind.repositoryRoot,
        label: 'repository root',
        expected: expected.rootPath,
        actual: actual.rootPath,
      ),
    if (expected.branch != actual.branch)
      OperationDrift(
        kind: OperationDriftKind.branch,
        label: 'branch',
        expected: expected.branch,
        actual: actual.branch,
      ),
    if (expected.head != actual.head)
      OperationDrift(
        kind: OperationDriftKind.head,
        label: 'HEAD',
        expected: expected.head,
        actual: actual.head,
      ),
    if (expected.statusFingerprint != actual.statusFingerprint)
      OperationDrift(
        kind: OperationDriftKind.status,
        label: 'worktree status',
        expected: _shortFingerprint(expected.statusFingerprint),
        actual: _shortFingerprint(actual.statusFingerprint),
      ),
    if (!_mapEquals(expected.remoteUrls, actual.remoteUrls))
      OperationDrift(
        kind: OperationDriftKind.remotes,
        label: 'remote configuration',
        expected: _mapSummary(expected.remoteUrls),
        actual: _mapSummary(actual.remoteUrls),
      ),
  ];
  final paths = {...expected.pathTypes.keys, ...actual.pathTypes.keys};
  for (final path in paths.toList(growable: false)..sort()) {
    final expectedType = expected.pathTypes[path] ?? 'unknown';
    final actualType = actual.pathTypes[path] ?? 'unknown';
    if (expectedType == actualType) continue;
    drifts.add(
      OperationDrift(
        kind: OperationDriftKind.pathType,
        label: path,
        expected: expectedType,
        actual: actualType,
      ),
    );
  }
  return drifts.isEmpty
      ? const OperationValidationResult.success()
      : OperationValidationResult.failure(List.unmodifiable(drifts));
}

OperationValidationResult comparePathTypes({
  required Map<String, String> expected,
  required Map<String, String> actual,
}) {
  final drifts = <OperationDrift>[];
  for (final entry in expected.entries) {
    final actualType = actual[entry.key] ?? 'unknown';
    if (entry.value == actualType) continue;
    drifts.add(
      OperationDrift(
        kind: OperationDriftKind.pathType,
        label: entry.key,
        expected: entry.value,
        actual: actualType,
      ),
    );
  }
  return drifts.isEmpty
      ? const OperationValidationResult.success()
      : OperationValidationResult.failure(List.unmodifiable(drifts));
}

OperationValidationResult compareBootstrapSnapshots({
  required BootstrapTargetSnapshot expected,
  required BootstrapTargetSnapshot actual,
}) {
  final drifts = <OperationDrift>[
    if (expected.targetPath != actual.targetPath)
      OperationDrift(
        kind: OperationDriftKind.source,
        label: 'target path',
        expected: expected.targetPath,
        actual: actual.targetPath,
      ),
    if (expected.parentPath != actual.parentPath)
      OperationDrift(
        kind: OperationDriftKind.destinationParent,
        label: 'parent directory',
        expected: expected.parentPath,
        actual: actual.parentPath,
      ),
    if (expected.targetExists != actual.targetExists)
      OperationDrift(
        kind: OperationDriftKind.destinationExists,
        label: 'target exists',
        expected: '${expected.targetExists}',
        actual: '${actual.targetExists}',
      ),
    if (expected.targetIsEmpty != actual.targetIsEmpty)
      OperationDrift(
        kind: OperationDriftKind.destinationEmpty,
        label: 'target is empty',
        expected: '${expected.targetIsEmpty}',
        actual: '${actual.targetIsEmpty}',
      ),
    if (expected.gitMetadataType != actual.gitMetadataType)
      OperationDrift(
        kind: OperationDriftKind.gitMetadata,
        label: '.git metadata',
        expected: expected.gitMetadataType,
        actual: actual.gitMetadataType,
      ),
    if (expected.source != actual.source)
      OperationDrift(
        kind: OperationDriftKind.source,
        label: 'source',
        expected: expected.source,
        actual: actual.source,
      ),
  ];
  return drifts.isEmpty
      ? const OperationValidationResult.success()
      : OperationValidationResult.failure(List.unmodifiable(drifts));
}

OperationValidationResult mergeValidationResults(
  Iterable<OperationValidationResult> results,
) {
  final drifts = <OperationDrift>[
    for (final result in results) ...result.drifts,
  ];
  return drifts.isEmpty
      ? const OperationValidationResult.success()
      : OperationValidationResult.failure(List.unmodifiable(drifts));
}

String _shortFingerprint(String value) {
  if (value.isEmpty) return '(clean)';
  final visible = value.replaceAll('\u0000', ' | ').trim();
  return visible.length <= 120 ? visible : '${visible.substring(0, 120)}…';
}

String _mapSummary(Map<String, String> values) {
  if (values.isEmpty) return '(none)';
  final keys = values.keys.toList(growable: false)..sort();
  return keys.map((key) => '$key=${values[key]}').join(', ');
}

bool _mapEquals(Map<String, String> left, Map<String, String> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

int _mapHash(Map<String, String> values) {
  final keys = values.keys.toList(growable: false)..sort();
  return Object.hashAll(keys.map((key) => Object.hash(key, values[key])));
}

bool _listEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) return true;
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
