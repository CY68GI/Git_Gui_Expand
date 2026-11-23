# Design

## Context

See `proposal.md` and
`specs/repository-operation-safety/spec.md`.

`RepositoryController` already owns an ordered in-memory plan for an opened
repository. `GitService` performs final path and Git validation, but bootstrap
commands and `.git` removal bypass the plan. Remote clearing captures refs when
the preview is created and later pushes with unconditional `--force`.

The application is single-user and has one in-flight operation guard, but files
and remote repositories can still be changed by external tools. Git CLI offers
atomic multi-ref pushes only for refs included in the push, not a repository-wide
cross-process lock.

## Goals / Non-Goals

**Goals:**

- Give opened-repository mutations and repository bootstrap actions one
  observable preview/confirm/execute contract.
- Detect local or destination drift before a confirmed action starts.
- Prevent lifecycle operations from leaving invalid later plan steps.
- Use remote lease checks so a changed known ref aborts remote clearing before
  replacement.
- Keep existing local data and settings compatible.

**Non-Goals:**

- Automatically watch the filesystem or remote and refresh plans in real time.
- Persist unfinished plans across application restarts.
- Add rollback for ordinary successful local Git commands.
- Implement merge, rebase, selective staging, pull, or other unlisted Git UI.
- Bypass protected branches or platform authentication restrictions.

## Decisions

### Use one operation contract with two execution hosts

Every mutating action will be represented as a previewable operation containing
an ID, localized title/description, danger metadata, exclusivity metadata,
operation-specific preconditions, and an execute callback.

Actions for an opened repository remain in `RepositoryController`. Actions that
create or discard repository context use a one-step bootstrap plan owned outside
the current repository state. Both hosts use the same plan presentation and
confirmation semantics.

This avoids pretending that `git init` or `git clone` can be queued against a
repository that does not exist yet, while still giving them the same safety
workflow. The alternative, forcing every action into `RepositoryController`,
would mix lifecycle state with repository state and make failure recovery less
clear.

### Revalidate plan-start state and operation-specific state

At confirmation time, the system refreshes the data on which the preview was
based. Repository actions compare canonical root, branch, HEAD or unborn state,
normalized Git status, and relevant remote configuration. Bootstrap actions
compare parent existence, destination absence/emptiness, and absence or
presence of `.git` as appropriate.

The whole plan is rejected before the first mutation if plan-start state drifted.
Each later step is validated against the state expected immediately before that
step, including effects intentionally produced by earlier steps. This preserves
valid sequences such as rename followed by commit without weakening local path
checks.

The alternative of checking every step against the original queue-time snapshot
would reject legitimate dependent steps. The alternative of only validating
inside Git commands would not give the user a clear explanation before work
starts.

### Keep preconditions operation-specific

File operations validate selected path existence, type, and repository
boundary. Commit and push validate branch/HEAD/status. Branch and Stash
operations validate names/selectors and relevant refs. Remote configuration
validates the remote set and URL. Metadata removal validates `.git` entity type
and an empty remote list immediately before deletion.

Status uses the existing NUL-delimited porcelain parser. Previews avoid volatile
timestamps and display-only formatting so harmless UI changes do not cause
false drift.

### Make context-invalidating operations exclusive

`.git` metadata removal can only be queued when the plan is empty, and no later
operation may be added. On success the controller closes the repository and
retains working files. Bootstrap operations are one-step plans by construction.

This is stricter than ordinary remote configuration changes because deleting
metadata invalidates every subsequent Git command for that context.

### Use atomic per-ref leases for remote clearing

Remote clearing will keep the existing backup refs, empty-tree/empty-root-commit
creation, and post-push verification. Immediately before the push it will
re-read the remote refs and compare the exact ref-to-object map with the
confirmed preview.

The push will include `--atomic` plus `--force-with-lease=<ref>:<expected-oid>`
for the target branch and every deleted branch/tag. Any changed known ref
therefore aborts the complete atomic push. Drift produces a refreshed preview
and no replacement attempt.

Git cannot lock refs that do not exist at preflight time, so an unknown ref
created in the final network window cannot be part of that transaction.
Post-push verification will still detect unexpected refs and preserve the
backup refs for recovery. Automatically rolling such a case back would perform a
second high-risk remote mutation and is outside this change.

### Keep plans in memory and rebuild on drift

Plans remain in memory with the existing clear/remove behavior. A safety
rejection leaves the plan available for inspection but requires the user to
refresh or rebuild it before another execution attempt.

Persisting partially executed plans would require durable conversation logs,
expired remote hashes, and recovery semantics that are not justified by this
change.

## Risks / Trade-offs

- **Remote changes can arrive after the last preflight read** -> Use leases for
  every known ref, atomic push, post-push verification, and retained backups.
- **More Git reads increase execution latency** -> Revalidate once per plan
  start and use targeted checks per step rather than rescanning the entire
  repository tree.
- **Strict status comparison may reject harmless external changes** -> Compare
  normalized Git-observable state, explain the drifted field, and let the user
  refresh/replan.
- **Bootstrap confirmation adds one more step** -> Use a compact one-step plan
  and preserve automatic repository opening after success.
- **Lifecycle and opened-repository plans could diverge** -> Share the same
  operation model, dialog components, outcome types, and tests.

## Migration Plan

1. Add the common operation contract and precondition result types without
   changing existing user settings or data files.
2. Migrate opened-repository actions, including metadata removal, to the common
   validation flow.
3. Move initialization and clone through one-step bootstrap plans.
4. Replace remote clearing's forced push with atomic per-ref leases.
5. Update localized UI text, guides, architecture notes, and tests.
6. If the release must be withdrawn, revert to the previous application version
   through the existing Launcher; no stored data migration rollback is needed.
