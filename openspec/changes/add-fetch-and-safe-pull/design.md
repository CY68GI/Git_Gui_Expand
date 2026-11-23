# Design

## Context

See `proposal.md`, `specs/repository-sync/spec.md`, and the delta for
`repository-operation-safety`.

The current application already has an ordered operation plan, repository state
snapshots, multi-remote management, non-interactive Git execution, and push.
Fetch is currently used internally before remote-history clearing. Commit runs
`git add -A` and `git commit` without checking effective Git identity.

## Goals / Non-Goals

**Goals:**

- Expose current branch tracking state and make fetch/pull operate through the
  existing preview and confirmation system.
- Keep pull limited to fast-forward updates so no merge commit or conflict state
  is created implicitly.
- Fail before commit if effective Git identity is unavailable.
- Keep the feature usable with existing GitHub/Gitee/GitLab/SSH/HTTPS
  authentication delegated to Git.

**Non-Goals:**

- Merge, rebase, cherry-pick, or conflict editing.
- Choosing an arbitrary remote branch as a temporary pull source.
- Auto-stash or pulling with a dirty worktree/index.
- Force-fetching, force-updating local branches, or rewriting history.
- Setting Git identity from the UI; the first version provides preflight and
  configuration guidance.

## Decisions

### Model synchronization state separately from repository statistics

Add an explicit sync-state model containing:

- current branch or detached state;
- upstream full ref, remote name, and remote branch;
- ahead and behind counts;
- clean/dirty worktree status.

Obtain upstream with `git rev-parse --abbrev-ref @{u}` and counts with
`git rev-list --left-right --count HEAD...@{u}`. Treat missing upstream,
detached HEAD, and Git command errors as distinct states rather than displaying
misleading zero counts.

This keeps synchronization state testable without introducing a Git-history or
graph feature.

### Use a dedicated synchronization dialog

Open the dialog from a compact branch-sync status button in the commit workspace.
Show branch, upstream, ahead/behind, clean/dirty status, and separate actions:

- Fetch current upstream remote;
- Fetch all remotes;
- Pull current branch safely.

The commit-workspace header is already crowded, so a dialog provides room for
explanations and error recovery without reducing the existing file list.

### Fetch and pull are separate planned operations

Fetch current uses `git fetch --prune <remote>`. Fetch all uses
`git fetch --all --prune`. Both run through the operation plan and refresh sync
state after completion.

Pull is a single planned operation with visible behavior:

1. Revalidate current branch, upstream, and clean worktree/index.
2. Fetch the upstream remote with pruning.
3. Recompute ahead/behind state.
4. Refuse if the branch is ahead or diverged.
5. If only behind, run `git merge --ff-only <upstream>`.

Using an explicit fetch followed by explicit fast-forward merge avoids the
configuration-dependent behavior of `git pull`, which may otherwise invoke
merge or rebase according to user settings. A fetch that succeeds before a later
divergence rejection is retained because it only updates remote-tracking refs and
provides current information; the UI reports this outcome explicitly.

Fetch-all is intentionally non-atomic across remotes. It reports per-remote
success and failure, matching existing push-all behavior.

### Pull requires a clean, non-diverged branch

Dirty worktree/index, detached HEAD, missing upstream, or diverged history block
pull before branch mutation. No auto-stash is used because it complicates
recovery and can hide conflicts. The user may stash changes explicitly through
the existing Stash workflow.

The existing operation preconditions recheck branch, upstream, status, and path
state before execution, preventing a stale pull plan from applying after an
external change.

### Validate effective Git identity with `git var`

Add identity readiness based on `git var GIT_AUTHOR_IDENT` and
`git var GIT_COMMITTER_IDENT`. These commands honor the effective Git
configuration and environment, unlike querying only `git config user.name` and
`user.email`.

Check identity before a commit is queued and again at the start of commit
execution, before `git add -A`. If missing, show localized setup guidance for
repository-local or global configuration and keep staging/history unchanged.

The first iteration does not edit Git config. That keeps this change focused on
predictable failure prevention; a dedicated identity editor can later reuse the
same readiness model.

## Risks / Trade-offs

- **Pull becomes stricter than command-line Git** -> The restriction is explicit
  and prevents accidental merge/conflict states; merge and rebase remain future
  features.
- **Fetch-all can be partially successful** -> Report each remote result and
  retain successful fetch updates; never claim all remotes succeeded.
- **A safe pull may fetch successfully but refuse a diverged merge** -> Explain
  that remote-tracking refs were refreshed and worktree/branch were not changed.
- **Large repositories may take time to compare ahead/behind** -> Compute only
  when the sync dialog or operations refresh state, not on every file-row render.
- **Git identity can change after planning** -> Revalidate at execution before
  staging or commit creation.
- **Remote names or branch names containing slashes complicate parsing** ->
  Resolve the full upstream ref from Git and split only the first path segment
  as the remote name.

## Migration Plan

1. Add read-only sync-state and identity-state models.
2. Add Fetch/Pull operation kinds and controller integration.
3. Add the synchronization dialog and commit-workspace entry point.
4. Add commit identity preflight without changing existing settings formats.
5. Update localization, logs, README, guides, and tests.
6. No stored-data migration or rollback is required; removing the feature leaves
   existing Git repositories unchanged.
