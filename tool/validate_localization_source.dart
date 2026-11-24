import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final root = Directory.current;
  final findings = await validateLocalizationSource(projectRoot: root);
  if (findings.isNotEmpty) {
    stderr.writeln(findings.join('\n'));
    exitCode = 1;
    return;
  }
  stdout.writeln('Localization source checks passed.');
}

Future<List<String>> validateLocalizationSource({
  required Directory projectRoot,
}) async {
  final arb = jsonDecode(
    await File('${projectRoot.path}/lib/l10n/app_en.arb').readAsString(),
  ) as Map<String, dynamic>;
  final keys = arb.keys.where((key) => !key.startsWith('@')).toSet();
  final findings = <String>[];
  final forbiddenFiles = [
    'lib/core/localization/legacy_localization_adapter.dart',
    'tool/convert_hant_once.py',
    'tool/replace_dynamic_tr.dart',
    'tool/localization_source_allowlist.json',
  ];
  for (final path in forbiddenFiles) {
    if (await File('${projectRoot.path}/$path').exists()) {
      findings.add(
        '$path must not exist after the structured-message migration.',
      );
    }
  }
  await for (final entity in Directory(
    '${projectRoot.path}/lib',
  ).list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative = entity.path
        .substring(projectRoot.path.length + 1)
        .replaceAll('\\', '/');
    if (relative.startsWith('lib/l10n/') ||
        relative == 'lib/core/localization/app_localizations.dart') {
      continue;
    }
    final text = await entity.readAsString();
    if (text.contains('.legacyText(') ||
        text.contains('LegacyLocalizationAdapter')) {
      findings.add('$relative still uses legacy sentence translation.');
    }
    if (RegExp(
      r'''OperationOutcome\.(?:success|failure)\(\s*(?:const\s+)?['"]''',
    ).hasMatch(text)) {
      findings.add(
        '$relative constructs an operation outcome from a display sentence.',
      );
    }
    if (RegExp(
      r'''\.(?:info|detail|warning|error)\(\s*['"][^'"]+['"]\s*,\s*['"]''',
    ).hasMatch(text)) {
      findings.add('$relative still logs a formatted display sentence.');
    }
    for (final match in RegExp(r"\.tr\(\s*'([^']+)'").allMatches(text)) {
      final key = match.group(1)!;
      if (!keys.contains(key)) {
        findings.add('$relative references unknown localization key $key.');
      }
    }
    for (final match in RegExp(
      r"RuntimeMessages\.messageFor\(\s*'([^']+)'",
      dotAll: true,
    ).allMatches(text)) {
      final key = match.group(1)!;
      if (!keys.contains(key)) {
        findings.add('$relative references unknown runtime message key $key.');
      }
    }
    for (final match in RegExp(
      r"LocalizedMessage\(\s*key:\s*'([^']+)'",
      dotAll: true,
    ).allMatches(text)) {
      final key = match.group(1)!;
      if (!keys.contains(key)) {
        findings.add('$relative references unknown runtime message key $key.');
      }
    }
    for (final match in RegExp(
      r"(?<![A-Za-z])(?:Text|SelectableText|hintText:|label:|tooltip:)\s*\(\s*'[^'\n]*[\u3400-\u9fff]",
    ).allMatches(text)) {
      findings.add(
        '$relative:${_lineAt(text, match.start)} contains an apparently '
        'hard-coded UI literal: ${match.group(0)!.replaceAll('\n', r'\n')}',
      );
    }
  }
  return findings;
}

int _lineAt(String text, int offset) =>
    '\n'.allMatches(text.substring(0, offset)).length + 1;
