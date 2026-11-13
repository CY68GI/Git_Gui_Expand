class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.items,
  });

  final String version;
  final String date;
  final String title;
  final List<String> items;
}

const List<ChangelogEntry> builtInChangelog = [
  ChangelogEntry(
    version: '0.8.1',
    date: '2026-11-13',
    title: 'Launcher 多版本安全更新',
    items: [
      'Windows 发布结构改为稳定 Launcher 与 versions/<版本> 独立目录。',
      '自动更新只准备并校验新版本目录，不再覆盖正在运行的程序文件。',
      '主程序退出后由 Launcher 原子切换版本并自动重启。',
      '新版本启动失败时自动恢复上一版本。',
      'userdata 由所有版本共享，升级不会覆盖设置、日志或最近仓库记录。',
      '修复 detached PowerShell 更新助手未执行的问题。',
    ],
  ),
  ChangelogEntry(
    version: '0.8.0',
    date: '2026-11-13',
    title: '多平台远端与安全字号',
    items: [
      '提交工作区新增远端管理，可查看 GitHub、Gitee、GitLab 和通用 Git 远端。',
      '支持添加、修改、删除远端，并可逐项推送或推送到全部远端。',
      '新增字体大小 90%、100%、110% 三档，模型层强制限制安全范围。',
      '源代码和自动更新发布流程同时支持 GitHub 与 Gitee。',
    ],
  ),
  ChangelogEntry(
    version: '0.7.0',
    date: '2026-11-13',
    title: '可搜索 UI 字体与增量发布说明',
    items: [
      '软件内置 Inter UI、Noto Sans SC 和 IBM Plex Sans 三款 OFL 开源 UI 字体。',
      '软件默认字体改为内置的 Noto Sans SC / 思源黑体。',
      '字体设置按“软件内置”和“系统自带”分组，并支持按名称与用途实时搜索。',
      '字体列表显示实际字体预览，避免逐项查找和误选。',
      'GitHub Release 描述只生成上一个标签到当前标签范围内的更新与提交。',
      '继续保留更新页“打开发布页”和提交工作区推送。',
    ],
  ),
  ChangelogEntry(
    version: '0.6.0',
    date: '2026-11-13',
    title: '设置分页、更新后备与提交区推送',
    items: [
      '更新页新增“打开发布页”，网络缓慢或自动更新失败时可手动进入 Release。',
      '推送按钮从顶部移动到提交工作区，保留 Ctrl+Shift+U 快捷键。',
      '设置重构为字体、外观模式、单位设置和关于四个独立页面。',
      '关于页和 README 新增 DeepSeek 人工智能与 ChatGPT Codex 协作致谢。',
    ],
  ),
  ChangelogEntry(
    version: '0.5.0',
    date: '2026-11-13',
    title: '一键自动更新',
    items: [
      '发现新版本后可直接下载、校验、替换并自动重启，无需手动下载 ZIP。',
      '更新包必须通过 GitHub Release 提供的 SHA-256 校验。',
      '更新助手在独立进程中等待应用退出，保留 userdata 并创建更新前备份。',
      '替换或启动失败时自动回滚到上一版本。',
      'Release 包新增 version.json，更新前会验证包内版本与目标版本一致。',
    ],
  ),
  ChangelogEntry(
    version: '0.4.0',
    date: '2026-11-13',
    title: '最近仓库历史',
    items: [
      '启动页新增最近打开 Git 仓库卡片，可单击快速打开。',
      '仅保存经过 Git 根目录验证的仓库，最多保留 10 条并按时间排序。',
      '重复仓库自动前移，失效记录自动清理，也可手动从历史中移除。',
      '历史记录保存在软件目录 userdata/recent_repositories.json。',
    ],
  ),
  ChangelogEntry(
    version: '0.3.0',
    date: '2026-11-13',
    title: '文件删除、远程推送与字体选择',
    items: [
      '新增带确认的批量删除，已跟踪项使用 git rm，未跟踪和忽略项使用 git clean。',
      '新增推送当前分支，可自动使用 upstream、origin 或第一个可用远程。',
      '新增 Delete 删除和 Ctrl+Shift+U 推送快捷键。',
      '新增系统字体读取和字体选择，默认使用各操作系统原生字体。',
      '字体与主题、大小单位一起持久化到软件目录 userdata。',
    ],
  ),
  ChangelogEntry(
    version: '0.2.1',
    date: '2026-11-13',
    title: '桌面体验与诊断升级',
    items: [
      '新增跟随 Windows、浅色和深色三种外观模式，切换后即时生效。',
      '应用设置、普通日志和详细日志统一存放在软件目录 userdata 文件夹。',
      '新增操作日志查看器，详细日志记录导航、选择、设置、更新和每条 Git 命令。',
      'Windows、macOS、Linux 预留位置和应用内品牌统一为圆角矩形树形图标。',
      '版本号升级为 0.2.1，并发布 Windows x64 完整程序包。',
    ],
  ),
  ChangelogEntry(
    version: '0.1.0',
    date: '2026-11-13',
    title: '首个 Windows 版本',
    items: [
      '左右双资源面板可独立浏览同一个已初始化 Git 仓库。',
      '复选框支持批量选择，通过剪切、复制、粘贴在左右面板间移动文件。',
      '文件与文件夹重命名使用 git mv，并拒绝危险的目标冲突。',
      '目录复制使用 Git 对象、索引与 checkout-index 完成。',
      '提供提交工作区，可暂存、取消暂存、填写说明并提交全部更改。',
      '显示仓库大小和每个文件大小，支持 IEC、SI、Byte 与 bit 切换。',
      '支持检查 GitHub Releases，并提供内置更新日志。',
    ],
  ),
];
