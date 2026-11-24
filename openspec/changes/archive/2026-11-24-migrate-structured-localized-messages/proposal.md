# Proposal

## Why

Runtime-generated interface messages, operation-plan content, and logs still pass completed Chinese sentences through a temporary compatibility adapter. This prevents typed parameterization, stable log event identifiers, and safe removal of the legacy translation tables.

## What Changes

- Introduce one structured message contract with a semantic key, typed parameters, a stable event identifier, and unmodified technical details.
- Store operation outcomes and planned-operation titles/descriptions as structured messages instead of completed display sentences.
- Localize structured messages when rendered or logged using the active interface language.
- Migrate dynamic counts, paths, branch names, remote names, errors, and technical values without translating the values themselves.
- Migrate normal and detailed logs to stable event identifiers plus localized templates, while retaining raw Git output and secret-redaction behavior.
- Remove the compatibility adapter, old source-string dictionaries, dynamic regex translation, and automatic script conversion after every production use is migrated.
- Add tests for language changes during a session, raw technical values, missing/mismatched parameters, and prohibited adapter references.

## Capabilities

### New Capabilities

- `structured-localized-messages`: Defines structured runtime messages, operation outcome and plan localization, event-identified logs, parameter preservation, and removal of legacy message translation.

### Modified Capabilities

None.

## Impact

- Operation outcome and planned-operation models
- Repository controller, dialogs, commit workspace, remote and synchronization flows
- Log service and all production logging call sites
- Localization adapter and generated ARB resources
- Logging, operation-plan, repository-sync, and localization tests
