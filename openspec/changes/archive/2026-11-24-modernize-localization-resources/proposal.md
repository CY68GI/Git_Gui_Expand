# Proposal

## Why

Static interface labels currently use Chinese source sentences as keys, while Simplified and Traditional Chinese are maintained in overlapping tables that already contain mixed-script text. Moving static UI text to semantic resources now fixes localized labels and creates a stable foundation for a separate runtime-message migration.

## What Changes

- Replace static UI source-string lookup with stable semantic keys and generated locale resources.
- Add independent English, Simplified Chinese, and Traditional Chinese catalogs with identical static keys and parameters.
- Migrate static labels, headings, buttons, hints, titles, and enum values across all UI domains.
- Keep runtime-generated messages and logging behind an explicitly deprecated compatibility adapter.
- Add automated checks for missing static keys, parameter mismatches, hard-coded UI text, and Traditional-only characters in Simplified resources.
- Add regression tests for the known mixed-script entry and static UI localization.
- Preserve existing language preference values so saved settings continue to work.
- Exclude structured operation outcomes, dynamic operation-plan content, and localized log events; those move to `migrate-structured-localized-messages`.

## Capabilities

### New Capabilities

- `localized-interface`: Defines complete static UI locale resources, semantic keys, locale resolution, compatibility boundaries, and automated localization quality checks.

### Modified Capabilities

None.

## Impact

- `lib/core/localization/app_localizations.dart`
- Flutter localization configuration and locale resource files
- Static UI call sites
- Localization and widget tests
- `pubspec.yaml` and `l10n.yaml`
