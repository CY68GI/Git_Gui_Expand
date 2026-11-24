import 'localized_message.dart';

/// Central factories for runtime-visible messages.
///
/// Values inserted into [LocalizedMessage.parameters] remain opaque. Keep raw
/// paths, branches, remotes, URLs, counts, and Git diagnostics in technical
/// details unless a localized template explicitly presents them to the user.
abstract final class RuntimeMessages {
  static LocalizedMessage message(
    String key, {
    Map<String, Object?> parameters = const {},
    String eventId = '',
    Map<String, String> technicalDetails = const {},
  }) {
    return LocalizedMessage(
      key: key,
      parameters: parameters,
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static LocalizedMessage operationCompleted({
    String eventId = '',
    Map<String, String> technicalDetails = const {},
  }) {
    return message(
      'operationCompleted',
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static LocalizedMessage operationCompletedFor(
    String target, {
    String eventId = '',
    Map<String, String> technicalDetails = const {},
  }) {
    return message(
      'operationCompletedFor',
      parameters: {'target': target},
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static LocalizedMessage operationCompletedForItems(
    int count, {
    String eventId = '',
    Map<String, String> technicalDetails = const {},
  }) {
    return message(
      'operationCompletedForItems',
      parameters: {'count': count},
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static LocalizedMessage operationFailed(
    Object error, {
    String eventId = '',
    String? target,
    Map<String, String> technicalDetails = const {},
  }) {
    final message = _cleanError(error);
    return messageFor(
      target == null ? 'operationFailed' : 'operationFailedFor',
      parameters: target == null
          ? {'error': message}
          : {'error': message, 'target': target},
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static LocalizedMessage messageFor(
    String key, {
    Map<String, Object?> parameters = const {},
    String eventId = '',
    Map<String, String> technicalDetails = const {},
  }) {
    return message(
      key,
      parameters: parameters,
      eventId: eventId,
      technicalDetails: technicalDetails,
    );
  }

  static String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('GitException: ', '')
        .trim();
  }
}
