import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/validate_localization_source.dart';

void main() {
  test(
    'source validator rejects legacy and formatted runtime messages',
    () async {
      final root = await Directory.systemTemp.createTemp('l10n_source_');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final l10n = Directory('${root.path}/lib/l10n');
      final ui = Directory('${root.path}/lib/ui');
      await l10n.create(recursive: true);
      await ui.create(recursive: true);
      await File('${l10n.path}/app_en.arb')
          .writeAsString('{"knownKey":"Known"}');
      await File('${ui.path}/invalid.dart').writeAsString(r'''
final legacy = localizations.legacyText('old sentence');
final outcome = OperationOutcome.success('formatted result');
final log = logger.info('area', 'formatted log');
final unknown = RuntimeMessages.messageFor('unknownKey');
''');

      final findings = await validateLocalizationSource(projectRoot: root);

      expect(findings, hasLength(greaterThanOrEqualTo(4)));
      expect(findings.join('\n'), contains('legacy sentence translation'));
      expect(findings.join('\n'), contains('operation outcome'));
      expect(findings.join('\n'), contains('formatted display sentence'));
      expect(findings.join('\n'), contains('unknown runtime message key'));
    },
  );
}
