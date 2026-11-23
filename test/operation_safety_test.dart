import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/models/operation_safety.dart';

void main() {
  test('repository snapshots compare normalized values deeply', () {
    const first = RepositoryStateSnapshot(
      rootPath: r'C:\repo',
      branch: 'main',
      head: 'abc',
      statusFingerprint: ' M file.txt',
      remoteUrls: {'origin': 'git@example/repo.git'},
      pathTypes: {'file.txt': 'file'},
    );
    const second = RepositoryStateSnapshot(
      rootPath: r'C:\repo',
      branch: 'main',
      head: 'abc',
      statusFingerprint: ' M file.txt',
      remoteUrls: {'origin': 'git@example/repo.git'},
      pathTypes: {'file.txt': 'file'},
    );
    const changed = RepositoryStateSnapshot(
      rootPath: r'C:\repo',
      branch: 'feature',
      head: 'def',
      statusFingerprint: ' M file.txt',
      remoteUrls: {'origin': 'git@example/repo.git'},
      pathTypes: {'file.txt': 'file'},
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
    expect(first, isNot(changed));
  });

  test('bootstrap and remote snapshots retain operation inputs', () {
    const bootstrap = BootstrapTargetSnapshot(
      contextKind: OperationContextKind.bootstrap,
      targetPath: r'C:\work\repo',
      parentPath: r'C:\work',
      targetExists: true,
      targetIsEmpty: true,
      gitMetadataType: 'notFound',
      source: 'git@example/repo.git',
    );
    const remote = RemoteRefSnapshot(
      remoteName: 'origin',
      targetBranch: 'main',
      refs: {'refs/heads/main': 'abc', 'refs/tags/v1': 'def'},
    );

    expect(bootstrap.gitMetadataType, 'notFound');
    expect(remote.targetRef, 'refs/heads/main');
    expect(remote.targetOid, 'abc');
  });

  test('validation results expose readable drift summaries', () {
    const result = OperationValidationResult.failure([
      OperationDrift(
        kind: OperationDriftKind.branch,
        label: 'branch',
        expected: 'main',
        actual: 'feature',
      ),
      OperationDrift(
        kind: OperationDriftKind.remoteRefs,
        label: 'remote refs',
        expected: '2 refs',
        actual: '3 refs',
      ),
    ]);

    expect(result.isSuccess, isFalse);
    expect(result.drifts, hasLength(2));
    expect(result.summary, contains('branch'));
    expect(result.summary, contains('remote refs'));
    expect(result, isNot(const OperationValidationResult.success()));
  });
}
