# Git GUI Expand

<img src="assets/icons/app_icon.png" alt="Git GUI Expand icon" width="96">

English | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

[![Windows Release](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml/badge.svg)](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml)
![platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D4)
![license](https://img.shields.io/badge/license-MIT-blue)

## Screenshots

| Main page | Operation plan |
| --- | --- |
| <img src="docs/images/start-page.png" width="480" alt="Main page"> | <img src="docs/images/operation-plan.png" width="480" alt="Operation plan"> |

| Remote management | Appearance settings |
| --- | --- |
| <img src="docs/images/remote-management.png" width="480" alt="Remote management"> | <img src="docs/images/appearance-settings.png" width="480" alt="Appearance settings"> |

Git GUI Expand is a Windows-first Flutter desktop application for working with
an existing Git repository through a dual-pane file workspace. File and history
changes run through the local Git CLI; the application is a visual layer over
Git rather than a replacement implementation.

Current version: `0.10.0`

- GitHub: <https://github.com/CY68GI/Git_Gui_Expand>
- Gitee: <https://gitee.com/CY68EWZRY/Git_Gui_Expand>

## Features

- Open a repository with the native Windows **Open** dialog.
- Open an empty folder and optionally run `git init` immediately.
- Clone a repository from HTTPS, SSH, or a local Git URL.
- Clear `.git` metadata only for repositories without any configured remote;
  working files are preserved and the destructive consequences are explained.
- Reopen verified Git repositories from the recent-repository list.
- Browse the same repository in independent left and right panes.
- Select files and folders with checkboxes and perform batch operations.
- Cut, copy, paste, rename, move, and delete through Git commands.
- Review every repository mutation in a pending operation plan before execution.
- Revalidate repository, path, and remote state before execution; stale plans stop
  with a localized drift summary and recovery action.
- Stage, unstage, commit, push, manage multiple remotes, and create, switch,
  rename, or delete local branches.
- Validate effective Git author/committer identity before commit planning and
  again before staging or commit creation.
- Inspect upstream ahead/behind state and fetch the current upstream or all
  remotes through the operation plan.
- Safely Pull only clean, non-diverged branches through fetch followed by
  `git merge --ff-only`; no automatic merge commit is created.
- Create, list, apply, pop, and drop Git stashes.
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
- Show the actual executable versions of `git_gui_expand` and
  `GitGuiExpandLauncher` in **Settings → About**.
- Scan and one-click clean old versions and downloaded installers from
  **Settings → About**.
- Use automatic updates through a stable Launcher and isolated version
  directories, with startup health checks and rollback.
- Keep only the current version after a successful update and remove downloaded
  update packages and staging files.

## Git feature coverage

Legend: `✅` implemented in the application, `❌` not currently implemented.

| Git capability | Status | Notes |
| --- | --- | --- |
| Open an existing initialized repository | ✅ | Native Windows picker and recent-repository history |
| `git init` | ✅ | One-step preview, target revalidation, explicit confirmation |
| `git clone` | ✅ | Preview dialog, destination revalidation, explicit confirmation |
| Remove Git metadata (`.git`) | ✅ | Exclusive planned step; only when no remote is configured; working files remain |
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
| Create, switch, rename, delete branches | ✅ | Planned locally before execution |
| Merge, rebase, cherry-pick | ❌ | Not implemented |
| Reset, revert, restore UI | ❌ | Internal reset is used only by remote-history clearing |
| `git stash` | ✅ | Create, apply, pop, drop, and include untracked files |
| Create, delete, or push tags | ❌ | Release tags are managed outside the UI |
| Git log, graph, blame, reflog | ❌ | Application logs are not Git history |
| Git grep / bisect | ❌ | Not implemented |
| Merge conflict editor | ❌ | Not implemented |
| List/add/edit/remove remotes | ✅ | Multiple platform remotes |
| Push current branch | ✅ | One or all remotes; upstream is configured |
| Fetch | ✅ | Upstream/all-remote fetch is planned; successful remote-tracking refs are retained on partial failure |
| Pull | ✅ | Clean tracked branches only; fetch then `git merge --ff-only`; diverged histories are rejected |
| Clear remote history | ✅ | Ref snapshot revalidation, atomic per-ref leases, empty-root replacement, and retained backups |
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
.\tool\package_windows_release.ps1 -Tag v0.10.0
```

## Downloads

Download releases from [GitHub Releases](https://github.com/CY68GI/Git_Gui_Expand/releases)
or [Gitee Releases](https://gitee.com/CY68EWZRY/Git_Gui_Expand/releases).

1. `Git_Gui_Expand-<tag>-windows-x64.zip` is the recommended standard package.
   Install Git for Windows from <https://git-scm.com/download/win>; the app
   always prefers a valid system Git.
2. `Git_Gui_Expand-<tag>-windows-x64-PortableGit.zip` includes the pinned
   PortableGit runtime and is intended for computers where Git cannot be
   installed separately.
3. `PortableGit-<version>-64-bit-runtime.zip` is the independent runtime update
   package.

The standard package is recommended because it lets Windows and the user keep
Git, SSH, and credential-manager updates under their normal maintenance.
The PortableGit package can optionally add its stable
`runtime/git/current/cmd` directory to the current-user or system `PATH` from
Settings → Git. It backs up PATH before every change and can remove only the
managed entry.

## Release layout

```text
Git GUI Expand/
  GitGuiExpandLauncher.exe
  current-version.txt
  versions/
    0.10.0/
      maintenance/
        GitGuiExpandLauncher.exe
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
history clearing are first added to the operation plan. Repository, branch,
HEAD, status, affected paths, bootstrap destinations, and remote refs are
revalidated before mutation. Nothing is executed until the plan is confirmed;
dangerous steps require explicit confirmation;
remote history clearing additionally requires
`remote-owner/project/branch` to be typed exactly.

Git commands are executed without shell string concatenation. Protected
branches, authentication failures, network failures, and servers that do not
support atomic push are reported as failures rather than being treated as
successful operations. Remote clearing refreshes every ref hash and uses atomic
per-ref leases so changed known refs abort before target replacement.

## Updates

The update page supports both GitHub and Gitee as release sources. Choose Gitee
for networks in mainland China. New releases do not publish separate `.sha256`
assets; the updater reads SHA-256 from the GitHub release asset metadata. When
the package bytes are downloaded from the Gitee mirror, the same GitHub tag and
asset name provide the expected digest. If no trusted digest is available,
automatic installation is disabled and the release page remains available.

The Launcher downloads and verifies a Windows x64 ZIP, extracts the new version
to `versions/<version>`, and switches versions after the running application
exits. A new version that does not stay alive for the startup health check is
rolled back automatically.

After a successful update, only the current version is retained. All older
version directories, downloaded update ZIPs, partial downloads, and staged
extraction folders are removed. Settings, logs, recent repositories, and other
`userdata` files are shared across versions.

The app also performs the same cleanup during startup. This is required because
older Launcher versions cannot update themselves. The payload includes a
maintenance Launcher; after the running app exits, a maintenance helper retries
copying it over the root `GitGuiExpandLauncher.exe` once Windows releases the
running executable.

Release notes are generated from the previous Git tag to the current tag and are
provided in English, Simplified Chinese, and Traditional Chinese.

## Documentation

- [User guide](docs/USER_GUIDE.md)
- [简体中文使用指南](docs/USER_GUIDE.zh-CN.md)
- [繁體中文使用指南](docs/USER_GUIDE.zh-TW.md)
- [Architecture](docs/ARCHITECTURE.md)
- [PortableGit notices](docs/PORTABLEGIT.md)
- [Interaction design](docs/UX.md)

## Acknowledgements

Thanks to DeepSeek AI and ChatGPT Codex for jointly creating, writing, and
improving this project.

## License

This project is licensed under the [MIT License](LICENSE).
