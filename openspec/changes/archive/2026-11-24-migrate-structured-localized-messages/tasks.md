# Tasks

## 1. Structured Message Model

- [x] 1.1 Add an immutable localized-message value containing key, named parameters, event ID, and technical details; verify unit tests preserve values without translation.
- [x] 1.2 Add generated-resource resolution with missing-parameter validation; verify a missing parameter fails before presentation.
- [x] 1.3 Add shared credential redaction for URLs and authentication details; verify masked and non-secret portions remain exact.
- [x] 1.4 Document the structured runtime-message and event-ID conventions; verify documented key and event examples exist in the migration tests.

## 2. Outcomes and Operation Plans

- [x] 2.1 Change operation outcomes to carry structured messages while retaining success/failure semantics; verify controller and widget tests.
- [x] 2.2 Change planned-operation titles and descriptions to structured templates; verify move, copy, rename, delete, commit, branch, Stash, remote, and clear-history plans.
- [x] 2.3 Resolve outcome and plan messages at render time using the active locale; verify changing language with a queued plan preserves state and changes presentation.
- [x] 2.4 Migrate repository opening, file operations, branches, Stashes, remotes, synchronization, settings, maintenance, and update outcomes to structured keys; verify domain tests.

## 3. Event-Identified Logging

- [x] 3.1 Add normal and detailed event-aware logging APIs with stable event IDs and unmodified technical details; verify startup, settings, update, maintenance, and repository events.
- [x] 3.2 Migrate all production logging call sites from formatted strings to structured events; verify source checks find no legacy message adapter use.
- [x] 3.3 Capture the active locale at write time and test a mid-session language change; verify previous entries remain unchanged.
- [x] 3.4 Verify raw command, path, URL, exit code, stdout, stderr, and commit-message values are not localized; verify credential redaction tests.

## 4. Parameter and Template Coverage

- [x] 4.1 Migrate dynamic counts, paths, branch names, remote names, target folders, and confirmation text to typed templates; verify opaque-parameter tests.
- [x] 4.2 Add runtime localization resources for every event and message key; verify all generated catalogs contain equal keys and placeholders.
- [x] 4.3 Add operation-plan dialog and log-viewer widget tests for Simplified Chinese, Traditional Chinese, and English; verify no layout overflow or untranslated controlled messages.
- [x] 4.4 Add an end-to-end test that changes language while an operation plan is queued and a log session remains open; verify the plan and new logs use the new locale while old logs do not change.

## 5. Remove Legacy Translation

- [x] 5.1 Remove the compatibility adapter, source-string dictionaries, regex sentence translation, and automatic script conversion after all call sites migrate; verify no production or test reference remains.
- [x] 5.2 Tighten source and CI checks to reject formatted runtime sentence construction and unregistered dynamic message keys; verify representative invalid fixtures fail.

## 6. Final Verification

- [x] 6.1 Run `flutter analyze`, the complete test suite, localization checks, locale-specific widget tests, and a Windows release build; verify no missing keys, layout overflows, or legacy adapter usage.
- [x] 6.2 Perform a Windows smoke test of repository operations, operation plans, normal/detailed logs, language switching, and raw Git diagnostics; verify observed behavior matches the specs.
