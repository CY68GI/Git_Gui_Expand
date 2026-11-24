# Design

## Context

See `proposal.md` for motivation. The current dialog loads one of three bundled Markdown assets and passes raw text to a 150-line line parser. That parser recognizes a small heading, list, and code-block subset, removes backticks indiscriminately, and has no link, table, block-quote, nested-list, or inline-markup model.

## Goals / Non-Goals

**Goals:**

- Preserve the meaning and hierarchy of the bundled Markdown documents.
- Use one renderer for all supported locales, themes, fonts, and text sizes.
- Keep links explicit and safe.
- Make parser and layout regressions visible in tests.

**Non-Goals:**

- Add an in-application Markdown editor.
- Render arbitrary HTML.
- Download remote guide content at runtime.
- Support plugins, scripts, embedded video, or interactive forms.
- Change the content scope of the guides beyond formatting and navigation fixes.

## Decisions

### Parse a document tree, then render Flutter widgets

Use a maintained Markdown parser to produce a document/AST and implement one Flutter mapping for document blocks and inline nodes. Enable the GitHub-flavored extension set needed for tables and strikethrough, but do not render raw HTML.

Alternatives considered:

- Extend the existing line parser. Each new construct requires regex and line-state logic, and nested inline nodes remain unreliable.
- Put Markdown text directly into a rich-text wrapper. This still requires parsing and risks inconsistent block layout.

A parsed tree keeps security checks and visual styling independent from the syntax parser.

### Cache parsed guides by asset and locale

Load and parse each guide once, then reuse the parsed document while the locale is unchanged. The selection path remains the source of truth for `en`, `zh`, and `zh_Hant`.

This avoids reparsing and progress flicker when the dialog rebuilds because of theme, font, or MediaQuery changes.

### Render semantically with shared theme tokens

Map headings, paragraphs, lists, quotes, tables, code, links, and rules to dedicated widgets or inline text spans that consume the active `ColorScheme` and text theme. Body and headings use the selected application font. Code uses a bundled or system monospace fallback and horizontal scrolling when needed.

Tables are horizontally scrollable at constrained widths. Long words and URLs wrap or scroll without overflowing the dialog. Selection remains available across rendered text.

### Restrict link behavior by category

Classify links before activation:

- `https://` links open through the shared external-link service.
- Relative `.md` links resolve only against the known bundled guide assets and switch the displayed guide.
- Fragment links can scroll to an internal heading when a matching anchor exists.
- Other schemes, raw HTML, and paths outside the approved asset set remain inert.

The renderer does not infer an external action merely because a target looks like a URL.

### Test structure separately from appearance

Parser tests use a representative fixture containing every supported element, escaped Markdown characters, unsafe links, nested lists, and a multi-line code block. Widget/golden tests cover the actual guides in light and dark themes at the supported font-size bounds. Accessibility tests verify focusable links and selectable text.

Parser tests do not depend on exact pixel layout; visual tests do not substitute for checking the semantic element mapping.

## Risks / Trade-offs

- The parser dependency may change API or maintenance status → Pin a compatible version, wrap parsing behind one adapter, and add fixture tests that make replacement straightforward.
- Full Markdown support can create unsafe or visually noisy output → Disable raw HTML, classify links, constrain media, and use the application's typography rather than arbitrary inline styles.
- Wide tables and unbroken URLs can overflow → Use horizontal scrolling and controlled wrapping at every font size.
- Rich text can reduce text selection reliability → Keep block widgets selection-friendly and add select/copy widget tests.
- Multiple guide links can create confusing locale changes → Only switch among known bundled guide assets and keep the dialog title tied to the active language.

## Migration Plan

1. Add and pin the parser dependency behind a small document-loading adapter.
2. Implement the Flutter node mapping and remove the old line parser.
3. Add safe link classification and locale-aware asset loading.
4. Extend the three guides with fixture-covered formatting only where useful to users.
5. Add parser, widget, accessibility, and golden tests.
6. Verify light/dark themes, all supported fonts and font sizes, and external-link behavior.

Rollback consists of restoring the previous dialog implementation and assets; no user data or persisted setting schema changes are involved.

## Open Questions

None blocking. The exact parser dependency version will be chosen and verified against the project SDK during implementation without changing the rendering contract.
