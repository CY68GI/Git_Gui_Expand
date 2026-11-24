# Localization Guide

Git GUI Expand uses Flutter `gen-l10n` resources:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_zh_Hans.arb`
- `lib/l10n/app_zh_Hant.arb`

`app_zh.arb` is the required base-locale fallback for Flutter and must stay
identical to `app_zh_Hans.arb`.

## Key naming

Keys describe meaning, not source-language sentences.

- Use lower camel case: `openRepository`, `saveSettings`,
  `fetchAllRemotes`.
- Include the feature when a label is ambiguous:
  `gitRuntimeUnavailable`, `operationPlanConfirmation`.
- Do not use Chinese source text, English display text, hashes, or numeric
  timestamps as keys.
- Reuse an existing key only when every context can use the same wording.

## Parameters

Values are positional generated parameters and must use the same placeholder
name in every locale. For example:

```text
foundItemsAndCanBeFreed
Removed {count} items and freed {size}.
```

Paths, branch names, remote URLs, commit messages, and raw Git output are
opaque values. They must never be translated or used to select another key.

## Chinese glossary

| Concept | zh_Hans | zh_Hant |
|---|---|---|
| file | 文件 | 檔案 |
| folder | 文件夹 | 資料夾 |
| repository | 仓库 | 儲存庫 |
| remote | 远端 | 遠端 |
| branch | 分支 | 分支 |
| commit | 提交 | 提交 |
| push | 推送 | 推送 |
| operation plan | 操作计划 | 操作計畫 |
| update | 更新 | 更新 |

`zh_Hans` must not contain Traditional-only forms such as `遠`, `檔`, `設`,
`關`, `刪`, or `倉`. `zh_Hant` is authored independently and must not be
produced by runtime character substitution.

## Allowlists

The source scanner permits:

- Git commands such as `git clone`, `git stash`, and `git push`;
- product names such as `Git GUI Expand`, `GitHub`, and `Gitee`;
- keyboard keys and format examples;
- stable technical or diagnostic identifiers;
- test fixtures that deliberately represent another locale.

Language names such as `简体中文` and `繁體中文` may appear in the language
selector because they are intentionally written in their own scripts.

## Validation

Run:

```powershell
flutter gen-l10n
dart run tool/validate_localizations.dart --arb-dir lib/l10n --report build/l10n_untranslated.json
flutter test test/localization_resources_test.dart
dart run tool/validate_localization_scripts.dart lib/l10n
dart run tool/validate_localization_source.dart
```

The generated `build/l10n_untranslated.json` must be `{}`. Any missing key,
parameter mismatch, mixed Chinese script, or unlocalized user-facing literal
fails validation.
