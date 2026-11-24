import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_environment_service.dart';

void main() {
  late Directory root;
  late AppStorageService storage;
  late FakeEnvironmentPathStore store;
  late GitPathIntegrationService service;
  late AppLogService logger;
  var notifications = 0;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('git_path_integration_');
    storage = AppStorageService(softwareDirectoryOverride: root.path);
    store = FakeEnvironmentPathStore();
    logger = AppLogService(storage: storage);
    notifications = 0;
    service = GitPathIntegrationService(
      storage: storage,
      store: store,
      logService: logger,
      notifier: () async => notifications++,
    );
  });

  tearDown(() async {
    await logger.flush();
    if (await root.exists()) await root.delete(recursive: true);
  });

  test(
    'PATH editor preserves order, variables, malformed entries and type',
    () {
      const current = r'%JAVA_HOME%\bin;;C:\Tools\;D:\Program Files\App;';
      final managed = r'C:\App\runtime\git\current\cmd';

      final added = GitPathEditor.add(current, managed);

      expect(
        added,
        r'%JAVA_HOME%\bin;;C:\Tools\;D:\Program Files\App;'
        r'C:\App\runtime\git\current\cmd',
      );
      expect(added, contains(r'%JAVA_HOME%\bin'));
      expect(GitPathEditor.add(added, managed), added);
      expect(
        GitPathEditor.contains(r'C:\APP\RUNTIME\GIT\CURRENT\CMD\', managed),
        isTrue,
      );
    },
  );

  test(
    'user-scope integration preserves value kind and writes a backup',
    () async {
      final managed = service.managedPath;
      store.values[GitPathScope.user] = const EnvironmentPathValue(
        value: r'%USERPROFILE%\bin;C:\Tools',
        kind: 'ExpandString',
      );

      final result = await service.add(GitPathScope.user);

      expect(result.isSuccess, isTrue);
      expect(result.action, GitPathAction.added);
      expect(
        store.values[GitPathScope.user]!.value,
        '%USERPROFILE%\\bin;C:\\Tools;$managed',
      );
      expect(store.values[GitPathScope.user]!.kind, 'ExpandString');
      expect(store.userWrites, 1);
      expect(store.systemWrites, 0);
      expect(notifications, 1);
      expect(await File(result.backupPath!).exists(), isTrue);
    },
  );

  test('system-scope elevation cancellation makes no PATH change', () async {
    store.values[GitPathScope.system] = const EnvironmentPathValue(
      value: r'C:\Windows',
      kind: 'String',
    );
    store.cancelSystemWrites = true;

    final result = await service.add(GitPathScope.system);

    expect(result.action, GitPathAction.cancelled);
    expect(result.isSuccess, isFalse);
    expect(store.values[GitPathScope.system]!.value, r'C:\Windows');
    expect(store.systemWrites, 0);
    expect(result.backupPath, isNotNull);
  });

  test('system-scope integration succeeds and is idempotent', () async {
    store.values[GitPathScope.system] = const EnvironmentPathValue(
      value: r'C:\Windows',
      kind: 'String',
    );

    final first = await service.add(GitPathScope.system);
    final second = await service.add(GitPathScope.system);

    expect(first.action, GitPathAction.added);
    expect(second.action, GitPathAction.alreadyPresent);
    expect(store.systemWrites, 1);
    expect(notifications, 1);
  });

  test('removal only removes the managed entry in each scope', () async {
    final managed = storage.gitRuntimeStableCommandDirectory.path;
    store.values[GitPathScope.user] = const EnvironmentPathValue(
      value: '',
      kind: 'String',
    );
    store.values[GitPathScope.system] = const EnvironmentPathValue(
      value: '',
      kind: 'String',
    );
    store.values[GitPathScope.user] = EnvironmentPathValue(
      value: r'%USERPROFILE%\bin;' + managed + r';C:\Tools',
      kind: 'ExpandString',
    );
    store.values[GitPathScope.system] = EnvironmentPathValue(
      value: r'C:\Windows;' + managed + r';D:\SystemTools',
      kind: 'String',
    );

    final user = await service.remove(GitPathScope.user);
    final system = await service.remove(GitPathScope.system);
    final repeated = await service.remove(GitPathScope.system);

    expect(user.action, GitPathAction.removed);
    expect(system.action, GitPathAction.removed);
    expect(repeated.action, GitPathAction.notPresent);
    expect(store.values[GitPathScope.user]!.value, contains('%USERPROFILE%'));
    expect(store.values[GitPathScope.user]!.value, contains(r'C:\Tools'));
    expect(store.values[GitPathScope.user]!.value, isNot(contains(managed)));
    expect(store.values[GitPathScope.system]!.value, contains(r'C:\Windows'));
    expect(
      store.values[GitPathScope.system]!.value,
      contains(r'D:\SystemTools'),
    );
    expect(store.values[GitPathScope.system]!.value, isNot(contains(managed)));
  });

  test('stable managed path is independent of PortableGit version', () {
    final before = service.managedPath;
    final changed = AppStorageService(softwareDirectoryOverride: root.path)
        .gitRuntimeVersionDirectory('PortableGit-2.57.0-64-bit');

    expect(changed.path, isNot(service.managedPath));
    expect(service.managedPath, before);
    expect(service.managedPath, contains(r'runtime\git\current\cmd'));
  });
}

class FakeEnvironmentPathStore implements EnvironmentPathStore {
  final Map<GitPathScope, EnvironmentPathValue> values = {};
  bool cancelSystemWrites = false;
  int userWrites = 0;
  int systemWrites = 0;

  @override
  Future<EnvironmentPathValue> read(GitPathScope scope) async {
    return values[scope] ??
        const EnvironmentPathValue(value: '', kind: 'String');
  }

  @override
  Future<void> write(GitPathScope scope, EnvironmentPathValue value) async {
    if (scope == GitPathScope.system && cancelSystemWrites) {
      throw const EnvironmentPathElevationCancelledException();
    }
    values[scope] = value;
    if (scope == GitPathScope.user) {
      userWrites++;
    } else {
      systemWrites++;
    }
  }
}
