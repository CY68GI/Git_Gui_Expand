import 'dart:convert';
import 'dart:io';

class LocalizationValidationException implements Exception {
  const LocalizationValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

Future<int> validateLocalizationCatalogs({
  required Directory arbDirectory,
  required File report,
}) async {
  final catalogs = <String, Map<String, dynamic>>{};
  for (final locale in const ['en', 'zh_Hans', 'zh_Hant']) {
    final file = File('${arbDirectory.path}/app_$locale.arb');
    if (!await file.exists()) {
      _fail('Missing ARB catalog: ${file.path}');
    }
    final decoded = jsonDecode(await file.readAsString());
    if (decoded is! Map<String, dynamic>) {
      _fail('ARB catalog is not a JSON object: ${file.path}');
    }
    catalogs[locale] = decoded;
  }

  final templateKeys = _messageKeys(catalogs['en']!);
  for (final locale in const ['zh_Hans', 'zh_Hant']) {
    final keys = _messageKeys(catalogs[locale]!);
    final missing = templateKeys.difference(keys);
    final extra = keys.difference(templateKeys);
    if (missing.isNotEmpty) {
      _fail('$locale is missing keys: ${missing.join(', ')}');
    }
    if (extra.isNotEmpty) {
      _fail('$locale has keys absent from en: ${extra.join(', ')}');
    }
    for (final key in templateKeys) {
      final expected = _placeholders('${catalogs['en']![key]}');
      final actual = _placeholders('${catalogs[locale]![key]}');
      if (!_sameSet(expected, actual)) {
        _fail(
          '$locale placeholder mismatch for $key: '
          'en=${expected.join(',')} actual=${actual.join(',')}',
        );
      }
    }
  }

  if (await report.exists()) {
    final text = (await report.readAsString()).trim();
    if (text.isNotEmpty && text != '{}') {
      _fail('Untranslated localization messages remain: $text');
    }
  }
  return templateKeys.length;
}

Set<String> _messageKeys(Map<String, dynamic> catalog) =>
    catalog.keys.where((key) => !key.startsWith('@')).toSet();

Set<String> _placeholders(String message) {
  return RegExp(r'\{([A-Za-z_][A-Za-z0-9_]*)\}')
      .allMatches(message)
      .map((match) => match.group(1)!)
      .toSet();
}

bool _sameSet(Set<String> left, Set<String> right) =>
    left.length == right.length && left.containsAll(right);

Never _fail(String message) {
  throw LocalizationValidationException(message);
}
