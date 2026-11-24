import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/models/settings_models.dart';

import '../tool/localization_validator.dart';

void main() {
  late Map<String, dynamic> english;
  late Map<String, dynamic> simplified;
  late Map<String, dynamic> traditional;

  setUpAll(() async {
    english = await _catalog('app_en.arb');
    simplified = await _catalog('app_zh_Hans.arb');
    traditional = await _catalog('app_zh_Hant.arb');
  });

  test('catalogs and placeholders are complete', () async {
    final root = Directory('${Directory.current.path}/lib/l10n');
    final report = File(
      '${Directory.current.path}/build/l10n_untranslated.json',
    );
    final count = await validateLocalizationCatalogs(
      arbDirectory: root,
      report: report,
    );

    expect(count, greaterThan(380));
  });

  test('known Traditional value never appears in Simplified catalog', () {
    final key = (english.entries)
        .firstWhere(
          (entry) =>
              !entry.key.startsWith('@') && entry.value == 'Fetch all remotes',
        )
        .key;

    expect(simplified[key], '获取全部远端');
    expect(simplified[key], isNot(contains('遠')));
    expect(traditional[key], '取得全部遠端');
  });

  test('all static tr calls use existing semantic keys', () async {
    final keys = english.keys.where((key) => !key.startsWith('@')).toSet();
    final pattern = RegExp(r"\.tr\(\s*'([^']+)'");
    final missing = <String>[];
    await for (final entity in Directory(
      '${Directory.current.path}/lib',
    ).list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final normalized = entity.path.replaceAll('\\', '/');
      if (normalized.contains('/l10n/') ||
          normalized.endsWith('/core/localization/app_localizations.dart')) {
        continue;
      }
      final text = await entity.readAsString();
      for (final match in pattern.allMatches(text.replaceAll('\r\n', '\n'))) {
        final key = match.group(1)!;
        if (RegExp(r'[\u3400-\u9fff]').hasMatch(key) || !keys.contains(key)) {
          missing.add('$normalized: $key');
        }
      }
    }
    expect(missing, isEmpty);
  });

  test('saved language preferences resolve to generated locale scripts', () {
    expect(
      AppLocalizations.localeForPreference(
        AppLanguagePreference.simplifiedChinese,
      ),
      AppLocalizations.simplifiedChinese,
    );
    expect(
      AppLocalizations.localeForPreference(
        AppLanguagePreference.traditionalChinese,
      ),
      AppLocalizations.traditionalChinese,
    );
    expect(
      AppLocalizations.localeForPreference(AppLanguagePreference.english),
      AppLocalizations.english,
    );
  });

  test('documented localization examples exist in resources', () async {
    final guide = await File('${Directory.current.path}/docs/LOCALIZATION.md')
        .readAsString();
    for (final key in [
      'openRepository',
      'saveSettings',
      'fetchAllRemotes',
      'foundItemsAndCanBeFreed',
    ]) {
      expect(guide, contains(key));
      expect(english, contains(key));
    }
    expect(english.containsKey('@foundItemsAndCanBeFreed'), isTrue);
  });

  test('approved Chinese glossary is consistent across catalogs', () {
    const pairs = {
      'files': ('文件', '檔案'),
      'folder': ('文件夹', '資料夾'),
      'gitRepository': ('Git 仓库', 'Git 儲存庫'),
      'push': ('推送', '推送'),
      'pendingOperationPlan': ('待执行操作计划', '待執行操作計劃'),
      'updates': ('更新', '更新'),
    };
    for (final entry in pairs.entries) {
      expect(simplified[entry.key], entry.value.$1);
      expect(traditional[entry.key], entry.value.$2);
    }
    expect(simplified['branchManagement'], contains('分支'));
    expect(traditional['branchManagement'], contains('分支'));
    expect(simplified['commitWorkspace'], contains('提交'));
    expect(traditional['commitWorkspace'], contains('提交'));
    expect(simplified['remotes'], contains('远端'));
    expect(traditional['remotes'], contains('遠端'));
  });
}

Future<Map<String, dynamic>> _catalog(String file) async {
  return jsonDecode(
    await File('${Directory.current.path}/lib/l10n/$file').readAsString(),
  ) as Map<String, dynamic>;
}
