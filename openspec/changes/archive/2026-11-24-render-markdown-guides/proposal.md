# Proposal

## Why

The bundled user guides are Markdown documents, but the guide dialog renders them with a small line-based parser that leaves common Markdown syntax visible and cannot represent links, tables, nested lists, block quotes, or inline formatting correctly.

## What Changes

- Replace the ad hoc line parser with one Markdown rendering path based on parsed document structure.
- Render headings, paragraphs, emphasis, inline code, fenced code blocks, ordered and unordered nested lists, block quotes, tables, horizontal rules, and safe links.
- Load the guide matching the selected English, Simplified Chinese, or Traditional Chinese locale.
- Route HTTPS links through the existing external-link capability and handle bundled relative Markdown links without allowing unsafe protocols or raw HTML execution.
- Preserve selection, scrolling, keyboard accessibility, theme colors, custom fonts, and safe font scaling.
- Add representative Markdown fixture tests and visual regression tests for light and dark themes and supported font sizes.

## Capabilities

### New Capabilities

- `guide-rendering`: Defines correct Markdown presentation, locale-specific guide selection, safe link behavior, and accessibility requirements for bundled guides.

### Modified Capabilities

None.

## Impact

- `lib/features/dialogs/user_guide_dialog.dart`
- Bundled guide assets under `docs/`
- External-link handling shared with updates and settings
- Markdown parsing dependency and Flutter rendering widgets
- Widget, golden, and accessibility tests
