import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final catalog = jsonDecode(
    await File('lib/l10n/app_en.arb').readAsString(),
  ) as Map<String, dynamic>;
  final keys = catalog.keys.where((key) => !key.startsWith('@')).toList()
    ..sort();
  final output = StringBuffer()
    ..writeln("import 'app_l10n.dart';")
    ..writeln()
    ..writeln(
      'String localizeAppMessage('
      'AppL10n l10n, String key, [Map<String, Object?> values = const {}]) {',
    )
    ..writeln('  switch (key) {');
  for (final key in keys) {
    final metadata = catalog['@$key'];
    final placeholders = metadata is Map<String, dynamic>
        ? metadata['placeholders']
        : null;
    final params = placeholders is Map<String, dynamic>
        ? (placeholders.keys.toList()..sort())
        : const <String>[];
    output.writeln("    case '$key':");
    if (params.isEmpty) {
      output.writeln('      return l10n.$key;');
    } else {
      final arguments = params
          .map((param) => "values['$param']?.toString() ?? ''")
          .join(', ');
      output.writeln('      return l10n.$key($arguments);');
    }
  }
  output
    ..writeln('    default:')
    ..writeln(
      "      throw ArgumentError.value(key, 'key', 'Unknown localization key');",
    )
    ..writeln('  }')
    ..writeln('}')
    ..writeln()
    ..writeln('Set<String> appMessageParameters(String key) {')
    ..writeln('  switch (key) {');
  final parameterMap = <String, List<String>>{};
  for (final key in keys) {
    final metadata = catalog['@$key'];
    final placeholders = metadata is Map<String, dynamic>
        ? metadata['placeholders']
        : null;
    final params = placeholders is Map<String, dynamic>
        ? (placeholders.keys.toList()..sort())
        : const <String>[];
    if (params.isEmpty) continue;
    parameterMap[key] = params;
  }
  for (final entry in parameterMap.entries) {
    output.writeln(
      "    case '${entry.key}': return const {${entry.value.map((value) => "'$value'").join(', ')}};",
    );
  }
  output
    ..writeln('    default: return const <String>{};')
    ..writeln('  }')
    ..writeln('}');
  await File('lib/l10n/app_l10n_registry.dart')
      .writeAsString(output.toString(), flush: true);
  stdout.writeln('Generated localization registry for ${keys.length} keys.');
}
