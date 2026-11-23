import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/constants/app_info.dart';
import 'package:git_gui_expand/core/constants/changelog.dart';

void main() {
  test('application Launcher package and changelog versions match', () async {
    final root = Directory.current.path;
    final pubspec = await File('$root${Platform.pathSeparator}pubspec.yaml')
        .readAsString();
    final launcher = await File(
      '$root${Platform.pathSeparator}windows'
      '${Platform.pathSeparator}launcher'
      '${Platform.pathSeparator}launcher.rc',
    ).readAsString();
    final changelog = await File('$root${Platform.pathSeparator}CHANGELOG.md')
        .readAsString();

    expect(AppInfo.version, '0.9.9');
    expect(pubspec, contains('version: 0.9.9+22'));
    expect(launcher, contains('FILEVERSION 0,9,9,22'));
    expect(launcher, contains('PRODUCTVERSION 0,9,9,22'));
    expect(launcher, contains('VALUE "FileVersion", "0.9.9.22"'));
    expect(launcher, contains('VALUE "ProductVersion", "0.9.9.22"'));
    expect(changelog, contains('## 0.9.9 - 2026-11-23'));
    expect(builtInChangelog.first.version, AppInfo.version);
  });
}
