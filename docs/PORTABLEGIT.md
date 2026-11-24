# PortableGit Runtime Notices

Git GUI Expand does not modify a system Git installation. The optional
PortableGit package contains a pinned Git for Windows distribution for computers
where Git is not installed separately.

## Runtime layout

```text
runtime/git/
  current.json
  current/cmd/
  versions/
    PortableGit-<version>-64-bit/
      cmd/git.exe
      mingw64/
      ucrt64/
      usr/
      git-runtime.json
      licenses/
        GIT-COPYING.txt
        PORTABLEGIT-LICENSE.txt
        PORTABLEGIT-NOTICE.txt
```

`current.json` stores the active and previous validated runtime. After a
successful update, maintenance retains the active and previous runtimes and
removes older runtime directories and `userdata/updates/git-stage-*` folders.
Repository files, application settings, logs, recent repositories, SSH keys,
and credential-manager entries are not removed.

## Source and license

The exact upstream package name, Git version, source URL, source SHA-256, and
source-availability URL are stored in
`tool/portablegit-runtime.lock.json` and copied into each runtime's
`git-runtime.json`. The normalized runtime also preserves the upstream Git
license and PortableGit notice files.

Git for Windows and PortableGit are distributed under their upstream licenses.
Their source is available from:

- <https://github.com/git-for-windows/git/releases>
- <https://github.com/git-for-windows/git>

The application's own MIT license does not replace the licenses of bundled
third-party executables.

## PATH integration

Settings → Git exposes PATH integration only when the active Git source is the
bundled PortableGit. PATH changes are opt-in, create a timestamped backup under
`userdata/git-path-backups`, preserve unrelated entries and `REG_EXPAND_SZ`
semantics, and can be removed for user or system scope. System scope requires
administrator elevation; cancelling elevation changes nothing.

The PATH entry points to the stable `runtime/git/current/cmd` location. It does
not need to be edited when PortableGit is updated.
