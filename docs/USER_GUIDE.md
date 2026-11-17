# Git GUI Expand User Guide

Languages: English | [简体中文](USER_GUIDE.zh-CN.md) | [繁體中文](USER_GUIDE.zh-TW.md)

## 1. Plan before execution

Git GUI Expand does not immediately move, rename, delete, commit, push, or clear
remote history. Each requested action is first added to the pending operation
plan.

1. Select files and folders with the checkboxes.
2. Choose an action from the toolbar, context menu, commit workspace, or remote
   manager.
3. Review the pending operation plan.
4. Remove or clear any unwanted steps.
5. Confirm the plan to execute it step by step.

If a step fails, execution stops. The failed step and later steps remain in the
plan. Completed steps are not automatically rolled back.

## 2. Opening a repository

Click **Open Git repository**. The Windows standard **Open** dialog is shown.
Choose the root of a folder that already contains `.git`.

After opening, **Project folder** opens the current repository root in File
Explorer. Verified repositories are saved to the recent list; the list stores
only existing Git roots and keeps at most ten entries.

Start distributed releases with `GitGuiExpandLauncher.exe`. If
`current-version.txt` is missing from a freshly extracted package, the Launcher
automatically discovers a single valid `versions/<version>` directory and
repairs the marker. A flat development directory containing
`git_gui_expand.exe`, `flutter_windows.dll`, and `data` can also be launched.

## 3. Dual-pane file operations

The left and right panes show the same repository but maintain independent
folders, loading state, and selections.

- Click a pane to make it the paste target.
- Double-click a folder to enter it.
- Use checkboxes for one or more items.
- Use Cut (`Ctrl+X`) or Copy (`Ctrl+C`) on the source pane.
- Enter the destination folder and click Paste (`Ctrl+V`).

Move, copy, rename, and delete operations are added to the plan first.

### Context menu

Right-click a file row to:

- reveal and select it in File Explorer;
- open it with the Windows default application.

### Rename

Select exactly one item, click **Rename** or press `F2`, enter the new name, and
add it to the plan. The software uses `git mv` after confirmation.

### Delete

Select one or more items and click **Delete** or press `Delete`. After adding the
step to the plan, select the dangerous-operation confirmation. Tracked files use
`git rm`; untracked or ignored files use `git clean`. File deletion cannot be
undone by the application.

## 4. Commit workspace

- **Stage all** plans `git add -A`.
- **Unstage** restores the index to `HEAD` while keeping workspace files.
- **Add commit to plan** plans `git add -A` followed by `git commit`.

Enter a meaningful commit message, review the plan, then confirm execution.
After a commit step is queued, additional file-change steps are blocked until the
commit step is removed or executed.

## 5. Push and remotes

The remote manager supports GitHub, Gitee, GitLab, Bitbucket, and generic Git
remotes.

- Add or update a remote URL.
- Remove only the local remote configuration.
- Push the current branch to one remote or all remotes.
- Refresh the remote list.

Pushes are planned first. If upstream is configured, the software runs
`git push`; otherwise it prefers `origin`, configures upstream, and reports
authentication or network failures.

## 6. Clearing remote history

This is a dangerous operation. It replaces the selected remote branch with a
single empty root commit and removes other branches and tags. Local files remain,
but the local matching branch and index are synchronized to the empty commit, so
files become untracked after refresh.

Before execution:

1. The local current branch must match the target remote branch.
2. Review the remote reference list.
3. Select the dangerous-operation confirmation.
4. Enter the exact `owner/project/branch` confirmation.

Reference backups are stored under
`refs/gitgui-expand/backup/<remote>`. Protected branches, missing permissions,
network failures, or servers without atomic push can reject the operation.

## 7. Settings

Settings contains five pages:

- Font
- Language
- Appearance settings
- Units
- About

### Language

Choose English, Simplified Chinese, Traditional Chinese, or Follow system.
When Follow system is selected, the option is displayed only in the actual
operating-system language instead of showing three labels at once.

The language change takes effect after saving. New normal and detailed log
entries use the selected interface language. Git command output and external
technical error text are preserved as returned by Git.

### Font and appearance

The default UI font is bundled `Noto Sans SC`. Search bundled or installed system
fonts by name or purpose. The font page has a permanent scroll bar and a visible
hint that font preview and size controls continue below.

Text size is limited to 90%, 100%, and 110%. Appearance settings can follow the
operating system or use a fixed light or dark display mode. It also provides
Emerald, Ocean, Violet, Amber, and Rose color schemes; buttons, selection
states, borders, and icons follow the selected scheme.

### Desktop shortcut

Open **Settings → About**, then click **Send shortcut to desktop**. The shortcut
targets `GitGuiExpandLauncher.exe` when available, with the software directory as
its working directory.

## 8. Updates

The update page checks GitHub Releases and offers **Update and restart now**.
The application downloads the Windows x64 ZIP, verifies SHA-256, extracts the
payload into `versions/<version>`, and exits. The stable Launcher switches the
current version and starts the new application.

If the new version exits during the startup health check, the Launcher rolls
back. After a successful update, only the current version remains. Older version
directories, downloaded ZIPs, partial downloads, staged extraction folders, and
the legacy updater script are removed.

Use **Open release page** when automatic publication metadata is unavailable or
network conditions are poor.

## 9. Logs

Open **Logs** from the top bar:

- **Normal log** contains startup, repository, Git action, warning, and error
  events.
- **Detailed log** also contains navigation, selections, settings changes, update
  checks, and each Git command with its arguments, exit code, stdout, and stderr.

Logs are stored in `userdata/logs` beneath the software directory.

## 10. Keyboard shortcuts

`Ctrl+O` opens a repository.

`Ctrl+X` records a cut selection.

`Ctrl+C` records a copy selection.

`Ctrl+V` adds a paste operation to the plan.

`F2` adds a rename operation to the plan.

`Delete` adds a delete operation to the plan.

`Ctrl+A` selects all visible items in the active pane.

`Ctrl+R` refreshes the repository.

`Ctrl+Shift+U` adds a push of the current branch to the plan.

## 11. Safety recommendations

- Back up important repositories before dangerous operations.
- Review every planned path, branch, remote, and commit message.
- Do not use remote history clearing as a normal cleanup command.
- Check protected-branch settings before clearing remote history.
- Keep Git credentials and the software directory under your control.

## Acknowledgements

Thanks to DeepSeek AI and ChatGPT Codex for jointly creating, writing, and
improving this project.
