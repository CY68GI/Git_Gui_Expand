import 'dart:convert';
import 'dart:io';

import 'app_log_service.dart';
import 'app_storage_service.dart';

enum GitPathScope { user, system }

enum GitPathAction {
  added,
  alreadyPresent,
  removed,
  notPresent,
  cancelled,
  failed,
}

class GitPathResult {
  const GitPathResult({
    required this.action,
    required this.scope,
    required this.managedPath,
    this.backupPath,
    this.error,
  });

  final GitPathAction action;
  final GitPathScope scope;
  final String managedPath;
  final String? backupPath;
  final String? error;

  bool get isSuccess =>
      action != GitPathAction.cancelled && action != GitPathAction.failed;
}

class EnvironmentPathValue {
  const EnvironmentPathValue({required this.value, required this.kind});

  final String value;
  final String kind;
}

class EnvironmentPathElevationCancelledException implements Exception {
  const EnvironmentPathElevationCancelledException();

  @override
  String toString() => 'Environment PATH elevation was cancelled.';
}

abstract class EnvironmentPathStore {
  Future<EnvironmentPathValue> read(GitPathScope scope);
  Future<void> write(GitPathScope scope, EnvironmentPathValue value);
}

class PowerShellEnvironmentPathStore implements EnvironmentPathStore {
  const PowerShellEnvironmentPathStore();

  @override
  Future<EnvironmentPathValue> read(GitPathScope scope) async {
    final result = await _runPowerShell(_readScript(scope));
    if (result.exitCode != 0) {
      throw ProcessException(
        'powershell.exe',
        const [],
        (result.stderr as String? ?? '').trim(),
        result.exitCode,
      );
    }
    final decoded = jsonDecode((result.stdout as String? ?? '').trim());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid environment PATH response.');
    }
    return EnvironmentPathValue(
      value: decoded['value'] as String? ?? '',
      kind: decoded['kind'] as String? ?? 'String',
    );
  }

  @override
  Future<void> write(GitPathScope scope, EnvironmentPathValue value) async {
    final writeCommand = _writeScript(scope, value);
    if (scope == GitPathScope.user) {
      final result = await _runPowerShell(writeCommand);
      if (result.exitCode != 0) {
        throw ProcessException(
          'powershell.exe',
          const [],
          (result.stderr as String? ?? '').trim(),
          result.exitCode,
        );
      }
      return;
    }

    final encoded = base64Encode(_utf16Le(writeCommand));
    final elevateScript = r'''
$process = Start-Process -FilePath $env:GIT_GUI_POWERSHELL `
  -ArgumentList @('-NoProfile', '-NonInteractive', '-EncodedCommand', $env:GIT_GUI_ENCODED) `
  -Verb RunAs -Wait -PassThru
exit $process.ExitCode
''';
    final result = await _runPowerShell(
      elevateScript,
      environment: {
        'GIT_GUI_POWERSHELL':
            Platform.resolvedExecutable.endsWith('git_gui_expand.exe')
            ? 'powershell.exe'
            : 'powershell.exe',
        'GIT_GUI_ENCODED': encoded,
      },
    );
    if (result.exitCode != 0) {
      final message = (result.stderr as String? ?? '').toLowerCase();
      if (message.contains('cancel') || message.contains('取消')) {
        throw const EnvironmentPathElevationCancelledException();
      }
      throw ProcessException(
        'powershell.exe',
        const [],
        (result.stderr as String? ?? '').trim(),
        result.exitCode,
      );
    }
  }

  Future<ProcessResult> _runPowerShell(
    String command, {
    Map<String, String>? environment,
  }) {
    return Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        command,
      ],
      environment: environment,
      includeParentEnvironment: true,
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
  }

  String _readScript(GitPathScope scope) {
    final hive = scope == GitPathScope.user
        ? r'[Microsoft.Win32.Registry]::CurrentUser'
        : r'[Microsoft.Win32.Registry]::LocalMachine';
    final subkey = scope == GitPathScope.user
        ? 'Environment'
        : r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
    return '''
\$key = $hive.OpenSubKey('${subkey.replaceAll("'", "''")}')
\$value = \$key.GetValue('Path', '', [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
\$kind = \$key.GetValueKind('Path').ToString()
@{ value = [string]\$value; kind = \$kind } | ConvertTo-Json -Compress
''';
  }

  String _writeScript(GitPathScope scope, EnvironmentPathValue value) {
    final hive = scope == GitPathScope.user ? 'CurrentUser' : 'LocalMachine';
    final subkey = scope == GitPathScope.user
        ? 'Environment'
        : r'SYSTEM\CurrentControlSet\Control\Session Manager\Environment';
    final escapedValue = value.value.replaceAll("'", "''");
    final escapedKind = value.kind == 'ExpandString'
        ? 'ExpandString'
        : 'String';
    return '''
\$key = [Microsoft.Win32.Registry]::$hive.OpenSubKey(
  '${subkey.replaceAll("'", "''")}',
  \$true
)
\$key.SetValue(
  'Path',
  '$escapedValue',
  [Microsoft.Win32.RegistryValueKind]::$escapedKind
)
exit 0
''';
  }

  List<int> _utf16Le(String value) {
    final result = <int>[];
    for (final codeUnit in value.codeUnits) {
      result
        ..add(codeUnit & 0xFF)
        ..add((codeUnit >> 8) & 0xFF);
    }
    return result;
  }
}

class GitPathEditor {
  const GitPathEditor._();

  static String add(String current, String managedPath) {
    final segments = current.split(';');
    final normalizedManaged = normalize(managedPath);
    if (segments.any((segment) => normalize(segment) == normalizedManaged)) {
      return current;
    }
    if (current.trim().isEmpty) return managedPath;
    return current.endsWith(';')
        ? '$current$managedPath'
        : '$current;$managedPath';
  }

  static String remove(String current, String managedPath) {
    final normalizedManaged = normalize(managedPath);
    final segments = current.split(';');
    return segments
        .where((segment) => normalize(segment) != normalizedManaged)
        .join(';');
  }

  static bool contains(String current, String managedPath) {
    final normalizedManaged = normalize(managedPath);
    return current
        .split(';')
        .any((segment) => normalize(segment) == normalizedManaged);
  }

  static String normalize(String path) {
    var value = path.trim();
    if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
      value = value.substring(1, value.length - 1).trim();
    }
    value = value.replaceAll('/', r'\');
    while (value.length > 3 && value.endsWith(r'\')) {
      value = value.substring(0, value.length - 1);
    }
    return Platform.isWindows ? value.toLowerCase() : value;
  }
}

typedef EnvironmentChangeNotifier = Future<void> Function();

class GitPathIntegrationService {
  GitPathIntegrationService({
    this.storage = const AppStorageService(),
    EnvironmentPathStore? store,
    AppLogService? logService,
    EnvironmentChangeNotifier? notifier,
  }) : _store = store ?? const PowerShellEnvironmentPathStore(),
       _log = logService ?? AppLogService.instance,
       _notifier = notifier ?? _notifyEnvironmentChange;

  final AppStorageService storage;
  final EnvironmentPathStore _store;
  final AppLogService _log;
  final EnvironmentChangeNotifier _notifier;

  String get managedPath => storage.gitRuntimeStableCommandDirectory.path;

  Future<bool> contains(GitPathScope scope) async {
    final current = await _store.read(scope);
    return GitPathEditor.contains(current.value, managedPath);
  }

  Future<GitPathResult> add(GitPathScope scope) async {
    final current = await _store.read(scope);
    final next = GitPathEditor.add(current.value, managedPath);
    if (next == current.value) {
      return GitPathResult(
        action: GitPathAction.alreadyPresent,
        scope: scope,
        managedPath: managedPath,
      );
    }
    final backup = await _writeBackup(scope, current, 'add');
    try {
      await _store.write(
        scope,
        EnvironmentPathValue(value: next, kind: current.kind),
      );
      await _notifyBestEffort();
      _log.infoEvent(
        'environment',
        'environment.path.added',
        details: {'scope': scope.name},
      );
      return GitPathResult(
        action: GitPathAction.added,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
      );
    } on EnvironmentPathElevationCancelledException catch (error) {
      return GitPathResult(
        action: GitPathAction.cancelled,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
        error: error.toString(),
      );
    } catch (error) {
      _log.errorEvent(
        'environment',
        'environment.path.write.failed',
        details: {'scope': scope.name, 'error': '$error'},
      );
      return GitPathResult(
        action: GitPathAction.failed,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
        error: error.toString(),
      );
    }
  }

  Future<GitPathResult> remove(GitPathScope scope) async {
    final current = await _store.read(scope);
    final next = GitPathEditor.remove(current.value, managedPath);
    if (next == current.value) {
      return GitPathResult(
        action: GitPathAction.notPresent,
        scope: scope,
        managedPath: managedPath,
      );
    }
    final backup = await _writeBackup(scope, current, 'remove');
    try {
      await _store.write(
        scope,
        EnvironmentPathValue(value: next, kind: current.kind),
      );
      await _notifyBestEffort();
      _log.infoEvent(
        'environment',
        'environment.path.removed',
        details: {'scope': scope.name},
      );
      return GitPathResult(
        action: GitPathAction.removed,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
      );
    } on EnvironmentPathElevationCancelledException catch (error) {
      return GitPathResult(
        action: GitPathAction.cancelled,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
        error: error.toString(),
      );
    } catch (error) {
      return GitPathResult(
        action: GitPathAction.failed,
        scope: scope,
        managedPath: managedPath,
        backupPath: backup.path,
        error: error.toString(),
      );
    }
  }

  Future<File> _writeBackup(
    GitPathScope scope,
    EnvironmentPathValue current,
    String action,
  ) async {
    final directory = storage.gitPathBackupDirectory;
    await directory.create(recursive: true);
    final stamp = DateTime.now()
        .toUtc()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File(
      '${directory.path}${Platform.pathSeparator}'
      'path-${scope.name}-$stamp.json',
    );
    final payload = const JsonEncoder.withIndent('  ').convert({
      'scope': scope.name,
      'action': action,
      'kind': current.kind,
      'managedPath': managedPath,
      'previousValue': current.value,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
    await file.writeAsString('$payload\n', flush: true);
    return file;
  }

  Future<void> _notifyBestEffort() async {
    try {
      await _notifier();
    } catch (error) {
      _log.warningEvent(
        'environment',
        'environment.notification.failed',
        details: {'error': '$error'},
      );
    }
  }

  static Future<void> _notifyEnvironmentChange() async {
    if (!Platform.isWindows) return;
    await Process.run(
      'powershell.exe',
      [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        r'''
Add-Type -Namespace GitGuiExpand -Name NativeMethods -MemberDefinition @"
[DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
public static extern IntPtr SendMessageTimeout(
  IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam,
  uint flags, uint timeout, out UIntPtr result);
"@
$result = [UIntPtr]::Zero
[GitGuiExpand.NativeMethods]::SendMessageTimeout(
  [IntPtr]0xffff, 0x001A, [UIntPtr]::Zero, "Environment", 2, 5000,
  [ref]$result) | Out-Null
''',
      ],
      runInShell: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
  }
}
