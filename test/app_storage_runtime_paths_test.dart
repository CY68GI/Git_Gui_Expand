import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';

void main() {
  test('normal versioned executable resolves the installation root', () {
    final storage = AppStorageService(
      executablePathOverride: r'C:\Software\versions\0.9.9\git_gui_expand.exe',
    );

    expect(storage.softwareDirectory, r'C:\Software');
  });

  test('Launcher root overrides executable discovery', () {
    final storage = AppStorageService(
      launcherRootOverride: r'D:\Git GUI Expand',
      executablePathOverride: r'C:\Software\versions\0.9.9\git_gui_expand.exe',
    );

    expect(storage.softwareDirectory, r'D:\Git GUI Expand');
  });

  test('clean extraction resolves its executable directory', () {
    final storage = AppStorageService(
      executablePathOverride: r'E:\Downloads\GitGuiExpand\git_gui_expand.exe',
    );

    expect(storage.softwareDirectory, r'E:\Downloads\GitGuiExpand');
  });

  test(
    'shared runtime and staging paths stay under the software directory',
    () {
      final storage = AppStorageService(
        softwareDirectoryOverride: r'C:\Software',
        launchedByLauncherOverride: true,
      );

      expect(storage.gitRuntimeRoot.path, r'C:\Software\runtime\git');
      expect(
        storage.gitRuntimeExecutableFile.path,
        r'C:\Software\runtime\git\current\cmd\git.exe',
      );
      expect(
        storage.gitRuntimeVersionDirectory('PortableGit-2.56.1').path,
        r'C:\Software\runtime\git\versions\PortableGit-2.56.1',
      );
      expect(
        storage.gitRuntimeManifestFile('PortableGit-2.56.1').path,
        r'C:\Software\runtime\git\versions\PortableGit-2.56.1'
        '${Platform.pathSeparator}git-runtime.json',
      );
      expect(
        storage.gitRuntimeStageDirectory('PortableGit-2.56.1').path,
        r'C:\Software\userdata\updates\git-stage-PortableGit-2.56.1',
      );
      expect(storage.isLaunchedByLauncher, isTrue);
      expect(
        () => storage.gitRuntimeVersionDirectory('../escape'),
        throwsA(isA<FormatException>()),
      );
    },
  );
}
