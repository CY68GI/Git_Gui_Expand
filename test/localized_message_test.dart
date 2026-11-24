import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/localization/localized_message.dart';
import 'package:git_gui_expand/core/utils/credential_redactor.dart';

void main() {
  test('structured messages preserve opaque parameter values', () {
    final message = LocalizedMessage(
      key: 'versionV',
      parameters: {'version': 'feature/{safe}'},
      eventId: 'application.opened',
      technicalDetails: {'cwd': r'C:\Repository'},
    );

    final rendered = message.resolve(
      const AppLocalizations(AppLocalizations.english),
    );

    expect(rendered, contains('feature/{safe}'));
    expect(message.eventId, 'application.opened');
    expect(message.technicalDetails['cwd'], r'C:\Repository');
  });

  test('missing parameters fail before presentation', () {
    expect(() => LocalizedMessage(key: 'versionV'), throwsArgumentError);
  });

  test('credential redaction preserves non-secret URL content', () {
    expect(
      redactCredentials('https://user:secret@example.com/team/repository.git'),
      'https://***@example.com/team/repository.git',
    );
    expect(
      redactCredentials('Authorization: Basic abc123\nNext line'),
      'Authorization: ***\nNext line',
    );
  });
}
