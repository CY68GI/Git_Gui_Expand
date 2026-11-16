# Git GUI Expand

<img src="assets/icons/app_icon.png" alt="Git GUI Expand 图标" width="96">

[English](README.md) | 简体中文 | [繁體中文](README.zh-TW.md)

[![Windows Release](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml/badge.svg)](https://github.com/CY68GI/Git_Gui_Expand/actions/workflows/windows-release.yml)
![platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D4)
![license](https://img.shields.io/badge/license-MIT-blue)

Git GUI Expand 是一个以 Windows 为首要目标的 Flutter 桌面应用。它把 Git
仓库中的文件浏览、批量移动、复制、重命名、暂存与提交集中到左右双栏界面中，
所有文件和提交变更都通过本机 Git CLI 执行。

当前版本：`0.9.4`

远程仓库：<https://github.com/CY68GI/Git_Gui_Expand>
Gitee 镜像：<https://gitee.com/CY68EWZRY/Git_Gui_Expand>

## 当前支持

- Windows 10/11 为当前开发和验证平台。
- 选择并打开已经初始化的 Git 仓库根目录。
- Windows 使用标准“打开”对话框选择仓库根目录，而不是“浏览文件夹”对话框。
- 启动页显示最近打开的 Git 仓库，可快速重新打开或移除记录。
- 打开项目后可从顶部“项目目录”直接在 Windows 资源管理器中打开当前仓库。
- 左右两个资源面板独立浏览同一仓库，可分别进入不同目录。
- 文件夹和文件复选框选择，支持跨目录保留批量选择。
- 文件行右键菜单支持在资源管理器中定位文件，或使用系统默认应用打开。
- 剪切、复制、粘贴、重命名和左右面板间批量移动。
- 所有仓库修改先进入可检查、可移除的待执行操作计划，确认后才逐步运行 Git。
- 带危险确认的批量删除，支持已跟踪、未跟踪和忽略内容。
- 当前活动面板决定粘贴目标文件夹。
- 支持推送当前分支，自动检查 upstream，并在需要时设置 `origin` 或首个远程。
- 支持同时管理 GitHub、Gitee、GitLab、Bitbucket 和通用 Git 远端。
- 可查看所有远端、添加/修改/删除远端，并可逐项推送或推送到全部远端。
- 可备份并清空选定远端历史，把目标分支替换为一个空根提交并删除其它分支和标签；
  本地文件不变，但本地分支与索引同步为空，文件随后显示为未跟踪；受保护分支会阻止操作。
- 实时显示 Git 状态，可把暂存、取消暂存和提交说明加入执行计划。
- 显示仓库名称、分支、仓库总大小、文件数量、待提交数量和每个文件大小。
- 大小单位支持 IEC 二进制、SI 十进制、Byte 和 bit。
- 支持跟随系统、浅色和深色三种显示模式，并提供经典绿、海洋蓝、星夜紫、
  琥珀金和玫瑰红五种配色方案。
- 设置提供语言页面，支持 English、简体中文和繁體中文；默认跟随操作系统语言。
- 支持选择当前系统已安装字体，默认使用内置 Noto Sans SC / 思源黑体。
- 内置 Inter UI、Noto Sans SC、IBM Plex Sans 三款 OFL 开源 UI 字体。
- 字体大小仅提供 90%、100%、110% 三档，并在数据模型中限制安全范围。
- 所有窗口、任务栏、可执行文件、macOS 预留图标集和应用内品牌使用同一圆角矩形树形图标。
- 普通日志记录关键事件，详细日志记录导航、选择、设置、更新及每条 Git 命令和输出。
- 普通日志和详细日志使用当前界面语言生成；Git 原始命令及技术错误内容保持原样。
- 在“设置 → 关于”中可一键创建指向稳定 Launcher 的桌面快捷方式。
- 全新解压目录缺少版本标记时，Launcher 可从唯一有效的 `versions/<版本>` 自动恢复，
  也支持直接运行根目录中平铺的 Release 文件。
- 新增应用内使用指南和 [完整使用指南](docs/USER_GUIDE.zh-CN.md)。
- 设置、日志、选择器临时文件等运行数据统一保存在软件目录的 `userdata` 文件夹。
- 通过 GitHub Releases API 检查并自动安装更新，完成后自动重启。
- 使用稳定 Launcher 与独立版本目录完成热更新和启动失败自动回滚。
- 新版本通过启动检查后只保留当前版本与更新前版本，自动清理更早的版本目录。
- 项目使用 Git 标签版本控制，推送 `v*` 标签会触发 Windows Release 构建与上传。
- Linux 和 macOS 目录已由 Flutter 保留，但当前版本未开发、未构建验证。

## 环境要求

- Flutter `3.47.x` 或兼容版本
- Dart `3.13.x`
- Git `2.40+`
- Windows 构建需要 Visual Studio 的“使用 C++ 的桌面开发”工作负载

确认环境：

```powershell
flutter --version
dart --version
git --version
```

## 运行与构建

```powershell
flutter pub get
flutter run -d windows
flutter test
flutter analyze
flutter build windows --release
```

Release 输出目录：

```text
build\windows\x64\runner\Release\
```

软件运行目标仓库必须已执行过 `git init`，并且选择的是仓库根目录，不是其子目录。

## 操作方式

1. 点击“打开 Git 仓库”，选择仓库根目录；也可以点击启动页的最近仓库卡片。
2. 在任一资源面板使用复选框勾选文件或文件夹。
3. 双击文件夹进入；点击面板即将其设为当前粘贴目标。
4. 右键单击文件，可选择“用文件资源打开”或“用默认打开方式打开”。
5. 使用工具栏或快捷键剪切/复制，再在目标面板执行粘贴。
6. 使用“重命名”或 `F2` 修改单个选中项。
7. 使用“删除”或 `Delete` 批量选择要删除的项目。
8. 在底部提交区填写说明，点击“加入提交计划”。
9. 点击“待执行 N”，检查所有路径、顺序和危险提示。
10. 确认后软件按顺序逐步执行 Git 操作。
11. 点击提交工作区的“远端”按钮管理、推送或清空选定远端。

打开项目后，顶部“项目目录”会直接打开当前仓库根目录。

| 快捷键 | 操作 |
| --- | --- |
| `Ctrl+O` | 打开仓库 |
| `Ctrl+X` | 将当前勾选项目放入剪切剪贴板 |
| `Ctrl+C` | 将当前勾选项目放入复制剪贴板 |
| `Ctrl+V` | 把粘贴到当前活动面板加入计划 |
| `F2` | 把重命名加入计划 |
| `Delete` | 把删除加入计划 |
| `Ctrl+A` | 全选当前面板可见项目 |
| `Ctrl+R` | 刷新仓库、状态与容量 |
| `Ctrl+Shift+U` | 把当前分支推送加入计划 |

资源快捷键由窗口级事件处理。提交说明输入框获得焦点时，文本编辑会优先处理
`Ctrl+C`、`Ctrl+V`，不会被文件剪贴板抢占。

## Git 行为

- 重命名、移动使用 `git mv`。
- 未跟踪项目在移动或重命名前可能先通过 `git add --all -- <path>` 加入索引，
  否则 `git mv` 无法处理未跟踪项目。
- Git 不提供 `git cp`。复制通过 `git hash-object -w`、
  `git update-index --add --cacheinfo` 和 `git checkout-index -f` 完成；
  复制的文件会作为新增项进入索引。
- 提交前执行 `git add -A`，随后执行 `git commit -m <message>`。
- 删除已跟踪内容使用 `git rm -r -f`，未跟踪或忽略内容使用
  `git clean -f -d -x`。
- 推送已有 upstream 时执行 `git push`；否则使用 `origin` 或第一个远程并设置
  upstream。
- 远端管理通过 `git remote add/set-url/remove` 执行，平台根据 URL 自动识别。
- 清空远端通过 `git ls-remote` 查看分支/标签，先抓取到本地备份引用，再创建一个
  空根提交，并使用原子强推替换目标分支、删除其它分支和标签。确认时必须输入
  `远端项目全称/目标分支`。受保护分支通常会导致整个操作被拒绝。
- 应用不会拉取、切换分支或以普通操作改写本地提交历史；推送、删除和远端清空
  都需要在执行计划中明确确认。
- 冲突解决、分支图和自动拉取尚未实现；推送只处理当前分支，但支持多个远端。

## 设置与更新

字体、主题和大小设置保存在软件目录的 `userdata` 文件夹。字体默认值为
软件内置的 `Noto Sans SC / 思源黑体`，用户仍可切换为其他内置字体、系统字体
或“系统默认（自动适配）”。

字体页面按“软件内置”和“系统自带”分组，提供按名称、用途和描述实时搜索。
所有候选字体都有实际字体预览，无需逐项查找。软件内置字体来自 Google Fonts，
使用 SIL Open Font License，许可证位于 `assets/fonts`。
字体大小限制为 90%–110%，避免过小或过大导致界面布局损坏。
字体页面使用常驻滚动条，并在顶部提示下方还有字体预览和字体大小设置。

设置窗口分为五个页面：字体、语言、外观设置、单位设置和关于。保存后设置应用到
整个软件。语言页面使用 `English`、`简体中文` 和 `繁體中文` 自身文字显示选项，
默认跟随操作系统语言。关于页包含版本、项目仓库入口和人工智能协作致谢。

所有软件运行数据都位于可执行文件旁的目录：

```text
<软件目录>/
  GitGuiExpandLauncher.exe
  current-version.txt
  pending-version.txt          # 仅更新准备完成后出现
  versions/
    0.9.3/                    # 更新成功后保留的上一版本
    0.9.4/                    # 当前版本
      git_gui_expand.exe
      data/
      version.json
  userdata/
    settings.json
    recent_repositories.json
    updates/
      launcher.log
    logs/
      normal-YYYY-MM-DD.log
      detailed-YYYY-MM-DD.log
```

因此软件目录必须可写。若安装到 `Program Files` 等受保护目录，Windows 会阻止
设置和日志写入；可将完整 Release 目录解压到用户可写的位置。

请始终通过 `GitGuiExpandLauncher.exe` 启动软件。Launcher 会读取
`current-version.txt`，从 `versions/<版本>` 启动对应应用，并把共享数据目录设置为
根目录下的 `userdata`。

旧版本保存在 `%APPDATA%` 的设置会在首次启动时复制到新位置。日志查看器顶部提供
当前日志目录路径，并可直接打开该目录。

更新检查请求 GitHub 的公开 Releases API。发现新版本后可以点击“立即更新并重启”：

1. 自动下载 Release 中的 Windows x64 ZIP；
2. 使用 GitHub Release 提供的 SHA-256 校验下载文件；
3. 解压并验证 `versions/<版本>` 内的 EXE、Flutter 数据和 `version.json`；
4. 将新版本目录移动到 `versions/<新版本>`；
5. 写入 `pending-version.txt`，应用退出；
6. 常驻 Launcher 原子切换 `current-version.txt` 并启动新版本；
7. 新版本 8 秒内异常退出时恢复上一版本，不清理版本目录；
8. 新版本通过启动检查后，只保留新版本和更新前版本，其余版本目录自动删除。

`v0.8.1` 起使用 Launcher 更新架构。`v0.8.0` 及更早版本的原 PowerShell 更新助手存在
进程未启动问题，必须先手动安装一次 Launcher 版本。`v0.8.1` 和 `v0.8.2` 的哈希校验还会
受 Windows PowerShell 文本编码影响，请手动安装一次 `v0.8.3`；安装后从 Launcher 启动，
后续版本可继续自动切换。
没有公开 Release、缺少 Windows x64 资产、缺少 SHA-256 或网络不可用时，会显示可重试
提示，不会执行不完整更新。

自动更新之外始终提供“打开发布页”按钮。网络较慢、自动更新材料不完整或用户希望
手动选择安装包时，可以直接打开当前 GitHub Release 页面。

Release 页面中 Assets 上方的更新说明由 `tool/generate_release_notes.ps1` 自动生成，
只包含上一个 Git 标签到当前标签之间的 CHANGELOG 内容和提交记录，不再附加全部历史日志。

## 目录结构

```text
lib/
  app.dart
  core/
    constants/       # 应用信息与内置更新日志
    models/          # Git、文件项与设置模型
    localization/    # English、简体中文、繁體中文文案与系统语言解析
    services/        # Git、历史、字体、存储、日志、设置、更新和文件夹选择器
    theme/           # 浅色/深色主题
    utils/           # 路径和容量单位格式化
  features/
    commit/          # 提交工作区
    dialogs/         # 设置、远端管理、操作日志与更新日志
    explorer/        # 左右资源面板
    project/         # 应用框架与主工作区
    repository/      # 状态控制器
    start/           # 仓库打开页
windows/             # Windows Runner 与原生多版本 Launcher
linux/               # 预留，未开发验证
macos/               # 预留，未开发验证
docs/                # 架构、交互与平台路线
test/                # Git、远端、历史、字体、设置与启动页测试
assets/icons/        # 圆角矩形应用图标
assets/fonts/        # 软件内置 UI 字体与 OFL 许可证
tool/                # 图标、发布说明等构建辅助脚本
.github/workflows/   # 标签触发的 Windows Release 构建
```

更多说明见 [架构文档](docs/ARCHITECTURE.md)、
[交互说明](docs/UX.md) 和 [平台路线](docs/PLATFORM_ROADMAP.md)。

## 已知边界

- Windows 文件名规则会主动拒绝尾随点/空格及 `<>:"|?*` 等非法字符。
- 空目录不会被 Git 跟踪，因此资源面板只显示包含 Git 文件的项目。
- 复制目录会复制其中 tracked/untracked 且未被 `.gitignore` 排除的文件。
- 最近仓库最多保存 10 条；不存在的路径和缺失 `.git` 的记录会自动移除。
- 当前没有内置冲突编辑器、分支图、自动拉取或撤销栈。
- 待执行计划保存在当前运行会话；关闭软件前应确认执行或清空计划。
- 清空远端依赖服务器支持 atomic push；受保护分支通常需要在托管平台临时解除保护。
- 软件数据固定在程序目录，运行用户必须对软件目录拥有写权限。

## 致谢

感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。

## 许可证

本项目使用 [MIT License](LICENSE)。
