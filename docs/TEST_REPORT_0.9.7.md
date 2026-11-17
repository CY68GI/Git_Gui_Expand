# Git GUI Expand 0.9.7 Test Report

## Test repository

- Local repository:
  `C:\Data\ChatGPT_Files\ChatGPT_Codex_Files\Git_GUI_Expand_Test_Repository`
- Remote:
  `git@github.com:CY68GI/Git_Gui_Expand_Test_Repository.git`
- Branch: `main`
- Current content commit: `9cec0b6`
- Parent empty commit after destructive testing: `d21be4e`

## Automated results

- `flutter analyze`: passed with no issues.
- Full automated test suite: 75 tests passed.
- Windows Release build: passed.
- Release startup from the test repository path: remained healthy for 10 seconds.
- Live GitHub/Gitee latest-release checks: both sources reachable.

## Feature coverage

| Area | Tested behavior | Result |
| --- | --- | --- |
| Repository opening | Open repository, detect `main`, read status | Passed |
| Explorer | Enumerate tracked and untracked files/folders | Passed |
| Statistics | Repository and file-size calculation | Passed |
| File operations | Copy, move, rename, tracked/untracked delete | Passed |
| Commit | Stage all, unstage, commit and commit message | Passed |
| Operation plan | Queue before execution, confirm, failure stops remaining steps | Passed |
| Branches | Create, switch, rename, safe/force delete | Passed |
| Stash | Create, list, apply, pop, drop, include untracked files | Passed |
| Remote management | List, add, update, remove and recognize remotes | Passed |
| Push | Push current branch to configured local test remote | Passed |
| Clone | Clone test repository through software Git service | Passed |
| Init | Initialize an isolated empty folder with `git init` | Passed |
| Remote clearing | Atomic history clear in isolated test remotes | Passed |
| Clear Git metadata | Allowed only with no remote; denied with a remote | Passed |
| Update sources | GitHub and Gitee endpoints and SHA-256 asset parsing | Passed |
| Settings | Languages, fonts, themes, color schemes and unit settings | Passed |
| Logs | Normal/detailed logs and selected log language | Passed |
| Desktop shortcut | Create a Windows `.lnk` in isolated desktop folder | Passed |
| Installation maintenance | Remove old versions/update archives and preserve `userdata` | Passed |
| Launcher migration | Old Launcher starts new version and self-updates after exit | Passed |

## Safety notes

- Remote history clearing was performed against the public test repository after
  creating extra test branches and tags.
- Git metadata clearing was performed against the local test repository after
  removing its remote configuration.
- The test repository was then reinitialized on top of the remote empty commit,
  connected to `origin`, and populated with test files, screenshots and reports.
