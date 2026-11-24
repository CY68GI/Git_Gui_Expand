# Tasks

## 1. Markdown Parsing Foundation

- [x] 1.1 Add and pin a maintained Markdown parser dependency behind a small document-loading adapter; verify dependency resolution and an empty parse smoke test.
- [x] 1.2 Create a representative fixture with headings, paragraphs, emphasis, links, code, nested lists, quotes, tables, rules, escapes, and unsafe inputs; verify parser tests assert each semantic node type.
- [x] 1.3 Disable raw HTML execution and add fixture cases for HTML, script, `javascript:`, `data:`, `file:`, and arbitrary local paths; verify tests confirm they cannot trigger actions.

## 2. Flutter Block and Inline Rendering

- [x] 2.1 Implement reusable block widgets for headings, paragraphs, lists, quotes, fenced code, tables, and horizontal rules; verify widget tests find each element.
- [x] 2.2 Implement inline spans for emphasis, strong text, strikethrough, inline code, links, and escaped characters; verify nested-list and mixed-inline fixture tests.
- [x] 2.3 Make multi-line code blocks visually coherent and horizontally safe, and make wide tables horizontally scrollable; verify constrained-width widget tests have no exceptions or overflow.
- [x] 2.4 Replace the old line parser in the guide dialog and delete its backtick-stripping behavior; verify no raw Markdown markers appear in the fixture rendering.

## 3. Localized Guide Loading

- [x] 3.1 Load and cache English, Simplified Chinese, and Traditional Chinese guide documents by active locale; verify switching locale loads the matching document once without flashing stale content.
- [x] 3.2 Add a localized load-error state with retry behavior; verify an unavailable fixture asset produces an actionable error and no partial document.
- [x] 3.3 Keep the active guide title, language, and asset footer synchronized with the loaded document; verify widget tests for all three locales.

## 4. Link and Navigation Behavior

- [x] 4.1 Extract or reuse a single HTTPS-only external-link service for guide links; verify a tapped HTTPS link is passed to the browser service exactly once.
- [x] 4.2 Resolve approved relative Markdown guide links and heading fragments without accessing arbitrary files; verify valid guide switching and anchor cases.
- [x] 4.3 Keep unsafe or unsupported links inert and expose no misleading tap action; verify the unsafe-link fixture and accessibility semantics tests.

## 5. Typography, Selection, and Accessibility

- [x] 5.1 Apply the selected application font to guide content with an appropriate monospace fallback for code; verify selected-font widget coverage.
- [x] 5.2 Preserve selectable text and verify copying formatted content does not include Markdown delimiters; verify selection/copy widget tests.
- [x] 5.3 Make links keyboard-focusable with visible focus and meaningful labels; verify keyboard navigation and semantics tests.
- [x] 5.4 Add light/dark and minimum/default/maximum font-size golden or layout tests; verify no essential content or controls overflow.

## 6. Guide Content and Developer Documentation

- [x] 6.1 Update the three user guides with representative examples of supported formatting and safe links; verify each guide renders without raw Markdown markers.
- [x] 6.2 Document how to add a guide, heading anchor, local image, or approved link in the project documentation; verify each documented example is covered by the fixture or guide tests.

## 7. Integration Verification

- [x] 7.1 Run `flutter analyze`, parser tests, widget tests, golden tests, accessibility tests, and a Windows release build; verify all supported locales and font sizes render the complete guide.
- [x] 7.2 Open every bundled guide in the built application in both themes and exercise safe external and internal links; verify the observed result matches the rendered test fixtures.
