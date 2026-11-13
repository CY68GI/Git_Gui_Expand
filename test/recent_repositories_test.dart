import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/recent_repositories_service.dart';

void main() {
  late Directory softwareDirectory;
  late Directory repository;
  late Directory invalidDirectory;
  late AppStorageService storage;
  late AppLogService logger;
  late RecentRepositoriesService service;

  setUp(() async {
    softwareDirectory = await Directory.systemTemp.createTemp(
      'git_gui_history_data_',
    );
    repository = await Directory.systemTemp.createTemp('git_gui_history_repo_');
    invalidDirectory = await Directory.systemTemp.createTemp(
      'git_gui_history_invalid_',
    );
    await _git(repository, ['init']);
    storage = AppStorageService(
      softwareDirectoryOverride: softwareDirectory.path,
    );
    logger = AppLogService(storage: storage);
    service = RecentRepositoriesService(storage: storage, logService: logger);
  });

  tearDown(() async {
    await logger.flush();
    for (final directory in [softwareDirectory, repository, invalidDirectory]) {
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  });

  test(
    'only valid Git repositories are stored and duplicates are removed',
    () async {
      await expectLater(
        service.add(invalidDirectory.path),
        throwsA(isA<FormatException>()),
      );

      await service.add(repository.path);
      final entries = await service.add(repository.path);

      expect(entries, hasLength(1));
      expect(entries.single.path, repository.path);
      final historyFile = File(
        '${softwareDirectory.path}${Platform.pathSeparator}userdata'
        '${Platform.pathSeparator}recent_repositories.json',
      );
      expect(await historyFile.exists(), isTrue);
    },
  );

  test(
    'history loads in newest-first order and drops deleted repositories',
    () async {
      await service.add(repository.path);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await _git(invalidDirectory, ['init']);
      await service.add(invalidDirectory.path);

      final newestFirst = await service.load();
      expect(newestFirst.first.path, invalidDirectory.path);

      await Directory('${invalidDirectory.path}${Platform.pathSeparator}.git')
          .delete(recursive: true);

      final loaded = await service.load();

      expect(loaded, hasLength(1));
      expect(loaded.single.path, repository.path);
    },
  );

  test('history entry can be removed explicitly', () async {
    await service.add(repository.path);
    final remaining = await service.remove(repository.path);

    expect(remaining, isEmpty);
    expect(await service.load(), isEmpty);
  });
}

Future<void> _git(Directory directory, List<String> arguments) async {
  final result = await Process.run(
    'git',
    arguments,
    workingDirectory: directory.path,
    runInShell: false,
  );
  if (result.exitCode != 0) {
    throw StateError('git failed: ${result.stderr}');
  }
}
