# Design

## Context

See `proposal.md` for motivation. `GitService` currently launches the literal command `git` for every operation and only produces a user-facing error after `ProcessException`. Settings has no Git section. Release packaging creates one application ZIP plus a separate `.sha256` asset. The updater already prefers a GitHub asset `digest` field when present but retains fallback logic for sidecar checksum assets.

## Goals / Non-Goals

**Goals:**

- Make the active Git source, path, version, and failure state observable before a repository command runs.
- Preserve an existing system Git as the primary implementation.
- Provide a controlled PortableGit fallback and independent runtime updates.
- Make PATH integration optional, auditable, and reversible.
- Keep installed app files and application-owned data beneath the software directory.

**Non-Goals:**

- Install Git for the user automatically.
- Replace, upgrade, or modify an existing system Git installation.
- Copy a user's global `.gitconfig`, SSH keys, or system credential store into the application directory.
- Support non-Windows runtime integration in this change.
- Silently add anything to `PATH`.
- Upload checksum sidecar files for new releases.

## Decisions

### Central runtime discovery with system precedence

Introduce one Git runtime discovery service that returns an immutable status containing source, executable path, parsed version, validation state, and checked time. Every Git process launch uses the selected absolute executable path.

Discovery order is:

```text
1. Resolve git.exe candidates from the effective PATH.
2. Exclude candidates located inside the application runtime directory.
3. Validate the first remaining candidate with git --version.
4. If no valid external candidate exists, resolve runtime/git/current.
5. Validate the bundled candidate with git --version and a smoke command.
6. If neither source is valid, return unavailable.
```

The application runtime root is compared by canonical path. This preserves the rule that a bundled Git added to PATH is still reported and treated as bundled, not misclassified as a system installation.

Alternatives considered:

- Prefer bundled Git to guarantee one version. Rejected because the user requires system Git precedence and it would bypass the user's maintained installation.
- Use only the literal `git` command. Rejected because it hides the executable source, makes diagnostics ambiguous, and cannot implement reliable fallback.

### Keep discovery non-blocking for application startup

The application frame opens even when Git is unavailable. A shared runtime state drives a persistent warning, disabled mutating actions, Settings details, and a re-detect action. Opening a repository or mutating action while unavailable shows the detailed recovery dialog.

Repository history and settings remain visible so the application is still diagnosable. Re-detection replaces the runtime state and notifies the project controller and Settings without restarting the app.

### Use a shared versioned PortableGit runtime

Use this software-directory layout:

```text
<software>/
  runtime/
    git/
      current.json
      current/                     stable directory junction or equivalent
      versions/
        PortableGit-<version>-64-bit/
          cmd/git.exe
          mingw64/
          usr/
          LICENSE and upstream notices
  userdata/
    updates/
      git-stage-<version>/
  versions/
    <application-version>/
```

The runtime is outside individual application version directories because it is independently updated. `current.json` records the active and previous PortableGit versions and their validated relative paths. Activation writes a temporary metadata file, validates it, then atomically replaces `current.json`. The stable `current` entry is updated only after the pointer is valid.

The previous runtime remains available for rollback. Maintenance prunes older runtime directories and staging data only after a successful activation or successful fallback.

### Publish standard and PortableGit packages

Release builds produce two application packages:

```text
Git_Gui_Expand-<tag>-windows-x64.zip
Git_Gui_Expand-<tag>-windows-x64-PortableGit.zip
```

Only the package containing the runtime uses the `PortableGit` marker. A separate runtime update asset also includes `PortableGit` in its name. The standard package remains the default recommendation in README files and release notes.

The PortableGit application package contains the application payload plus the versioned runtime payload. During installation or update, the application remains in `versions/<version>`, while the runtime is staged under the shared runtime tree and activated separately. The standard package does not remove an already-installed runtime.

### Pin and normalize the upstream PortableGit release

Build tooling downloads one explicitly pinned official Git for Windows PortableGit release and records its expected upstream digest in the repository lock file. It extracts the official runtime without copying an installer into the application, validates `cmd/git.exe`, and creates our normalized runtime ZIP and manifest.

The manifest records:

- upstream PortableGit version;
- upstream source URL;
- runtime file-name marker;
- expected package digest;
- license/notice paths;
- build time.

No release sidecar `.sha256` asset is generated.

### Use stable PATH integration

The PATH entry points to the stable `runtime/git/current/cmd` location, never a version-specific folder. This allows a runtime update without requiring the user to repair PATH.

The environment integration service:

- reads the selected user or machine environment value and preserves unrelated entries;
- compares paths case-insensitively and de-duplicates only the managed entry;
- records a timestamped backup under `userdata`;
- requests confirmation that clearly explains user versus system scope;
- uses elevation only for machine scope and treats cancellation as no change;
- refreshes the environment notification after a successful change;
- offers removal of only the application-managed entry.

`setx` is not used because it can truncate values and does not preserve registry value semantics. The implementation uses registry-aware reads and writes through a bounded Windows helper or PowerShell command, preserving `REG_EXPAND_SZ` where applicable.

The application never offers this action when a valid external system Git is active. It can offer it when only PortableGit is available, including the case where PortableGit is currently active but not in PATH.

### Obtain release integrity from hosting metadata

GitHub release asset `digest` metadata is the primary expected SHA-256. Packaging and upload scripts stop creating and uploading `.sha256` sidecar files.

For the Gitee mirror, the updater finds the matching GitHub release asset by tag and asset name to obtain the expected digest while downloading bytes from Gitee. If GitHub metadata cannot be obtained, automatic installation is disabled and the release page remains available for manual download. The updater never installs an unverified automatic update.

Existing updater support for historical releases containing a checksum sidecar may remain temporarily, but new publishing paths and tests must not produce one.

### Preserve Git user data boundaries

The runtime, application-owned settings, logs, update staging, path backups, and runtime manifests remain under the software directory. Global Git identity, SSH keys, credential-manager entries, and user Git configuration remain in their standard user locations unless a future separate portable-user-profile feature is approved.

This avoids breaking interoperability with the system Git and the user's existing repositories while still allowing application-owned runtime files to remain local to the installation.

## Risks / Trade-offs

- System Git behavior can differ between machines → Prefer it as required, show its version/path, and keep PortableGit available as a validated fallback only when no valid system Git exists.
- PATH changes can damage a user's shell environment → Use registry-aware backup, exact managed-entry matching, explicit confirmation, elevation only when needed, and exact removal.
- PortableGit substantially increases package size → Publish the standard package first, make the PortableGit package clearly optional, and use a shared runtime instead of copying it into every app version.
- Runtime updates can occur while Git commands are active → Track active command count, block activation until idle or require restart, and never replace files in the active runtime directory.
- Updating `current` can race with discovery → Serialize runtime and PATH operations and validate the pointer after activation.
- PortableGit redistribution creates licensing obligations → Preserve upstream license and source-availability information and fail packaging when required notices are absent.
- Gitee-only network access may leave GitHub digest metadata unavailable → Refuse unverified automatic installation and open the release page for manual action rather than weakening integrity checks.
- Environment changes are not always visible to already-running processes → Use the appropriate environment-change notification and report that other applications may need to restart.

## Migration Plan

1. Add the runtime status model and discovery service without changing repository command semantics.
2. Route `GitService` through the selected absolute executable path and add missing-Git UI/Settings behavior.
3. Add the shared runtime layout, current-pointer validation, and rollback behavior.
4. Add PortableGit fetch, manifest, packaging, and standard/PortableGit dual-package release outputs.
5. Extend update installation to stage and atomically activate runtime payloads.
6. Add optional user/system PATH integration and removal.
7. Remove checksum sidecar generation and upload; migrate update tests to platform digests.
8. Update README/download guidance and run clean-install, no-Git, system-plus-bundled, bundled-only, runtime-update, rollback, and PATH tests.

Rollback before any release requires reverting the source changes. User PATH changes are independently reversible through the Settings action. Runtime activation keeps the previous validated runtime, so a failed new runtime can fall back without changing application versions.

## Open Questions

None blocking. The exact supported PortableGit version and its pinned digest will be selected during implementation from an official Git for Windows release and recorded in the runtime lock file.
