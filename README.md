# Git GUI Expand

<img src="assets/icons/app_icon.png" alt="Git GUI Expand 图标" width="96">

Git GUI Expand 是一个以 Windows 为首要目标的 Flutter 桌面应用。它把 Git
仓库中的文件浏览、批量移动、复制、重命名、暂存与提交集中到左右双栏界面中，
所有文件和提交变更都通过本机 Git CLI 执行。

当前版本：`0.2.1`

远程仓库：<https://github.com/CY68GI/Git_Gui_Expand>

## 当前支持

- Windows 10/11 为当前开发和验证平台。
- 选择并打开已经初始化的 Git 仓库根目录。
- 左右两个资源面板独立浏览同一仓库，可分别进入不同目录。
- 文件夹和文件复选框选择，支持跨目录保留批量选择。
- 剪切、复制、粘贴、重命名和左右面板间批量移动。
- 当前活动面板决定粘贴目标文件夹。
- 实时显示 Git 状态，可暂存全部、取消暂存并填写说明提交全部更改。
- 显示仓库名称、分支、仓库总大小、文件数量、待提交数量和每个文件大小。
- 大小单位支持 IEC 二进制、SI 十进制、Byte 和 bit。
- 支持跟随系统、浅色和深色三种外观模式，系统外观变化会即时同步。
- 所有窗口、任务栏、可执行文件、macOS 预留图标集和应用内品牌使用同一圆角矩形树形图标。
- 普通日志记录关键事件，详细日志记录导航、选择、设置、更新及每条 Git 命令和输出。
- 设置、日志、选择器临时文件等运行数据统一保存在软件目录的 `userdata` 文件夹。
- 通过 GitHub Releases API 检查更新，并内置当前版本更新日志。
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

1. 点击“打开 Git 仓库”，选择仓库根目录。
2. 在任一资源面板使用复选框勾选文件或文件夹。
3. 双击文件夹进入；点击面板即将其设为当前粘贴目标。
4. 使用工具栏或快捷键剪切/复制，再在目标面板执行粘贴。
5. 使用“重命名”或 `F2` 修改单个选中项。
6. 在底部提交区填写说明，点击“提交全部更改”。

| 快捷键 | 操作 |
| --- | --- |
| `Ctrl+O` | 打开仓库 |
| `Ctrl+X` | 将当前勾选项目放入剪切剪贴板 |
| `Ctrl+C` | 将当前勾选项目放入复制剪贴板 |
| `Ctrl+V` | 粘贴到当前活动面板所在目录 |
| `F2` | 重命名当前唯一勾选项目 |
| `Ctrl+A` | 全选当前面板可见项目 |
| `Ctrl+R` | 刷新仓库、状态与容量 |

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
- 应用不会自行推送、拉取、切换分支或改写历史。
- 删除、冲突解决、分支管理和远程同步尚未实现。

## 设置与更新

所有软件运行数据都位于可执行文件旁的目录：

```text
<软件目录>/
  git_gui_expand.exe
  userdata/
    settings.json
    logs/
      normal-YYYY-MM-DD.log
      detailed-YYYY-MM-DD.log
```

因此软件目录必须可写。若安装到 `Program Files` 等受保护目录，Windows 会阻止
设置和日志写入；可将完整 Release 目录解压到用户可写的位置。

旧版本保存在 `%APPDATA%` 的设置会在首次启动时复制到新位置。日志查看器顶部提供
当前日志目录路径，并可直接打开该目录。

更新检查请求 GitHub 的公开 Releases API。发现新版本时只打开下载页面，
不会自动下载、替换或重启程序。没有公开 Release 或离线时会显示可重试的提示；
内置更新日志仍然可以离线查看。

## 目录结构

```text
lib/
  app.dart
  core/
    constants/       # 应用信息与内置更新日志
    models/          # Git、文件项与设置模型
    services/        # Git、存储、日志、设置、更新和文件夹选择器
    theme/           # 浅色/深色主题
    utils/           # 路径和容量单位格式化
  features/
    commit/          # 提交工作区
    dialogs/         # 设置、操作日志与更新日志
    explorer/        # 左右资源面板
    project/         # 应用框架与主工作区
    repository/      # 状态控制器
    start/           # 仓库打开页
windows/             # 当前支持平台
linux/               # 预留，未开发验证
macos/               # 预留，未开发验证
docs/                # 架构、交互与平台路线
test/                # Git 服务与启动页测试
assets/icons/        # 圆角矩形应用图标
.github/workflows/   # 标签触发的 Windows Release 构建
```

更多说明见 [架构文档](docs/ARCHITECTURE.md)、
[交互说明](docs/UX.md) 和 [平台路线](docs/PLATFORM_ROADMAP.md)。

## 已知边界

- Windows 文件名规则会主动拒绝尾随点/空格及 `<>:"|?*` 等非法字符。
- 空目录不会被 Git 跟踪，因此资源面板只显示包含 Git 文件的项目。
- 复制目录会复制其中 tracked/untracked 且未被 `.gitignore` 排除的文件。
- 当前没有内置冲突编辑器、分支图、远程同步或撤销栈。
- 软件数据固定在程序目录，运行用户必须对软件目录拥有写权限。

## 许可证

仓库尚未提供许可证文件。分发或商用前应由项目所有者补充明确许可证。
