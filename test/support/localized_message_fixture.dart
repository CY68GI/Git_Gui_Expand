import 'package:flutter/widgets.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/localization/localized_message.dart';
import 'package:git_gui_expand/core/localization/runtime_messages.dart';

LocalizedMessage fixtureMessage(
  String target, {
  String eventId = 'test.fixture',
  Map<String, String> technicalDetails = const {},
}) {
  return RuntimeMessages.operationCompletedFor(
    target,
    eventId: eventId,
    technicalDetails: technicalDetails,
  );
}

LocalizedMessage fixturePlanTitle(String target) {
  return RuntimeMessages.messageFor(
    'operationCompletedFor',
    parameters: {'target': target},
    eventId: 'test.plan.title',
  );
}

LocalizedMessage fixturePlanDescription(String target) {
  return RuntimeMessages.messageFor(
    'operationCompletedFor',
    parameters: {'target': target},
    eventId: 'test.plan.description',
  );
}

String fixtureText(
  LocalizedMessage message, {
  Locale locale = AppLocalizations.english,
}) {
  return message.resolve(AppLocalizations(locale));
}
