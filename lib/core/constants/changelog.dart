class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.items,
    this.titleKey = '',
    this.itemKeys = const [],
  });

  final String version;
  final String date;
  final String title;
  final List<String> items;
  final String titleKey;
  final List<String> itemKeys;
}

const List<ChangelogEntry> builtInChangelog = [
  ChangelogEntry(
    version: '0.10.0',
    date: '2026-11-24',
    title: '结构化运行消息、Markdown 指南与安全链接',
    titleKey: 'changelog0100Title',
    items: [
      '操作结果、待执行计划和日志改用语义模板；日志新增稳定事件 ID、写入时语言和凭据遮蔽。',
      '内置指南改为真正的 Markdown 渲染，支持标题、列表、表格、引用、代码块、图片和行内格式。',
      '指南链接仅允许 HTTPS、内置指南和标题锚点，并提供键盘焦点、选择复制与安全响应式布局。',
      '新增三语指南资源、源码防回归检查和完整的结构化消息测试覆盖。',
    ],
    itemKeys: [
      'changelog0100ItemMessages',
      'changelog0100ItemMarkdown',
      'changelog0100ItemLinks',
      'changelog0100ItemTests',
    ],
  ),
  ChangelogEntry(
    version: '0.9.9',
    date: '2026-11-23',
    title: '分支同步、安全快进 Pull 与提交身份预检',
    titleKey: 'changelog099Title',
    items: [
      '显示 upstream、ahead、behind 和工作区同步状态。',
      '新增当前 upstream 或全部远端 Fetch 计划，并逐项报告结果。',
      '新增仅快进 Pull，拒绝脏工作区、无 upstream 和分叉历史。',
      '提交前及执行前检查有效的 Git 作者和提交者身份。',
    ],
    itemKeys: [
      'changelog099ItemSyncStatus',
      'changelog099ItemFetchPlan',
      'changelog099ItemFastForwardPull',
      'changelog099ItemGitIdentity',
    ],
  ),
  ChangelogEntry(
    version: '0.9.8',
    date: '2026-11-23',
    title: '统一操作计划与执行前状态复核',
    items: [
      '初始化、克隆、仓库修改和 .git 清除统一使用可确认的操作预览。',
      '执行前复核仓库根目录、分支、HEAD、状态、路径和远端引用。',
      '状态漂移时停止操作，显示详情并提供刷新仓库、重建计划入口。',
      '清空远端前比较引用哈希，并使用 atomic push 和逐引用 lease。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.7',
    date: '2026-11-17',
    title: '空白目录初始化、克隆与 Stash 管理',
    items: [
      '打开空白文件夹时可立即询问是否执行 git init。',
      '新增克隆仓库窗口，可填写远程地址、父目录和项目名称。',
      '新增 Stash 创建、查看、应用、弹出、删除和包含未跟踪文件。',
      '无远端仓库可清除 .git 元数据，工作文件保留并显示完整风险说明。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.6',
    date: '2026-11-17',
    title: '修复根目录 Launcher 未更新并提供清理扫描',
    items: [
      '应用启动后自动清理旧版本、下载包、临时目录和旧平铺程序文件。',
      '新版本携带维护用 Launcher，应用退出后安全更新根目录 Launcher。',
      '设置关于页新增扫描窗口和一键清除旧版本内容。',
      '关于页显示 git_gui_expand 和 GitGuiExpandLauncher 实际版本。',
      '新增分支创建、切换、重命名、安全删除和强制删除。',
      '更新支持 GitHub 与 Gitee 双源，并使用 SHA-256 校验。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.5',
    date: '2026-11-17',
    title: '只保留最新版、全局配色与 Git 功能清单',
    items: [
      '每次成功启动后只保留当前版本，删除其他版本和下载的更新包。',
      '配色方案统一应用到界面表面、图标、状态徽标、按钮和提示。',
      '三份 README 增加 Git 功能覆盖表，明确已完成和未完成功能。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.4',
    date: '2026-11-16',
    title: 'MIT 许可证、自动清理旧版本与外观配色',
    items: [
      '项目正式采用 MIT License，并在三份 README 中增加项目徽章。',
      'Launcher 每次成功启动都会保留当前版本和上一已安装版本，删除其余旧版本。',
      '“外观模式”改名为“外观设置”，新增五种可选配色方案。',
      '按钮、选择状态、边框、图标和强调文字会随配色方案变化。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.3',
    date: '2026-11-16',
    title: '三语界面、桌面快捷方式与全新解压修复',
    items: [
      '设置支持 English、简体中文和繁體中文；跟随系统时只显示操作系统实际语言。',
      'README、使用指南、更新日志和普通/详细日志支持三种语言。',
      '全新解压包缺少版本标记时，Launcher 可自动恢复有效版本目录并直接启动。',
      '设置关于页新增一键发送桌面快捷方式，优先指向稳定 Launcher。',
      '更新成功后只保留当前版本与更新前版本，失败或回滚时不会清理版本目录。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.2',
    date: '2026-11-16',
    title: '文件右键菜单与系统打开方式',
    items: [
      '文件行支持右键菜单，可在 Windows 文件资源管理器中定位文件。',
      '右键菜单可使用系统默认应用打开文件。',
      '右键未选中文件时会自动设为当前活动面板的单选项目。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.1',
    date: '2026-11-16',
    title: '同步本地空历史并显示未跟踪文件',
    items: [
      '清空远端历史后，本地同名分支会同步指向同一个空根提交。',
      '本地索引重置为空，但磁盘文件保留，软件刷新后显示为未跟踪。',
      '空提交说明改为包含时间、远端用户名、项目名、分支名和 Git GUI Expand。',
      '本地分支与远端目标分支不一致时，在执行任何远端修改前拒绝操作。',
    ],
  ),
  ChangelogEntry(
    version: '0.9.0',
    date: '2026-11-16',
    title: '执行计划、远端清空与可读性',
    items: [
      '所有会修改仓库的操作先进入待执行计划，可逐项移除或整体放弃。',
      '确认后按顺序逐步执行，失败时停止并保留失败步骤及后续步骤。',
      '新增远端历史原子清空：保留一个空根提交，删除其它分支和标签；'
          '本地文件保留并变为未跟踪。',
      '危险操作需要危险确认；清空远端还必须手动输入“远端项目全称/分支名称”。',
      'Windows 仓库选择改为标准“打开”对话框，项目打开后可直接打开项目目录。',
      '提高页面、对话框、日志和操作提示的关键文字字号。',
      '设置页增加常驻滚动条，字体页明确提示下方还有字体预览和字体大小。',
      '新增应用内使用指南，说明计划、提交、推送和远端清空流程。',
    ],
  ),
  ChangelogEntry(
    version: '0.8.3',
    date: '2026-11-14',
    title: '修复更新包校验与自动重启',
    items: [
      'SHA-256 改为直接读取文件字节计算，不再依赖 PowerShell 输出的系统文本编码。',
      '修复下载达到 100% 后在校验阶段中止、软件退出但不切换版本的问题。',
      '增加文件哈希回归测试，确保 Windows 更新包可以继续进入解压和 Launcher 切换流程。',
    ],
  ),
  ChangelogEntry(
    version: '0.8.2',
    date: '2026-11-14',
    title: 'Launcher 更新链路验证与设置迁移',
    items: [
      '修复旧设置中空字体字段导致 Noto Sans SC 默认字体未生效的问题。',
      '增加一次性设置版本迁移，同时保留用户主动选择的系统默认字体。',
      '验证 Launcher 可完成版本目录准备、切换、重启和共享 userdata。',
    ],
  ),
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
