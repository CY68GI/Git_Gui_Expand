import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../repository/repository_controller.dart';

void showAppOutcomeSnackBar(
  BuildContext context,
  OperationOutcome outcome, {
  VoidCallback? onViewLogs,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final localizedMessage = context.l10n.tr(outcome.message);
  final isLongFailure = !outcome.isSuccess && localizedMessage.length > 520;
  final displayMessage = isLongFailure
      ? '${localizedMessage.substring(0, 520)}…\n${context.l10n.tr('详细原因已写入操作日志。')}'
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
                color: Colors.white,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  displayMessage,
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: outcome.isSuccess
            ? const Color(0xFF1C3D35)
            : const Color(0xFF7B3434),
        duration: Duration(seconds: outcome.isSuccess ? 5 : 10),
        showCloseIcon: true,
        closeIconColor: Colors.white,
        action: isLongFailure && onViewLogs != null
            ? SnackBarAction(
                label: context.l10n.tr('查看日志'),
                textColor: Colors.white,
                onPressed: onViewLogs,
              )
            : null,
      ),
    );
}
