import 'package:flutter/foundation.dart';

import '../../l10n/app_l10n_registry.dart';
import '../utils/credential_redactor.dart';
import 'app_localizations.dart';

@immutable
class LocalizedMessage {
  LocalizedMessage({
    required this.key,
    Map<String, Object?> parameters = const {},
    this.eventId = '',
    Map<String, String> technicalDetails = const {},
  }) : parameters = Map.unmodifiable(parameters),
       technicalDetails = Map.unmodifiable(
         technicalDetails.map(
           (name, value) => MapEntry(name, redactCredentials(value)),
         ),
       ) {
    final required = appMessageParameters(key);
    final missing =
        required
            .where((parameter) => !this.parameters.containsKey(parameter))
            .toList()
          ..sort();
    if (missing.isNotEmpty) {
      throw ArgumentError.value(
        key,
        'key',
        'Missing localization parameters: ${missing.join(', ')}',
      );
    }
  }

  final String key;
  final Map<String, Object?> parameters;
  final String eventId;
  final Map<String, String> technicalDetails;

  String resolve(AppLocalizations localizations) {
    return localizations.tr(key, parameters);
  }

  LocalizedMessage copyWith({
    String? key,
    Map<String, Object?>? parameters,
    String? eventId,
    Map<String, String>? technicalDetails,
  }) {
    return LocalizedMessage(
      key: key ?? this.key,
      parameters: parameters ?? this.parameters,
      eventId: eventId ?? this.eventId,
      technicalDetails: technicalDetails ?? this.technicalDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocalizedMessage &&
        other.key == key &&
        mapEquals(other.parameters, parameters) &&
        other.eventId == eventId &&
        mapEquals(other.technicalDetails, technicalDetails);
  }

  @override
  int get hashCode => Object.hash(
    key,
    Object.hashAll(
      parameters.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
    eventId,
    Object.hashAll(
      technicalDetails.entries.map(
        (entry) => Object.hash(entry.key, entry.value),
      ),
    ),
  );
}
