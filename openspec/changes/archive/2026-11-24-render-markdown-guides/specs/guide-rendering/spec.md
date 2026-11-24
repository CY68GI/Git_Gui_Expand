# Spec Delta

## Purpose

Defines how bundled Markdown user guides are selected, parsed, rendered, linked, and tested so readers see formatted documentation instead of raw markup.

## ADDED Requirements

### Requirement: Guides load by active locale

The system SHALL display the bundled guide associated with the active language and MUST provide English, Simplified Chinese, and Traditional Chinese guides.

#### Scenario: Open the guide in each supported language

- **WHEN** the user opens the guide while English, Simplified Chinese, or Traditional Chinese is active
- **THEN** the corresponding complete guide is loaded without mixing guide languages

#### Scenario: A guide asset is unavailable

- **WHEN** the selected guide cannot be loaded
- **THEN** the dialog shows a localized actionable error and does not display partially parsed content

### Requirement: Markdown is rendered structurally

The system SHALL parse Markdown into document structure and render supported block and inline elements with their intended appearance instead of exposing Markdown control characters as ordinary text.

#### Scenario: Render common formatting

- **WHEN** a guide contains headings, paragraphs, emphasis, inline code, fenced code blocks, ordered lists, unordered lists, nested lists, block quotes, tables, links, and horizontal rules
- **THEN** each element is displayed as its corresponding formatted interface element

#### Scenario: Inline markup is nested

- **WHEN** inline emphasis, code, or a link appears inside a list item or another supported block
- **THEN** selection, wrapping, and spacing remain correct without overlapping text

#### Scenario: A code block spans multiple lines

- **WHEN** a fenced code block contains multiple lines
- **THEN** the lines render as one visually coherent, horizontally safe code block with preserved whitespace

### Requirement: Markdown links are safe

The system SHALL allow only approved link behavior and MUST NOT execute raw HTML, scripts, local-file protocols, or unvalidated URL schemes from bundled guides.

#### Scenario: Open an HTTPS link

- **WHEN** the user activates an HTTPS link in the guide
- **THEN** the system opens it in the default browser through the approved external-link service

#### Scenario: Open a bundled relative guide link

- **WHEN** the user activates a relative link to another bundled Markdown guide
- **THEN** the system resolves it within the approved guide assets and does not access arbitrary local paths

#### Scenario: Encounter an unsafe link

- **WHEN** a guide contains HTML or a link with a protocol other than the approved external or bundled-relative schemes
- **THEN** the content is rendered as inert text or omitted and no external action occurs

### Requirement: Guide typography remains readable

The rendered guide SHALL use the selected application font, remain legible in light and dark themes, and preserve layout at every supported font-size setting.

#### Scenario: Use the largest supported font size

- **WHEN** the guide is viewed at the maximum supported font size in a standard desktop window
- **THEN** headings, code, tables, and controls remain readable and provide scrolling instead of clipping essential content

#### Scenario: Use the smallest supported font size

- **WHEN** the guide is viewed at the minimum supported font size
- **THEN** body text remains readable and no content becomes hidden through a layout overflow

### Requirement: Guide content is selectable and accessible

The system SHALL expose guide text for selection and screen readers, and interactive links MUST be keyboard reachable with meaningful labels.

#### Scenario: Select and copy guide text

- **WHEN** the user selects formatted guide content
- **THEN** the visible textual content can be copied without including unintended Markdown formatting characters

#### Scenario: Navigate links by keyboard

- **WHEN** keyboard focus reaches a guide link
- **THEN** the link has visible focus and can be activated without a pointer

### Requirement: Rendering is covered by regression tests

The project SHALL test representative Markdown fixtures and visual layouts so parser or style changes cannot silently revive raw Markdown output or break readability.

#### Scenario: Run Markdown fixture tests

- **WHEN** the test suite renders the representative fixture
- **THEN** all supported element types are present with their expected semantic structure and unsafe syntax remains inert

#### Scenario: Run theme and font-size visual tests

- **WHEN** golden or layout tests render the guide in light and dark themes at supported font sizes
- **THEN** no prohibited overflow occurs and essential controls remain visible
