# Changelog

## 0.9.6 - 2026-11-17

### English

- Fixed the root cause where automatic updates replaced only files under
  `versions` while the root Launcher remained at an old version.
- The application now scans and removes old versions, downloaded installers,
  partial downloads, staging folders, and legacy flat app files during startup.
- The current release includes a maintenance copy of the Launcher and schedules
  a safe root Launcher update after the running app exits.
- Added Settings → About → Scan old versions and installers with a scan window
  and one-click cleanup fallback.
- Settings → About now displays the actual file versions of
  `git_gui_expand.exe` and `GitGuiExpandLauncher.exe`.
- Added local branch creation, switching, renaming, and safe/force deletion.
- The update page can check and install releases from either GitHub or Gitee.
- Releases now include a companion SHA-256 checksum file for Gitee updates.

### 简体中文

- 修复自动更新只替换 `versions` 内文件、根目录 Launcher 仍停留在旧版本的问题。
- 应用启动后会主动扫描并清理旧版本、下载的安装包、未完成下载、临时目录和旧平铺程序文件。
- 新版本目录包含维护用 Launcher，并在当前应用退出后安全更新根目录 Launcher。
- 在“设置 → 关于”新增“扫描旧版本与安装包”，提供扫描窗口和一键清除兜底。
- “设置 → 关于”显示 `git_gui_expand.exe` 与 `GitGuiExpandLauncher.exe` 实际文件版本。
- 新增本地分支创建、切换、重命名、安全删除和强制删除。
- 更新页面可选择 GitHub 或 Gitee 获取最新版和安装包。
- Release 新增 SHA-256 校验文件，供 Gitee 自动更新验证。

### 繁體中文

- 修復自動更新只替換 `versions` 內檔案、根目錄 Launcher 仍停留在舊版本的問題。
- 應用程式啟動後會主動掃描並清理舊版本、下載的安裝包、未完成下載、臨時目錄和舊平鋪程式檔案。
- 新版本目錄包含維護用 Launcher，並在目前應用程式結束後安全更新根目錄 Launcher。
- 在「設定 → 關於」新增「掃描舊版本與安裝包」，提供掃描視窗和一鍵清除備援。
- 「設定 → 關於」顯示 `git_gui_expand.exe` 與 `GitGuiExpandLauncher.exe` 實際檔案版本。
- 新增本機分支建立、切換、重新命名、安全刪除和強制刪除。
- 更新頁面可選擇 GitHub 或 Gitee 取得最新版和安裝包。
- Release 新增 SHA-256 校驗檔案，供 Gitee 自動更新驗證。

## 0.9.5 - 2026-11-17

### English

- Successful Launcher startup now keeps only the current version directory and
  removes every other installed version.
- Downloaded update ZIPs, partial downloads, staged extraction directories, and
  the legacy updater script are removed after the new version passes startup.
- Appearance colors now drive primary accents, tinted surfaces, document icons,
  status badges, selected states, buttons, and success messages throughout the
  application.
- All three READMEs now include a detailed Git feature coverage matrix covering
  implemented and unimplemented Git capabilities.

### 简体中文

- Launcher 成功启动后只保留当前版本目录，删除所有其他已安装版本。
- 新版本通过启动检查后，清除下载的更新 ZIP、未完成下载、临时解压目录和旧更新脚本。
- 配色方案现在统一影响全局强调色、带色调表面、文件图标、状态徽标、选择状态、
  按钮和成功提示。
- 三份 README 新增详细 Git 功能覆盖表，分别列出已实现和尚未实现的能力。

### 繁體中文

- Launcher 成功啟動後只保留目前版本目錄，刪除所有其他已安裝版本。
- 新版本通過啟動檢查後，清除下載的更新 ZIP、未完成下載、臨時解壓目錄和舊更新指令碼。
- 配色方案現在統一影響全域強調色、帶色調表面、檔案圖示、狀態徽章、選取狀態、
  按鈕和成功提示。
- 三份 README 新增詳細 Git 功能覆蓋表，分別列出已實現和尚未實現的能力。

## 0.9.4 - 2026-11-16

### English

- The project is now licensed under the MIT License.
- README files include Windows Release, platform, and MIT license badges.
- Every successful Launcher startup now detects the current and immediately
  previous installed versions, then removes all older version directories.
- Renamed Appearance to Appearance settings and added Emerald, Ocean, Violet,
  Amber, and Rose color schemes. Buttons, selected states, borders, and icons
  follow the selected scheme.

### 简体中文

- 项目许可证改为 MIT License。
- 三份 README 增加 Windows Release、平台和 MIT 许可证徽章。
- Launcher 每次成功启动都会识别当前版本和上一已安装版本，并删除其余旧版本目录。
- “外观模式”改名为“外观设置”，新增经典绿、海洋蓝、星夜紫、琥珀金和玫瑰红
  五种配色方案；按钮、选择状态、边框和图标会跟随配色方案。

### 繁體中文

- 專案授權改為 MIT License。
- 三份 README 新增 Windows Release、平台和 MIT 授權徽章。
- Launcher 每次成功啟動都會辨識目前版本和上一個已安裝版本，並刪除其餘舊版本目錄。
- 「外觀模式」改名為「外觀設定」，新增經典綠、海洋藍、星夜紫、琥珀金和玫瑰紅
  五種配色方案；按鈕、選取狀態、邊框和圖示會跟隨配色方案。

## 0.9.3 - 2026-11-16

### English

- Added English, Simplified Chinese, and Traditional Chinese to Settings,
  README, user guides, update notes, and normal/detailed logs.
- The Follow system language option now displays only the actual operating-system
  language instead of showing all translations at once.
- Added a one-click desktop shortcut action in Settings → About. The shortcut
  prefers the stable Launcher.
- A clean extraction with no valid version marker can now recover the unique
  valid `versions/<version>` directory. Flat Release directories are also
  launchable.
- Successful automatic updates retain only the current version and the version it
  was updated from; failed updates and rollbacks do not prune versions.
- Release packaging now writes UTF-8 markers without a BOM and validates the
  complete Launcher/version payload.
- Fixed settings migration so an intentional “System default” font choice is not
  overwritten.

### 简体中文

- 设置、README、使用指南、更新日志以及普通/详细日志支持 English、简体中文和繁體中文。
- “跟随系统”只显示操作系统实际语言，不再同时显示三种语言。
- 在“设置 → 关于”新增一键发送桌面快捷方式，优先指向稳定 Launcher。
- 全新解压包缺少有效版本标记时，自动恢复唯一的 `versions/<版本>` 目录；平铺的
  Release 目录也可以直接启动。
- 自动更新成功后只保留当前版本与更新前版本；失败和回滚不会清理版本。
- 发布打包改为无 BOM 的 UTF-8 版本标记，并验证完整 Launcher/版本文件。
- 修复旧设置迁移，避免主动选择的“系统默认字体”被覆盖。

### 繁體中文

- 設定、README、使用指南、更新日誌以及普通/詳細日誌支援 English、简体中文和繁體中文。
- 「跟隨系統」只顯示作業系統實際語言，不再同時顯示三種語言。
- 在「設定 → 關於」新增一鍵傳送桌面捷徑，優先指向穩定 Launcher。
- 全新解壓縮包缺少有效版本標記時，自動恢復唯一的 `versions/<版本>` 目錄；平鋪的
  Release 目錄也可以直接啟動。
- 自動更新成功後只保留目前版本與更新前版本；失敗和回滾不會清理版本。
- 發布封裝改為無 BOM 的 UTF-8 版本標記，並驗證完整 Launcher/版本檔案。
- 修復舊設定移轉，避免主動選擇的「系統預設字型」被覆蓋。

## 0.9.2 - 2026-11-16

### Added

- 文件资源行支持右键菜单。
- 新增“用文件资源打开”，在 Windows 资源管理器中定位并选中文件。
- 新增“用默认打开方式打开”，使用 Windows 系统默认关联程序打开文件。
- 右键未选中文件时会自动将其设为当前活动面板的单选项目。

## 0.9.1 - 2026-11-16

### Fixed

- 清空远端历史后同步重置本地同名分支和索引，磁盘文件保留并显示为未跟踪，
  不再错误提示“工作区干净”。
- 本地当前分支与远端目标分支不一致时，在修改远端前拒绝清空。
- 空提交说明改为：
  `日期 时间 仓库已清除，这是第一次空提交(用户名/项目名/分支名)，来自软件Git GUI Expand的功能`。

## 0.9.0 - 2026-11-16

### Added

- 文件移动、复制、重命名、删除、暂存、取消暂存、提交、推送和远端配置操作
  统一进入“待执行操作计划”。
- 计划中的步骤可以逐项移除或整体清空；确认后按记录顺序逐步执行。
- 新增高风险“清空远端历史”操作：把目标分支替换为只有一个空根提交的历史，
  删除其它分支和标签；本地文件保留，本地分支和索引同步到空提交，文件显示为未跟踪。
- 清空远端前会备份引用到 `refs/gitgui-expand/backup/<remote>`，并使用
  `git push --atomic --force` 一次完成目标分支替换与其它引用删除。
- 新增应用内使用指南和 `docs/USER_GUIDE.md`。
- Windows 仓库选择改用标准“打开”对话框；项目打开后新增“项目目录”入口。
- 设置页增加常驻滚动条，字体页顶部提示下方还有字体预览和字体大小设置。

### Changed

- 提交、推送、删除和远端清空不再点击后立即执行，必须通过计划窗口确认。
- 危险步骤要求勾选确认；清空远端还要求手动输入准确的“远端项目全称/分支名称”。
- 提高日志、远端管理、设置、文件列表和提交结果的文字可读性。

### Safety

- 清空远端遇到受保护分支、缺少权限或服务器不支持原子推送时失败并报告，
  不会宣称删除成功。

## 0.8.3 - 2026-11-14

### Fixed

- SHA-256 改为直接流式读取文件字节计算，移除对 PowerShell 文本输出编码的依赖。
- 修复真实更新在下载达到 100% 后、SHA-256 校验阶段以
  `FormatException: Missing extension byte` 中止的问题。
- 增加 SHA-256 回归测试，并重新验证 Launcher 版本切换和启动健康检查。

### Migration

- `v0.8.1` 和 `v0.8.2` 使用相同的 PowerShell 哈希输出实现，无法可靠执行这次自动更新。
- 请从 Release 手动安装一次 `v0.8.3`，之后始终通过
  `GitGuiExpandLauncher.exe` 启动即可继续使用自动更新。

## 0.8.2 - 2026-11-14

### Fixed

- 旧设置中的空 `fontFamily` 现在会一次性迁移到内置 Noto Sans SC / 思源黑体。
- 新设置版本会保留用户之后主动选择的“系统默认（自动适配）”。
- 验证 v0.8.1 Launcher 的多版本目录准备、切换、重启和共享 userdata 链路。

## 0.8.1 - 2026-11-13

### Added

- 新增稳定的 `GitGuiExpandLauncher.exe` 和版本目录启动架构。
- Launcher 支持 pending 版本切换、启动健康检查和自动回滚。
- 新版本目录与当前运行版本完全隔离，共享同一 `userdata`。

### Fixed

- 修复 Dart detached PowerShell 子进程未执行、导致更新下载完成后软件退出但不重启的问题。
- 自动更新不再覆盖正在运行的程序文件，也不需要生成替换脚本。

### Migration

- v0.8.0 及更早版本无法自动修复自身，需要手动安装一次 v0.8.1 Launcher 包。
- 安装后必须从 `GitGuiExpandLauncher.exe` 启动，后续版本才能自动切换。

## 0.8.0 - 2026-11-13

### Added

- 新增多平台远端管理，自动识别 GitHub、Gitee、GitLab、Bitbucket 和通用 Git。
- 提交工作区可查看全部远端地址，支持添加、修改、删除远端。
- 支持推送到单个远端或全部远端，并分别报告成功与失败结果。
- 新增字体大小 90%、100%、110% 三档，模型层强制限制安全范围。
- 源代码和 Release 配置同时支持 GitHub 与 Gitee。

### Changed

- 字体大小应用于整个 Flutter UI，并保持紧凑布局在安全范围内。

## 0.7.0 - 2026-11-13

### Added

- 软件内置 Inter UI、Noto Sans SC 和 IBM Plex Sans 三款专业 UI 字体。
- 软件默认字体改为内置的 Noto Sans SC / 思源黑体。
- 字体设置按“软件内置”和“系统自带”分组，支持按名称、用途和描述实时搜索。
- 字体候选行显示实际字体预览，便于快速确认和避免误选。
- 新增发布说明生成脚本和 OFL 字体许可证。

### Changed

- GitHub Release Assets 上方的说明只包含上一个标签到当前标签范围内的变更。
- 发布工作流改用当前版本 CHANGELOG 节选和提交范围生成说明。

## 0.6.0 - 2026-11-13

### Added

- 更新页新增“打开发布页”，作为自动更新失败或网络缓慢时的手动后备入口。
- 设置重构为字体、外观模式、单位设置和关于四个分页。
- 关于页和 README 新增 DeepSeek 人工智能与 ChatGPT Codex 协作致谢。

### Changed

- 推送按钮从顶部移入提交工作区，保留 `Ctrl+Shift+U` 快捷键。

## 0.5.0 - 2026-11-13

### Added

- 更新界面新增“一键更新并重启”，无需手动打开发布页或下载 ZIP。
- 自动选择带 SHA-256 的 Windows x64 Release ZIP 并验证下载内容。
- 新增独立 PowerShell 更新助手，在应用退出后备份、替换文件并重启。
- 更新保留 `userdata`，失败时自动回滚到之前版本。
- Release ZIP 新增 `version.json`，更新前验证包内版本。

### Changed

- 更新包、暂存目录、更新助手日志和本地备份统一存放在
  `userdata/updates`。

## 0.4.0 - 2026-11-13

### Added

- 启动页新增最近打开 Git 仓库历史卡片和快速打开入口。
- 历史记录只接受存在 `.git` 文件或目录的仓库根路径。
- 重复仓库自动去重并前移至最近位置，最多保存 10 条。
- 失效仓库自动清理，支持手动移除历史记录。
- 历史数据保存到 `userdata/recent_repositories.json`。

## 0.3.0 - 2026-11-13

### Added

- 新增批量删除确认，已跟踪项通过 `git rm` 删除并暂存，未跟踪/忽略项通过
  `git clean -f -d -x` 删除。
- 新增当前分支推送；检测 upstream，缺失时自动选择 `origin` 或首个远程。
- 新增 `Delete` 删除和 `Ctrl+Shift+U` 推送快捷键。
- 新增系统字体枚举和字体选择器，默认使用平台原生系统字体。
- 字体选择与主题、大小单位一起保存到 `userdata/settings.json`。

## 0.2.1 - 2026-11-13

### Added

- 新增跟随系统、浅色和深色三种外观模式，并响应 Windows 外观变化。
- 新增普通日志、详细日志及内置日志查看器。
- 详细日志记录导航、选择、设置、窗口级快捷键、更新检查和每条 Git 命令及输出。
- 新增统一圆角矩形树形图标，覆盖 Windows ICO、macOS 图标集、Linux 预留图标和应用内品牌。
- 新增软件目录 `userdata` 存储层，集中保存设置、日志和内部临时文件。
- 新增标签驱动的 Windows Release 自动化构建和程序包上传工作流。

### Changed

- 应用版本升级到 `0.2.1`。
- 固定发布工作流的 Flutter 版本，确保云端分析、构建和本地验证一致。
- 数据目录从用户配置目录迁移到软件目录下，旧设置会自动复制迁移。
- 非编辑区域的资源快捷键改为窗口级处理，输入框仍保留文本复制粘贴行为。

### Security

- 外链仍限制为 HTTPS，自动更新不会替换正在运行的程序。
- 软件目录需要可写；发布包不应解压到无写权限的系统保护目录。

## 0.1.0 - 2026-11-13

### Added

- 新增 Windows Flutter 桌面应用骨架与左右双资源面板。
- 新增 Git 仓库根目录验证和仓库、分支、容量统计。
- 新增复选框批量选择、`Ctrl+X` / `Ctrl+C` / `Ctrl+V` 和 `F2` 重命名。
- 新增基于 `git mv` 的文件与文件夹批量移动、重命名。
- 新增基于 Git object/index/checkout-index 的文件与目录复制。
- 新增提交工作区、全部暂存、取消暂存和提交说明输入。
- 新增 IEC/SI、Byte/bit 文件大小显示设置。
- 新增 GitHub Releases 更新检查、下载页跳转和离线内置更新日志。
- 新增 Git 服务与启动页自动化测试。

### Platform

- Windows 为首个开发与验证目标。
- Linux、macOS 目录保留，当前版本不支持。
