# localized-interface Specification

## Purpose

Provides complete and independent static interface translations so supported languages can evolve without leaking another script or relying on source-sentence keys.

## Requirements

### Requirement: Static interface text uses semantic localization keys

The system SHALL reference stable semantic keys for static labels, titles, hints, buttons, and enum values instead of using a sentence from one language as the identifier.

#### Scenario: Render a localized label

- **WHEN** the interface requires a label such as an open-repository action
- **THEN** it resolves a semantic key from the active locale catalog

#### Scenario: Existing behavior is migrated

- **WHEN** an existing source-string translation call is migrated
- **THEN** the observable wording and behavior remain equivalent except for corrected localization defects

### Requirement: Locale catalogs are complete and independent

The system SHALL provide a complete catalog for English, Simplified Chinese, and Traditional Chinese, and each catalog MUST define the same keys with matching parameters.

#### Scenario: All required keys are present

- **WHEN** localization validation runs for all supported locales
- **THEN** every catalog contains every required semantic key and placeholder exactly once

#### Scenario: A translation is missing

- **WHEN** a key or required placeholder is absent from any supported locale
- **THEN** validation fails and identifies the locale, key, and missing or mismatched parameter

### Requirement: Dynamic messages remain behind an explicit compatibility boundary

The system SHALL keep runtime-generated messages and logging outside the static localization migration until a separate structured-message change replaces them.

#### Scenario: A legacy dynamic message is displayed

- **WHEN** the interface displays a runtime-generated outcome through the compatibility adapter
- **THEN** the adapter is used only from an approved migration boundary and the static resource path is not bypassed

#### Scenario: New static UI text is added

- **WHEN** a developer adds a static label, title, hint, button, or enum value
- **THEN** the source check rejects the compatibility adapter and requires a semantic resource key

### Requirement: Chinese locales contain only their declared script

Simplified Chinese resources MUST NOT contain Traditional-only forms, and Traditional Chinese resources MUST NOT depend on automatic character substitution from Simplified Chinese.

#### Scenario: Simplified Chinese contains a Traditional-only character

- **WHEN** localization quality checks find a disallowed Traditional-only form in the Simplified Chinese catalog
- **THEN** validation fails with the file, key, and offending text

#### Scenario: A Traditional Chinese key is missing

- **WHEN** Traditional Chinese is selected and a required key has no explicit translation
- **THEN** the application reports a localization failure to tests rather than silently character-converting the Simplified text

#### Scenario: A proper name uses Chinese characters

- **WHEN** a language name, product name, or approved technical term legitimately uses a form covered by the script checker
- **THEN** the checker uses an explicit allowlist rather than weakening the global script rule

### Requirement: Localization quality gates protect UI additions

The project SHALL include automated checks that detect missing catalog keys and unlocalized static user-facing string literals outside approved localization resources.

#### Scenario: New UI text bypasses localization

- **WHEN** a changed UI source contains a user-visible Chinese or English literal outside the approved localization files
- **THEN** the localization check fails unless the literal is explicitly allowlisted

#### Scenario: A new locale is added

- **WHEN** a new locale resource is registered
- **THEN** the same completeness, parameter, and vocabulary checks run without changing the UI call sites

### Requirement: Existing language preferences remain compatible

The system SHALL preserve existing English, Simplified Chinese, Traditional Chinese, and follow-system preference selections across the localization migration.

#### Scenario: Load a saved language preference

- **WHEN** existing settings contain a supported language preference
- **THEN** the application opens with the equivalent locale and does not require the user to select it again
