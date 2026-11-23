# Tasks

## 1. Shared Operation Safety Model

- [x] 1.1 Add shared operation precondition and validation-result models that
  support normalized local state, bootstrap paths, remote ref maps, exclusivity,
  and localized drift details; verify with unit tests for equality and
  human-readable drift summaries.
- [x] 1.2 Refactor the operation-plan presenter to accept the shared plan model
  without assuming an already-open repository; verify existing operation-plan
  widget tests still pass and add a presenter test for cancel/confirm behavior.
- [x] 1.3 Add normal/detailed logging for preview creation, precondition
  rejection, execution start, completion, and failure; verify tests confirm
  localized log text and unchanged raw Git diagnostics.
- [x] 1.4 Add English, Simplified Chinese, and Traditional Chinese strings for
  preview validation, drift descriptions, lifecycle exclusivity, and remote
  lease rejection; verify `AppLocalizations.validateTranslations()` and widget
  tests cover the new messages.

## 2. Opened-Repository Revalidation

- [x] 2.1 Implement a GitService state snapshot for canonical root, branch,
  HEAD or unborn state, normalized status, remote set, and selected-path types;
  verify snapshots ignore display-only differences and detect repository,
  branch, HEAD, index, worktree, path, and remote drift.
- [x] 2.2 Validate the plan-start snapshot before the first planned mutation and
  reject the whole plan without running any step when drift is detected; verify
  with tests where an external file change and branch switch each block a queued
  rename or commit.
- [x] 2.3 Validate later steps against the state expected immediately after
  prior planned steps; verify a rename followed by commit still succeeds while
  an unrelated external change between steps stops execution and preserves
  remaining steps.
- [x] 2.4 Migrate `.git` metadata removal into an exclusive planned operation
  that rechecks metadata entity type and the absence of remotes at execution;
  verify it cannot be queued with other steps and closes the repository while
  retaining working files after success.
- [x] 2.5 Update the operation-plan UI to show refreshed drift details and a
  clear "rebuild or refresh plan" recovery action; verify with widget and
  golden-layout tests at 90%, 100%, and 110% text scale.
- [x] 2.6 Update the three user guides and the README feature text to explain
  plan-time preview, execution-time drift rejection, metadata exclusivity, and
  recovery; verify every documented workflow matches the implemented button and
  dialog flow.

## 3. Bootstrap Operation Plans

- [x] 3.1 Add a one-step bootstrap plan for `git init` with target-path preview,
  explicit confirmation, parent/existence checks, and `.git` absence checks;
  verify cancel creates nothing and confirm initializes and opens the repository
  exactly once.
- [x] 3.2 Revalidate the initialization destination immediately before
  mutation; verify a `.git` folder created after confirmation causes rejection
  without altering the folder.
- [x] 3.3 Move cloning onto a one-step bootstrap plan that previews URL,
  destination, and existing-content behavior; verify cancel creates no files,
  and a successful clone opens the new repository.
- [x] 3.4 Revalidate clone parent, destination emptiness, and URL before
  execution; verify a destination populated after confirmation is rejected
  without overwriting files.
- [x] 3.5 Update bootstrap localization and the three user guides; verify widget
  tests cover initialization and clone preview, cancel, confirmation, and stale
  destination messages.

## 4. Remote History Lease Safety

- [x] 4.1 Extend remote-clear previews with the exact ref-to-object map required
  for lease arguments; verify current branch/tag inventories and target commit
  hashes are preserved in the preview.
- [x] 4.2 Re-read the remote immediately before clearing and compare the exact
  ref map with the confirmed preview; verify a changed target commit, changed
  tag, added branch, removed branch, or changed ref target is rejected before
  the empty-history push starts.
- [x] 4.3 Replace unconditional forced push with `--atomic` and one
  `--force-with-lease=<ref>:<expected-oid>` per target/deleted ref; verify local
  bare-remote tests inspect the generated command and confirm changed known refs
  abort without replacement.
- [x] 4.4 Keep backup refs and post-push verification, then surface unexpected
  last-window refs as a recoverable failure without automatically performing a
  second destructive rollback; verify the reported backup refs can restore the
  original remote state.
- [x] 4.5 Update remote-clear UI text, logs, architecture documentation, three
  user guides, and README notes; verify tests cover refreshed previews,
  localized rejection details, and protected-branch guidance.

## 5. Integration Verification

- [x] 5.1 Run `flutter analyze` and verify there are no analyzer issues.
- [x] 5.2 Run the full automated Flutter test suite and verify all tests pass,
  including new drift, bootstrap, exclusivity, localization, and remote-lease
  cases.
- [x] 5.3 Run the opt-in live repository and destructive Git tests against an
  isolated test repository and verify remote refs, backups, Stashes, branches,
  metadata removal, and local working files end in the documented state.
- [x] 5.4 Build and package the Windows release, launch it from the test
  repository path, and verify startup health, preview dialogs, logging, and
  version metadata.

## 6. Release Readiness

- [x] 6.1 Update application, Launcher, and package version metadata together
  with the three changelogs/README version references; verify a version-consistency
  test reports no mismatch.
- [x] 6.2 Run release packaging and verify the ZIP contains the Launcher,
  versioned payload, `current-version.txt`, `version.json`, and matching SHA-256
  sidecar.

## Workflow follow-up

- Review the applied change and sync or archive its specification after merge.
- Commit, push, and publish a Release only when the user explicitly requests it.
