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
