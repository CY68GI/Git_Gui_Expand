import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../repository/repository_controller.dart';

void showAppOutcomeSnackBar(
  BuildContext context,
  OperationOutcome outcome, {
  VoidCallback? onViewLogs,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final colors = Theme.of(context).colorScheme;
  final background = outcome.isSuccess ? colors.primary : colors.error;
  final foreground = outcome.isSuccess ? colors.onPrimary : colors.onError;
  final localizedMessage = outcome.message.resolve(context.l10n);
  final isLongFailure = !outcome.isSuccess && localizedMessage.length > 520;
  final displayMessage = isLongFailure
      ? '${localizedMessage.substring(0, 520)}…\n${context.l10n.tr('theDetailedReasonHasBeenWrittenToTheApplicationLog')}'
      : localizedMessage;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                outcome.isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                size: 19,
                color: foreground,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  displayMessage,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: background,
        duration: Duration(seconds: outcome.isSuccess ? 5 : 10),
        showCloseIcon: true,
        closeIconColor: foreground,
        action: isLongFailure && onViewLogs != null
            ? SnackBarAction(
                label: context.l10n.tr('viewLogs'),
                textColor: foreground,
                onPressed: onViewLogs,
              )
            : null,
      ),
    );
}
