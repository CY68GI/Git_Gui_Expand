import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/services/app_log_service.dart';
import 'package:git_gui_expand/core/services/app_storage_service.dart';
import 'package:git_gui_expand/core/services/update_service.dart';

void main() {
  test('GitHub and Gitee latest release endpoints are reachable', () async {
    if (Platform.environment['GIT_GUI_LIVE_UPDATE_TEST'] != '1') {
      return;
    }
    final temp = await Directory.systemTemp.createTemp(
      'git_gui_update_source_test_',
    );
    try {
      final logger = AppLogService(
        storage: AppStorageService(softwareDirectoryOverride: temp.path),
      );
      final service = UpdateService(logService: logger);
      for (final source in UpdateSource.values) {
        final result = await service.checkForUpdates(source: source);
        expect(
          result.status,
          isNot(UpdateCheckStatus.unavailable),
          reason: '${source.name}: ${result.message}',
        );
        expect(result.latestVersion, isNotEmpty);
        expect(result.releaseUrl, startsWith('https://'));
      }
      await logger.flush();
    } finally {
      if (await temp.exists()) {
        await temp.delete(recursive: true);
      }
    }
  }, timeout: const Timeout(Duration(minutes: 1)));
}
