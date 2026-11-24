# git-runtime-management Specification

## Purpose

Defines deterministic Git discovery, optional PortableGit provisioning, environment integration, runtime updates, and release artifact integrity for every repository operation.

## Requirements

### Requirement: A valid system Git always has priority

The system SHALL prefer a valid Git executable installed outside the application runtime even when the current application package contains PortableGit.

#### Scenario: System and bundled Git are both available

- **WHEN** discovery finds both a valid system Git and a valid bundled PortableGit
- **THEN** repository commands use the system Git executable and Settings reports the source as system Git

#### Scenario: Only bundled Git is available

- **WHEN** no valid system Git is found and the bundled PortableGit passes validation
- **THEN** repository commands use the bundled executable and Settings reports the source as bundled Git

#### Scenario: Bundled Git was added to PATH

- **WHEN** the bundled runtime path appears in the process or user environment
- **THEN** discovery still classifies executable paths inside the application runtime as bundled rather than as system Git

### Requirement: Git discovery is proactive and visible

The system SHALL check Git at application startup and on demand, and SHALL expose the active Git version, executable path, source, and availability in Settings.

#### Scenario: Open Settings with Git available

- **WHEN** Git discovery has completed successfully
- **THEN** Settings shows its version, full executable path, source, and successful availability

#### Scenario: Re-detect after installation

- **WHEN** the user installs Git outside the application and selects re-detect
- **THEN** discovery refreshes without restarting the application and a valid system Git takes priority immediately

#### Scenario: Discovery encounters multiple system candidates

- **WHEN** multiple executables named `git` are found
- **THEN** the system validates candidates in environment search order and records the first valid non-runtime executable

### Requirement: Missing Git has a recoverable blocking state

When neither source provides a valid Git, the application SHALL remain open, visibly explain that Git is unavailable, disable repository-mutating actions, and provide recovery actions.

#### Scenario: Start without Git

- **WHEN** application startup finds no valid system or bundled Git
- **THEN** the main interface opens with a persistent missing-Git warning and repository actions explain that Git is required

#### Scenario: Open the Git download page

- **WHEN** the user activates the missing-Git download action
- **THEN** the system opens the official Git for Windows download page in the default browser

#### Scenario: Recover without restarting

- **WHEN** the user installs Git and activates re-detect
- **THEN** Git becomes available and repository actions are enabled without restarting the application

### Requirement: Standard packages are recommended over bundled packages

Release downloads SHALL publish a standard application package without Git and a separate PortableGit-marked package, and download guidance SHALL recommend the standard package for users able to install Git themselves.

#### Scenario: View download guidance

- **WHEN** a user opens the release download description
- **THEN** the standard package appears first with guidance to install Git separately and choose it unless a bundled runtime is needed

#### Scenario: Choose a package without an active system Git

- **WHEN** the user needs an application that can work without a separately installed Git
- **THEN** the release description directs the user to the package marked `PortableGit`

### Requirement: PortableGit package names are explicit

Every application or runtime artifact that contains the bundled Git runtime MUST include `PortableGit` in its published package file name, while the standard package MUST remain distinguishable without that marker.

#### Scenario: Name the bundled application package

- **WHEN** release packaging creates an application artifact containing the bundled runtime
- **THEN** its file name contains `PortableGit` and its internal manifest identifies the PortableGit version

#### Scenario: Name the standard package

- **WHEN** release packaging creates an application artifact without the bundled runtime
- **THEN** its file name does not claim to contain PortableGit

### Requirement: Bundled Git uses an independent versioned runtime

PortableGit SHALL be stored as a shared, independently versioned runtime outside individual application version directories, with an atomic active pointer and a retained previous runtime.

#### Scenario: Activate a validated runtime

- **WHEN** a downloaded PortableGit runtime passes archive, layout, executable-version, and smoke validation
- **THEN** the system atomically makes it the active runtime and retains the previously active runtime for rollback

#### Scenario: Active runtime fails validation

- **WHEN** the active runtime is missing, corrupted, or cannot execute Git
- **THEN** the system attempts the previous validated runtime before reporting Git unavailable

#### Scenario: Runtime update is requested during Git work

- **WHEN** a Git command or repository operation is running
- **THEN** runtime activation waits until no command is using the existing runtime or requires an application restart before switching

#### Scenario: Runtime is no longer needed

- **WHEN** a runtime is neither active nor the retained previous runtime
- **THEN** maintenance removes the obsolete runtime and its staging data without removing user repositories, settings, logs, credentials, or configuration

### Requirement: Environment PATH integration is explicit and reversible

The system SHALL offer optional PATH integration only for the bundled PortableGit and MUST let the user choose user scope or system scope while preserving existing PATH entries.

#### Scenario: Add PortableGit to user PATH

- **WHEN** the user confirms user-scope integration
- **THEN** the stable bundled Git command directory is appended exactly once to the current user's PATH without requiring elevation

#### Scenario: Add PortableGit to system PATH

- **WHEN** the user confirms system-scope integration
- **THEN** the system explains the broader impact and elevation requirement, appends the stable bundled Git command directory exactly once, and reports cancellation or failure without changing PATH

#### Scenario: Existing PATH already contains the runtime

- **WHEN** the selected scope already contains the stable bundled Git path
- **THEN** the operation reports that integration already exists and does not duplicate the entry

#### Scenario: Remove PATH integration

- **WHEN** the user confirms removal for a scope previously configured by the application
- **THEN** only the application-managed stable runtime entry is removed and unrelated PATH entries retain their order and values

#### Scenario: Bundled runtime version changes

- **WHEN** the active PortableGit runtime changes
- **THEN** the PATH entry continues to reference a stable runtime location rather than a version-specific directory

### Requirement: Release assets use platform-provided SHA-256 metadata

Release publishing MUST NOT upload separate `.sha256` files, and automatic installation MUST verify the selected package against SHA-256 metadata supplied by the release platform.

#### Scenario: Install from GitHub

- **WHEN** the updater selects a GitHub release asset
- **THEN** it reads the SHA-256 digest from that asset's release metadata and verifies the downloaded bytes before extraction

#### Scenario: Download the same release asset from Gitee

- **WHEN** the updater downloads equivalent release bytes from the Gitee mirror
- **THEN** it verifies those bytes against the matching SHA-256 metadata for the same GitHub release asset

#### Scenario: Expected digest is unavailable

- **WHEN** no trusted digest can be obtained for a selected asset
- **THEN** automatic installation is refused and the user may open the release page for manual download

#### Scenario: Downloaded bytes do not match

- **WHEN** the downloaded package SHA-256 differs from the expected digest
- **THEN** the system deletes the rejected download, preserves the active application and runtime, and reports a verification failure

### Requirement: PortableGit redistribution preserves licensing

The bundled runtime SHALL preserve the PortableGit distribution's license and notice files and SHALL expose its source-availability information in the packaged notices.

#### Scenario: Build a PortableGit package

- **WHEN** packaging includes the bundled runtime
- **THEN** validation requires the designated PortableGit license and notice assets before creating the final archive

#### Scenario: Open third-party notices

- **WHEN** the user views third-party notices for a PortableGit-marked installation
- **THEN** the application identifies PortableGit, its version, license location, and source-availability information
