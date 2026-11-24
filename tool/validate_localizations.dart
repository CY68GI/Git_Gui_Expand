import 'dart:io';

import 'localization_validator.dart';

Future<void> main(List<String> arguments) async {
  final options = _arguments(arguments);
  final arbDirectory = Directory(options['arb-dir'] ?? 'lib/l10n');
  final report = File(options['report'] ?? 'build/l10n_untranslated.json');
  try {
    final count = await validateLocalizationCatalogs(
      arbDirectory: arbDirectory,
      report: report,
    );
    stdout.writeln(
      'Localization catalogs are complete: '
      '$count keys across en, zh_Hans, and zh_Hant.',
    );
  } on LocalizationValidationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}

Map<String, String> _arguments(List<String> arguments) {
  final result = <String, String>{};
  for (var index = 0; index < arguments.length; index++) {
    final value = arguments[index];
    if (!value.startsWith('--')) continue;
    final name = value.substring(2);
    if (index + 1 >= arguments.length ||
        arguments[index + 1].startsWith('--')) {
      throw LocalizationValidationException('Missing value for --$name');
    }
    result[name] = arguments[++index];
  }
  return result;
}
