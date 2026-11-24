import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_runtime_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';
import 'package:git_gui_expand/core/services/settings_service.dart';
import 'package:git_gui_expand/features/repository/repository_controller.dart';

import 'support/localized_message_fixture.dart';

void main() {
  test(
    're-detection updates controller state after a fake Git install',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'git_gui_runtime_controller_',
      );
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final storage = AppStorageService(softwareDirectoryOverride: root.path);
      final logger = AppLogService(storage: storage);
      var installed = false;
      final discovery = GitRuntimeDiscovery(
        storage: storage,
        candidateProvider: () async =>
            installed ? const [r'C:\Program Files\Git\cmd\git.exe'] : const [],
        versionProbe: (path) async => installed ? '2.56.1' : null,
      );
      final runtime = GitRuntimeManager(
        discovery: discovery,
        logService: logger,
      );
      final controller = RepositoryController(
        settingsService: SettingsService(storage: storage, logService: logger),
        recentRepositoriesService: RecentRepositoriesService(
          storage: storage,
          logService: logger,
        ),
        runtimeManager: runtime,
        logService: logger,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      await controller.refreshGitRuntime();
      expect(controller.isGitAvailable, isFalse);

      installed = true;
      final status = await controller.refreshGitRuntime();

      expect(status.isAvailable, isTrue);
      expect(controller.isGitAvailable, isTrue);
      expect(controller.gitRuntimeStatus.source, GitRuntimeSource.system);
      expect(controller.gitRuntimeStatus.version, '2.56.1');
      await logger.flush();
    },
  );

  test(
    'unavailable Git blocks repository opening before command execution',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'git_gui_runtime_blocked_',
      );
      final repository = Directory(
        '${root.path}${Platform.pathSeparator}repository',
      );
      await repository.create();
      await Directory('${repository.path}${Platform.pathSeparator}.git')
          .create();
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final storage = AppStorageService(softwareDirectoryOverride: root.path);
      final logger = AppLogService(storage: storage);
      final runtime = GitRuntimeManager(
        discovery: GitRuntimeDiscovery(
          storage: storage,
          candidateProvider: () async => const [],
          versionProbe: (_) async => null,
        ),
        logService: logger,
      );
      final controller = RepositoryController(
        settingsService: SettingsService(storage: storage, logService: logger),
        recentRepositoriesService: RecentRepositoriesService(
          storage: storage,
          logService: logger,
        ),
        runtimeManager: runtime,
        logService: logger,
      );
      addTearDown(controller.dispose);
      await controller.initialize();
      await controller.refreshGitRuntime();

      final outcome = await controller.openRepository(repository.path);

      expect(outcome.isSuccess, isFalse);
      expect(fixtureText(outcome.message), contains('Git is unavailable'));
      expect(controller.hasRepository, isFalse);
      await logger.flush();
    },
  );
}
