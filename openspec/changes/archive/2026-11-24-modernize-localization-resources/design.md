# Design

## Context

See `proposal.md` for motivation. Static UI calls have been moved to generated ARB resources. Runtime-generated messages, operation outcomes, and logs still depend on a temporary compatibility adapter and are intentionally excluded from this change.

## Goals / Non-Goals

**Goals:**

- Make locale completeness and script correctness mechanically verifiable.
- Keep every static UI string usable through generated resources.
- Preserve current English, Simplified Chinese, Traditional Chinese, and follow-system behavior.
- Make a later locale addition a resource-and-registration task rather than a UI rewrite.

**Non-Goals:**

- Add another user-visible language in this change.
- Redesign the language-selection screen.
- Translate repository names, branch names, paths, commit messages, remote URLs, or raw Git output.
- Provide live language switching for historical log entries.
- Replace dynamic operation outcomes, operation-plan content, or log events.
- Remove the compatibility adapter in this change.

## Decisions

### Use Flutter generated ARB resources

Add English, Simplified Chinese, and Traditional Chinese ARB resources and generated localization accessors. Use explicit script variants `en`, `zh_Hans`, and `zh_Hant` internally while preserving the existing settings preference values and follow-system behavior.

Alternatives considered:

- Keep a handwritten semantic-key map. This avoids code generation but leaves completeness and placeholder checks custom and less visible.
- Continue using Chinese source sentences as keys. This minimizes the initial diff but preserves ambiguous keys, fallback leakage, and the same maintenance problem.

Generated resources are preferred because missing accessors become build or validation failures and parameter types are checked at call sites.

### Migrate static UI domains and isolate runtime messages

Migrate settings, explorer, project shell, operation-plan labels, repository synchronization, updates, and dialogs in bounded static-text groups. Runtime-generated messages remain behind a deprecated adapter listed in an explicit allowlist.

The adapter, old dynamic translation logic, and automatic script conversion are removed by the separate `migrate-structured-localized-messages` change after all runtime messages have semantic templates and event identifiers.

### Protect scripts and vocabulary through two checks

Use a disallowed Traditional-only character list for Simplified Chinese resources and the inverse rule for explicitly Simplified-only forms in Traditional Chinese. Keep a narrow allowlist for product names, language names, commands, and approved technical terms. Add a terminology test for high-impact vocabulary such as file, folder, repository, remote, branch, commit, push, and operation plan.

This catches the known `获取全部远端` to `取得全部遠端` defect while avoiding an unsafe assumption that every shared Han character is invalid in one script.

### Detect bypasses in source

Add a repository test or analysis script that scans UI source for user-visible string literals outside localization resources. It will flag Chinese literals and likely user-facing English labels, with allowlists for keyboard keys, Git command names, format examples, and diagnostic event identifiers.

The check is intentionally source-aware rather than a blanket CJK scan because dynamic technical values and tests legitimately contain Chinese text.

## Risks / Trade-offs

- The initial migration produces a large diff and can change wording → Migrate and test by domain, use localization goldens, and review translation-only changes separately from behavior changes.
- A temporary compatibility layer can become permanent → Mark it deprecated, restrict it to migrated keys, and make its removal an explicit final task and test.
- Script linting can produce false positives for valid shared characters → Use Traditional-only forms, a reviewed glossary, and a narrowly documented allowlist.
- Generated localization changes the build workflow → Add generation and validation to developer and CI commands before migrating call sites.
- A missing key may fall back during development → Fail CI when the untranslated-messages report is non-empty and add tests for all supported locales.

## Migration Plan

1. Add localization generation configuration and the three ARB catalogs.
2. Inventory existing keys, extract parameters, and create a reviewed mapping to semantic IDs.
3. Introduce the generated API and temporary compatibility adapter.
4. Migrate static UI call sites by domain while running tests after each domain.
5. Fix known mixed-script text and add script/vocabulary/static-source checks.
6. Keep runtime-message compatibility explicit in an allowlist and document the follow-up change.
7. Run full tests and build all supported font-size localization goldens.

Rollback is possible while the static migration and compatibility adapter coexist: restore a static call site to its prior source lookup, then remove the generated key usage. Runtime-message rollback remains independent.

## Open Questions

None blocking. The exact approved glossary and source-scan allowlist can be finalized during implementation without changing the architecture or requirements.
