# Tasks

## 1. Localization Infrastructure

- [x] 1.1 Add Flutter localization generation configuration and English, Simplified Chinese, and Traditional Chinese ARB resources; verify generation succeeds with `flutter gen-l10n`.
- [x] 1.2 Configure the build to fail when the untranslated-messages report contains any generated key; verify a deliberately missing temporary test key makes the check fail.
- [x] 1.3 Update locale resolution for `en`, `zh_Hans`, `zh_Hant`, and follow-system behavior while preserving existing preference values; verify locale-resolution and saved-settings tests pass.

## 2. Key Inventory and Resource Content

- [x] 2.1 Inventory every current `.tr()` call and dynamic message pattern, record parameters and duplicate source strings, and produce a reviewed semantic-key mapping; verify the inventory has no unclassified production call sites.
- [x] 2.2 Create the complete three-locale catalogs from the mapping and correct the known Simplified Chinese entry `获取全部远端`; verify the Simplified and Traditional resources contain their declared scripts.
- [x] 2.3 Add tests for catalog key equality, parameter equality, language preference compatibility, and the corrected mixed-script regression; verify all localization resource tests pass.
- [x] 2.4 Document the semantic-key naming rules, parameter rules, Chinese glossary, and allowlist policy in `docs/LOCALIZATION.md`; verify every documented example exists in a resource or test.

## 3. Generated API and Migration Bridge

- [x] 3.1 Replace the custom localization delegate with the generated localization accessors and a context extension; verify Material, Cupertino, and Widgets localization delegates still build.
- [x] 3.2 Add a temporary compatibility adapter for not-yet-migrated source-string messages and mark it deprecated; verify new production files fail the source check if they use the adapter.
- [x] 3.3 Migrate language settings and follow-system labels first; verify all language options and automatic system-language behavior in widget tests.

## 4. UI Migration

- [x] 4.1 Migrate static Settings, About, font, appearance, and unit labels to semantic resources; verify dialog widget and visual-layout tests.
- [x] 4.2 Migrate static start page, recent repository, repository bootstrap, and project shell labels to semantic resources; verify localization tests for Simplified and Traditional Chinese and English.
- [x] 4.3 Migrate static explorer, operation-plan, commit, branch, Stash, remote, and synchronization labels to semantic resources; verify operation-plan and repository-sync widget tests.

## 5. Quality Gates

- [x] 5.1 Add a scripted check for Traditional-only forms in Simplified Chinese resources and Simplified-only forms in Traditional Chinese resources with a narrow reviewable allowlist; verify it rejects the former mixed-script value.
- [x] 5.2 Add a source-aware scan for static user-visible literals and unapproved compatibility-adapter use; verify it flags representative bad fixtures and accepts approved technical values.
- [x] 5.3 Add vocabulary consistency tests for file, folder, repository, remote, branch, commit, push, operation plan, and update terminology; verify all three languages use the approved glossary.
- [x] 5.4 Add localization checks to the normal test workflow and document the local command; verify the workflow fails on a missing key and passes on the completed catalogs.

## 6. Preserve the Runtime-Message Boundary

- [x] 6.1 Verify the compatibility adapter is referenced only by allowlisted runtime-message and logging boundaries; verify a new static UI use fails the source check.
- [x] 6.2 Run `flutter analyze`, the full test suite, locale-specific widget tests, and a release build; verify there are no missing static keys, layout overflows, or untranslated static UI messages.
