import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/external_link_service.dart';

void main() {
  test('opens an HTTPS URL through the injected launcher', () async {
    final opened = <String>[];
    final service = ExternalLinkService(
      launcher: (url) async => opened.add(url),
    );

    await service.openExternalUrl('https://git-scm.com/download/win');

    expect(opened, ['https://git-scm.com/download/win']);
  });

  test('rejects non-HTTPS URLs', () async {
    final opened = <String>[];
    final service = ExternalLinkService(
      launcher: (url) async => opened.add(url),
    );

    await expectLater(
      service.openExternalUrl('file:///C:/secret.txt'),
      throwsA(isA<FormatException>()),
    );
    await expectLater(
      service.openExternalUrl('https://'),
      throwsA(isA<FormatException>()),
    );
    expect(opened, isEmpty);
  });
}
