#include <windows.h>
#include <shellapi.h>

#include <algorithm>
#include <cctype>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cwctype>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace {

struct LaunchPlan {
  fs::path root;
  std::wstring version;
  fs::path version_directory;
  fs::path executable;
};

struct PendingResult {
  bool applied = false;
  std::wstring previous_version;
};

std::string Utf8(const std::wstring& value) {
  if (value.empty()) {
    return {};
  }
  const int size = WideCharToMultiByte(CP_UTF8, 0, value.data(),
                                       static_cast<int>(value.size()), nullptr,
                                       0, nullptr, nullptr);
  std::string result(size, '\0');
  WideCharToMultiByte(CP_UTF8, 0, value.data(),
                      static_cast<int>(value.size()), result.data(), size,
                      nullptr, nullptr);
  return result;
}

std::wstring Trim(std::wstring value) {
  const auto first = std::find_if_not(
      value.begin(), value.end(),
      [](wchar_t character) { return std::iswspace(character) != 0; });
  const auto last = std::find_if_not(
      value.rbegin(), value.rend(),
      [](wchar_t character) { return std::iswspace(character) != 0; });
  if (first >= last.base()) {
    return {};
  }
  return std::wstring(first, last.base());
}

std::wstring ReadVersionFile(const fs::path& path) {
  std::ifstream stream(path, std::ios::binary);
  if (!stream) {
    return {};
  }
  std::string line;
  std::getline(stream, line);
  const int required = MultiByteToWideChar(CP_UTF8, 0, line.data(),
                                           static_cast<int>(line.size()),
                                           nullptr, 0);
  std::wstring value(required, L'\0');
  if (required > 0) {
    MultiByteToWideChar(CP_UTF8, 0, line.data(),
                        static_cast<int>(line.size()), value.data(),
                        required);
  }
  return Trim(value);
}

bool IsSafeVersion(const std::wstring& version) {
  if (version.empty() || version.size() > 64) {
    return false;
  }
  return std::all_of(version.begin(), version.end(), [](wchar_t character) {
    return std::iswalnum(character) != 0 || character == L'.' ||
           character == L'-' || character == L'_';
  });
}

bool WriteVersionFile(const fs::path& path, const std::wstring& version) {
  const fs::path temporary = path.wstring() + L".tmp";
  {
    std::ofstream stream(temporary, std::ios::binary | std::ios::trunc);
    if (!stream) {
      return false;
    }
    const std::string utf8 = Utf8(version) + "\n";
    stream.write(utf8.data(), static_cast<std::streamsize>(utf8.size()));
    stream.flush();
  }
  if (!MoveFileExW(temporary.c_str(), path.c_str(),
                   MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
    DeleteFileW(temporary.c_str());
    return false;
  }
  return true;
}

std::wstring CurrentTime() {
  SYSTEMTIME time{};
  GetLocalTime(&time);
  wchar_t buffer[64]{};
  swprintf_s(buffer, L"%04d-%02d-%02dT%02d:%02d:%02d.%03d",
             time.wYear, time.wMonth, time.wDay, time.wHour, time.wMinute,
             time.wSecond, time.wMilliseconds);
  return buffer;
}

void WriteLog(const fs::path& root, const std::wstring& message) {
  const fs::path directory = root / L"userdata" / L"updates";
  std::error_code error;
  fs::create_directories(directory, error);
  if (error) {
    return;
  }
  const fs::path logPath = directory / L"launcher.log";
  std::ofstream stream(logPath, std::ios::binary | std::ios::app);
  if (!stream) {
    return;
  }
  const std::string line = Utf8(CurrentTime() + L" " + message + L"\r\n");
  stream.write(line.data(), static_cast<std::streamsize>(line.size()));
}

bool IsLaunchableVersion(const fs::path& root,
                         const std::wstring& version,
                         LaunchPlan* plan) {
  if (!IsSafeVersion(version)) {
    return false;
  }
  const fs::path directory = root / L"versions" / version;
  const fs::path executable = directory / L"git_gui_expand.exe";
  const fs::path appData = directory / L"data" / L"app.so";
  if (!fs::is_regular_file(executable) || !fs::is_regular_file(appData)) {
    return false;
  }
  if (plan != nullptr) {
    plan->root = root;
    plan->version = version;
    plan->version_directory = directory;
    plan->executable = executable;
  }
  return true;
}

PendingResult ApplyPendingVersion(const fs::path& root) {
  PendingResult result;
  const fs::path pending = root / L"pending-version.txt";
  if (!fs::exists(pending)) {
    return result;
  }
  const std::wstring next = ReadVersionFile(pending);
  if (!IsLaunchableVersion(root, next, nullptr)) {
    WriteLog(root, L"Pending version is invalid: " + next);
    const fs::path invalid =
        root / L"pending-version.invalid.txt";
    MoveFileExW(pending.c_str(), invalid.c_str(),
                MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH);
    return result;
  }

  const fs::path current = root / L"current-version.txt";
  const std::wstring previous = ReadVersionFile(current);
  const fs::path rollback = root / L"rollback-version.txt";
  if (!previous.empty() && IsSafeVersion(previous) && previous != next) {
    if (!WriteVersionFile(rollback, previous)) {
      WriteLog(root, L"Could not write rollback version");
      return result;
    }
    result.previous_version = previous;
  }

  if (!WriteVersionFile(current, next)) {
    WriteLog(root, L"Could not switch current version to " + next);
    return result;
  }
  DeleteFileW(pending.c_str());
  WriteLog(root, L"Switched current version to " + next);
  result.applied = true;
  return result;
}

bool WaitForOtherProcess(DWORD processId) {
  if (processId == 0) {
    return true;
  }
  HANDLE process = OpenProcess(SYNCHRONIZE, FALSE, processId);
  if (process == nullptr) {
    return true;
  }
  const DWORD waitResult = WaitForSingleObject(process, 120000);
  CloseHandle(process);
  return waitResult != WAIT_TIMEOUT;
}

DWORD RunVersion(const LaunchPlan& plan, PROCESS_INFORMATION* processInfo) {
  SetEnvironmentVariableW(L"GIT_GUI_EXPAND_ROOT", plan.root.c_str());
  SetEnvironmentVariableW(L"GIT_GUI_EXPAND_LAUNCHED", L"1");
  SetEnvironmentVariableW(L"GIT_GUI_EXPAND_VERSION", plan.version.c_str());

  std::wstring commandLine = L"\"" + plan.executable.wstring() + L"\"";
  std::vector<wchar_t> mutableCommand(commandLine.begin(), commandLine.end());
  mutableCommand.push_back(L'\0');

  STARTUPINFOW startup{};
  startup.cb = sizeof(startup);
  PROCESS_INFORMATION process{};
  WriteLog(plan.root, L"Starting version " + plan.version);
  const BOOL created =
      CreateProcessW(plan.executable.c_str(), mutableCommand.data(), nullptr,
                     nullptr, FALSE, 0, nullptr,
                     plan.version_directory.c_str(), &startup, &process);
  if (!created) {
    const DWORD error = GetLastError();
    WriteLog(plan.root,
             L"CreateProcess failed for " + plan.version + L", error=" +
                 std::to_wstring(error));
    MessageBoxW(nullptr,
                (L"无法启动 Git GUI Expand 版本 " + plan.version +
                 L"。\n请查看 userdata\\updates\\launcher.log")
                    .c_str(),
                L"Git GUI Expand Launcher", MB_OK | MB_ICONERROR);
    return ERROR_PROCESS_ABORTED;
  }
  CloseHandle(process.hThread);
  *processInfo = process;
  return ERROR_SUCCESS;
}

DWORD ReadExitCode(HANDLE process) {
  DWORD exitCode = 1;
  GetExitCodeProcess(process, &exitCode);
  return exitCode;
}

DWORD RunLauncher(const fs::path& root, DWORD waitProcessId) {
  if (!WaitForOtherProcess(waitProcessId)) {
    WriteLog(root, L"Timed out waiting for previous application process");
    return ERROR_TIMEOUT;
  }

  for (;;) {
    const PendingResult pendingResult = ApplyPendingVersion(root);
    std::wstring version = ReadVersionFile(root / L"current-version.txt");
    LaunchPlan plan;
    if (!IsLaunchableVersion(root, version, &plan)) {
      const std::wstring rollback = ReadVersionFile(root / L"rollback-version.txt");
      if (!IsLaunchableVersion(root, rollback, &plan)) {
        WriteLog(root, L"Current version is invalid: " + version);
        MessageBoxW(nullptr,
                    L"当前版本目录无效。请重新安装 Git GUI Expand。",
                    L"Git GUI Expand Launcher", MB_OK | MB_ICONERROR);
        return ERROR_FILE_NOT_FOUND;
      }
      WriteVersionFile(root / L"current-version.txt", rollback);
      version = rollback;
    }

    PROCESS_INFORMATION process{};
    const DWORD startResult = RunVersion(plan, &process);
    if (startResult != ERROR_SUCCESS) {
      return startResult;
    }

    const DWORD firstWait = WaitForSingleObject(process.hProcess, 8000);
    if (firstWait == WAIT_TIMEOUT) {
      DeleteFileW((root / L"rollback-version.txt").c_str());
      WriteLog(root, L"Version " + version + L" passed startup check");
      WaitForSingleObject(process.hProcess, INFINITE);
      const DWORD exitCode = ReadExitCode(process.hProcess);
      CloseHandle(process.hProcess);
      WriteLog(root,
               L"Version " + version + L" exited with code " +
                   std::to_wstring(exitCode));

      if (fs::exists(root / L"pending-version.txt")) {
        continue;
      }
      return exitCode;
    }

    const DWORD exitCode = ReadExitCode(process.hProcess);
    CloseHandle(process.hProcess);
    WriteLog(root,
             L"Version " + version + L" exited during startup check, code=" +
                 std::to_wstring(exitCode));

    if (pendingResult.applied && !pendingResult.previous_version.empty() &&
        IsLaunchableVersion(root, pendingResult.previous_version, nullptr)) {
      WriteVersionFile(root / L"current-version.txt",
                       pendingResult.previous_version);
      DeleteFileW((root / L"rollback-version.txt").c_str());
      WriteLog(root,
               L"Rolled back to " + pendingResult.previous_version);
      continue;
    }
    if (fs::exists(root / L"pending-version.txt")) {
      continue;
    }
    return exitCode;
  }
}

}  // namespace

int APIENTRY wWinMain(_In_ HINSTANCE, _In_opt_ HINSTANCE, _In_ LPWSTR,
                      _In_ int) {
  wchar_t modulePath[MAX_PATH]{};
  const DWORD moduleLength =
      GetModuleFileNameW(nullptr, modulePath, MAX_PATH);
  if (moduleLength == 0 || moduleLength >= MAX_PATH) {
    return ERROR_PATH_NOT_FOUND;
  }
  const fs::path root = fs::path(modulePath).parent_path();

  DWORD waitProcessId = 0;
  int argumentCount = 0;
  LPWSTR* arguments = CommandLineToArgvW(GetCommandLineW(), &argumentCount);
  if (arguments != nullptr) {
    for (int index = 1; index + 1 < argumentCount; ++index) {
      if (std::wstring(arguments[index]) == L"--wait-pid") {
        waitProcessId =
            static_cast<DWORD>(std::wcstoul(arguments[index + 1], nullptr, 10));
      }
    }
    LocalFree(arguments);
  }

  WriteLog(root, L"Launcher started");
  const DWORD result = RunLauncher(root, waitProcessId);
  WriteLog(root, L"Launcher exited with code " + std::to_wstring(result));
  return static_cast<int>(result);
}
