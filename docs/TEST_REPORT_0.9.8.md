# Git GUI Expand 0.9.8 Test Report

## Automated verification

- `flutter analyze`: passed with no issues.
- Full Flutter test suite: 98 tests passed.
- Golden layout checks cover operation-plan drift recovery at 90%, 100%, and
  110% text scale.
- Version consistency test confirms `0.9.8+21` across the app, package metadata,
  Launcher resource, changelog, and built-in changelog.

## Live verification

- Live test-repository smoke test: passed.
- Opt-in destructive Git workflow test: passed.
  - File operations, commit, branch force deletion, Stash deletion, push,
    remote ref drift rejection, atomic remote clearing, backups, `.git` metadata
    removal, and retained working files were exercised.
- GitHub and Gitee latest-release endpoints: reachable.

## Build verification

- Windows Release build: passed.
- Release package contains:
  - `GitGuiExpandLauncher.exe`
  - `current-version.txt`
  - `versions/0.9.8/git_gui_expand.exe`
  - `versions/0.9.8/data/app.so`
  - `versions/0.9.8/version.json`
  - maintenance Launcher
- Application version: `0.9.8+21`.
- Launcher version: `0.9.8.21`.
- Release startup from the test repository path remained healthy for 10 seconds.

## Package

- File: `Git_Gui_Expand-v0.9.8-windows-x64.zip`
- SHA-256:
  `d85d8245a8ec5241b98d5126abc5d1995bec9a9d78317ca5da94251e9d0ee3bf`
