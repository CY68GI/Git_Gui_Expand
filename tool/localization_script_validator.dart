import 'dart:convert';
import 'dart:io';

class LocalizationScriptException implements Exception {
  const LocalizationScriptException(this.message);

  final String message;

  @override
  String toString() => message;
}

const _traditionalOnly = '遠檔設關刪倉儲軟體網預應檢測開復選確歷專為與這後個當數據庫轉進計劃執發級來時會從將們對無過裏裡釋';
const _simplifiedOnly = '远档设关删仓储软体网预应检测开复选确历专为与这后个当数据库转进计划执发级来时从将们对无过里释';

const _allowedKeys = {
  'languageSimplifiedChineseOptionLabel',
  'languageSimplifiedChineseDescription',
  'languageTraditionalChineseOptionLabel',
  'languageTraditionalChineseDescription',
  'guideLanguageSimplifiedChinese',
  'guideLanguageTraditionalChinese',
};

Future<void> validateLocalizationScripts(Directory arbDirectory) async {
  final hans = await _readCatalog(arbDirectory, 'app_zh_Hans.arb');
  final hant = await _readCatalog(arbDirectory, 'app_zh_Hant.arb');
  final findings = <String>[];
  findings.addAll(
    _findings(
      hans,
      _traditionalOnly,
      'Traditional-only form in Simplified Chinese',
    ),
  );
  findings.addAll(
    _findings(
      hant,
      _simplifiedOnly,
      'Simplified-only form in Traditional Chinese',
    ),
  );
  if (findings.isNotEmpty) {
    throw LocalizationScriptException(findings.join('\n'));
  }
}

List<String> _findings(
  Map<String, dynamic> catalog,
  String forbiddenCharacters,
  String label,
) {
  final forbidden = forbiddenCharacters.runes.toSet();
  final findings = <String>[];
  for (final entry in catalog.entries) {
    if (entry.key.startsWith('@') || _allowedKeys.contains(entry.key)) continue;
    final value = entry.value;
    if (value is! String) continue;
    final offenders = value.runes
        .where(forbidden.contains)
        .map(String.fromCharCode)
        .toSet();
    if (offenders.isNotEmpty) {
      findings.add('$label ${entry.key}: ${offenders.join()} -> $value');
    }
  }
  return findings;
}

Future<Map<String, dynamic>> _readCatalog(
  Directory directory,
  String name,
) async {
  final decoded = jsonDecode(
    await File('${directory.path}/$name').readAsString(),
  );
  if (decoded is! Map<String, dynamic>) {
    throw LocalizationScriptException('$name is not a JSON object.');
  }
  return decoded;
}
