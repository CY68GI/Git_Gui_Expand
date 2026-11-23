# Proposal

## Why

Git GUI Expand already queues most repository changes, but repository bootstrap
and `.git` metadata removal execute through separate confirmation paths. The
remote-history clear flow also trusts a preview snapshot that may become stale
before execution, so concurrent remote changes can be discovered only after
some refs have already been replaced.

This change establishes one consistent safety contract: every mutating Git
action is previewed, confirmed, and checked against current state immediately
before any mutation begins.

## What Changes

- Introduce a unified operation-preview and execution model for file changes,
  commit/push, branch and Stash operations, remote configuration, remote-history
  clearing, `git init`, `git clone`, and `.git` metadata removal.
- Preserve the existing ordered operation plan for an opened repository and add
  a bootstrap plan for actions that create or discard the repository context.
- Capture operation-specific preconditions when an action is planned and refresh
  them before execution. If repository identity, branch, HEAD, index/worktree
  state, destination state, or relevant remote refs have changed, stop before
  mutating anything and explain what changed.
- Make lifecycle operations that invalidate the current repository context
  exclusive plan steps. Clearing `.git` metadata must run alone and close the
  repository after success.
- Re-read the selected remote's refs immediately before remote-history clearing.
  Use per-ref lease protection together with an atomic push so a changed branch,
  tag, or target commit causes the operation to fail before replacement.
- Treat remote drift as a normal safety rejection with a refreshed preview;
  never silently force through a stale plan.
- Record preview, validation rejection, execution start, completion, and failure
  in normal/detailed logs using the current interface language.
- Add automated coverage for stale local state, stale remote refs, exclusive
  lifecycle operations, bootstrap confirmation, and metadata-clear revalidation.

## Capabilities

### New Capabilities

- `repository-operation-safety`: Defines the common preview, confirmation,
  execution-precondition, exclusivity, failure, and audit behavior for all
  mutating repository operations.

### Modified Capabilities

None.

## Impact

- `RepositoryController` operation-plan state and execution flow.
- `GitService` mutation APIs, precondition snapshots, remote ref clearing, and
  repository bootstrap commands.
- Start-page initialization/clone flows, metadata-clear dialog, operation-plan
  dialog, and related status/error presentation.
- Localization strings, user guides, architecture documentation, and tests.
- No new runtime dependency is required.
- Existing settings and local data formats remain compatible.
