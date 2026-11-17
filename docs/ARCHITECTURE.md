# 架构说明

## 分层

```text
Flutter widgets
      │
RepositoryController (ChangeNotifier)
      │
GitService ───────── SettingsService
      │                    │
本机 git CLI        AppStorageService
                           │
                 软件目录/userdata + AppLogService
```

界面不直接拼接 shell 命令。所有 Git 参数以字符串数组传给
`Process.run('git', args)`，仓库相对路径统一保存为 POSIX `/` 分隔格式，
在访问磁盘时转换为当前平台绝对路径。

## 主要模块

| 模块 | 职责 |
| --- | --- |
| `RepositoryController` | 打开仓库、面板状态、待执行计划、逐步执行、提交与提示 |
| `GitService` | Git 命令、文件操作、远端增删改、推送、引用清空与统计 |
| `FileExplorerPanel` | 单侧资源树视图、面包屑、复选框与空/错误状态 |
| `CommitPanel` | 变更列表、提交说明、暂存、提交、推送和远端入口 |
| `RemoteManagementDialog` | 多平台远端查看、增删改和逐项/全部推送 |
| `OperationPlanDialog` | 展示、移除、确认和监控待执行操作 |
| `UserGuideDialog` | 读取并显示内置 Markdown 使用指南 |
| `SettingsService` | 用户级 JSON 设置读写及平台目录选择 |
| `RecentRepositoriesService` | 仓库验证、最近打开排序、去重、清理与 JSON 持久化 |
| `AppStorageService` | 把设置、日志与临时数据定位到可执行文件旁的 `userdata` |
| `AppLogService` | 写入普通日志和详细日志，提供读取与打开目录 |
| `DesktopShortcutService` | 通过 Windows WScript.Shell 创建当前用户桌面快捷方式 |
| `AppTheme` | 浅色、深色主题；`ThemeMode.system` 跟随设备 |
| `AppLocalizations` | English、简体中文、繁體中文文案与操作系统语言解析 |
| `UpdateService` | GitHub Releases API 检查与 HTTPS 外链打开 |
| `UpdateInstallerService` | 下载、SHA-256 校验、准备独立版本目录并写入 pending 标记 |
| `GitGuiExpandLauncher` | 原生 Windows 启动器，切换版本、重启和失败回滚 |
| `FolderPickerService` | Windows 标准“打开”对话框、目录启动、文件定位与默认应用打开 |
| `FontCatalogService` | 读取 Windows InstalledFontCollection 或跨平台 fontconfig 字体 |

## 本地数据

```text
<软件目录>/userdata/
  settings.json
  recent_repositories.json
  logs/
    normal-YYYY-MM-DD.log
    detailed-YYYY-MM-DD.log
  picker-<timestamp>.txt
  updates/
    backups/
    stage-v<version>/
    updater.log
```

`picker-*` 只在文件夹选择期间存在，读取后立即删除。设置和日志不使用用户
`APPDATA`、`XDG_CONFIG_HOME` 或 macOS Application Support。旧版设置只读复制到
新位置，旧文件不会被改写。

最近仓库记录仅包含经过 Git 根目录验证、且当前仍存在 `.git` 文件或目录的路径。
记录按最后打开时间倒序，Windows 下路径比较不区分大小写，最多保存 10 条。

普通日志接收 `info`、`warning` 和 `error`。详细日志额外接收 `detail`，并包含
普通日志全部内容。日志写入采用串行队列，单次失败不会中断 Git 操作。
`AppLogService` 在写入前使用当前本地化器转换已知事件文案，因此新日志跟随所选
界面语言；Git 命令、stdout/stderr 和外部技术错误保持原始内容。

## 操作计划

界面只把用户意图转换为 `PlannedRepositoryOperation`，先追加到
`RepositoryController.pendingOperations`，不会直接调用会修改仓库的 GitService
方法。计划步骤保存标题、说明、危险标志、二次确认文本和执行闭包。

`OperationPlanDialog` 提供：

- 按顺序展示全部步骤；
- 逐项移除或整体清空；
- 危险确认和“项目全称/目标分支”精确匹配；
- 逐步执行进度；
- 失败后保留失败步骤和后续步骤。

`executePendingOperations` 在执行前设置全局 busy，随后顺序调用每个步骤的执行闭包。
成功步骤从计划中移除；任一步失败立即停止。文件操作仍由
`GitService` 重新验证源路径、目标冲突和仓库边界。

清空远端要求该步骤独占计划。执行时先用 `git ls-remote --refs` 快照 heads/tags，
把原引用 `git fetch` 到 `refs/gitgui-expand/backup/<remote>`；然后使用
`git mktree` 和 `git commit-tree` 创建空目录树及空根提交，不修改工作区或索引。
最后以 `git push --atomic --force` 把目标分支替换为该提交，并删除其它 heads/tags。
推送成功后使用 `git reset --mixed` 把本地同名分支和索引同步到空提交，磁盘文件仍保留，
因此刷新后会显示为未跟踪。
平台保护、atomic push 不支持、认证或网络失败都会终止并记录。

## 自动更新

1. `UpdateService` 读取最新 Release，并只选择带 SHA-256 的 Windows x64 ZIP。
2. 下载文件写入 `userdata/updates`，随后由 Dart `crypto` 流式计算 SHA-256。
3. 解压到 `userdata/updates/stage-v<version>`，寻找发布包中的
   `versions/<version>`。
4. 验证 EXE、`data/app.so`、`data/flutter_assets` 和 `version.json`。
5. 将已验证目录移动到根目录 `versions/<version>`，写入 `pending-version.txt`。
6. 主应用退出后，Launcher 切换 `current-version.txt` 并启动新版本。
7. 新版本若在 8 秒内退出，Launcher 恢复 `rollback-version.txt`，不删除版本目录。
8. 新版本通过启动检查后，Launcher 只保留当前版本，其余版本目录递归删除。
9. Launcher 同时清理下载的 ZIP、未完成下载、`stage-v*` 临时目录和旧更新脚本；
   清理失败只写 `userdata/updates/launcher.log`。

运行中的版本不会被覆盖。`userdata` 位于 Launcher 根目录，由全部版本共享。
回滚路径和未实际应用更新时的启动不会触发旧版本清理。

`ReadVersionFile` 兼容 UTF-8 BOM、UTF-16 LE/BE BOM。若
`current-version.txt` 缺失或无效，Launcher 会从 `versions` 中选择有效目录并重建
标记；多个有效目录时按数字版本段选择最高版本。根目录直接包含
`git_gui_expand.exe` 与 `data/app.so` 时，提供平铺 Release 兼容启动。

`InstallationMaintenanceService` 在应用启动时执行第二层清理，处理旧 Launcher
不会运行新版清理代码的迁移场景。它扫描并删除非当前版本目录、更新 ZIP、
`.part`、`stage-v*`、旧更新脚本和根目录旧平铺程序文件，保留当前版本及
`userdata`。扫描结果也可通过设置中的 `InstallationCleanupDialog` 手动查看和清除。

发布包在 `versions/<version>/maintenance` 携带新版 Launcher。应用退出后，维护
PowerShell 助手会重试覆盖根目录 Launcher；这是为了解决 Windows 无法覆盖正在
运行的可执行文件，以及旧 Launcher 无法自更新的一次性迁移问题。

Release 说明由 `tool/generate_release_notes.ps1` 生成。脚本从当前标签的父提交
寻找上一个标签，读取 CHANGELOG 中当前标签之前、上个标签之后的全部版本小节，并收集
`<previousTag>..<currentTag>` 的提交记录。完整历史 CHANGELOG 不会写入 Release 描述。

## 外观

`AppSettings.themePreference` 保存 `system`、`light` 或 `dark`。
`AppSettings.colorSchemePreference` 保存 `emerald`、`ocean`、`violet`、
`amber` 或 `rose`，主题根据所选配色生成 Material ColorScheme。
`MaterialApp` 同时提供 `theme`、`darkTheme` 和 `ThemeMode`，选择跟随系统时由
Flutter 监听设备亮度并自动重建。窗口级 `WidgetsBindingObserver` 额外记录外观变化。
字体默认值是内置字体族 `Noto Sans SC`。选择“系统默认”时，
`ThemeData.fontFamily` 保持 null 以使用当前平台系统字体。缺失字体由 Flutter
回退到系统字体。

软件内置字体通过 Flutter `fonts` 资源注册：

| 字体族 | 用途 | 许可证 |
| --- | --- | --- |
| `Inter UI` | 高密度英文与数字界面 | SIL OFL |
| `Noto Sans SC` | 中英文混排界面 | SIL OFL |
| `IBM Plex Sans` | 产品信息与数字阅读 | SIL OFL |

系统字体由 `FontCatalogService` 枚举，设置页把内置和系统字体合并为可搜索列表。
全局字号通过 `MediaQuery.textScaler` 应用，模型只接受 0.9–1.1 的范围，
设置页只提供 90%、100%、110% 三档。

## 本地化

`AppSettings.languagePreference` 保存 `system`、`english`、
`simplifiedChinese` 或 `traditionalChinese`，默认值为 `system`。
`MaterialApp` 注册 Flutter 官方 Material/Widgets/Cupertino 本地化代理以及软件
自有 `AppLocalizations` 代理。

选择系统语言时把 `MaterialApp.locale` 设为 null，由
`localeListResolutionCallback` 读取平台语言列表。英文解析为 `en`；简体中文区域
解析为 `zh-CN`；繁体中文脚本或台湾、香港、澳门区域解析为 `zh-Hant`；其它语言
回退到英文。语言偏好、字体迁移和配色方案使用独立设置版本，当前版本为 4。

## 图标

`tool/generate_app_icons.ps1` 从同一几何规则生成多尺寸 Windows ICO、macOS
AppIcon PNG、Linux 预留 PNG 和 Flutter 资源图。树形节点与界面品牌内容保持一致，
外轮廓始终是透明背景上的圆角矩形。

## 版本目录

```text
GitGuiExpandLauncher.exe
current-version.txt
pending-version.txt
versions/<version>/
userdata/
```

Launcher 和 `userdata` 在版本切换时保持不变。版本字符串只允许字母、数字、点、横线和
下划线，防止目录穿越。

Launcher 从 `pending-version.txt` 获取本次新版本，从切换前的
新版本通过启动检查后，只有 `current-version.txt` 指向的目录被保留，其它同级版本
目录会被清理。符号链接目录不会被递归删除。

## 文件枚举

目录列表使用：

```text
git ls-files -z --cached --others --exclude-standard -- <directory>/
```

结果同时包含已跟踪和未跟踪但未被忽略的文件。直接子文件夹从文件路径推导，
空目录不会显示。每个文件的大小通过磁盘元数据读取，项目总大小会遍历仓库并跳过
`.git` 元数据。

## 状态解析

Git 状态使用 `git status --porcelain=v1 -z --untracked-files=all`。
解析器处理重命名/复制条目后的第二个 NUL 字段，并将新路径作为当前路径。

## 移动与重命名

执行前会验证：

- 目标目录存在；
- 目标目录不是源文件夹自身或其后代；
- 目标位置没有同名项目；
- 批量目标之间没有重名；
- 不会操作 `.git` 或逃逸到仓库外。

未跟踪项目会先用 `git add --all -- <path>` 加入索引，再使用 `git mv`。

## 删除与推送

批量删除会先去重并移除被父目录覆盖的子路径，然后逐项判断索引状态：

- 已跟踪内容：`git rm -r -f -- <path>`；
- 未跟踪或忽略内容：`git clean -f -d -x -- <path>`；
- 删除结束后重新读取面板、Git 状态和项目容量。

推送先读取当前分支。若 `@{u}` 存在则执行 `git push`；否则读取 remote，
优先使用 `origin`，否则选择第一个远程并执行 `git push -u <remote> <branch>`。
应用不会自动提交，也不会在认证失败后尝试交互式密码输入。

## 分支

`GitService.localBranches` 使用 `git for-each-ref refs/heads`；创建使用
`git branch --`，切换使用 `git switch`，重命名使用 `git branch -m`，
安全删除使用 `git branch -d`，用户明确选择后才使用 `git branch -D`。
所有分支操作先进入 `RepositoryController` 的执行计划。

## 初始化、克隆与 Stash

空白目录初始化通过 `git init`，克隆通过 `git clone -- <url> <destination>`；
两者都先验证目录和远程地址。Stash 使用 `git stash push`、`list`、`apply`、
`pop` 和 `drop`，`--include-untracked` 由用户选择。Stash 操作经过执行计划，
选择器必须符合 `stash@{n}`。

清除 Git 元数据会再次执行 `git remote`；只要存在任何 remote 就拒绝。确认后仅
递归删除仓库根目录的 `.git` 普通目录，工作文件保留。worktree/子模块的 `.git`
文件以及符号链接不会作为清理目标。

## 复制

Git 没有复制命令，因此复制使用 Git plumbing：

1. `git ls-files -s` 获取模式。
2. `git hash-object -w --path=<target> -- <source>` 写入 blob。
3. `git update-index --add --cacheinfo <mode>,<hash>,<target>` 建立索引项。
4. `git checkout-index -f -- <target>` 从索引写出工作区文件。

目录复制先用 `git ls-files` 展开内部 tracked/untracked 文件，并在写入前检查全部
目标冲突。复制会修改索引，使新增文件出现在 Git 变更列表中。

## 提交

应用当前采用“提交全部更改”：

```text
git add -A
git commit -m <message>
```

没有独立的分块暂存、历史改写或自动推送。

## 平台扩展

Linux/macOS 需要替换 Windows PowerShell 文件夹选择器和外链启动逻辑，并补充
对应平台的构建、文件权限、窗口最小尺寸与交互测试。现有 `GitService` 和业务状态
层不依赖 Win32 API。
