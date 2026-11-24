# Proposal

## Why

Git is only discovered when a command fails, Settings cannot show which Git executable the application uses, and packaged builds have no controlled way to provide Git when the computer does not have it. The application needs deterministic Git discovery, an optional PortableGit runtime, explicit environment integration, and release packaging that helps users choose the smaller standard package first.

## What Changes

- Add startup and on-demand Git discovery that records availability, version, executable path, and whether Git came from the system or the application runtime.
- Always prefer a valid system Git, even when the installed application package contains PortableGit; use the bundled runtime only as a fallback.
- Show Git status and its full executable path in Settings, with actions to download Git, re-detect it, and optionally add a bundled runtime to the user or system `PATH`.
- Keep repository editing available but visibly disabled when Git is unavailable; provide the official Git for Windows download page without requiring a restart.
- Publish a standard package and a separate PortableGit-marked package. The standard package is recommended on download pages so users can install and maintain system Git themselves.
- Package PortableGit as an independently versioned runtime with atomic activation, validation, rollback, and retention of only the active and previous runtimes.
- Make `PATH` integration opt-in and scoped to a stable runtime path. System `PATH` changes require elevation; user `PATH` changes do not. Existing values must be preserved and de-duplicated, and removal must be offered.
- Stop publishing separate `.sha256` release assets. Use the GitHub release asset digest metadata for verification, including when the bytes are downloaded from the Gitee mirror for the same release asset.
- Add package validation, release naming checks, update-source tests, missing-Git tests, and `PATH` migration tests.

## Capabilities

### New Capabilities

- `git-runtime-management`: Defines Git discovery precedence, missing-Git recovery, runtime reporting, PortableGit packaging and updates, environment `PATH` integration, and release artifact integrity behavior.

### Modified Capabilities

None.

## Impact

- Git command execution and repository bootstrap services
- Application startup, project UI, and Settings navigation
- Settings models and persisted preferences
- Windows release packaging and release workflows
- Update discovery, download verification, extraction, and cleanup
- PortableGit download, license handling, and runtime manifests
- Launcher/runtime compatibility checks and maintenance cleanup
- README, download guidance, tests, and release notes
