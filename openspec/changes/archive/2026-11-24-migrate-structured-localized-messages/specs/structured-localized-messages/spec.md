# Spec Delta

## Purpose

Defines structured runtime messages for operation results, planned operations, and logs so dynamic values remain opaque, logs retain diagnostic identifiers, and legacy sentence translation can be removed.

## ADDED Requirements

### Requirement: Runtime messages use a structured contract

The system SHALL represent runtime-visible messages with a semantic localization key, typed parameters, and optional unmodified technical details rather than a completed display sentence.

#### Scenario: Create a structured message

- **WHEN** application code needs to report a runtime result or event
- **THEN** it creates a message containing a semantic key and named values instead of translating a preformatted sentence

#### Scenario: Render a structured message

- **WHEN** a structured message is displayed
- **THEN** the active locale resolves its key and inserts its parameters

### Requirement: Operation outcomes are structured

Repository success and failure results SHALL carry semantic message keys and parameters through the controller and UI layers.

#### Scenario: Successful repository operation

- **WHEN** an operation succeeds with a project, branch, path, or count
- **THEN** the outcome retains those values as parameters and the active locale renders the result

#### Scenario: Failure includes Git diagnostics

- **WHEN** a Git command fails
- **THEN** the user-facing outcome is localized while raw Git output remains available as unmodified technical detail

### Requirement: Operation-plan content is structured

Planned-operation titles and descriptions SHALL be resolved from semantic templates with parameters instead of storing completed Chinese text.

#### Scenario: Queue a file operation

- **WHEN** a move, copy, rename, or delete step is queued
- **THEN** its title and description use a semantic template with the affected count and paths supplied as parameters

#### Scenario: Change language with queued operations

- **WHEN** the interface language changes while a plan is queued
- **THEN** the same plan renders its titles and descriptions in the new language without changing repository state

### Requirement: Parameters remain opaque

Branch names, remote names, paths, URLs, commit messages, counts, and Git output MUST remain unmodified when inserted into localized templates.

#### Scenario: Parameter looks like a localization key

- **WHEN** a parameter contains text resembling a key or another localized phrase
- **THEN** it is not translated, normalized, or recursively localized

### Requirement: Logs use event identifiers and localized templates

Normal and detailed logs SHALL record a stable event identifier and localized message generated at write time, while preserving raw command, path, URL, and Git diagnostics.

#### Scenario: Record a normal event

- **WHEN** a repository, update, setting, startup, or maintenance event is logged
- **THEN** the record contains the event identifier and a message in the language active at write time

#### Scenario: Record a detailed Git event

- **WHEN** a Git command is logged in detail
- **THEN** command, working directory, exit code, stdout, and stderr remain raw and unmodified

#### Scenario: Change language during the session

- **WHEN** the user changes the interface language
- **THEN** earlier log entries retain their previous language and later entries use the new language

### Requirement: Sensitive values are redacted without localization

Credential-bearing URLs and authentication details SHALL be redacted consistently in user messages and detailed logs without translating their remaining technical values.

#### Scenario: Log an authenticated remote URL

- **WHEN** a remote URL contains a username or secret
- **THEN** the credential portion is masked and the remaining URL is preserved exactly

### Requirement: Legacy runtime translation is removed

After migration, production code MUST NOT depend on the compatibility adapter, source-sentence dictionaries, regex sentence translation, or automatic script conversion.

#### Scenario: Build the completed migration

- **WHEN** all runtime messages use structured templates
- **THEN** the legacy adapter and translation tables are removed and the source check rejects their use

### Requirement: Structured-message behavior is tested

The project SHALL test counts, paths, branch and remote names, Git output, error details, language changes, redaction, and missing or mismatched parameters.

#### Scenario: Missing template parameter

- **WHEN** a structured message omits a required parameter
- **THEN** validation fails before the message is presented as a successful localized result

#### Scenario: Localization is incomplete

- **WHEN** a structured key or parameter is missing in a supported locale
- **THEN** the normal localization quality gate fails
