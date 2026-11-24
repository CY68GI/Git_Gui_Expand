import 'dart:io';

import 'localization_script_validator.dart';

Future<void> main(List<String> arguments) async {
  final directory = Directory(arguments.isEmpty ? 'lib/l10n' : arguments.first);
  try {
    await validateLocalizationScripts(directory);
    stdout.writeln('Chinese localization script checks passed.');
  } on LocalizationScriptException catch (error) {
    stderr.writeln(error.message);
    exitCode = 1;
  }
}
