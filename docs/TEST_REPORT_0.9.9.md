# Git GUI Expand 0.9.9 Test Report

## Automated verification

- `flutter analyze`: passed with no issues.
- Full Flutter test suite: 123 tests passed.
- Repository synchronization tests cover:
  - upstream/ahead/behind and dirty state;
  - current-upstream and all-remote fetch;
  - prune and partial fetch-all failure;
  - fast-forward Pull;
  - up-to-date, ahead, diverged, dirty, detached, and missing-upstream rejection;
  - fetch-then-divergence rejection without worktree or branch mutation.
- Git identity tests cover effective identity parsing, missing identity, commit
  planning rejection, execution-time recheck before staging, localized logs, and
  setup commands.
- Synchronization dialog widget tests and 90%, 100%, 110% golden layouts passed.

## Live verification

- Isolated bare-remote live Fetch and fast-forward Pull test passed.
- Dirty worktree Pull rejection passed.
- Windows Release startup from the test repository path remained healthy for
  10 seconds.

## Build verification

- Application version: `0.9.9+22`.
- Launcher version: `0.9.9.22`.
- Release package contains the stable Launcher, versioned payload,
  `current-version.txt`, `version.json`, and maintenance Launcher.

## Package

- File: `Git_Gui_Expand-v0.9.9-windows-x64.zip`
- SHA-256:
  `999b0cdc994ac08247d1c18a8ddbc5b0d69bf8c82c98dc27cb6e8e5c4f7142b4`
