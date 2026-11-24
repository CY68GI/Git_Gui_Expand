# Design

## Context

See `proposal.md` for motivation. Static UI text now uses generated ARB resources, while a deprecated adapter still handles runtime-generated operation results, plan content, and logs. The remaining migration touches controller models, dialog presentation, logging, and approximately 187 logging call sites.

## Goals / Non-Goals

**Goals:**

- Keep one immutable runtime-message representation across UI and logs.
- Preserve arbitrary values exactly.
- Separate localized human text from diagnostic technical details.
- Make event identifiers searchable without depending on translated wording.
- Remove the compatibility adapter and old regex conversion safely.

**Non-Goals:**

- Redesign the visual presentation of operation plans, logs, or result messages.
- Translate raw Git command output.
- Change Git command behavior or operation-plan safety rules.
- Add a new user-visible language.

## Decisions

### Introduce an immutable localized-message value

Represent runtime messages as an immutable value containing:

```text
key
parameters
eventId
technicalDetails
```

Resolution uses the generated ARB registry. Parameters are inserted as strings and never recursively localized. `technicalDetails` are retained for logs and failure diagnostics but are not translated.

Alternatives considered:

- Continue passing formatted sentences and infer placeholders. Rejected because values cannot be reliably separated after formatting.
- Store only event IDs. Rejected because users still need a localized result message and some events have no log record.

### Make outcomes and plans message-bearing

Change operation outcomes and planned operations to carry structured messages. UI code resolves the message against the active locale at render time; controllers do not display Chinese source text.

The plan model keeps stable identifiers and state, so changing language while a plan is queued only changes presentation. Existing execution and safety contracts are unchanged.

### Add event-aware logging APIs

Add logging methods that accept a structured event rather than a completed sentence. Each record writes:

```text
timestamp level area eventId localized-message technical-details
```

Normal logs contain the localized message and stable identifier. Detailed logs additionally retain raw command, working directory, exit code, stdout, stderr, paths, and URLs after credential redaction.

Existing plain-string logging entry points are removed or converted to structured events in the same migration so source checks can prevent reintroduction.

### Reuse the generated localization registry

All runtime keys are authored in the same ARB catalogs as static UI text. ICU placeholders remain typed strings for this migration, which preserves exact parameter text across counts, paths, and identifiers. Completeness and parameter validation use the existing localization checks.

### Migrate by domain with compile-time pressure

Convert the message model and logger APIs first, then migrate operation outcomes, plan creation, controller flows, dialogs, services, and startup/maintenance logging. Temporary overloads may exist only while call sites are being converted and are removed before the change completes.

## Risks / Trade-offs

- [Large model/API diff] → Migrate centrally first, then compile each domain and remove temporary overloads incrementally.
- [Loss of diagnostic context] → Keep technical details separate from localized parameters and assert raw Git values in tests.
- [Sensitive values leak through parameters] → Apply one shared redaction function before storing or rendering URLs and authentication details.
- [Event IDs become unstable] → Use semantic event names such as `repository.open.failed`, add tests for stable IDs, and do not derive IDs from translated text.
- [Parameter type drift] → Validate required placeholder names before message creation and through ARB catalog tests.
- [Historical logs change language] → Capture the active locale when writing each record; never retranslate existing entries.

## Migration Plan

1. Add the structured message model and generated-resource resolution.
2. Change operation outcomes and planned operations to structured message fields.
3. Add event-aware normal/detailed logging and shared credential redaction.
4. Migrate repository, plan, branch, Stash, remote, synchronization, update, settings, maintenance, and startup flows.
5. Remove the compatibility adapter, source-string dictionaries, regex translation, and automatic script conversion.
6. Enforce source checks that reject legacy adapter usage and unregistered dynamic message construction.
7. Run full tests, language-switch tests, log-redaction tests, and a Windows release build.

Rollback can restore the deprecated adapter while migrating individual domains. Once adapter removal is committed, rollback uses a normal source revert because runtime messages no longer depend on formatted-text inference.

## Open Questions

None blocking. Exact event names and ARB key names follow the feature and domain being migrated.
