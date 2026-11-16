# Git GUI Expand

<img src="assets/icons/app_icon.png" alt="Git GUI Expand 圖示" width="96">

[English](README.md) | [简体中文](README.zh-CN.md) | 繁體中文

Git GUI Expand 是一套以 Windows 為優先的 Flutter 桌面應用程式，透過左右雙欄
檔案工作區操作已初始化的 Git 儲存庫。檔案與版本控制變更都交由本機 Git CLI
執行，軟體提供可視化操作，不會自行取代 Git。

目前版本：`0.9.3`

- GitHub：<https://github.com/CY68GI/Git_Gui_Expand>
- Gitee：<https://gitee.com/CY68EWZRY/Git_Gui_Expand>

## 主要功能

- 使用 Windows 標準「開啟」對話框開啟儲存庫。
- 從最近開啟記錄快速重新開啟已驗證的 Git 儲存庫。
- 左右資源面板可獨立瀏覽同一個儲存庫。
- 使用核取方塊選取檔案與資料夾，支援批次操作。
- 透過 Git 執行剪下、複製、貼上、重新命名、移動與刪除。
- 所有會修改儲存庫的操作先進入待執行計畫，確認後才逐步執行。
- 支援暫存、取消暫存、提交、推送與多平台遠端管理。
- 可管理 GitHub、Gitee、GitLab、Bitbucket 與一般 Git 遠端。
- 輸入「遠端擁有者/專案/分支」確認後，可用原子空根提交清除指定遠端歷史。
- 可在檔案總管中定位檔案，或使用系統預設應用程式開啟。
- 顯示專案大小、檔案大小、目前分支、Git 狀態與待提交變更。
- 支援 IEC/SI 大小單位與 Byte/bit 基礎單位。
- 支援跟隨系統、淺色與深色外觀。
- 可搜尋內建與系統 UI 字型，字級限制為 90%、100%、110%。
- 支援 English、简体中文、繁體中文，預設跟隨作業系統語言。
- 普通日誌與詳細日誌依目前介面語言產生。
- 可在「設定 → 關於」一鍵建立桌面捷徑。
- 使用穩定 Launcher、獨立版本目錄、啟動健康檢查與自動回滾完成更新。
- 更新成功後只保留目前版本與更新前版本。

## 環境需求

- Windows 10 或 Windows 11
- Git 2.40 以上
- 原始碼建置需要 Flutter 3.47.x、Dart 3.13.x
- 需要 Visual Studio「使用 C++ 的桌面開發」工作負載

Linux 與 macOS 目錄目前僅作預留，尚未建置或驗證。

## 建置與測試

```powershell
flutter pub get
flutter analyze
flutter test
flutter build windows --release
```

Flutter 建置輸出：

```text
build\windows\x64\runner\Release\
```

建立發布 ZIP：

```powershell
.\tool\package_windows_release.ps1 -Tag v0.9.3
```

## 發布目錄結構

```text
Git GUI Expand/
  GitGuiExpandLauncher.exe
  current-version.txt
  versions/
    0.9.3/
      git_gui_expand.exe
      flutter_windows.dll
      data/
      version.json
  userdata/
    settings.json
    recent_repositories.json
    logs/
    updates/
```

請一律透過 `GitGuiExpandLauncher.exe` 啟動。Launcher 會驗證版本資訊與程式檔案；
若 `current-version.txt` 缺失，會從唯一有效的 `versions/<版本>` 自動恢復，也支援
根目錄直接放置 `git_gui_expand.exe` 與 `data` 的開發或相容目錄。

所有設定、日誌、最近開啟記錄與更新資料都保存在軟體目錄的 `userdata`。
軟體目錄必須可寫入。

## 操作安全

檔案移動、複製、重新命名、刪除、提交、推送、遠端設定與清除遠端歷史都會先加入
待執行計畫。危險操作需要明確勾選確認；清除遠端歷史還必須準確輸入
`遠端擁有者/專案/分支`。

## 自動更新與版本保留

Launcher 會下載並驗證 Windows x64 ZIP，解壓縮到獨立版本目錄，應用程式結束後
切換版本。新版本未通過啟動檢查時會自動回滾。

更新成功後只保留目前版本與更新前版本，其他舊版本目錄會刪除。設定、日誌、
最近開啟記錄與其他 `userdata` 檔案由所有版本共用。

## 文件

- [English User Guide](docs/USER_GUIDE.md)
- [简体中文使用指南](docs/USER_GUIDE.zh-CN.md)
- [繁體中文使用指南](docs/USER_GUIDE.zh-TW.md)
- [架構說明](docs/ARCHITECTURE.md)
- [互動說明](docs/UX.md)

## 致謝

感謝 DeepSeek 人工智慧和 ChatGPT Codex，兩者合力建立、編寫、修改此專案。

## 授權

倉庫目前尚未包含授權條款。散布或商用前，請由專案所有者補充明確授權。
