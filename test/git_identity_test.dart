import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/models/git_identity.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/git_service.dart';

void main() {
  test('parses effective Git identity output', () {
    final person = GitIdentityPerson.tryParse(
      'Git GUI Expand <expand@example.invalid> 1763899200 +0800',
    );

    expect(person, isNotNull);
    expect(person?.name, 'Git GUI Expand');
    expect(person?.email, 'expand@example.invalid');
    expect(GitIdentityPerson.tryParse('not an identity'), isNull);
  });

  test('reads valid effective author and committer identity', () async {
    final repository = await Directory.systemTemp.createTemp(
      'git_gui_identity_valid_',
    );
    addTearDown(() async {
      if (await repository.exists()) await repository.delete(recursive: true);
    });
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', 'Identity Test']);
    await _git(repository, [
      'config',
      'user.email',
      'identity@example.invalid',
    ]);

    final state = await GitService(repository.path).identityState();

    expect(state.isReady, isTrue);
    expect(state.author?.name, 'Identity Test');
    expect(state.author?.email, 'identity@example.invalid');
    expect(state.committer, state.author);
  });

  test('reports empty effective identity as unavailable', () async {
    final repository = await Directory.systemTemp.createTemp(
      'git_gui_identity_missing_',
    );
    addTearDown(() async {
      if (await repository.exists()) await repository.delete(recursive: true);
    });
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', '']);
    await _git(repository, ['config', 'user.email', '']);

    final state = await GitService(repository.path).identityState();

    expect(state.isReady, isFalse);
    expect(state.errorMessage, isNotEmpty);
  });

  test('identity logs and setup guidance are localized', () async {
    final repository = await Directory.systemTemp.createTemp(
      'git_gui_identity_logs_',
    );
    final logRoot = await Directory.systemTemp.createTemp(
      'git_gui_identity_log_data_',
    );
    addTearDown(() async {
      if (await repository.exists()) await repository.delete(recursive: true);
      if (await logRoot.exists()) await logRoot.delete(recursive: true);
    });
    await _git(repository, ['init', '-b', 'main']);
    await _git(repository, ['config', 'user.name', 'Identity Log']);
    await _git(repository, ['config', 'user.email', 'log@example.invalid']);
    final logger = AppLogService(
      storage: AppStorageService(softwareDirectoryOverride: logRoot.path),
    )..setLocale(AppLocalizations.english);
    final service = GitService(repository.path, logService: logger);

    expect((await service.identityState()).isReady, isTrue);
    await _git(repository, ['config', 'user.name', '']);
    await _git(repository, ['config', 'user.email', '']);
    expect((await service.identityState()).isReady, isFalse);
    await logger.flush();

    final normal = await logger.readRecent(AppLogType.normal);
    final detailed = await logger.readRecent(AppLogType.detailed);
    expect(normal, contains('git.identity.unavailable'));
    expect(detailed, contains('git.identity.valid'));
    expect(
      const AppLocalizations(AppLocalizations.english)
          .tr('commitIdentityUnavailable'),
      contains('user.name and user.email'),
    );
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
    throw StateError(
      'git ${arguments.join(' ')} failed:\n'
      '${result.stdout}\n${result.stderr}',
    );
  }
}
