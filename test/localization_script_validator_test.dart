import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/localization_script_validator.dart';

void main() {
  test(
    'script validator rejects a Traditional-only value in Simplified Chinese',
    () async {
      final root = await Directory.systemTemp.createTemp('l10n_script_');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      await File('${root.path}${Platform.pathSeparator}app_zh_Hans.arb')
          .writeAsString(jsonEncode({'fetchAllRemotes': '取得全部遠端'}));
      await File('${root.path}${Platform.pathSeparator}app_zh_Hant.arb')
          .writeAsString(jsonEncode({'fetchAllRemotes': '取得全部遠端'}));

      await expectLater(
        validateLocalizationScripts(root),
        throwsA(
          isA<LocalizationScriptException>().having(
            (error) => error.message,
            'message',
            contains('Traditional-only'),
          ),
        ),
      );
    },
  );
}
