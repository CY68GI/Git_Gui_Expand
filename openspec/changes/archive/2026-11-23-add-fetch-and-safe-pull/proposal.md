# Proposal

## Why

Git GUI Expand can commit and push, but it cannot fetch or pull remote updates,
so the normal synchronization loop remains incomplete. Commit execution also
relies on Git identity being configured externally and fails late when
`user.name` or `user.email` is missing.

## What Changes

- Add a repository synchronization view showing the current upstream, ahead
  count, and behind count.
- Add planned fetch operations for the current upstream remote and for all
  remotes, including prune behavior and authentication/network error reporting.
- Add a safe pull operation that fetches the current upstream and updates the
  branch only through a fast-forward operation.
- Refuse pull for detached HEAD, missing upstream, dirty worktree/index, or
  diverged local/remote history. Do not create merge commits and do not add a
  conflict-resolution interface in this change.
- Add commit identity preflight for effective Git author and committer identity.
  Missing identity blocks the commit before it enters the plan and is checked
  again immediately before execution.
- Add localized UI, normal/detailed logs, update the three user guides and README
  feature matrix, and cover the workflows with unit, repository, widget, and
  live-upstream tests.

## Capabilities

### New Capabilities

- `repository-sync`: Covers upstream tracking information, fetch operations, and
  safe fast-forward-only branch synchronization.

### Modified Capabilities

- `repository-operation-safety`: Adds commit-identity readiness as a required
  precondition before a commit can be planned or executed.

## Impact

- `GitService` gains synchronization-state, fetch, safe-pull, upstream, and
  identity-reading APIs.
- `RepositoryController` gains synchronization state, fetch/pull planning, and
  commit identity preflight.
- Commit workspace or a dedicated synchronization dialog gains ahead/behind,
  fetch, pull, and identity status.
- Existing operation-plan, localization, logging, README, guides, and tests are
  extended.
- No new package dependency is required.
- Merge, rebase, cherry-pick, conflict resolution, and arbitrary upstream
  selection are out of scope.
