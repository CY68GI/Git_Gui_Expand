# Git GUI Expand

<img src="assets/icons/app_icon.png" alt="Git GUI Expand icon" width="96">

English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

[![Windows Release](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml/badge.svg)](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml)
![platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D4)
![license](https://img.shields.io/badge/license-MIT-blue)

Git GUI Expand is a Windows-first Flutter desktop application for working with
an existing Git repository through a dual-pane file workspace. File and history
changes run through the local Git CLI; the application is a visual layer over
Git rather than a replacement implementation.

Current version: `0.9.5`

- GitHub: <https://github.com/CY68GI/Git_Gui_Expand>
- Gitee: <https://gitee.com/CY68EWZRY/Git_Gui_Expand>

## Features

- Open a repository with the native Windows **Open** dialog.
- Reopen verified Git repositories from the recent-repository list.
- Browse the same repository in independent left and right panes.
- Select files and folders with checkboxes and perform batch operations.
- Cut, copy, paste, rename, move, and delete through Git commands.
- Review every repository mutation in a pending operation plan before execution.
- Stage, unstage, commit, push, and manage multiple remotes.
- Manage GitHub, Gitee, GitLab, Bitbucket, and generic Git remotes.
- Clear a selected remote history with an atomic empty-root commit after an
  explicit project/branch confirmation.
- Open a selected file in File Explorer or with its default application.
- Show project size, file size, branch, status, and pending changes.
- Switch between IEC/SI size units and byte/bit base units.
- Use light, dark, or operating-system display mode with Emerald, Ocean,
  Violet, Amber, and Rose color schemes.
- Search bundled and installed UI fonts, with a safe 90%–100%–110% text scale.
- Use English, Simplified Chinese, or Traditional Chinese, or follow the
  operating-system language.
- Record normal and detailed logs in the selected interface language.
- Create a desktop shortcut from **Settings → About**.
- Use automatic updates through a stable Launcher and isolated version
  directories, with startup health checks and rollback.
- Keep only the current version after a successful update and remove downloaded
  update packages and staging files.

## Git feature coverage

Legend: `✅` implemented in the application, `❌` not currently implemented.

| Git capability | Status | Notes |
| --- | --- | --- |
| Open an existing initialized repository | ✅ | Native Windows picker and recent-repository history |
| `git init` | ❌ | The app opens existing repositories only |
| `git clone` | ❌ | Not implemented |
| `git status` | ✅ | Branch, staged, unstaged, and untracked state |
| List tracked and untracked files | ✅ | `.gitignore`-aware enumeration |
| Selective staging / hunk staging | ❌ | Staging is currently all-or-nothing |
| `git add -A` / stage all | ✅ | Planned and confirmed before execution |
| Unstage all | ✅ | Keeps workspace file contents |
| `git commit` / commit all changes | ✅ | Commit message and confirmation required |
| Amend, sign-off, GPG-signed commits | ❌ | Not implemented |
| Diff viewer / hunk editor | ❌ | File status is shown without a diff editor |
| `git mv` / rename and move | ✅ | Files and folders |
| Copy through Git objects and index | ✅ | Git has no native `git cp` |
| `git rm` / `git clean` deletion | ✅ | Dangerous confirmation required |
| Display current branch | ✅ | Shown in the commit workspace |
| Create, switch, rename, delete branches | ❌ | Only the current branch is displayed |
| Merge, rebase, cherry-pick | ❌ | Not implemented |
| Reset, revert, restore UI | ❌ | Internal reset is used only by remote-history clearing |
| `git stash` | ❌ | Not implemented |
| Create, delete, or push tags | ❌ | Release tags are managed outside the UI |
| Git log, graph, blame, reflog | ❌ | Application logs are not Git history |
| Git grep / bisect | ❌ | Not implemented |
| Merge conflict editor | ❌ | Not implemented |
| List/add/edit/remove remotes | ✅ | Multiple platform remotes |
| Push current branch | ✅ | One or all remotes; upstream is configured |
| Fetch and pull | ❌ | Internal fetch is only used before remote clearing |
| Clear remote history | ✅ | Atomic empty-root replacement after strong confirmation |
| SSH/HTTPS authentication | ✅ | Delegated to the installed Git credential system |
| Submodules, worktrees, sparse checkout | ❌ | Not implemented |
| Git LFS | ❌ | Not implemented |
| Hooks editor | ❌ | Not implemented |
| Archive / bundle / fsck / gc UI | ❌ | Not implemented |

## Requirements

- Windows 10 or Windows 11
- Git 2.40 or newer
- Flutter 3.47.x and Dart 3.13.x for source builds
- Visual Studio with the **Desktop development with C++** workload

Linux and macOS directories are reserved for future work and are not currently
built or verified.

## Build and test

```powershell
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

The Flutter build output is:

```text
build\windows\x64\runner\Release\
```

Create the distributable ZIP with:

```powershell
.\tool\package_windows_release.ps1 -Tag v0.9.5
```

## Release layout

```text
Git GUI Expand/
  GitGuiExpandLauncher.exe
  current-version.txt
  versions/
    0.9.5/
      git_gui_expand.exe
      flutter_windows.dll
      data/
      version.json
  userdata/
    settings.json
    recent_repositories.json
    logs/
      normal-YYYY-MM-DD.log
      detailed-YYYY-MM-DD.log
    updates/
      launcher.log
```

Always start the distributed application with `GitGuiExpandLauncher.exe`.
The Launcher validates the version marker and payload, repairs a missing current
version from a valid `versions/<version>` directory, and also supports a flat
development/release directory containing `git_gui_expand.exe` beside `data`.

All application data remains under the software directory in `userdata`.
The software directory must be writable; extracting under `Program Files` may
require additional permissions.

## Operation safety

File moves, copies, renames, deletes, commits, pushes, remote changes, and remote
history clearing are first added to the operation plan. Nothing is executed
until the plan is confirmed. Dangerous steps require explicit confirmation;
remote history clearing additionally requires
`remote-owner/project/branch` to be typed exactly.

Git commands are executed without shell string concatenation. Protected
branches, authentication failures, network failures, and servers that do not
support atomic push are reported as failures rather than being treated as
successful operations.

## Updates

The Launcher downloads and verifies a Windows x64 ZIP, extracts the new version
to `versions/<version>`, and switches versions after the running application
exits. A new version that does not stay alive for the startup health check is
rolled back automatically.

After a successful update, only the current version is retained. All older
version directories, downloaded update ZIPs, partial downloads, and staged
extraction folders are removed. Settings, logs, recent repositories, and other
`userdata` files are shared across versions.

Release notes are generated from the previous Git tag to the current tag and are
provided in English, Simplified Chinese, and Traditional Chinese.

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [简体中文使用指南](docs/USER_GUIDE.zh-CN.md)
- [繁體中文使用指南](docs/USER_GUIDE.zh-TW.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Interaction design](docs/UX.md)

## Acknowledgements

Thanks to DeepSeek AI and ChatGPT Codex for jointly creating, writing, and
improving this project.

## License

This project is licensed under the [MIT License](LICENSE).
