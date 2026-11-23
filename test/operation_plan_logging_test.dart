import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

void main() {
  test(
    'plan preview and execution are localized while Git output stays raw',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'git_gui_plan_logging_',
      );
      final repository = Directory(
        '${root.path}${Platform.pathSeparator}repository',
      );
      await repository.create();
      await _git(repository, ['init', '-b', 'main']);
      await _git(repository, ['config', 'user.name', 'Plan Logging Test']);
      await _git(repository, ['config', 'user.email', 'log@example.invalid']);
      await File('${repository.path}${Platform.pathSeparator}alpha.txt')
          .writeAsString('alpha');
      await _git(repository, ['add', '-A']);
      await _git(repository, ['commit', '-m', 'initial']);

      final storage = AppStorageService(softwareDirectoryOverride: root.path);
      final logger = AppLogService(storage: storage)
        ..setLocale(AppLocalizations.english);
      final controller = RepositoryController(
        settingsService: SettingsService(storage: storage, logService: logger),
        logService: logger,
        recentRepositoriesService: RecentRepositoriesService(
          storage: storage,
          logService: logger,
        ),
      );
      try {
        await controller.initialize();
        expect(
          (await controller.openRepository(repository.path)).isSuccess,
          true,
        );
        controller.toggleSelection(ExplorerSide.left, 'alpha.txt');
        expect(
          (await controller.renameSelection('renamed.txt')).isSuccess,
          true,
        );
        final result = await controller.executePendingOperations(
          confirmedDangerous: true,
        );
        expect(result.isSuccess, true, reason: result.message);
        await logger.flush();

        final normal = await logger.readRecent(AppLogType.normal);
        final detailed = await logger.readRecent(AppLogType.detailed);
        expect(normal, contains('Operation preview 1 created'));
        expect(normal, contains('Starting operation plan: 1 steps'));
        expect(detailed, contains('Operation preview 1 created'));
        expect(detailed, contains('command=git mv'));
        expect(detailed, contains('stdout='));
        expect(detailed, contains('stderr='));
      } finally {
        controller.dispose();
        await logger.flush();
        if (await root.exists()) {
          await root.delete(recursive: true);
        }
      }
    },
  );
}

Future<void> _git(Directory directory, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
}
