import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/localization_validator.dart';

void main() {
  test('localization validator fails on a deliberately missing key', () async {
    final root = await Directory.systemTemp.createTemp('l10n_validation_');
    addTearDown(() async {
      if (await root.exists()) await root.delete(recursive: true);
    });
    await File('${root.path}${Platform.pathSeparator}app_en.arb')
        .writeAsString(jsonEncode({'hello': 'Hello', 'goodbye': 'Goodbye'}));
    await File('${root.path}${Platform.pathSeparator}app_zh_Hans.arb')
        .writeAsString(jsonEncode({'hello': '你好'}));
    await File('${root.path}${Platform.pathSeparator}app_zh_Hant.arb')
        .writeAsString(jsonEncode({'hello': '你好', 'goodbye': '再見'}));
    final report = File(
      '${root.path}${Platform.pathSeparator}untranslated.json',
    );
    await report.writeAsString('{}');

    await expectLater(
      validateLocalizationCatalogs(arbDirectory: root, report: report),
      throwsA(
        isA<LocalizationValidationException>().having(
          (error) => error.message,
          'message',
          contains('missing keys'),
        ),
      ),
    );
  });
}
