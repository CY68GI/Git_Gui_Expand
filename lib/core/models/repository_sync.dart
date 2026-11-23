enum BranchSyncKind { tracked, noUpstream, detachedHead, unborn }

enum BranchSyncRelation { upToDate, ahead, behind, diverged, unknown }

class BranchSyncState {
  const BranchSyncState({
    required this.kind,
    required this.branch,
    required this.upstreamRef,
    required this.upstreamRemote,
    required this.upstreamBranch,
    required this.ahead,
    required this.behind,
    required this.worktreeClean,
  });

  const BranchSyncState.noUpstream({
    required String branch,
    required bool worktreeClean,
  }) : this(
         kind: BranchSyncKind.noUpstream,
         branch: branch,
         upstreamRef: '',
         upstreamRemote: '',
         upstreamBranch: '',
         ahead: 0,
         behind: 0,
         worktreeClean: worktreeClean,
       );

  const BranchSyncState.detached({required bool worktreeClean})
    : this(
        kind: BranchSyncKind.detachedHead,
        branch: '',
        upstreamRef: '',
        upstreamRemote: '',
        upstreamBranch: '',
        ahead: 0,
        behind: 0,
        worktreeClean: worktreeClean,
      );

  const BranchSyncState.unborn({required bool worktreeClean})
    : this(
        kind: BranchSyncKind.unborn,
        branch: '',
        upstreamRef: '',
        upstreamRemote: '',
        upstreamBranch: '',
        ahead: 0,
        behind: 0,
        worktreeClean: worktreeClean,
      );

  final BranchSyncKind kind;
  final String branch;
  final String upstreamRef;
  final String upstreamRemote;
  final String upstreamBranch;
  final int ahead;
  final int behind;
  final bool worktreeClean;

  bool get hasUpstream =>
      kind == BranchSyncKind.tracked &&
      upstreamRemote.isNotEmpty &&
      upstreamBranch.isNotEmpty;
  bool get isDetached => kind == BranchSyncKind.detachedHead;
  bool get isUnborn => kind == BranchSyncKind.unborn;

  BranchSyncRelation get relation {
    if (!hasUpstream) return BranchSyncRelation.unknown;
    if (ahead > 0 && behind > 0) return BranchSyncRelation.diverged;
    if (ahead > 0) return BranchSyncRelation.ahead;
    if (behind > 0) return BranchSyncRelation.behind;
    return BranchSyncRelation.upToDate;
  }

  bool get canFetchCurrent => hasUpstream;
  bool get canPull =>
      hasUpstream && worktreeClean && relation == BranchSyncRelation.behind;

  @override
  bool operator ==(Object other) {
    return other is BranchSyncState &&
        other.kind == kind &&
        other.branch == branch &&
        other.upstreamRef == upstreamRef &&
        other.upstreamRemote == upstreamRemote &&
        other.upstreamBranch == upstreamBranch &&
        other.ahead == ahead &&
        other.behind == behind &&
        other.worktreeClean == worktreeClean;
  }

  @override
  int get hashCode => Object.hash(
    kind,
    branch,
    upstreamRef,
    upstreamRemote,
    upstreamBranch,
    ahead,
    behind,
    worktreeClean,
  );
}

class SafePullResult {
  const SafePullResult({
    required this.updated,
    required this.state,
    required this.output,
  });

  final bool updated;
  final BranchSyncState state;
  final String output;
}
