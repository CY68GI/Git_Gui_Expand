# Spec Delta

## Purpose

Lets users inspect branch tracking state, fetch remote updates, and safely
fast-forward the current branch without creating undocumented merge commits.

## ADDED Requirements

### Requirement: Current branch synchronization state is visible

The system SHALL display the current branch's upstream, ahead count, and behind
count, and MUST distinguish a branch without an upstream from a detached HEAD.

#### Scenario: Branch has an upstream

- **WHEN** the current branch tracks a remote branch
- **THEN** the system shows the upstream name and the number of local commits
  ahead and remote commits behind

#### Scenario: Branch has no upstream

- **WHEN** the current branch has no configured upstream
- **THEN** the system explains that fetch and pull cannot use an upstream until
  one is configured

#### Scenario: Repository is on detached HEAD

- **WHEN** the repository has no current branch
- **THEN** the system reports detached HEAD and disables branch pull actions

### Requirement: Fetch operations use the operation plan

The system SHALL preview and plan fetching the current upstream remote or all
configured remotes before changing remote-tracking refs.

#### Scenario: Fetch current upstream

- **WHEN** the user confirms a planned fetch for the current upstream remote
- **THEN** the system runs a non-interactive Git fetch with pruning and refreshes
  synchronization state after completion

#### Scenario: Fetch all remotes

- **WHEN** the user confirms a planned fetch-all operation
- **THEN** the system attempts every configured remote, reports per-remote
  success or failure, and refreshes state with the successful updates retained

#### Scenario: Authentication or network failure

- **WHEN** Git cannot authenticate or reach a selected remote
- **THEN** the system reports a localized failure with raw Git diagnostics and
  does not claim that synchronization succeeded

### Requirement: Pull is fast-forward only

The system SHALL update the current branch only when the remote branch is a
direct descendant and MUST NEVER create an automatic merge commit.

#### Scenario: Branch is behind and not ahead

- **WHEN** fetch shows the current branch behind its upstream and no local
  commits ahead
- **THEN** the system performs a fast-forward-only update and refreshes files,
  status, branch state, and synchronization counts

#### Scenario: Histories have diverged

- **WHEN** the current branch has both local and remote commits that are not in
  the other history
- **THEN** the system refuses pull before changing the branch and explains that
  merge or rebase must be handled separately

### Requirement: Pull has explicit safety preconditions

The system MUST require a current branch, configured upstream, and clean
worktree and index before performing pull.

#### Scenario: Worktree or index is dirty

- **WHEN** a pull is requested with uncommitted or staged changes
- **THEN** the system refuses the operation without modifying files or refs

#### Scenario: Branch is already synchronized or ahead

- **WHEN** the branch has no commits behind its upstream
- **THEN** the system reports that no pull is needed and does not mutate the
  repository

#### Scenario: Preconditions change before execution

- **WHEN** branch, upstream, worktree state, or divergence changes after the pull
  preview is created
- **THEN** the system rejects the stale pull plan before changing the branch
