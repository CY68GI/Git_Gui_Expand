import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/localization/localized_message.dart';
import 'package:git_gui_expand/core/localization/runtime_messages.dart';
import 'package:git_gui_expand/core/models/operation_plan.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/features/dialogs/log_viewer_dialog.dart';
import 'package:git_gui_expand/features/dialogs/operation_plan_dialog.dart';
import 'package:git_gui_expand/l10n/app_l10n.dart';

import 'support/localized_message_fixture.dart';

void main() {
  test(
    'logs keep the locale captured at write time and redact secrets',
    () async {
      final root = await Directory.systemTemp.createTemp('structured_logs_');
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final logger = AppLogService(
        storage: AppStorageService(softwareDirectoryOverride: root.path),
      )..setLocale(AppLocalizations.english);

      logger.infoEvent(
        'git',
        'git.command.completed',
        details: {
          'command': 'git fetch --prune origin',
          'cwd': r'C:\Repository',
          'exitCode': '0',
          'stdout': 'raw stdout',
          'stderr': 'raw stderr',
          'url': 'https://user:secret@example.com/team/repository.git',
          'authorization': 'Authorization: Basic abc123',
        },
      );
      logger.setLocale(AppLocalizations.traditionalChinese);
      logger.warningEvent(
        'update',
        'update.network.warning',
        details: {'message': '保持原样的技术值'},
      );
      await logger.flush();

      final normal = await logger.readRecent(AppLogType.normal);
      final detailed = await logger.readRecent(AppLogType.detailed);

      expect(normal, contains('Information event: git.command.completed'));
      expect(normal, contains('警告事件：update.network.warning'));
      expect(detailed, contains('https://***@example.com/team/repository.git'));
      expect(detailed, contains('Authorization: ***'));
      expect(detailed, isNot(contains('user:secret')));
      expect(detailed, contains('command=git fetch --prune origin'));
      expect(detailed, contains(r'cwd=C:\Repository'));
      expect(detailed, contains('exitCode=0'));
      expect(detailed, contains('stdout=raw stdout'));
      expect(detailed, contains('stderr=raw stderr'));
    },
  );

  testWidgets('operation plans render in all three supported languages', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      final operation = _operation();
      final host = _FakePlanHost(operation);
      final l10n = AppLocalizations(locale);
      await tester.pumpWidget(
        _localizedApp(locale, OperationPlanDialog(planHost: host)),
      );
      await tester.pumpAndSettle();

      expect(find.text(operation.title.resolve(l10n)), findsOneWidget);
      expect(find.text(operation.description.resolve(l10n)), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('log viewer labels localize in all three supported languages', (
    tester,
  ) async {
    for (final locale in AppLocalizations.supportedLocales) {
      final logger = _MemoryLogService()..setLocale(locale);
      await tester.pumpWidget(
        _localizedApp(
          locale,
          Scaffold(body: LogViewerDialog(logService: logger)),
        ),
      );
      await tester.pumpAndSettle();
      final l10n = AppLocalizations(locale);

      expect(find.text(l10n.tr('applicationLogs')), findsOneWidget);
      expect(find.text(l10n.tr('normalLog')), findsOneWidget);
      expect(find.text(l10n.tr('detailedLog')), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('language switch preserves a queued plan and its state', (
    tester,
  ) async {
    final operation = _operation();
    final host = _FakePlanHost(operation);
    final locale = ValueNotifier<Locale>(AppLocalizations.english);
    addTearDown(locale.dispose);

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: locale,
        builder: (context, value, _) {
          return _localizedApp(
            value,
            Scaffold(
              body: Column(
                children: [
                  FilledButton(
                    onPressed: () =>
                        locale.value = AppLocalizations.simplifiedChinese,
                    child: const Text('Switch language'),
                  ),
                  Expanded(child: OperationPlanDialog(planHost: host)),
                ],
              ),
            ),
          );
        },
      ),
    );
    await tester.pumpAndSettle();
    final english = operation.title.resolve(
      const AppLocalizations(AppLocalizations.english),
    );
    final simplified = operation.title.resolve(
      const AppLocalizations(AppLocalizations.simplifiedChinese),
    );
    expect(find.text(english), findsOneWidget);

    await tester.tap(find.text('Switch language'));
    await tester.pumpAndSettle();

    expect(find.text(english), findsNothing);
    expect(find.text(simplified), findsOneWidget);
    expect(host.pendingOperations.single, same(operation));
    expect(host.executeCount, 0);
  });

  testWidgets(
    'plan and open log session use new locale without rewriting old logs',
    (tester) async {
      final logger = _MemoryLogService()..setLocale(AppLocalizations.english);
      logger.infoEvent('ui', 'ui.beforeLanguageChange');
      await logger.flush();
      final oldLog = await logger.readRecent(AppLogType.normal);
      final operation = _operation();
      final host = _FakePlanHost(operation);
      final locale = ValueNotifier<Locale>(AppLocalizations.english);
      addTearDown(locale.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: locale,
          builder: (context, value, _) {
            return _localizedApp(
              value,
              Scaffold(
                body: Column(
                  children: [
                    FilledButton(
                      onPressed: () async {
                        locale.value = AppLocalizations.traditionalChinese;
                        logger.setLocale(AppLocalizations.traditionalChinese);
                        logger.infoEvent('ui', 'ui.afterLanguageChange');
                      },
                      child: const Text('Change'),
                    ),
                    Expanded(child: OperationPlanDialog(planHost: host)),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change'));
      await tester.pumpAndSettle();
      await logger.flush();

      final newLog = await logger.readRecent(AppLogType.normal);
      expect(newLog, startsWith(oldLog.trimRight()));
      expect(newLog, contains('ui.beforeLanguageChange'));
      expect(newLog, contains('資訊事件：ui.afterLanguageChange'));
      expect(
        find.text(
          operation.title.resolve(
            const AppLocalizations(AppLocalizations.traditionalChinese),
          ),
        ),
        findsOneWidget,
      );
      expect(host.executeCount, 0);
    },
  );
}

Widget _localizedApp(Locale locale, Widget child) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppL10n.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

PlannedRepositoryOperation _operation() {
  return PlannedRepositoryOperation(
    id: 'localized-plan',
    kind: PlannedOperationKind.pullFastForward,
    title: RuntimeMessages.messageFor(
      'planTitlePull',
      parameters: {'branch': '功能/很长的测试分支'},
    ),
    description: RuntimeMessages.messageFor(
      'planDescriptionPull',
      parameters: {
        'branch': '功能/很长的测试分支',
        'remote': 'origin',
        'upstream': 'origin/功能/很长的测试分支',
      },
    ),
    run: () async => OperationOutcome.success(
      RuntimeMessages.messageFor('operationCompleted'),
    ),
  );
}

class _FakePlanHost implements OperationPlanHost {
  _FakePlanHost(PlannedRepositoryOperation operation)
    : pendingOperations = [operation];

  @override
  List<PlannedRepositoryOperation> pendingOperations;
  int executeCount = 0;

  @override
  bool get canExecutePlan => pendingOperations.isNotEmpty && !isBusy;

  @override
  bool get isBusy => false;

  @override
  OperationOutcome clearPendingOperations() {
    pendingOperations = const [];
    return OperationOutcome.success(fixtureMessage('cleared'));
  }

  @override
  Future<OperationPlanResult> executePendingOperations({
    required bool confirmedDangerous,
    String? strongConfirmationText,
    void Function(OperationPlanProgress progress)? onProgress,
  }) async {
    executeCount += 1;
    return OperationPlanResult(
      isSuccess: true,
      message: RuntimeMessages.messageFor('operationCompleted'),
      completed: 1,
      total: 1,
      remaining: const [],
    );
  }

  @override
  OperationOutcome removePendingOperation(String id) {
    pendingOperations = const [];
    return OperationOutcome.success(fixtureMessage('removed'));
  }

  @override
  Future<void> recoverFromSafetyRejection() async {}
}

class _MemoryLogService extends AppLogService {
  Locale _locale = AppLocalizations.english;
  final List<String> _normal = [];
  final List<String> _detailed = [];

  @override
  String get logsDirectoryPath => r'C:\Git_Gui_Expand\userdata\logs';

  @override
  void setLocale(Locale locale) {
    _locale = AppLocalizations.resolveLocale(locale);
  }

  @override
  void event({
    required AppLogLevel level,
    required String area,
    required LocalizedMessage message,
  }) {
    final line =
        '[${level.label}] [$area] [${message.eventId}] '
        '${message.resolve(AppLocalizations(_locale))}';
    _detailed.add(line);
    if (level != AppLogLevel.detail) {
      _normal.add(line);
    }
  }

  @override
  Future<void> flush() async {}

  @override
  Future<String> readRecent(
    AppLogType type, {
    int maxCharacters = 180000,
  }) async {
    final entries = type == AppLogType.normal ? _normal : _detailed;
    return entries.join('\n');
  }
}
