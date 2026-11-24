# Structured Runtime Messages

Runtime-visible messages use a semantic localization key, named parameters, an
optional stable event ID, and optional technical details.

Example event ID:

```text
repository.open.failed
```

Example localization key and parameters:

```text
versionV
{"version": "1.2.3"}
```

Rules:

- Do not pass completed sentences to the localization layer.
- Do not translate paths, branch names, remote names, commit messages, or Git
  output.
- Keep technical details separate from display parameters.
- Redact credentials before storing or displaying URLs and authentication data.
- Use stable semantic event IDs and never derive IDs from translated text.
