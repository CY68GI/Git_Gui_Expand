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
| `RepositoryController` | 打开仓库、左右面板状态、选择集合、剪贴板、提交与提示 |
| `GitService` | Git 命令、目录列表、状态解析、移动/复制/重命名/删除/推送、统计 |
| `FileExplorerPanel` | 单侧资源树视图、面包屑、复选框与空/错误状态 |
| `CommitPanel` | 变更列表、提交说明、暂存与提交按钮 |
| `SettingsService` | 用户级 JSON 设置读写及平台目录选择 |
| `RecentRepositoriesService` | 仓库验证、最近打开排序、去重、清理与 JSON 持久化 |
| `AppStorageService` | 把设置、日志与临时数据定位到可执行文件旁的 `userdata` |
| `AppLogService` | 写入普通日志和详细日志，提供读取与打开目录 |
| `AppTheme` | 浅色、深色主题；`ThemeMode.system` 跟随设备 |
| `UpdateService` | GitHub Releases API 检查与 HTTPS 外链打开 |
| `UpdateInstallerService` | 下载、SHA-256 校验、解压、验证和启动更新助手 |
| `FolderPickerService` | Windows 原生文件夹选择器，通过独立 PowerShell 进程 |
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

## 自动更新

1. `UpdateService` 读取最新 Release，并只选择文件名包含 `windows`、`x64`、
   且 API 提供 `sha256:` digest 的 ZIP。
2. 下载文件写入 `userdata/updates`，随后调用 Windows `Get-FileHash` 校验。
3. PowerShell 解压到 `userdata/updates/stage-v<version>`，验证
   `git_gui_expand.exe`、Flutter `data` 和 `version.json`。
4. 更新助手以隐藏进程启动，等待当前应用退出。
5. 助手将除 `userdata` 外的程序文件备份到 `updates/backups`，替换文件并启动新版本。
6. 新进程两秒内异常退出、文件复制失败或可执行文件缺失时，删除新文件、恢复备份并
   启动旧版本。

更新助手脚本自身和全部下载/备份数据都在软件目录内，不写入用户配置目录。

## 外观

`AppSettings.themePreference` 保存 `system`、`light` 或 `dark`。
`MaterialApp` 同时提供 `theme`、`darkTheme` 和 `ThemeMode`，选择跟随系统时由
Flutter 监听设备亮度并自动重建。窗口级 `WidgetsBindingObserver` 额外记录外观变化。
字体默认值为空，`ThemeData.fontFamily` 保持 null 以使用当前平台系统字体。只有用户
明确选择后才写入具体字体族，缺失字体由 Flutter 回退到系统字体。

## 图标

`tool/generate_app_icons.ps1` 从同一几何规则生成多尺寸 Windows ICO、macOS
AppIcon PNG、Linux 预留 PNG 和 Flutter 资源图。树形节点与界面品牌内容保持一致，
外轮廓始终是透明背景上的圆角矩形。

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
