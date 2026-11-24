# Tasks

## 1. Discovery and Repository Execution

- [x] 1.1 Add an immutable Git runtime status model and discovery service that validates PATH candidates and the bundled runtime; verify tests for no Git, system-only, bundled-only, and both-available cases.
- [x] 1.2 Add path-provenance classification so a bundled path added to PATH remains `bundled`; verify the system-precedence and runtime-classification tests.
- [x] 1.3 Route every Git process launch through the selected absolute executable path and retain non-interactive Git environment variables; verify repository, bootstrap, remote, and identity tests.
- [x] 1.4 Add proactive startup discovery and a re-detect operation that updates dependents without restart; verify a fake install transition changes the active runtime and enables actions.

## 2. Missing-Git and Settings Experience

- [x] 2.1 Add a persistent missing-Git warning and recoverable action dialog while keeping the application frame usable; verify no repository mutation can run in the unavailable state.
- [x] 2.2 Add the official Git for Windows download action through the shared external-link service; verify the exact HTTPS destination and browser-service invocation.
- [x] 2.3 Add a Settings Git page showing availability, version, executable path, source, and last detection; verify system and bundled states plus the unavailable state.
- [x] 2.4 Add localized strings and widget tests for missing Git, download, re-detect, and Settings status; verify Simplified, Traditional, and English layouts have no overflow.

## 3. Independent PortableGit Runtime

- [x] 3.1 Extend application storage with shared runtime paths, manifests, staging paths, and a stable current entry; verify path tests for normal, launcher, and clean-extraction layouts.
- [x] 3.2 Implement runtime layout and smoke validation for `cmd/git.exe`, version, expected roots, manifests, and license files; verify malformed and incomplete runtime fixtures are rejected.
- [x] 3.3 Implement atomic runtime activation with active and previous manifests and restore-previous behavior; verify successful activation, interrupted write, corrupt active runtime, and rollback tests.
- [x] 3.4 Track active Git commands and block or defer runtime replacement while commands are running; verify the runtime update path waits for idle or requests a controlled restart.
- [x] 3.5 Extend maintenance cleanup to remove obsolete runtimes and staging data while retaining active, previous, user data, settings, and repositories; verify cleanup tests.

## 4. PortableGit Packaging and Release Artifacts

- [x] 4.1 Add a pinned PortableGit source lock and fetch/normalize script that verifies the upstream archive digest and validates the extracted Git version; verify the script fails on a digested-file mismatch.
- [x] 4.2 Package the normalized runtime and manifest with required `PortableGit` naming; verify runtime and application artifact file names contain `PortableGit` exactly when runtime files are present.
- [x] 4.3 Produce both the standard application ZIP and the PortableGit application ZIP; verify both unpack to launchable layouts and the standard package contains no Git runtime.
- [x] 4.4 Require and package PortableGit license, notice, and source-availability information; verify packaging fails when a required notice is absent and that third-party notice lookup identifies it.
- [x] 4.5 Remove `.sha256` generation and upload from Windows packaging and both hosting workflows; verify the release asset list contains neither application nor runtime checksum sidecars.

## 5. Update and Integrity Verification

- [x] 5.1 Read GitHub release asset SHA-256 from platform `digest` metadata for both standard and PortableGit packages; verify tests using representative GitHub API payloads.
- [x] 5.2 Match Gitee-downloaded bytes to the same GitHub tag and asset name digest before installation; verify the Gitee mirror test uses a matching digest and rejects a mismatch.
- [x] 5.3 Refuse automatic installation and offer the release page when no trusted digest is available; verify the updater state does not claim a downloadable update is safely installable.
- [x] 5.4 Extend update staging to process application payloads and shared runtime payloads independently; verify the application pointer and runtime pointer switch only after both required validations pass.
- [x] 5.5 Preserve an installed runtime when updating with the standard package and validate its compatibility before launching the new application; verify standard-over-PortableGit and PortableGit-over-standard update tests.

## 6. User and System PATH Integration

- [x] 6.1 Implement environment reads and writes that preserve unrelated values, order, expansion behavior, and registry value type; verify fixtures with long, expanded, duplicate, and malformed PATH values.
- [x] 6.2 Add opt-in user-scope integration for `runtime/git/current/cmd`, including exact de-duplication and a timestamped backup under `userdata`; verify no elevation is requested and existing entries remain.
- [x] 6.3 Add system-scope integration with an explicit impact warning, elevation request, and no-change result on cancellation; verify success, duplicate, cancellation, and failure tests.
- [x] 6.4 Add managed-entry detection and reversible removal for both scopes without removing unrelated PATH entries; verify removal and repeated-removal tests.
- [x] 6.5 Verify a PortableGit runtime version change does not break the stable PATH target and that external PATH additions do not change system-over-bundled precedence.

## 7. Download and Runtime Documentation

- [x] 7.1 Update English, Simplified Chinese, and Traditional Chinese README downloads to list the standard package first and recommend a separately installed Git; verify all three files use the same asset names and ordering.
- [x] 7.2 Update release-note generation to explain standard versus PortableGit packages and the optional PATH integration; verify generated descriptions contain no checksum asset links.
- [x] 7.3 Document PortableGit license, source availability, runtime location, update retention, and user-data boundaries; verify the documented paths match package and runtime tests.

## 8. End-to-End Verification

- [x] 8.1 Test a clean machine state with no system Git in both standard and PortableGit packages; verify the standard package reports the recoverable missing-Git state and PortableGit supplies a working fallback.
- [x] 8.2 Test system Git plus bundled PortableGit and verify the system executable/path are selected even when the bundled path appears in PATH.
- [x] 8.3 Test PortableGit runtime download, activation, failure rollback, cleanup, and re-detection across an application restart; verify active and previous runtime contents and logs.
- [x] 8.4 Run `flutter analyze`, the full test suite, packaging scripts, release-artifact assertions, and Windows release builds; verify both package types launch and no new `.sha256` asset is produced.
