import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('PortableGit fetch script rejects a digest mismatch', () async {
    final root = Directory.current;
    final script = File(
      '${root.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}fetch_portablegit_runtime.ps1',
    );
    final temporary = await Directory.systemTemp.createTemp(
      'portablegit_digest_',
    );
    addTearDown(() async {
      if (await temporary.exists()) await temporary.delete(recursive: true);
    });
    final archive = File(
      '${temporary.path}${Platform.pathSeparator}PortableGit-test.7z.exe',
    );
    await archive.writeAsString('not a real archive');

    final result = await Process.run('powershell.exe', [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script.path,
      '-ArchivePath',
      archive.path,
      '-ExpectedSha256',
      List.filled(64, '0').join(),
      '-OutputDirectory',
      '${temporary.path}${Platform.pathSeparator}output',
      '-CacheDirectory',
      '${temporary.path}${Platform.pathSeparator}cache',
    ], runInShell: false);

    expect(result.exitCode, isNot(0));
    expect('${result.stdout}\n${result.stderr}', contains('SHA-256 mismatch'));
  });

  test('PortableGit lock is pinned and names a PortableGit artifact', () async {
    final lock = await File(
      '${Directory.current.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}portablegit-runtime.lock.json',
    ).readAsString();

    expect(lock, contains('"packageName": "PortableGit-'));
    expect(lock, contains('"gitVersion": "2.56.1.windows.1"'));
    expect(
      lock,
      contains(
        '"sourceSha256": '
        '"9dd04a608ceb5f6ab32a73709e0ecb159d211da71b697c45ff81f6dd0c6b49c7"',
      ),
    );
  });

  test('packaging emits standard and PortableGit application packages without checksum sidecars', () async {
    final fixture = await _createPackagingFixture();
    addTearDown(() async {
      if (await fixture.root.exists()) {
        await fixture.root.delete(recursive: true);
      }
    });
    final script = File(
      '${Directory.current.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}package_windows_release.ps1',
    );

    final result = await Process.run(_systemPowerShell, [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script.path,
      '-Tag',
      'v1.2.3',
      '-RepositoryRoot',
      fixture.root.path,
      '-BuildOutput',
      'build/windows/x64/runner/Release',
      '-OutputDirectory',
      'dist',
      '-PortableGitRuntimeDirectory',
      fixture.runtime.path,
    ], runInShell: false);

    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    final standard = File(
      '${fixture.dist.path}${Platform.pathSeparator}'
      'Git_Gui_Expand-v1.2.3-windows-x64.zip',
    );
    final portable = File(
      '${fixture.dist.path}${Platform.pathSeparator}'
      'Git_Gui_Expand-v1.2.3-windows-x64-PortableGit.zip',
    );
    final runtime = File(
      '${fixture.dist.path}${Platform.pathSeparator}'
      'PortableGit-2.56.1-64-bit-runtime.zip',
    );
    expect(await standard.exists(), isTrue);
    expect(await portable.exists(), isTrue);
    expect(await runtime.exists(), isTrue);
    expect(portable.path, contains('PortableGit'));
    expect(runtime.path, contains('PortableGit'));
    expect(standard.path, isNot(contains('PortableGit')));

    final standardEntries = await _zipEntries(standard.path);
    final portableEntries = await _zipEntries(portable.path);
    expect(
      standardEntries.any((entry) => entry.contains('runtime/git/')),
      isFalse,
    );
    expect(
      portableEntries.any(
        (entry) => entry.contains(
          'runtime/git/versions/PortableGit-2.56.1-64-bit/git-runtime.json',
        ),
      ),
      isTrue,
    );
    expect(
      await fixture.dist
          .list()
          .where((entry) => entry.path.endsWith('.sha256'))
          .isEmpty,
      isTrue,
    );
  });

  test('packaging fails when the PortableGit notice is missing', () async {
    final fixture = await _createPackagingFixture();
    addTearDown(() async {
      if (await fixture.root.exists()) {
        await fixture.root.delete(recursive: true);
      }
    });
    await File(
      '${fixture.runtime.path}${Platform.pathSeparator}licenses'
      '${Platform.pathSeparator}PORTABLEGIT-NOTICE.txt',
    ).delete();
    final script = File(
      '${Directory.current.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}package_windows_release.ps1',
    );

    final result = await Process.run(_systemPowerShell, [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-File',
      script.path,
      '-Tag',
      'v1.2.3',
      '-RepositoryRoot',
      fixture.root.path,
      '-PortableGitRuntimeDirectory',
      fixture.runtime.path,
    ], runInShell: false);

    expect(result.exitCode, isNot(0));
    expect(
      '${result.stdout}\n${result.stderr}',
      contains('PORTABLEGIT-NOTICE'),
    );
  });

  test('release workflow publishes no checksum sidecar assets', () async {
    final workflow = await File(
      '${Directory.current.path}${Platform.pathSeparator}.github'
      '${Platform.pathSeparator}workflows'
      '${Platform.pathSeparator}windows-release.yml',
    ).readAsString();
    final packageScript = await File(
      '${Directory.current.path}${Platform.pathSeparator}tool'
      '${Platform.pathSeparator}package_windows_release.ps1',
    ).readAsString();

    expect(workflow, isNot(contains('.zip.sha256')));
    expect(workflow, contains('windows-x64-PortableGit.zip'));
    expect(workflow, contains('PortableGit-2.56.1-64-bit-runtime.zip'));
    expect(packageScript, isNot(contains(r'$checksumAsset')));
    expect(packageScript, isNot(contains('Get-FileHash')));
  });
}

const _systemPowerShell =
    r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe';

Future<({Directory root, Directory dist, Directory runtime})>
_createPackagingFixture() async {
  final root = await Directory.systemTemp.createTemp('git_gui_packaging_');
  final tool = Directory('${root.path}${Platform.pathSeparator}tool');
  await tool.create(recursive: true);
  await File(
    '${Directory.current.path}${Platform.pathSeparator}tool'
    '${Platform.pathSeparator}portablegit-runtime.lock.json',
  ).copy('${tool.path}${Platform.pathSeparator}portablegit-runtime.lock.json');
  await File('${root.path}${Platform.pathSeparator}README.md')
      .writeAsString('# Test');
  await File('${root.path}${Platform.pathSeparator}CHANGELOG.md')
      .writeAsString('# Changelog');
  await File('${root.path}${Platform.pathSeparator}LICENSE')
      .writeAsString('MIT License');
  final release = Directory(
    '${root.path}${Platform.pathSeparator}build'
    '${Platform.pathSeparator}windows'
    '${Platform.pathSeparator}x64'
    '${Platform.pathSeparator}runner'
    '${Platform.pathSeparator}Release',
  );
  await Directory('${release.path}${Platform.pathSeparator}data')
      .create(recursive: true);
  for (final name in [
    'git_gui_expand.exe',
    'flutter_windows.dll',
    'GitGuiExpandLauncher.exe',
  ]) {
    await File('${release.path}${Platform.pathSeparator}$name')
        .writeAsString(name);
  }
  await File(
    '${release.path}${Platform.pathSeparator}data'
    '${Platform.pathSeparator}app.so',
  ).writeAsString('app.so');

  final runtime = Directory(
    '${root.path}${Platform.pathSeparator}build'
    '${Platform.pathSeparator}portablegit-runtime'
    '${Platform.pathSeparator}PortableGit-2.56.1-64-bit',
  );
  await Directory('${runtime.path}${Platform.pathSeparator}cmd')
      .create(recursive: true);
  await File(
    '${runtime.path}${Platform.pathSeparator}cmd'
    '${Platform.pathSeparator}git.exe',
  ).writeAsString('git');
  await Directory('${runtime.path}${Platform.pathSeparator}mingw64').create();
  await Directory('${runtime.path}${Platform.pathSeparator}usr').create();
  final licenses = Directory(
    '${runtime.path}${Platform.pathSeparator}licenses',
  );
  await licenses.create();
  await File('${licenses.path}${Platform.pathSeparator}GIT-COPYING.txt')
      .writeAsString('Git license');
  await File('${licenses.path}${Platform.pathSeparator}PORTABLEGIT-NOTICE.txt')
      .writeAsString('PortableGit notice');
  await File('${runtime.path}${Platform.pathSeparator}git-runtime.json')
      .writeAsString('''
{
  "runtimeFormat": 1,
  "packageName": "PortableGit-2.56.1-64-bit",
  "gitVersion": "2.56.1.windows.1",
  "sourceUrl": "https://example.com/PortableGit.7z.exe",
  "archiveSha256": "${List.filled(64, 'a').join()}",
  "licensePath": "licenses/GIT-COPYING.txt",
  "noticePath": "licenses/PORTABLEGIT-NOTICE.txt",
  "builtAt": "2026-11-23T00:00:00Z"
}
''');
  final dist = Directory('${root.path}${Platform.pathSeparator}dist');
  await dist.create();
  return (root: root, dist: dist, runtime: runtime);
}

Future<List<String>> _zipEntries(String archivePath) async {
  final result = await Process.run('tar.exe', [
    '-tf',
    archivePath,
  ], runInShell: false);
  expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
  return (result.stdout as String)
      .split(RegExp(r'[\r\n]+'))
      .where((line) => line.trim().isNotEmpty)
      .map((line) => line.replaceAll('\\', '/'))
      .toList(growable: false);
}
