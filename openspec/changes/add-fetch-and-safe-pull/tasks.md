# Tasks

## 1. Synchronization State Model

- [x] 1.1 Add a branch synchronization-state model covering current branch,
  detached HEAD, upstream remote/branch, ahead count, behind count, and clean or
  dirty worktree state; verify equality and display-state unit tests.
- [x] 1.2 Implement GitService upstream and ahead/behind queries with distinct
  handling for missing upstream, detached HEAD, unborn branch, and Git errors;
  verify local repository tests cover all states.
- [x] 1.3 Refresh synchronization state when a repository opens, files or refs
  change, fetch/pull completes, remotes change, and the user refreshes; verify
  controller tests confirm state is cleared on close and updated after mutations.

## 2. Planned Fetch Operations

- [x] 2.1 Add planned operation kinds and controller methods for fetching the
  current upstream remote and fetching all remotes; verify cancel does not fetch
  and confirmation runs the expected Git command once.
- [x] 2.2 Implement non-interactive fetch with pruning, per-remote fetch-all
  reporting, and state refresh; verify local bare-remote tests cover updated
  remote-tracking refs, deleted remote branches, and partial fetch-all failures.
- [x] 2.3 Add localized fetch titles, descriptions, success/error messages,
  authentication/network guidance, and detailed logging; verify translation and
  logging tests preserve raw Git diagnostics.
- [x] 2.4 Update the README Git matrix and three user guides for fetch behavior;
  verify documented actions match the planned-operation flow and use the same
  remote names shown in the UI.

## 3. Safe Fast-Forward Pull

- [x] 3.1 Implement a planned safe-pull operation that validates current branch,
  upstream, clean worktree/index, fetches with pruning, recomputes ahead/behind,
  and runs `git merge --ff-only` only when behind and not ahead; verify repository
  tests for a successful fast-forward.
- [x] 3.2 Reject up-to-date and ahead-only pull requests without mutation, and
  reject diverged histories before the fast-forward merge; verify tests confirm
  no merge commit or worktree modification is created.
- [x] 3.3 Reject dirty worktree/index, detached HEAD, missing upstream, and stale
  pull previews before branch mutation; verify tests preserve files, index, and
  HEAD exactly.
- [x] 3.4 Report the safe-pull sequence clearly when fetch succeeds but a later
  divergence check refuses the merge; verify messages state that remote-tracking
  refs were refreshed while the current branch and files were not changed.
- [x] 3.5 Add a synchronization dialog showing branch, upstream, ahead/behind,
  and separate Fetch current, Fetch all, and Safe pull actions; verify widget
  tests for no-upstream, detached, behind, ahead, and diverged states.
- [x] 3.6 Add golden-layout coverage for the synchronization dialog at 90%, 100%,
  and 110% text scale; verify no clipping or unreadable warning text.
- [x] 3.7 Update all three user guides and README notes for safe pull, dirty
  worktree restrictions, divergence guidance, and the absence of automatic
  merge/rebase; verify documented recovery steps match errors shown by the UI.

## 4. Commit Identity Readiness

- [x] 4.1 Add effective-author and effective-committer identity models and query
  `git var GIT_AUTHOR_IDENT` plus `GIT_COMMITTER_IDENT`; verify parsing and
  missing-identity tests.
- [x] 4.2 Block commit planning when effective identity is unavailable and show
  repository-local/global setup guidance; verify the pending plan remains
  unchanged.
- [x] 4.3 Recheck identity at commit execution before staging, so a changed or
  invalid environment cannot create a partial commit; verify `git add` and
  `git commit` are both skipped on failure.
- [x] 4.4 Add localized identity messages and detailed log records without
  exposing credentials; verify translations and logging tests.
- [x] 4.5 Update the three user guides with identity preflight and setup
  commands; verify the documented commands work in a temporary repository.

## 5. Integration Verification

- [x] 5.1 Run `flutter analyze` and verify there are no analyzer issues.
- [x] 5.2 Run the full Flutter test suite and verify all synchronization,
  identity, operation-plan, localization, and layout tests pass.
- [x] 5.3 Run live fetch/pull tests against an isolated bare remote and clone,
  covering successful fast-forward, divergence rejection, dirty worktree, and
  fetch-all; verify branch hashes and files end in the documented state.
- [x] 5.4 Build and package the Windows release, launch it from a test repository,
  and verify sync dialog startup, logging, and version metadata.

## 6. Release Readiness

- [x] 6.1 Update the application version to `0.9.9+22`, Launcher to
  `0.9.9.22`, changelog/current README references, and version-consistency tests;
  verify all metadata matches.
- [x] 6.2 Generate the final ZIP and SHA-256 sidecar, verify required Launcher,
  versioned payload, `current-version.txt`, and `version.json` entries, and retain
  only the latest release package.

## Workflow follow-up

- Review the applied change and sync or archive its specifications after merge.
- Commit, push, and publish a Release only when the user explicitly requests it.
