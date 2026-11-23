# Spec Delta

## Purpose

Provides a consistent safety contract for previewing, confirming, validating,
and auditing every Git operation that can change a repository or its remote
history.

## ADDED Requirements

### Requirement: All mutating operations have a preview

The system SHALL present a user-visible preview before executing any operation
that can change worktree files, Git metadata, refs, remotes, branches, Stashes,
history, or a repository-creation destination.

#### Scenario: Queue an opened-repository mutation

- **WHEN** the user requests a file, commit, push, branch, Stash, remote, or
  remote-history mutation
- **THEN** the system shows the planned effect and makes no repository change
  until the user confirms execution

#### Scenario: Preview a repository bootstrap action

- **WHEN** the user requests `git init`, `git clone`, or `.git` metadata removal
- **THEN** the system shows the target path and resulting repository lifecycle
  change before execution

### Requirement: Confirmation is explicit and single-use

The system MUST require explicit confirmation for every previewed operation and
MUST NOT execute a confirmed operation more than once.

#### Scenario: Cancel a preview

- **WHEN** the user cancels a preview or closes the confirmation without
  approving it
- **THEN** the system leaves the repository and destination unchanged

#### Scenario: Confirm a preview

- **WHEN** the user approves a valid preview
- **THEN** the system executes that preview once and reports the final outcome

### Requirement: Execution preconditions are revalidated

Before the first mutation of each operation, the system SHALL revalidate the
state on which its preview depended. If any relevant state has changed, the
system MUST stop the operation before mutation and present a refreshed preview.

#### Scenario: Local repository state changes after planning

- **WHEN** repository identity, current branch, HEAD, index state, worktree
  state, or selected paths differ from the planned preconditions
- **THEN** the operation is rejected without changing repository content and the
  user is told which state changed

#### Scenario: Destination state changes after planning

- **WHEN** an initialization or clone destination is no longer absent or empty,
  or its parent no longer exists
- **THEN** the bootstrap operation is rejected without creating or overwriting
  repository content

#### Scenario: Preconditions still match

- **WHEN** all relevant local and destination preconditions match the preview
- **THEN** the system proceeds with the confirmed operation

### Requirement: Repository lifecycle operations are exclusive

Operations that invalidate the currently opened repository context MUST execute
as the only step in their plan. After successful `.git` metadata removal, the
system SHALL close the repository view and retain the working files.

#### Scenario: Clear metadata with other planned work

- **WHEN** `.git` metadata removal is requested while another operation is
  planned
- **THEN** the system refuses to add the lifecycle operation to that plan

#### Scenario: Clear metadata as a solo operation

- **WHEN** the user confirms an isolated `.git` metadata removal and the
  repository still has no remotes
- **THEN** the system removes only the eligible metadata, closes the repository
  view, and reports that working files were retained

### Requirement: Remote history clearing rejects stale refs

Remote history clearing SHALL refresh the selected remote's branch, tag, and
target-commit state immediately before pushing. The system MUST use atomic
per-ref lease protection and MUST reject drifted remote state before replacing
the target branch.

#### Scenario: Remote refs change after preview

- **WHEN** any planned branch, tag, or target commit differs from the refreshed
  remote state
- **THEN** the push is rejected before target replacement and the user receives
  a refreshed remote preview

#### Scenario: Remote state remains unchanged

- **WHEN** the refreshed refs match the confirmed remote preview
- **THEN** the system performs the atomic leased replacement, verifies that
  only the documented empty history remains, and reports the result

### Requirement: Safety decisions are auditable

The system SHALL record every preview, safety rejection, execution start,
completion, and failure in both applicable normal and detailed logs using the
current interface language, while preserving raw Git output for diagnosis.

#### Scenario: Reject stale state

- **WHEN** execution is rejected because preconditions changed
- **THEN** the user receives a localized explanation and the logs identify the
  operation, changed precondition, and rejection without exposing credentials

#### Scenario: Finish an approved operation

- **WHEN** an approved operation completes or fails
- **THEN** the logs record the final status and any remaining unexecuted steps
