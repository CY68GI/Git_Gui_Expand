// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppL10nZh extends AppL10n {
  AppL10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Git GUI Expand';

  @override
  String get openRepository => '打开 Git 仓库';

  @override
  String get settings => '设置';

  @override
  String get cancel => '取消';

  @override
  String get saveSettings => '保存设置';

  @override
  String get aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata =>
      '当前有待执行操作计划，请先清空或执行后再清除 Git。';

  @override
  String get aWindowsFirstFlutterGraphicalFileWorkspaceForGit =>
      'Windows 优先的 Flutter Git 图形化文件工作区。';

  @override
  String get about => '关于';

  @override
  String get aboutInformationDoesNotChangeSettings => '关于信息不会修改设置';

  @override
  String get acknowledgements => '致谢';

  @override
  String get addClearOperationToPlan => '加入清除计划';

  @override
  String get addClearToPlan => '加入清空计划';

  @override
  String get addCloneToPlan => '加入克隆计划';

  @override
  String get addCommitToPlan => '加入提交计划';

  @override
  String addDeletionOfItemsToThePlan(String count) {
    return '将删除 $count 个项目加入计划';
  }

  @override
  String get addDeletionToPlan => '加入删除计划';

  @override
  String get addGitToPath => '将 Git 加入 PATH';

  @override
  String get addPushAllPlan => '加入全部推送计划';

  @override
  String get addPushAllToThePlan => '将全部推送加入计划';

  @override
  String addPushOfToThePlan(String branch) {
    return '将推送 $branch 加入计划';
  }

  @override
  String get addPushToPlan => '加入推送计划';

  @override
  String addPushToToThePlan(String remote) {
    return '将推送到 $remote 加入计划';
  }

  @override
  String get addRemote => '添加远端';

  @override
  String addRemovalOfRemoteToThePlan(String remote) {
    return '将移除远端配置 $remote 加入计划';
  }

  @override
  String get addRemovalToPlan => '加入移除计划';

  @override
  String get addToAddPlan => '加入添加计划';

  @override
  String get addToPlan => '加入执行计划';

  @override
  String get addToSystemPath => '加入系统 PATH';

  @override
  String get addToUpdatePlan => '加入修改计划';

  @override
  String get addToUserPath => '加入用户 PATH';

  @override
  String
  addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
    String path,
    String url,
  ) {
    return '地址：$url\n目标目录：$path\n取消不会创建任何文件，确认计划后才会再次检查目标并执行 git clone。';
  }

  @override
  String
  get afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution =>
      '清理后该文件夹会变成普通目录，仍可用“打开空白文件夹”重新执行 git init。现在只加入清除计划；还需要在操作计划中输入 CLEAR GIT 并确认执行。';

  @override
  String get ahead => '待推送';

  @override
  String allowedRange(String max, String min) {
    return '允许范围：$min%–$max%';
  }

  @override
  String alreadyContainsPortablegit(String scope) {
    return '$scope 已包含 PortableGit';
  }

  @override
  String get alsoSaveUntrackedFilesGitStashIncludeUntracked =>
      '同时保存未跟踪文件（git stash --include-untracked）';

  @override
  String andMore(String count) {
    return '以及其他 $count 项';
  }

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get applicationLogs => '软件操作日志';

  @override
  String get applyStash => '应用 Stash';

  @override
  String
  get automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved =>
      '自动更新会从 GitHub 下载 Windows x64 ZIP 并校验 SHA-256，解压到 versions/<版本>。应用退出后由 GitGuiExpandLauncher 切换版本并自动重启；新版本启动失败时会回滚。根目录 userdata 和正在运行的版本不会被覆盖。';

  @override
  String get back => '返回';

  @override
  String get baseUnit => '基础单位';

  @override
  String get behind => '待拉取';

  @override
  String get binaryUses1024StepsDecimalUses1000 =>
      '二进制使用 1024 进位，十进制使用 1000 进位。';

  @override
  String get bitB => 'bit（b）';

  @override
  String get branchManagement => '分支管理';

  @override
  String get branchSynchronization => '分支同步';

  @override
  String get browseIndependentlyAndMoveAcrossPanes => '独立浏览，跨栏移动';

  @override
  String get browseMoveCopyDeleteCommitAndPushThroughTheGitCli =>
      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。';

  @override
  String
  get browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit =>
      '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。';

  @override
  String get bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense =>
      '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。';

  @override
  String get bundledPortablegit => '内置 PortableGit';

  @override
  String get bundledUiFonts => '软件内置 UI 字体';

  @override
  String
  get byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts =>
      '默认使用内置的 Noto Sans SC / 思源黑体，也可搜索系统字体或其他内置字体。';

  @override
  String get byteB => 'Byte（B）';

  @override
  String get byteDisplaysBKibOrKbBitIsMultipliedBy8First =>
      'Byte 显示 B、KiB 或 KB；bit 会先乘以 8。';

  @override
  String get cancel2 => '取消';

  @override
  String get cancelEditing => '取消编辑';

  @override
  String get changed => '有更改';

  @override
  String changes(String count) {
    return '$count 项变更';
  }

  @override
  String get changesApplyAfterSaving => '设置将在点击保存后应用到整个软件';

  @override
  String
  get changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing =>
      '修改系统 PATH 会影响整台电脑，并请求管理员权限。取消提权不会修改任何内容。';

  @override
  String get checkAgain => '重新检测';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checking => '检查中';

  @override
  String get checking2 => '正在检查…';

  @override
  String get checkingForGit => '正在检测 Git…';

  @override
  String get checkingForUpdates => '正在检查更新';

  @override
  String
  get chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst =>
      '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。';

  @override
  String get chooseCloneParentFolder => '选择克隆父目录';

  @override
  String
  get chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors =>
      '选择显示模式和配色方案；界面图标会跟随当前配色方案变化。';

  @override
  String get chooseFolder => '选择文件夹';

  @override
  String
  get chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup =>
      '可选择当前用户或系统环境变量。只添加软件管理的 runtime/git/current/cmd，并在修改前自动备份。';

  @override
  String get chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem =>
      '选择软件显示语言。默认跟随操作系统语言。';

  @override
  String get clean => '干净';

  @override
  String get cleanAll => '一键清除';

  @override
  String get clearAllRemoteBranchesAndTagsDangerous => '清空远端全部分支和标签（危险）';

  @override
  String get clearGitMetadata => '清除 Git 元数据';

  @override
  String get clearPlan => '清空计划';

  @override
  String clearRemoteHistoryFor(String remote) {
    return '清空远端历史 $remote？';
  }

  @override
  String get clearSearch => '清除搜索';

  @override
  String get clearSelection => '清除选择';

  @override
  String get cloneGitRepository => '克隆 Git 仓库';

  @override
  String get cloneIntoParentFolder => '克隆到父目录';

  @override
  String get close => '关闭';

  @override
  String get closeUserGuide => '关闭使用指南';

  @override
  String get closingTheRepository => '关闭仓库';

  @override
  String get colorScheme => '配色方案';

  @override
  String get commitMessage => '提交说明';

  @override
  String get commitWorkspace => '提交工作区';

  @override
  String get commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun =>
      '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。';

  @override
  String get confirmAndExecute => '确认并逐步执行';

  @override
  String get confirmDangerousOperations => '危险操作确认';

  @override
  String get controlHowProjectAndIndividualFileSizesAreDisplayed =>
      '控制项目大小和每个文件大小的显示方式。';

  @override
  String get copy => '复制';

  @override
  String
  get createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher =>
      '在当前用户桌面创建 Git GUI Expand 快捷方式，并通过稳定 Launcher 启动。';

  @override
  String get createBranch => '创建分支';

  @override
  String get createStash => '创建 Stash';

  @override
  String get current => '当前';

  @override
  String get currentBranch => '当前分支';

  @override
  String currentBranch2(String branch) {
    return '当前分支：$branch';
  }

  @override
  String get currentReleaseHighlights => '当前版本亮点';

  @override
  String currentSelection(String theme) {
    return '当前选择：$theme';
  }

  @override
  String currentV(String version) {
    return '当前 v$version';
  }

  @override
  String
  currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
    String version,
  ) {
    return '当前版本：$version。只清理旧版本、旧安装包和旧平铺程序文件，不删除 userdata 数据。';
  }

  @override
  String get cut => '剪切';

  @override
  String get cutCopyRenamePushAndCommit0123456789 =>
      '剪切、复制、重命名、推送与提交   0123456789';

  @override
  String get dark => '深色';

  @override
  String get delete => '删除';

  @override
  String get deleteBranch => '删除分支';

  @override
  String get deleteStash => '删除 Stash';

  @override
  String get desktopShortcut => '桌面快捷方式';

  @override
  String destinationFolder(String path) {
    return '目标目录：$path';
  }

  @override
  String
  destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
    String path,
  ) {
    return '目标目录：$path\n确认后在目标目录执行 git init，然后打开该仓库。';
  }

  @override
  String get detached => 'detached';

  @override
  String get detachedHead => 'detached HEAD';

  @override
  String get detachedHeadCannotFetchCurrentUpstreamOrPullABranch =>
      '当前处于 detached HEAD，不能 Fetch 当前 upstream 或 Pull。';

  @override
  String get detailedLog => '详细日志';

  @override
  String get detectTheGitRuntimeVersionSourceAndExecutableLocation =>
      '检测 Git 运行时、版本、来源和安装位置。';

  @override
  String detectionDetails(String error) {
    return '检测详情：$error';
  }

  @override
  String get discardPlanAndContinue => '放弃计划并继续';

  @override
  String get discardThePendingOperationPlan => '放弃待执行操作计划？';

  @override
  String get displayMode => '显示模式';

  @override
  String doesNotContainTheManagedPortablegitPath(String scope) {
    return '$scope 不包含软件管理的 PortableGit 路径';
  }

  @override
  String get doesNotExist => '不存在';

  @override
  String get done => '完成';

  @override
  String get doubleClickAFolderClickAPaneToChooseThePasteTarget =>
      '双击文件夹进入 · 点击面板切换粘贴目标';

  @override
  String get doubleClickAFolderToOpen => '双击文件夹进入';

  @override
  String get downloadGit => '下载 Git';

  @override
  String get dualPaneOperations => '双栏批量操作';

  @override
  String get editRemote => '编辑远端';

  @override
  String get editUrl => '编辑 URL';

  @override
  String get enterACloneUrlParentFolderAndProjectName => '请填写克隆地址、父目录和项目名称。';

  @override
  String get enterACommitMessage => '填写本次提交说明…';

  @override
  String enterProjectBranchToConfirm(String confirmation) {
    return '输入项目全称/分支“$confirmation”以确认';
  }

  @override
  String enterProjectBranchToConfirmAgain(String confirmation) {
    return '请输入远端项目全称/分支“$confirmation”进行二次确认。';
  }

  @override
  String get executing => '正在执行…';

  @override
  String get executingStepByStep => '正在逐步执行';

  @override
  String get executionComplete => '执行完成';

  @override
  String get executionIncomplete => '执行未全部完成';

  @override
  String get fetchAllRemotes => '获取全部远端';

  @override
  String get fetchCurrentUpstream => '获取当前 upstream';

  @override
  String get fileChangesArePendingInTheOperationPlan => '文件变更尚未执行，请在待执行操作计划中确认';

  @override
  String get files => '文件';

  @override
  String
  get filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns =>
      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。';

  @override
  String get folder => '文件夹';

  @override
  String get followSystem => '跟随系统';

  @override
  String get followSystemSwitchesWithTheDeviceLightOrDarkAppearance =>
      '跟随系统会根据设备当前的深色或浅色外观自动切换。';

  @override
  String get followTheOperatingSystemWithoutAFixedFamily => '跟随当前操作系统，不固定字体族';

  @override
  String get font => '字体';

  @override
  String get fontPreview => '字体预览';

  @override
  String get fontSize => '字体大小';

  @override
  String get forExampleFeatureLogin => '例如 feature/login';

  @override
  String get forExampleOriginGiteeOrGitlab => '例如 origin、gitee、gitlab';

  @override
  String get forExampleTemporarilySaveUnfinishedChanges => '例如 临时保存未完成修改';

  @override
  String get forceGitBranchDWhenDeletingAnUnmergedBranch =>
      '删除未合并分支时强制使用 git branch -D';

  @override
  String foundItemsAndCanBeFreed(String count, String size) {
    return '扫描到 $count 项，可释放 $size。';
  }

  @override
  String get git => 'Git';

  @override
  String get gitExecutableLocation => 'Git 安装位置';

  @override
  String get gitGuiExpandFileCommit => 'Git GUI Expand · 文件提交';

  @override
  String get gitGuiExpandUserGuide => 'Git GUI Expand 使用指南';

  @override
  String
  get gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain =>
      '需要 Git 才能打开或修改仓库。请安装 Git for Windows，然后点击“重新检测”。';

  @override
  String get gitIsUnavailableRepositoryActionsAreDisabled => 'Git 不可用，仓库操作已停用。';

  @override
  String get gitMetadata => 'Git 元数据';

  @override
  String get gitMvIndexCommit => 'git mv · index · commit';

  @override
  String get gitNotDetected => '未检测到 Git';

  @override
  String gitRepositories(String count) {
    return '$count 个 Git 仓库';
  }

  @override
  String get gitRepository => 'Git 仓库';

  @override
  String get gitRepositoryCloned => 'Git 仓库已克隆';

  @override
  String get gitRepositoryInitialized => 'Git 仓库已初始化';

  @override
  String get gitSettings => 'Git 设置';

  @override
  String get gitSource => 'Git 来源';

  @override
  String get gitVersion => 'Git 版本';

  @override
  String get gitee => 'Gitee';

  @override
  String get github => 'GitHub';

  @override
  String get githubUsuallyProvidesTheInternationalReleaseBuild =>
      'GitHub 更新源通常获取国际发布版本。';

  @override
  String get gotIt => '我知道了';

  @override
  String get guide => '指南';

  @override
  String get httpsOrGitHostOwnerRepoGit =>
      'https://... 或 git@host:owner/repo.git';

  @override
  String get iReviewedTheseOperationsAndWantToExecuteThemInOrder =>
      '我已检查上述操作，确认后立即按顺序执行';

  @override
  String get iecBinary => 'IEC 二进制';

  @override
  String get iecSiOptionalBits => 'IEC / SI，可切换 bit';

  @override
  String get importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation =>
      '重点：所有 Git 修改先进入执行计划，确认后才运行';

  @override
  String get initializeGitRepository => '初始化 Git 仓库';

  @override
  String get installedSystemFont => '系统已安装字体';

  @override
  String get installing => '正在安装…';

  @override
  String get interfaceLanguage => '界面语言';

  @override
  String items(String count) {
    return '$count 项';
  }

  @override
  String get language => '语言';

  @override
  String get language2 => '语言设置';

  @override
  String get largeFile => '大文件';

  @override
  String get lastChecked => '最近检测';

  @override
  String get leftExplorer => '左侧资源';

  @override
  String get light => '浅色';

  @override
  String
  get localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst =>
      '本地分支与 upstream 已分叉。软件不会自动 Merge 或 Rebase，请先使用外部 Git 处理分叉。';

  @override
  String get logs => '操作日志';

  @override
  String get mediumFile => '中文件';

  @override
  String get moreContentBelow => '此页还有下方内容';

  @override
  String get name => '名称';

  @override
  String get nativeGitChanges => 'Git 原生变更';

  @override
  String get newBranchNameOrRenamedBranchName => '新分支名称或重命名后的名称';

  @override
  String get newName => '新名称';

  @override
  String get noBranch => '无分支';

  @override
  String get noBundledFontMatches => '没有匹配的内置字体';

  @override
  String get noCommittedBranchYet => '尚无可提交分支';

  @override
  String
  get noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere =>
      '还没有详细日志。详细日志会记录选择、导航和每一条 Git 命令。';

  @override
  String get noFilesHere => '这里没有文件';

  @override
  String get noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents =>
      '还没有普通日志。执行打开仓库、文件操作或提交后会记录关键事件。';

  @override
  String get noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean =>
      '未发现旧版本或旧安装包，当前目录已经是干净状态。';

  @override
  String get noPendingOperations => '没有待执行操作';

  @override
  String get noPendingSteps => '当前没有待执行步骤';

  @override
  String get noProjectIsOpen => '当前没有打开的项目。';

  @override
  String get noRemoteRepositoryWasDetected => '未检测到任何远端仓库。';

  @override
  String get noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote =>
      '尚未配置远端仓库。请在右侧添加 GitHub、Gitee、GitLab 或其他 Git 远端。';

  @override
  String get noSystemFontMatches => '没有匹配的系统字体';

  @override
  String get noUpstream => '无 upstream';

  @override
  String get noUsableGitWasDetectedInstallItAndCheckAgain =>
      '未检测到可用的 Git。安装后请重新检测。';

  @override
  String get none => '无';

  @override
  String get normalLog => '普通日志';

  @override
  String get notCheckedYet => '尚未检测';

  @override
  String get notConfigured => '未配置';

  @override
  String get notDetected => '未检测';

  @override
  String nothingIsPushedYetThePlanPushesTo(
    String branch,
    String platform,
    String url,
  ) {
    return '现在不会联网推送。执行计划时，将当前分支 $branch 推送到 $platform。\n$url';
  }

  @override
  String
  get nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded =>
      '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。';

  @override
  String get oldVersionAndInstallerCleanup => '旧版本与安装包清理';

  @override
  String get onlineReleaseNotes => '线上发布说明';

  @override
  String
  get onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath =>
      '只修改当前用户的 PATH，不需要管理员权限。软件只会添加或移除自己管理的稳定运行时路径。';

  @override
  String get onlyTheLocalGitRemoteConfigurationIsRemoved =>
      '执行计划时只删除本地 Git remote 配置，不会删除远端平台上的仓库。';

  @override
  String get onlyVerifiedRepositoryRootsAreSaved => '仅保存验证成功的仓库根目录';

  @override
  String get open => '打开';

  @override
  String
  get openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository =>
      '打开现有仓库、初始化空白目录，或克隆远程仓库';

  @override
  String get openAnotherFolderOrRefreshToViewRepositoryContents =>
      '切换目录或刷新以查看仓库内容。';

  @override
  String get openEmptyFolder => '打开空白文件夹';

  @override
  String get openFolder => '打开目录';

  @override
  String get openGitRepository => '打开 Git 仓库';

  @override
  String get openReleasePage => '打开发布页';

  @override
  String get openRepository2 => '打开仓库';

  @override
  String get openWithDefaultApp => '用默认打开方式打开';

  @override
  String get openingAnotherRepository => '打开另一个仓库';

  @override
  String get openingRepository => '正在读取仓库…';

  @override
  String optionsFound(String count) {
    return '找到 $count 个选项';
  }

  @override
  String get parentFolder => '上一级';

  @override
  String get paste => '粘贴';

  @override
  String get pasteTarget => '粘贴目标';

  @override
  String get pasteToLeft => '粘贴到左侧';

  @override
  String get pasteToRight => '粘贴到右侧';

  @override
  String get pathChangeCancelled => '已取消修改 PATH';

  @override
  String pathChangeFailed(String error) {
    return 'PATH 修改失败：$error';
  }

  @override
  String pending(String count) {
    return '待执行 $count';
  }

  @override
  String get pending2 => '待提交';

  @override
  String get pendingOperationPlan => '待执行操作计划';

  @override
  String plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
    String action,
    String count,
  ) {
    return '当前有 $count 步操作尚未执行。$action会清除这些计划，仓库不会发生这些变更。';
  }

  @override
  String get popStash => '弹出 Stash';

  @override
  String get preciseSizeView => '精确大小视图';

  @override
  String get preparingToExecute => '准备执行';

  @override
  String get preparingUpdate => '正在准备更新…';

  @override
  String get projectFolder => '项目目录';

  @override
  String get projectFolderName => '项目文件夹名称';

  @override
  String get projectSize => '项目大小';

  @override
  String projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
    String branch,
    String confirmation,
    String message,
    String project,
    String target,
  ) {
    return '项目：$project\n目标分支：$branch\n目标提交：$target\n空提交说明：$message\n计划执行确认：$confirmation';
  }

  @override
  String
  get pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex =>
      'Pull 会先 Fetch 并重新检查 ahead/behind，只允许快进，不会自动创建 Merge 提交；工作区或索引不干净时禁止 Pull。';

  @override
  String get push => '推送';

  @override
  String get pushAll => '全部推送';

  @override
  String get pushCurrentBranchCtrlShiftU => '推送当前分支 (Ctrl+Shift+U)';

  @override
  String readingBranchesAndTagsFrom(String remote) {
    return '正在读取远端 $remote 的分支和标签…';
  }

  @override
  String get readingSynchronizationState => '正在读取同步状态…';

  @override
  String get recentlyOpened => '最近打开';

  @override
  String get refresh => '刷新';

  @override
  String get refreshBranches => '刷新分支';

  @override
  String get refreshLogs => '刷新日志';

  @override
  String get refreshRemotes => '刷新远端';

  @override
  String get refreshRepositoryAndRebuildPlan => '刷新仓库并重建计划';

  @override
  String get refreshRepositoryCtrlR => '刷新仓库 (Ctrl+R)';

  @override
  String get refreshStashes => '刷新 Stash';

  @override
  String get refreshSynchronizationState => '刷新同步状态';

  @override
  String get remoteCheck => '远端检查';

  @override
  String get remoteName => '远端名称';

  @override
  String get remoteRefList => '远端引用列表';

  @override
  String remoteRepositoriesWereDetectedSoClearingIsDisabled(String remotes) {
    return '检测到远端仓库，已禁止清除：$remotes';
  }

  @override
  String get remoteRepositoryUrl => '远程仓库地址';

  @override
  String get remoteUrl => '远端 URL';

  @override
  String remotes(String count) {
    return '远端 $count';
  }

  @override
  String get remotes2 => '远端仓库';

  @override
  String get removeFromHistory => '从历史记录移除';

  @override
  String get removeFromPlan => '从计划移除';

  @override
  String get removeFromSystemPath => '从系统 PATH 移除';

  @override
  String get removeFromUserPath => '从用户 PATH 移除';

  @override
  String get removeLocalRemoteConfiguration => '移除本地远端配置';

  @override
  String removedItemsAndFreed(String count, String size) {
    return '已清除 $count 项，共释放 $size。';
  }

  @override
  String removedItemsCouldNotBeDeletedCheckTheDetailedLog(
    String failed,
    String removed,
  ) {
    return '已清除 $removed 项；$failed 项无法删除，请查看详细日志。';
  }

  @override
  String get rename => '重命名';

  @override
  String get renameBranch => '重命名分支';

  @override
  String repository(String path) {
    return '仓库：$path';
  }

  @override
  String get repositoryAndRemoteOperationsAreAvailable => '可执行仓库与远端操作';

  @override
  String get repositoryViewRefreshed => '仓库视图已刷新';

  @override
  String get reviewRemoveOrExecutePendingOperations => '查看、移除或确认执行所有待处理操作';

  @override
  String get rightExplorer => '右侧资源';

  @override
  String get safeFastForwardPull => '安全快进 Pull';

  @override
  String get saveSettings2 => '保存设置';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get scanOldVersionsAndInstallers => '扫描旧版本与安装包';

  @override
  String get scrollDownForFontPreviewAndFontSizeSettings =>
      '向下滚动可查看字体预览和字体大小设置。';

  @override
  String get searchFontNameOrPurposeEGInterOrNoto => '搜索字体名称或用途，例如 Inter、思源、中文';

  @override
  String get selectAnItemToRename => '请先勾选要重命名的项目。';

  @override
  String get selectExactlyOneItemToRename => '重命名时只能勾选一个项目。';

  @override
  String get selectFilesToCutOrCopy => '勾选文件后可剪切或复制';

  @override
  String get selectItemsToDelete => '请先勾选要删除的项目。';

  @override
  String get selectTheDangerousOperationConfirmationFirst => '请先勾选“我已检查危险操作”。';

  @override
  String selected(String count) {
    return '已选 $count 项';
  }

  @override
  String selected2(String count) {
    return '已选择 $count 项';
  }

  @override
  String get settings2 => '设置';

  @override
  String get settingsDataDirectory => '设置数据目录';

  @override
  String get showInFileExplorer => '用文件资源打开';

  @override
  String get siDecimal => 'SI 十进制';

  @override
  String get size => '大小';

  @override
  String get sizeUnitSystem => '容量单位制';

  @override
  String get smallFile => '小文件';

  @override
  String get stageAll => '暂存全部';

  @override
  String staged(String count) {
    return '$count 项已暂存';
  }

  @override
  String get stash => 'Stash';

  @override
  String get stashManagement => 'Stash 管理';

  @override
  String get stashMessageOptional => 'Stash 说明（可选）';

  @override
  String get stateChangeDetails => '状态变化详情';

  @override
  String get stateChangedBeforeExecution => '执行前状态已变化';

  @override
  String get status => '状态';

  @override
  String step(String step, String title) {
    return '第 $step 步：$title';
  }

  @override
  String stepsTheRepositoryIsUnchangedUntilConfirmation(String count) {
    return '共 $count 步；确认前仓库不会发生任何改变';
  }

  @override
  String
  get supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst =>
      '支持 GitHub、Gitee、GitLab、Bitbucket 和任意标准 Git 远端。所有修改会先加入待执行计划。远端右侧红色垃圾桶用于清空该远端全部分支和标签。';

  @override
  String get switchBranch => '切换分支';

  @override
  String get sync => '同步';

  @override
  String get systemDefaultAutomatic => '系统默认（自动适配）';

  @override
  String get systemFonts => '系统自带';

  @override
  String get systemGit => '系统 Git';

  @override
  String textCanBeSelectedAndCopiedHereTheFullGuideIsIn(String path) {
    return '可在本窗口中选中并复制文字。完整指南保存在 $path。';
  }

  @override
  String
  get thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject =>
      '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。';

  @override
  String get theCloneDestinationFolderIsNotEmpty => '克隆目标目录不是空目录。';

  @override
  String get theCloneDestinationParentFolderDoesNotExist => '克隆目标父目录不存在。';

  @override
  String
  get theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText =>
      '配色方案会应用到按钮、选择状态、边框、图标和强调文字。';

  @override
  String get theCurrentBranchHasNoCommitAndCannotBePulled =>
      '当前分支尚无提交，不能 Pull。';

  @override
  String
  get theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking =>
      '当前分支没有 upstream。可获取全部远端，但 Pull 前需要配置跟踪分支。';

  @override
  String get theCurrentBranchIsSynchronizedWithUpstream =>
      '当前分支已经与 upstream 同步。';

  @override
  String get theDetailedReasonHasBeenWrittenToTheApplicationLog =>
      '详细原因已写入操作日志。';

  @override
  String get theGiteeSourceIsSuitedToMainlandChinaNetworks =>
      'Gitee 更新源适合中国大陆网络环境。';

  @override
  String
  get theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata =>
      '初始化目标必须存在且不能已经包含 Git 元数据。';

  @override
  String get theLanguageChangeTakesEffectImmediatelyAfterSaving =>
      '语言更改会在保存设置后立即生效。';

  @override
  String get theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull =>
      '本地分支有未推送提交，当前不需要 Pull。';

  @override
  String
  get theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone =>
      '下一步只创建克隆操作预览；取消不会创建任何文件，确认计划时才会再次检查目标目录并执行 git clone。';

  @override
  String thePlanPushesTo(String branch, String remotes) {
    return '执行计划时，当前分支 $branch 将依次推送到：\n$remotes';
  }

  @override
  String get theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated =>
      '远端当前没有分支或标签，将直接创建第一个空提交。';

  @override
  String get theRepositoryHasNoStashes => '当前仓库没有 Stash。';

  @override
  String get theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes =>
      '保存后会应用到菜单、资源面板、对话框和提交说明。';

  @override
  String get theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull =>
      '工作区或索引不干净。请先提交或 Stash 更改，再执行安全 Pull。';

  @override
  String get thereAreNoLocalBranchesToDisplay => '当前没有可显示的本地分支。';

  @override
  String get thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation =>
      '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。';

  @override
  String
  thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
    String branch,
  ) {
    return '这是不可撤销的高风险操作。软件会先备份远端引用，然后把 $branch 强制替换为一个不含文件的空根提交，删除其他分支和标签，并把本地同名分支与索引同步到该空提交。本地文件不会删除，刷新后会显示为未跟踪。';
  }

  @override
  String get thisOperationDeletesTheGitFolderInTheRepositoryRoot =>
      '此操作会删除仓库根目录中的 .git 文件夹。';

  @override
  String
  thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
    String count,
  ) {
    return '此计划包含 $count 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。';
  }

  @override
  String get thisProjectIsLicensedUnderTheMitLicense =>
      '本项目使用 MIT License 开源许可证。';

  @override
  String get threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge =>
      '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。';

  @override
  String today(String time) {
    return '今天 $time';
  }

  @override
  String get turnGitFileOperationsIntoAnIntuitiveWorkspace =>
      '把 Git 文件操作，\n变成一次直观的移动。';

  @override
  String get typeANameToFilter => '输入名称可快速筛选';

  @override
  String unableToOpenFile(String error) {
    return '无法打开文件：$error';
  }

  @override
  String unableToOpenLogsFolder(String error) {
    return '无法打开日志目录：$error';
  }

  @override
  String unableToOpenProjectFolder(String error) {
    return '无法打开项目目录：$error';
  }

  @override
  String unableToOpenTheGitDownloadPage(String error) {
    return '无法打开 Git 下载页面：$error';
  }

  @override
  String get unableToReadBranchSynchronizationStateRefreshAndTryAgain =>
      '无法读取分支同步状态。请刷新后重试。';

  @override
  String get unableToReadFolder => '无法读取目录';

  @override
  String unableToReadUserGuide(String error) {
    return '无法读取使用指南：$error';
  }

  @override
  String get unableToRetrieveTheOnlineVersion => '暂时无法获取线上版本';

  @override
  String get unitPreview => '单位预览';

  @override
  String get units => '单位设置';

  @override
  String get unstage => '取消暂存';

  @override
  String get updateAndRestartNow => '立即更新并重启';

  @override
  String get updateSource => '更新源';

  @override
  String updated(String scope) {
    return '已更新 $scope';
  }

  @override
  String get updates => '更新';

  @override
  String get updatesAndReleaseNotes => '更新与发布日志';

  @override
  String get updating => '更新中';

  @override
  String get updatingAutomatically => '正在自动更新';

  @override
  String get upstream => 'upstream';

  @override
  String
  usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
    String platform,
  ) {
    return '$platform 的默认分支通常受保护。如果服务器拒绝强制更新或删除，整个原子操作不会删除任何引用；需要先在托管平台临时解除默认分支保护。';
  }

  @override
  String get versionNotFoundOrUnreadable => '未找到或无法读取版本';

  @override
  String versionV(String version) {
    return '版本 v$version';
  }

  @override
  String versionVIsAvailable(String version) {
    return '发现新版本 v$version';
  }

  @override
  String get viewAndManageAllRemotes => '查看和管理全部远端仓库';

  @override
  String get viewBranchSynchronization => '查看分支同步状态';

  @override
  String get viewLogs => '查看日志';

  @override
  String
  get workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks =>
      '工作文件不会被删除，但以下 Git 内容会永久丢失：\n• 全部提交历史和 reflog\n• 本地分支、标签和当前分支状态\n• 暂存索引、Stash、未被工作文件保留的已提交内容\n• 引用、远端配置以及仓库级 Git 配置和 hooks';

  @override
  String get workingTreeClean => '工作区干净，没有待提交的更改';

  @override
  String get worktree => '工作区';

  @override
  String get youAreUpToDate => '已经是最新版本';

  @override
  String get followSystemLabel => '跟随系统';

  @override
  String get followSystemDescription => '使用操作系统设置的语言。';

  @override
  String get languageEnglishOptionLabel => 'English';

  @override
  String get languageEnglishDescription => '使用英文显示软件界面。';

  @override
  String get languageSimplifiedChineseOptionLabel => '简体中文';

  @override
  String get languageSimplifiedChineseDescription => '使用简体中文显示软件界面。';

  @override
  String get languageTraditionalChineseOptionLabel => '繁體中文';

  @override
  String get languageTraditionalChineseDescription => '使用繁體中文顯示軟體介面。';

  @override
  String get userPath => '用户 PATH';

  @override
  String get systemPath => '系统 PATH';

  @override
  String addPortableGitTo(String scope) {
    return '将 PortableGit 加入 $scope';
  }

  @override
  String removePortableGitFrom(String scope) {
    return '从 $scope 移除 PortableGit';
  }

  @override
  String get confirmAdd => '确认加入';

  @override
  String get confirmRemove => '确认移除';

  @override
  String get gitAvailable => 'Git 可用';

  @override
  String get gitUnavailable => 'Git 不可用';

  @override
  String get creatingShortcut => '正在创建快捷方式…';

  @override
  String get oneClickSendToDesktop => '一键发送到桌面';

  @override
  String get bundledLabel => '内置';

  @override
  String get iec1024BaseBit => 'IEC · 1024 进制 · bit';

  @override
  String get si1000BaseBit => 'SI · 1000 进制 · bit';

  @override
  String get iec1024BaseByte => 'IEC · 1024 进制 · Byte';

  @override
  String get si1000BaseByte => 'SI · 1000 进制 · Byte';

  @override
  String get classicGreen => '经典绿';

  @override
  String get oceanBlue => '海洋蓝';

  @override
  String get starryViolet => '星夜紫';

  @override
  String get amberGold => '琥珀金';

  @override
  String get roseRed => '玫瑰红';

  @override
  String get interUiDescription => '专为数字界面设计的开源无衬线字体，适合工具栏和高密度正文。';

  @override
  String get notoSansScDescription => '覆盖简体中文的现代界面字体，中英文混排清晰、字形稳定。';

  @override
  String get ibmPlexSansDescription => '为产品界面和企业信息设计，数字与英文阅读性突出。';

  @override
  String get fontDescription => '软件内置界面字体';

  @override
  String get operationCompleted => '操作已完成。';

  @override
  String operationCompletedFor(String target) {
    return '操作已完成：$target。';
  }

  @override
  String operationCompletedForItems(String count) {
    return '已完成 $count 项操作。';
  }

  @override
  String operationFailed(String error) {
    return '操作失败：$error';
  }

  @override
  String operationFailedFor(String error, String target) {
    return '$target 操作失败：$error';
  }

  @override
  String logInfo(String eventId) {
    return '信息事件：$eventId';
  }

  @override
  String logDetail(String eventId) {
    return '详细事件：$eventId';
  }

  @override
  String logWarning(String eventId) {
    return '警告事件：$eventId';
  }

  @override
  String logError(String eventId) {
    return '错误事件：$eventId';
  }

  @override
  String get logsTruncated => '… 仅显示最近日志 …';

  @override
  String logReadFailed(String error) {
    return '读取日志失败：$error';
  }

  @override
  String get noRepositoryOpen => '当前没有打开的仓库。';

  @override
  String get operationInProgress => '当前仍有操作正在执行。';

  @override
  String get emptyOperationPlan => '执行计划为空。';

  @override
  String get gitUnavailableHelp => '未检测到可用的 Git。请先安装 Git，或在设置中重新检测。';

  @override
  String get selectItemsFirst => '请先勾选文件或文件夹。';

  @override
  String get clipboardEmpty => '剪贴板为空。';

  @override
  String get clipboardCleared => '已清空剪贴板。';

  @override
  String clipboardPendingCut(String count) {
    return '待移动 $count 项';
  }

  @override
  String clipboardPendingCopy(String count) {
    return '待复制 $count 项';
  }

  @override
  String get operationPlanBusyEdit => '操作计划正在执行，暂时不能修改。';

  @override
  String get operationPlanBusyClear => '操作计划正在执行，暂时不能清空。';

  @override
  String get planOperationMissing => '待执行操作不存在。';

  @override
  String get planOperationRemoved => '已从执行计划移除该操作。';

  @override
  String planCleared(String count) {
    return '已清空 $count 步待执行操作。';
  }

  @override
  String planStrongConfirmationRequired(String confirmation) {
    return '请准确输入 $confirmation 以确认危险操作。';
  }

  @override
  String get planDangerousAcknowledgmentRequired => '请先勾选危险操作确认项。';

  @override
  String get planStateChanged => '仓库状态与确认预览不一致，已停止执行。请刷新并重新建立操作计划。';

  @override
  String planStepStateChanged(String step) {
    return '执行到第 $step 步前发现仓库状态已被修改，已停止。请刷新并重新建立操作计划。';
  }

  @override
  String planStepFailed(String error, String step) {
    return '第 $step 步失败：$error。后续步骤尚未执行，失败步骤仍保留在计划中。';
  }

  @override
  String planExecutionComplete(String count) {
    return '已按顺序执行全部 $count 步操作。';
  }

  @override
  String get planOperationAdded => '已加入待执行操作计划；尚未执行任何 Git 变更。';

  @override
  String planSnapshotFailed(String error) {
    return '无法建立操作预览的安全状态快照：$error';
  }

  @override
  String get clearRemoteMustRunAlone => '清空远端必须单独执行。请先移除或执行计划中的其他步骤。';

  @override
  String get commitMustRemainLast => '提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。';

  @override
  String get exclusiveOperationMustRunAlone => '此生命周期操作必须单独执行。';

  @override
  String get exclusiveOperationAlreadyQueued => '当前计划已包含必须单独执行的操作。';

  @override
  String get renameSelectOne => '重命名时请只勾选一个文件或文件夹。';

  @override
  String get nameCannotBeEmpty => '名称不能为空。';

  @override
  String get historyEntryRemoved => '已从最近仓库历史中移除。';

  @override
  String get gitMetadataClearAvailable => '当前仓库没有配置远端，可以清除 Git 元数据。';

  @override
  String get gitMetadataCleared => 'Git 元数据已清除，工作文件仍然保留。';

  @override
  String get gitMetadataRemoteForbidden => '当前仓库已连接远端，禁止清除 Git 元数据。';

  @override
  String fileRenamed(String name) {
    return '已重命名为 $name。';
  }

  @override
  String get bootstrapPlanAlreadyUsed => '此操作已经执行或正在执行，请重新打开预览。';

  @override
  String get bootstrapStateChanged => '目标状态与确认预览不一致，已停止执行。请刷新预览后重新确认。';

  @override
  String get unableToInspectRepository => '无法检查仓库。';

  @override
  String stepsCount(String count) {
    return '$count 步';
  }

  @override
  String get planKindInitialize => '初始化';

  @override
  String get planKindClone => '克隆';

  @override
  String get planKindMove => '移动';

  @override
  String get planKindCopy => '复制';

  @override
  String get planKindRename => '重命名';

  @override
  String get planKindDelete => '删除';

  @override
  String get planKindClearGitMetadata => '清除 Git 元数据';

  @override
  String get planKindStageAll => '暂存';

  @override
  String get planKindUnstageAll => '取消暂存';

  @override
  String get planKindCommit => '提交';

  @override
  String get planKindFetchCurrent => '获取 upstream';

  @override
  String get planKindFetchAll => '获取全部远端';

  @override
  String get planKindPull => '快进 Pull';

  @override
  String get planKindPush => '推送';

  @override
  String get planKindPushAll => '全部推送';

  @override
  String get planKindAddRemote => '添加远端';

  @override
  String get planKindUpdateRemote => '修改远端';

  @override
  String get planKindRemoveRemote => '移除远端';

  @override
  String get planKindClearRemote => '清空远端';

  @override
  String get planKindCreateBranch => '创建分支';

  @override
  String get planKindSwitchBranch => '切换分支';

  @override
  String get planKindRenameBranch => '重命名分支';

  @override
  String get planKindDeleteBranch => '删除分支';

  @override
  String get planKindCreateStash => '创建 Stash';

  @override
  String get planKindApplyStash => '应用 Stash';

  @override
  String get planKindPopStash => '弹出 Stash';

  @override
  String get planKindDropStash => '删除 Stash';

  @override
  String get planTitleInitializeRepository => '初始化 Git 仓库';

  @override
  String planDescriptionInitializeRepository(String path) {
    return '确认后在 $path 执行 git init，然后打开该仓库。';
  }

  @override
  String get planTitleCloneRepository => '克隆 Git 仓库';

  @override
  String planDescriptionCloneRepository(String path, String url) {
    return '把 $url 克隆到 $path。取消不会创建内容；确认后会重新检查目标并执行 git clone。';
  }

  @override
  String planTitleMove(String count, String destination) {
    return '移动 $count 项到 $destination';
  }

  @override
  String planDescriptionMove(String count, String destination) {
    return '使用 Git 将 $count 个项目移动到 $destination。';
  }

  @override
  String planTitleCopy(String count, String destination) {
    return '复制 $count 项到 $destination';
  }

  @override
  String planDescriptionCopy(String count, String destination) {
    return '使用 Git 将 $count 个项目复制到 $destination。';
  }

  @override
  String planTitleRename(String source) {
    return '重命名 $source';
  }

  @override
  String planDescriptionRename(String newName, String source) {
    return '把 $source 的名称改为 $newName。';
  }

  @override
  String planTitleDelete(String count) {
    return '删除 $count 个项目';
  }

  @override
  String planDescriptionDelete(String count, String paths) {
    return '将永久删除 $count 个项目：$paths。已跟踪内容使用 git rm，未跟踪或忽略内容使用 git clean。';
  }

  @override
  String get planTitleClearGitMetadata => '清除 Git 元数据';

  @override
  String planDescriptionClearGitMetadata(String path) {
    return '仓库：$path。将永久删除 .git 并保留工作文件。提交历史、分支、标签、索引、Stash、远端配置和仓库级设置都会丢失。此操作必须单独执行。';
  }

  @override
  String planTitleCreateBranch(String branch) {
    return '创建分支 $branch';
  }

  @override
  String planDescriptionCreateBranch(String branch) {
    return '执行 git branch -- $branch，从当前 HEAD 创建本地分支。';
  }

  @override
  String branchCreated(String branch) {
    return '已创建分支 $branch。';
  }

  @override
  String planTitleSwitchBranch(String branch) {
    return '切换到分支 $branch';
  }

  @override
  String planDescriptionSwitchBranch(String branch) {
    return '执行 git switch $branch。未提交修改发生冲突时 Git 会拒绝切换。';
  }

  @override
  String branchSwitched(String branch) {
    return '已切换到分支 $branch。';
  }

  @override
  String alreadyOnBranch(String branch) {
    return '已经位于分支 $branch。';
  }

  @override
  String planTitleRenameBranch(String from, String to) {
    return '重命名分支 $from 为 $to';
  }

  @override
  String planDescriptionRenameBranch(String from, String to) {
    return '执行 git branch -m $from $to。';
  }

  @override
  String branchRenamed(String from, String to) {
    return '已把分支 $from 重命名为 $to。';
  }

  @override
  String planTitleDeleteBranch(String branch) {
    return '删除分支 $branch';
  }

  @override
  String planDescriptionDeleteBranchForce(String branch) {
    return '执行 git branch -D $branch，强制删除未合并分支。';
  }

  @override
  String planDescriptionDeleteBranchSafe(String branch) {
    return '执行 git branch -d $branch，仅允许删除已合并分支。';
  }

  @override
  String branchDeleted(String branch) {
    return '已删除分支 $branch。';
  }

  @override
  String get cannotDeleteCurrentBranch => '不能删除当前分支，请先切换到其他分支。';

  @override
  String get planTitleCreateStash => '创建 Stash';

  @override
  String planTitleCreateStashNamed(String message) {
    return '创建 Stash：$message';
  }

  @override
  String planDescriptionCreateStash(String message) {
    return '执行 git stash push，提交说明为：$message';
  }

  @override
  String planDescriptionCreateStashIncludeUntracked(String message) {
    return '执行 git stash push --include-untracked，提交说明为：$message';
  }

  @override
  String get stashCreated => 'Stash 已创建。';

  @override
  String planTitleApplyStash(String selector) {
    return '应用 $selector';
  }

  @override
  String planDescriptionApplyStash(String selector) {
    return '执行 git stash apply $selector，并保留 Stash 记录。';
  }

  @override
  String stashApplied(String selector) {
    return '已应用 $selector。';
  }

  @override
  String planTitlePopStash(String selector) {
    return '弹出 $selector';
  }

  @override
  String planDescriptionPopStash(String selector) {
    return '执行 git stash pop $selector，应用后删除该 Stash。';
  }

  @override
  String stashPopped(String selector) {
    return '已弹出 $selector。';
  }

  @override
  String planTitleDropStash(String selector) {
    return '删除 $selector';
  }

  @override
  String planDescriptionDropStash(String selector) {
    return '执行 git stash drop $selector，此操作无法通过本软件撤销。';
  }

  @override
  String stashDropped(String selector) {
    return '已删除 $selector。';
  }

  @override
  String get invalidStashSelector => 'Stash 选择器无效。';

  @override
  String get planTitlePushCurrent => '推送当前分支';

  @override
  String planTitlePushBranch(String branch) {
    return '推送 $branch';
  }

  @override
  String get planDescriptionPushCurrent =>
      '把当前分支推送到 upstream；没有 upstream 时使用 origin 或首个远端并设置跟踪关系。';

  @override
  String planTitleFetchRemote(String remote) {
    return '获取远端 $remote';
  }

  @override
  String planDescriptionFetchRemote(String remote) {
    return '执行 git fetch --prune $remote；更新远端跟踪引用，不修改工作区文件。';
  }

  @override
  String planTitleFetchAllRemotes(String count) {
    return '获取全部 $count 个远端';
  }

  @override
  String planDescriptionFetchAllRemotes(String remotes) {
    return '依次为以下远端执行 git fetch --prune：$remotes。失败项会逐个报告。';
  }

  @override
  String remoteFetched(String remote) {
    return '已获取远端 $remote 的更新。';
  }

  @override
  String allRemotesFetched(String count) {
    return '已获取全部 $count 个远端。';
  }

  @override
  String remoteBatchPartialFailure(
    String details,
    String failed,
    String succeeded,
  ) {
    return '成功 $succeeded 个，失败 $failed 个。详情：$details';
  }

  @override
  String get syncStateUnavailable => '无法读取当前分支同步状态。';

  @override
  String get detachedCannotPull => '当前处于 detached HEAD，不能 Pull 分支。';

  @override
  String get unbornCannotPull => '当前分支尚无提交，不能 Pull。';

  @override
  String get upstreamMissing => '当前分支没有可用的 upstream，请先配置远端跟踪分支。';

  @override
  String get dirtyWorktreeCannotPull => '工作区或索引不干净，请先提交或 Stash 更改再 Pull。';

  @override
  String get pullUpToDate => '当前分支已经与 upstream 同步。';

  @override
  String get pullAhead => '当前分支包含 upstream 的全部提交，但有本地提交未推送。';

  @override
  String get pullDiverged => '本地分支与 upstream 已分叉，请先使用外部 Git 执行 Merge 或 Rebase。';

  @override
  String get pullRelationUnknown => '当前分支同步关系未知。';

  @override
  String get pullNoUpdate => '当前无需快进更新。';

  @override
  String planTitlePull(String branch) {
    return '安全快进 Pull $branch';
  }

  @override
  String planDescriptionPull(String branch, String remote, String upstream) {
    return '先从 $remote 获取更新并重新检查 ahead/behind；仅在 $branch 落后且未分叉时执行 git merge --ff-only $upstream，不会自动创建 Merge 提交。';
  }

  @override
  String pullCompleted(String branch, String upstream) {
    return '已快进更新 $branch 到 $upstream。';
  }

  @override
  String syncAuthenticationFailed(String error) {
    return 'Git 认证失败：$error';
  }

  @override
  String syncNetworkFailed(String error) {
    return 'Git 网络访问失败：$error';
  }

  @override
  String get pushedCurrentBranch => '已推送当前分支。';

  @override
  String pushedBranch(String branch) {
    return '已推送 $branch。';
  }

  @override
  String get noRemotesConfigured => '项目没有配置远端仓库。';

  @override
  String get remoteListRefreshed => '远端列表已刷新。';

  @override
  String planTitleAddRemote(String remote) {
    return '添加远端 $remote';
  }

  @override
  String planDescriptionAddRemote(String remote, String url) {
    return '添加远端 $remote，地址为 $url。';
  }

  @override
  String planTitleUpdateRemote(String remote) {
    return '修改远端 $remote';
  }

  @override
  String planDescriptionUpdateRemote(String remote, String url) {
    return '把远端 $remote 的地址改为 $url。';
  }

  @override
  String remoteAdded(String remote) {
    return '已添加远端 $remote。';
  }

  @override
  String remoteUpdated(String remote) {
    return '已更新远端 $remote。';
  }

  @override
  String remoteRemoved(String remote) {
    return '已删除远端 $remote。';
  }

  @override
  String planTitleRemoveRemote(String remote) {
    return '删除远端配置 $remote';
  }

  @override
  String get planDescriptionRemoveRemote =>
      '仅删除本仓库中的 Git remote 配置，不会删除远端平台上的仓库。';

  @override
  String planTitlePushRemote(String remote) {
    return '推送到远端 $remote';
  }

  @override
  String planDescriptionPushRemote(String branch, String remote) {
    return '把分支 $branch 推送到远端 $remote。';
  }

  @override
  String pushedToRemote(String remote) {
    return '已推送到 $remote。';
  }

  @override
  String planTitlePushAllRemotes(String count) {
    return '推送到全部 $count 个远端';
  }

  @override
  String planDescriptionPushAllRemotes(String remotes) {
    return '依次把当前分支推送到：$remotes。';
  }

  @override
  String pushedToAllRemotes(String count) {
    return '已推送到全部 $count 个远端。';
  }

  @override
  String remoteInspectionEmpty(String remote) {
    return '远端 $remote 当前没有分支或标签。';
  }

  @override
  String remoteInspectionCounts(String branches, String remote, String tags) {
    return '远端 $remote 有 $branches 个分支、$tags 个标签。';
  }

  @override
  String planTitleClearRemote(String remote) {
    return '清空远端历史 $remote';
  }

  @override
  String planDescriptionClearRemote(
    String branch,
    String branches,
    String message,
    String project,
    String tags,
  ) {
    return '项目 $project，目标分支 $branch。将备份并删除 $branches 个分支和 $tags 个标签，然后只保留一个空提交：“$message”。本地文件保留，但本地索引会重置为空，刷新后文件显示为未跟踪。';
  }

  @override
  String clearRemoteCompleted(String branch, String commit, String remote) {
    return '已清空远端 $remote。$branch 现指向空提交 $commit；本地文件保留并显示为未跟踪。';
  }

  @override
  String clearRemoteDrift(
    String branches,
    String error,
    String remote,
    String tags,
  ) {
    return '远端 $remote 的引用在确认后发生变化，已停止清空。当前有 $branches 个分支和 $tags 个标签。$error';
  }

  @override
  String get planTitleStageAll => '暂存全部更改';

  @override
  String get planDescriptionStageAll => '执行 git add -A，将当前全部更改加入 Git 索引。';

  @override
  String get stageAllCompleted => '已暂存全部更改。';

  @override
  String get planTitleUnstageAll => '取消暂存全部更改';

  @override
  String get planDescriptionUnstageAll => '把 Git 索引恢复到 HEAD，同时保留工作区文件。';

  @override
  String get unstageAllCompleted => '已取消暂存全部更改。';

  @override
  String get planTitleCommitAll => '提交全部更改';

  @override
  String planDescriptionCommitAll(String message) {
    return '提交说明：$message。执行时先运行 git add -A，再运行 git commit。';
  }

  @override
  String get commitMessageRequired => '请填写提交说明。';

  @override
  String get noChangesToCommit => '没有可提交的更改。';

  @override
  String get commitAlreadyQueued => '执行计划中已经有提交步骤。';

  @override
  String get commitIdentityUnavailable =>
      'Git 作者和提交者身份不可用。请配置 user.name 和 user.email 后重试。';

  @override
  String get commitSucceeded => '提交已创建。';

  @override
  String get settingsSaved => '设置已保存。';

  @override
  String get desktopShortcutWindowsOnly => '桌面快捷方式目前仅支持 Windows。';

  @override
  String desktopShortcutCreated(String path) {
    return '已创建桌面快捷方式：$path';
  }

  @override
  String get maintenanceKindOldVersion => '旧版本目录';

  @override
  String get maintenanceKindUpdateArchive => '更新安装包';

  @override
  String get maintenanceKindPartialDownload => '未完成下载';

  @override
  String get maintenanceKindStagingDirectory => '临时解压目录';

  @override
  String get maintenanceKindLegacyUpdater => '旧更新脚本';

  @override
  String get maintenanceKindLegacyFlatFile => '旧平铺程序文件';

  @override
  String get maintenanceKindLegacyFlatDirectory => '旧平铺程序目录';

  @override
  String get maintenanceKindObsoleteGitRuntime => '旧 PortableGit 运行时';

  @override
  String get maintenanceKindGitRuntimeArchive => 'PortableGit 更新包';

  @override
  String get maintenanceKindGitRuntimeStaging => 'PortableGit 暂存目录';

  @override
  String get driftRepositoryRoot => '仓库根目录';

  @override
  String get driftBranch => '分支';

  @override
  String get driftHead => 'HEAD';

  @override
  String get driftStatus => '工作区状态';

  @override
  String get driftRemotes => '远端配置';

  @override
  String get driftPathType => '路径类型';

  @override
  String get driftDestinationParent => '父目录';

  @override
  String get driftDestinationExists => '目标是否存在';

  @override
  String get driftDestinationEmpty => '目标是否为空';

  @override
  String get driftGitMetadata => 'Git 元数据';

  @override
  String get driftSource => '来源';

  @override
  String get driftRemoteName => '远端名称';

  @override
  String get driftRemoteTargetBranch => '目标分支';

  @override
  String get driftRemoteRefs => '远端引用';

  @override
  String get updateGithubNoRelease => '仓库暂未发布公开的 GitHub Release，可打开发布页查看。';

  @override
  String get updateGiteeNoRelease => '仓库暂未发布公开的 Gitee Release，可打开发布页查看。';

  @override
  String updateHttpError(String platform, String status) {
    return '$platform 返回 HTTP $status，请稍后重试。';
  }

  @override
  String get updateInvalidResponseGithub => 'GitHub 更新描述格式无法识别。';

  @override
  String get updateInvalidResponseGitee => 'Gitee 更新描述格式无法识别。';

  @override
  String get updateVersionMissingGithub => 'GitHub 公开 Release 没有可识别的版本号。';

  @override
  String get updateVersionMissingGitee => 'Gitee 公开 Release 没有可识别的版本号。';

  @override
  String get updateAssetMissingGithub =>
      '发现新版本，但 Release 缺少带 SHA-256 的 Windows x64 ZIP。';

  @override
  String get updateAvailableGithub => '发现可用的新版本，可直接下载、校验并自动重启更新。';

  @override
  String get updateAvailableGitee => '发现可用的 Gitee 新版本，可直接下载、校验并自动重启更新。';

  @override
  String updateUpToDate(String version) {
    return '当前版本 v$version 已是 GitHub 最新版本。';
  }

  @override
  String updateGiteeUpToDate(String version) {
    return '当前版本 v$version 已是 Gitee 最新版本。';
  }

  @override
  String get updateNetworkUnavailableGithub => '无法连接 GitHub，请检查网络后重试。';

  @override
  String get updateNetworkUnavailableGitee => '无法连接 Gitee，请检查网络后重试。';

  @override
  String get updateRequestFailed => '网络请求失败，请稍后重试。';

  @override
  String get updateGiteeRequestFailed => 'Gitee 网络请求失败，请稍后重试。';

  @override
  String get updateGiteeDigestMissing =>
      '发现 Gitee 新版本，但无法从 GitHub 资产元数据取得可信 SHA-256，已禁用自动安装。可打开发布页手动下载。';

  @override
  String get updateProgressPreparing => '正在准备自动更新…';

  @override
  String get updateProgressConnecting => '正在连接 Release 下载更新…';

  @override
  String updateProgressDownloading(String asset) {
    return '正在下载 $asset…';
  }

  @override
  String get updateProgressVerifying => '正在校验更新包 SHA-256…';

  @override
  String get updateProgressExtracting => '正在解压到独立版本目录…';

  @override
  String get updateProgressVerifyingRuntime => '正在验证安装包中的 PortableGit 运行时…';

  @override
  String get updateProgressNotifyingLauncher => '正在通知 Launcher 切换版本…';

  @override
  String get updatePackageMissing => '更新包不存在。';

  @override
  String get updateWindowsOnly => '当前自动更新仅支持 Windows。';

  @override
  String get updateNoNewVersion => '当前没有可安装的新版本。';

  @override
  String get updateAssetInvalid => '更新资产缺少下载地址或有效 SHA-256，已取消自动更新。';

  @override
  String get updateVersionInvalid => '更新版本号包含非法字符。';

  @override
  String updateInstallSuccess(String version) {
    return '新版本 v$version 已准备完成；应用退出后 Launcher 会切换并重启。';
  }

  @override
  String get changelog0100Title => '结构化运行消息、Markdown 指南与安全链接';

  @override
  String get changelog0100ItemMessages =>
      '操作结果、待执行计划和日志改用语义模板，并增加稳定事件 ID、写入时语言和凭据遮蔽。';

  @override
  String get changelog0100ItemMarkdown =>
      '内置指南改为真正的 Markdown 渲染，支持标题、列表、表格、引用、代码块、图片和行内格式。';

  @override
  String get changelog0100ItemLinks =>
      '指南链接仅允许 HTTPS、内置指南和标题锚点，并提供键盘焦点、选择复制和响应式布局。';

  @override
  String get changelog0100ItemTests => '新增三语指南资源、源码防回归检查和完整的结构化消息测试覆盖。';

  @override
  String get changelog099Title => '分支同步、安全快进 Pull 与提交身份预检';

  @override
  String get changelog099ItemSyncStatus => '显示 upstream、ahead、behind 和工作区同步状态。';

  @override
  String get changelog099ItemFetchPlan =>
      '新增当前 upstream 或全部远端 Fetch 计划，并逐项报告结果。';

  @override
  String get changelog099ItemFastForwardPull =>
      '新增仅快进 Pull，拒绝脏工作区、无 upstream 和分叉历史。';

  @override
  String get changelog099ItemGitIdentity => '提交前及执行前检查有效的 Git 作者和提交者身份。';

  @override
  String get guideLanguageEnglish => 'English';

  @override
  String get guideLanguageSimplifiedChinese => '简体中文';

  @override
  String get guideLanguageTraditionalChinese => '繁體中文';

  @override
  String unableToOpenGuideLink(String error) {
    return '无法打开指南链接：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppL10nZhHans extends AppL10nZh {
  AppL10nZhHans() : super('zh_Hans');

  @override
  String get appName => 'Git GUI Expand';

  @override
  String get openRepository => '打开 Git 仓库';

  @override
  String get settings => '设置';

  @override
  String get cancel => '取消';

  @override
  String get saveSettings => '保存设置';

  @override
  String get aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata =>
      '当前有待执行操作计划，请先清空或执行后再清除 Git。';

  @override
  String get aWindowsFirstFlutterGraphicalFileWorkspaceForGit =>
      'Windows 优先的 Flutter Git 图形化文件工作区。';

  @override
  String get about => '关于';

  @override
  String get aboutInformationDoesNotChangeSettings => '关于信息不会修改设置';

  @override
  String get acknowledgements => '致谢';

  @override
  String get addClearOperationToPlan => '加入清除计划';

  @override
  String get addClearToPlan => '加入清空计划';

  @override
  String get addCloneToPlan => '加入克隆计划';

  @override
  String get addCommitToPlan => '加入提交计划';

  @override
  String addDeletionOfItemsToThePlan(String count) {
    return '将删除 $count 个项目加入计划';
  }

  @override
  String get addDeletionToPlan => '加入删除计划';

  @override
  String get addGitToPath => '将 Git 加入 PATH';

  @override
  String get addPushAllPlan => '加入全部推送计划';

  @override
  String get addPushAllToThePlan => '将全部推送加入计划';

  @override
  String addPushOfToThePlan(String branch) {
    return '将推送 $branch 加入计划';
  }

  @override
  String get addPushToPlan => '加入推送计划';

  @override
  String addPushToToThePlan(String remote) {
    return '将推送到 $remote 加入计划';
  }

  @override
  String get addRemote => '添加远端';

  @override
  String addRemovalOfRemoteToThePlan(String remote) {
    return '将移除远端配置 $remote 加入计划';
  }

  @override
  String get addRemovalToPlan => '加入移除计划';

  @override
  String get addToAddPlan => '加入添加计划';

  @override
  String get addToPlan => '加入执行计划';

  @override
  String get addToSystemPath => '加入系统 PATH';

  @override
  String get addToUpdatePlan => '加入修改计划';

  @override
  String get addToUserPath => '加入用户 PATH';

  @override
  String
  addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
    String path,
    String url,
  ) {
    return '地址：$url\n目标目录：$path\n取消不会创建任何文件，确认计划后才会再次检查目标并执行 git clone。';
  }

  @override
  String
  get afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution =>
      '清理后该文件夹会变成普通目录，仍可用“打开空白文件夹”重新执行 git init。现在只加入清除计划；还需要在操作计划中输入 CLEAR GIT 并确认执行。';

  @override
  String get ahead => '待推送';

  @override
  String allowedRange(String max, String min) {
    return '允许范围：$min%–$max%';
  }

  @override
  String alreadyContainsPortablegit(String scope) {
    return '$scope 已包含 PortableGit';
  }

  @override
  String get alsoSaveUntrackedFilesGitStashIncludeUntracked =>
      '同时保存未跟踪文件（git stash --include-untracked）';

  @override
  String andMore(String count) {
    return '以及其他 $count 项';
  }

  @override
  String get appearanceSettings => '外观设置';

  @override
  String get applicationLogs => '软件操作日志';

  @override
  String get applyStash => '应用 Stash';

  @override
  String
  get automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved =>
      '自动更新会从 GitHub 下载 Windows x64 ZIP 并校验 SHA-256，解压到 versions/<版本>。应用退出后由 GitGuiExpandLauncher 切换版本并自动重启；新版本启动失败时会回滚。根目录 userdata 和正在运行的版本不会被覆盖。';

  @override
  String get back => '返回';

  @override
  String get baseUnit => '基础单位';

  @override
  String get behind => '待拉取';

  @override
  String get binaryUses1024StepsDecimalUses1000 =>
      '二进制使用 1024 进位，十进制使用 1000 进位。';

  @override
  String get bitB => 'bit（b）';

  @override
  String get branchManagement => '分支管理';

  @override
  String get branchSynchronization => '分支同步';

  @override
  String get browseIndependentlyAndMoveAcrossPanes => '独立浏览，跨栏移动';

  @override
  String get browseMoveCopyDeleteCommitAndPushThroughTheGitCli =>
      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。';

  @override
  String
  get browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit =>
      '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。';

  @override
  String get bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense =>
      '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。';

  @override
  String get bundledPortablegit => '内置 PortableGit';

  @override
  String get bundledUiFonts => '软件内置 UI 字体';

  @override
  String
  get byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts =>
      '默认使用内置的 Noto Sans SC / 思源黑体，也可搜索系统字体或其他内置字体。';

  @override
  String get byteB => 'Byte（B）';

  @override
  String get byteDisplaysBKibOrKbBitIsMultipliedBy8First =>
      'Byte 显示 B、KiB 或 KB；bit 会先乘以 8。';

  @override
  String get cancel2 => '取消';

  @override
  String get cancelEditing => '取消编辑';

  @override
  String get changed => '有更改';

  @override
  String changes(String count) {
    return '$count 项变更';
  }

  @override
  String get changesApplyAfterSaving => '设置将在点击保存后应用到整个软件';

  @override
  String
  get changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing =>
      '修改系统 PATH 会影响整台电脑，并请求管理员权限。取消提权不会修改任何内容。';

  @override
  String get checkAgain => '重新检测';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get checking => '检查中';

  @override
  String get checking2 => '正在检查…';

  @override
  String get checkingForGit => '正在检测 Git…';

  @override
  String get checkingForUpdates => '正在检查更新';

  @override
  String
  get chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst =>
      '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。';

  @override
  String get chooseCloneParentFolder => '选择克隆父目录';

  @override
  String
  get chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors =>
      '选择显示模式和配色方案；界面图标会跟随当前配色方案变化。';

  @override
  String get chooseFolder => '选择文件夹';

  @override
  String
  get chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup =>
      '可选择当前用户或系统环境变量。只添加软件管理的 runtime/git/current/cmd，并在修改前自动备份。';

  @override
  String get chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem =>
      '选择软件显示语言。默认跟随操作系统语言。';

  @override
  String get clean => '干净';

  @override
  String get cleanAll => '一键清除';

  @override
  String get clearAllRemoteBranchesAndTagsDangerous => '清空远端全部分支和标签（危险）';

  @override
  String get clearGitMetadata => '清除 Git 元数据';

  @override
  String get clearPlan => '清空计划';

  @override
  String clearRemoteHistoryFor(String remote) {
    return '清空远端历史 $remote？';
  }

  @override
  String get clearSearch => '清除搜索';

  @override
  String get clearSelection => '清除选择';

  @override
  String get cloneGitRepository => '克隆 Git 仓库';

  @override
  String get cloneIntoParentFolder => '克隆到父目录';

  @override
  String get close => '关闭';

  @override
  String get closeUserGuide => '关闭使用指南';

  @override
  String get closingTheRepository => '关闭仓库';

  @override
  String get colorScheme => '配色方案';

  @override
  String get commitMessage => '提交说明';

  @override
  String get commitWorkspace => '提交工作区';

  @override
  String get commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun =>
      '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。';

  @override
  String get confirmAndExecute => '确认并逐步执行';

  @override
  String get confirmDangerousOperations => '危险操作确认';

  @override
  String get controlHowProjectAndIndividualFileSizesAreDisplayed =>
      '控制项目大小和每个文件大小的显示方式。';

  @override
  String get copy => '复制';

  @override
  String
  get createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher =>
      '在当前用户桌面创建 Git GUI Expand 快捷方式，并通过稳定 Launcher 启动。';

  @override
  String get createBranch => '创建分支';

  @override
  String get createStash => '创建 Stash';

  @override
  String get current => '当前';

  @override
  String get currentBranch => '当前分支';

  @override
  String currentBranch2(String branch) {
    return '当前分支：$branch';
  }

  @override
  String get currentReleaseHighlights => '当前版本亮点';

  @override
  String currentSelection(String theme) {
    return '当前选择：$theme';
  }

  @override
  String currentV(String version) {
    return '当前 v$version';
  }

  @override
  String
  currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
    String version,
  ) {
    return '当前版本：$version。只清理旧版本、旧安装包和旧平铺程序文件，不删除 userdata 数据。';
  }

  @override
  String get cut => '剪切';

  @override
  String get cutCopyRenamePushAndCommit0123456789 =>
      '剪切、复制、重命名、推送与提交   0123456789';

  @override
  String get dark => '深色';

  @override
  String get delete => '删除';

  @override
  String get deleteBranch => '删除分支';

  @override
  String get deleteStash => '删除 Stash';

  @override
  String get desktopShortcut => '桌面快捷方式';

  @override
  String destinationFolder(String path) {
    return '目标目录：$path';
  }

  @override
  String
  destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
    String path,
  ) {
    return '目标目录：$path\n确认后在目标目录执行 git init，然后打开该仓库。';
  }

  @override
  String get detached => 'detached';

  @override
  String get detachedHead => 'detached HEAD';

  @override
  String get detachedHeadCannotFetchCurrentUpstreamOrPullABranch =>
      '当前处于 detached HEAD，不能 Fetch 当前 upstream 或 Pull。';

  @override
  String get detailedLog => '详细日志';

  @override
  String get detectTheGitRuntimeVersionSourceAndExecutableLocation =>
      '检测 Git 运行时、版本、来源和安装位置。';

  @override
  String detectionDetails(String error) {
    return '检测详情：$error';
  }

  @override
  String get discardPlanAndContinue => '放弃计划并继续';

  @override
  String get discardThePendingOperationPlan => '放弃待执行操作计划？';

  @override
  String get displayMode => '显示模式';

  @override
  String doesNotContainTheManagedPortablegitPath(String scope) {
    return '$scope 不包含软件管理的 PortableGit 路径';
  }

  @override
  String get doesNotExist => '不存在';

  @override
  String get done => '完成';

  @override
  String get doubleClickAFolderClickAPaneToChooseThePasteTarget =>
      '双击文件夹进入 · 点击面板切换粘贴目标';

  @override
  String get doubleClickAFolderToOpen => '双击文件夹进入';

  @override
  String get downloadGit => '下载 Git';

  @override
  String get dualPaneOperations => '双栏批量操作';

  @override
  String get editRemote => '编辑远端';

  @override
  String get editUrl => '编辑 URL';

  @override
  String get enterACloneUrlParentFolderAndProjectName => '请填写克隆地址、父目录和项目名称。';

  @override
  String get enterACommitMessage => '填写本次提交说明…';

  @override
  String enterProjectBranchToConfirm(String confirmation) {
    return '输入项目全称/分支“$confirmation”以确认';
  }

  @override
  String enterProjectBranchToConfirmAgain(String confirmation) {
    return '请输入远端项目全称/分支“$confirmation”进行二次确认。';
  }

  @override
  String get executing => '正在执行…';

  @override
  String get executingStepByStep => '正在逐步执行';

  @override
  String get executionComplete => '执行完成';

  @override
  String get executionIncomplete => '执行未全部完成';

  @override
  String get fetchAllRemotes => '获取全部远端';

  @override
  String get fetchCurrentUpstream => '获取当前 upstream';

  @override
  String get fileChangesArePendingInTheOperationPlan => '文件变更尚未执行，请在待执行操作计划中确认';

  @override
  String get files => '文件';

  @override
  String
  get filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns =>
      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。';

  @override
  String get folder => '文件夹';

  @override
  String get followSystem => '跟随系统';

  @override
  String get followSystemSwitchesWithTheDeviceLightOrDarkAppearance =>
      '跟随系统会根据设备当前的深色或浅色外观自动切换。';

  @override
  String get followTheOperatingSystemWithoutAFixedFamily => '跟随当前操作系统，不固定字体族';

  @override
  String get font => '字体';

  @override
  String get fontPreview => '字体预览';

  @override
  String get fontSize => '字体大小';

  @override
  String get forExampleFeatureLogin => '例如 feature/login';

  @override
  String get forExampleOriginGiteeOrGitlab => '例如 origin、gitee、gitlab';

  @override
  String get forExampleTemporarilySaveUnfinishedChanges => '例如 临时保存未完成修改';

  @override
  String get forceGitBranchDWhenDeletingAnUnmergedBranch =>
      '删除未合并分支时强制使用 git branch -D';

  @override
  String foundItemsAndCanBeFreed(String count, String size) {
    return '扫描到 $count 项，可释放 $size。';
  }

  @override
  String get git => 'Git';

  @override
  String get gitExecutableLocation => 'Git 安装位置';

  @override
  String get gitGuiExpandFileCommit => 'Git GUI Expand · 文件提交';

  @override
  String get gitGuiExpandUserGuide => 'Git GUI Expand 使用指南';

  @override
  String
  get gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain =>
      '需要 Git 才能打开或修改仓库。请安装 Git for Windows，然后点击“重新检测”。';

  @override
  String get gitIsUnavailableRepositoryActionsAreDisabled => 'Git 不可用，仓库操作已停用。';

  @override
  String get gitMetadata => 'Git 元数据';

  @override
  String get gitMvIndexCommit => 'git mv · index · commit';

  @override
  String get gitNotDetected => '未检测到 Git';

  @override
  String gitRepositories(String count) {
    return '$count 个 Git 仓库';
  }

  @override
  String get gitRepository => 'Git 仓库';

  @override
  String get gitRepositoryCloned => 'Git 仓库已克隆';

  @override
  String get gitRepositoryInitialized => 'Git 仓库已初始化';

  @override
  String get gitSettings => 'Git 设置';

  @override
  String get gitSource => 'Git 来源';

  @override
  String get gitVersion => 'Git 版本';

  @override
  String get gitee => 'Gitee';

  @override
  String get github => 'GitHub';

  @override
  String get githubUsuallyProvidesTheInternationalReleaseBuild =>
      'GitHub 更新源通常获取国际发布版本。';

  @override
  String get gotIt => '我知道了';

  @override
  String get guide => '指南';

  @override
  String get httpsOrGitHostOwnerRepoGit =>
      'https://... 或 git@host:owner/repo.git';

  @override
  String get iReviewedTheseOperationsAndWantToExecuteThemInOrder =>
      '我已检查上述操作，确认后立即按顺序执行';

  @override
  String get iecBinary => 'IEC 二进制';

  @override
  String get iecSiOptionalBits => 'IEC / SI，可切换 bit';

  @override
  String get importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation =>
      '重点：所有 Git 修改先进入执行计划，确认后才运行';

  @override
  String get initializeGitRepository => '初始化 Git 仓库';

  @override
  String get installedSystemFont => '系统已安装字体';

  @override
  String get installing => '正在安装…';

  @override
  String get interfaceLanguage => '界面语言';

  @override
  String items(String count) {
    return '$count 项';
  }

  @override
  String get language => '语言';

  @override
  String get language2 => '语言设置';

  @override
  String get largeFile => '大文件';

  @override
  String get lastChecked => '最近检测';

  @override
  String get leftExplorer => '左侧资源';

  @override
  String get light => '浅色';

  @override
  String
  get localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst =>
      '本地分支与 upstream 已分叉。软件不会自动 Merge 或 Rebase，请先使用外部 Git 处理分叉。';

  @override
  String get logs => '操作日志';

  @override
  String get mediumFile => '中文件';

  @override
  String get moreContentBelow => '此页还有下方内容';

  @override
  String get name => '名称';

  @override
  String get nativeGitChanges => 'Git 原生变更';

  @override
  String get newBranchNameOrRenamedBranchName => '新分支名称或重命名后的名称';

  @override
  String get newName => '新名称';

  @override
  String get noBranch => '无分支';

  @override
  String get noBundledFontMatches => '没有匹配的内置字体';

  @override
  String get noCommittedBranchYet => '尚无可提交分支';

  @override
  String
  get noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere =>
      '还没有详细日志。详细日志会记录选择、导航和每一条 Git 命令。';

  @override
  String get noFilesHere => '这里没有文件';

  @override
  String get noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents =>
      '还没有普通日志。执行打开仓库、文件操作或提交后会记录关键事件。';

  @override
  String get noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean =>
      '未发现旧版本或旧安装包，当前目录已经是干净状态。';

  @override
  String get noPendingOperations => '没有待执行操作';

  @override
  String get noPendingSteps => '当前没有待执行步骤';

  @override
  String get noProjectIsOpen => '当前没有打开的项目。';

  @override
  String get noRemoteRepositoryWasDetected => '未检测到任何远端仓库。';

  @override
  String get noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote =>
      '尚未配置远端仓库。请在右侧添加 GitHub、Gitee、GitLab 或其他 Git 远端。';

  @override
  String get noSystemFontMatches => '没有匹配的系统字体';

  @override
  String get noUpstream => '无 upstream';

  @override
  String get noUsableGitWasDetectedInstallItAndCheckAgain =>
      '未检测到可用的 Git。安装后请重新检测。';

  @override
  String get none => '无';

  @override
  String get normalLog => '普通日志';

  @override
  String get notCheckedYet => '尚未检测';

  @override
  String get notConfigured => '未配置';

  @override
  String get notDetected => '未检测';

  @override
  String nothingIsPushedYetThePlanPushesTo(
    String branch,
    String platform,
    String url,
  ) {
    return '现在不会联网推送。执行计划时，将当前分支 $branch 推送到 $platform。\n$url';
  }

  @override
  String
  get nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded =>
      '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。';

  @override
  String get oldVersionAndInstallerCleanup => '旧版本与安装包清理';

  @override
  String get onlineReleaseNotes => '线上发布说明';

  @override
  String
  get onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath =>
      '只修改当前用户的 PATH，不需要管理员权限。软件只会添加或移除自己管理的稳定运行时路径。';

  @override
  String get onlyTheLocalGitRemoteConfigurationIsRemoved =>
      '执行计划时只删除本地 Git remote 配置，不会删除远端平台上的仓库。';

  @override
  String get onlyVerifiedRepositoryRootsAreSaved => '仅保存验证成功的仓库根目录';

  @override
  String get open => '打开';

  @override
  String
  get openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository =>
      '打开现有仓库、初始化空白目录，或克隆远程仓库';

  @override
  String get openAnotherFolderOrRefreshToViewRepositoryContents =>
      '切换目录或刷新以查看仓库内容。';

  @override
  String get openEmptyFolder => '打开空白文件夹';

  @override
  String get openFolder => '打开目录';

  @override
  String get openGitRepository => '打开 Git 仓库';

  @override
  String get openReleasePage => '打开发布页';

  @override
  String get openRepository2 => '打开仓库';

  @override
  String get openWithDefaultApp => '用默认打开方式打开';

  @override
  String get openingAnotherRepository => '打开另一个仓库';

  @override
  String get openingRepository => '正在读取仓库…';

  @override
  String optionsFound(String count) {
    return '找到 $count 个选项';
  }

  @override
  String get parentFolder => '上一级';

  @override
  String get paste => '粘贴';

  @override
  String get pasteTarget => '粘贴目标';

  @override
  String get pasteToLeft => '粘贴到左侧';

  @override
  String get pasteToRight => '粘贴到右侧';

  @override
  String get pathChangeCancelled => '已取消修改 PATH';

  @override
  String pathChangeFailed(String error) {
    return 'PATH 修改失败：$error';
  }

  @override
  String pending(String count) {
    return '待执行 $count';
  }

  @override
  String get pending2 => '待提交';

  @override
  String get pendingOperationPlan => '待执行操作计划';

  @override
  String plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
    String action,
    String count,
  ) {
    return '当前有 $count 步操作尚未执行。$action会清除这些计划，仓库不会发生这些变更。';
  }

  @override
  String get popStash => '弹出 Stash';

  @override
  String get preciseSizeView => '精确大小视图';

  @override
  String get preparingToExecute => '准备执行';

  @override
  String get preparingUpdate => '正在准备更新…';

  @override
  String get projectFolder => '项目目录';

  @override
  String get projectFolderName => '项目文件夹名称';

  @override
  String get projectSize => '项目大小';

  @override
  String projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
    String branch,
    String confirmation,
    String message,
    String project,
    String target,
  ) {
    return '项目：$project\n目标分支：$branch\n目标提交：$target\n空提交说明：$message\n计划执行确认：$confirmation';
  }

  @override
  String
  get pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex =>
      'Pull 会先 Fetch 并重新检查 ahead/behind，只允许快进，不会自动创建 Merge 提交；工作区或索引不干净时禁止 Pull。';

  @override
  String get push => '推送';

  @override
  String get pushAll => '全部推送';

  @override
  String get pushCurrentBranchCtrlShiftU => '推送当前分支 (Ctrl+Shift+U)';

  @override
  String readingBranchesAndTagsFrom(String remote) {
    return '正在读取远端 $remote 的分支和标签…';
  }

  @override
  String get readingSynchronizationState => '正在读取同步状态…';

  @override
  String get recentlyOpened => '最近打开';

  @override
  String get refresh => '刷新';

  @override
  String get refreshBranches => '刷新分支';

  @override
  String get refreshLogs => '刷新日志';

  @override
  String get refreshRemotes => '刷新远端';

  @override
  String get refreshRepositoryAndRebuildPlan => '刷新仓库并重建计划';

  @override
  String get refreshRepositoryCtrlR => '刷新仓库 (Ctrl+R)';

  @override
  String get refreshStashes => '刷新 Stash';

  @override
  String get refreshSynchronizationState => '刷新同步状态';

  @override
  String get remoteCheck => '远端检查';

  @override
  String get remoteName => '远端名称';

  @override
  String get remoteRefList => '远端引用列表';

  @override
  String remoteRepositoriesWereDetectedSoClearingIsDisabled(String remotes) {
    return '检测到远端仓库，已禁止清除：$remotes';
  }

  @override
  String get remoteRepositoryUrl => '远程仓库地址';

  @override
  String get remoteUrl => '远端 URL';

  @override
  String remotes(String count) {
    return '远端 $count';
  }

  @override
  String get remotes2 => '远端仓库';

  @override
  String get removeFromHistory => '从历史记录移除';

  @override
  String get removeFromPlan => '从计划移除';

  @override
  String get removeFromSystemPath => '从系统 PATH 移除';

  @override
  String get removeFromUserPath => '从用户 PATH 移除';

  @override
  String get removeLocalRemoteConfiguration => '移除本地远端配置';

  @override
  String removedItemsAndFreed(String count, String size) {
    return '已清除 $count 项，共释放 $size。';
  }

  @override
  String removedItemsCouldNotBeDeletedCheckTheDetailedLog(
    String failed,
    String removed,
  ) {
    return '已清除 $removed 项；$failed 项无法删除，请查看详细日志。';
  }

  @override
  String get rename => '重命名';

  @override
  String get renameBranch => '重命名分支';

  @override
  String repository(String path) {
    return '仓库：$path';
  }

  @override
  String get repositoryAndRemoteOperationsAreAvailable => '可执行仓库与远端操作';

  @override
  String get repositoryViewRefreshed => '仓库视图已刷新';

  @override
  String get reviewRemoveOrExecutePendingOperations => '查看、移除或确认执行所有待处理操作';

  @override
  String get rightExplorer => '右侧资源';

  @override
  String get safeFastForwardPull => '安全快进 Pull';

  @override
  String get saveSettings2 => '保存设置';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get scanOldVersionsAndInstallers => '扫描旧版本与安装包';

  @override
  String get scrollDownForFontPreviewAndFontSizeSettings =>
      '向下滚动可查看字体预览和字体大小设置。';

  @override
  String get searchFontNameOrPurposeEGInterOrNoto => '搜索字体名称或用途，例如 Inter、思源、中文';

  @override
  String get selectAnItemToRename => '请先勾选要重命名的项目。';

  @override
  String get selectExactlyOneItemToRename => '重命名时只能勾选一个项目。';

  @override
  String get selectFilesToCutOrCopy => '勾选文件后可剪切或复制';

  @override
  String get selectItemsToDelete => '请先勾选要删除的项目。';

  @override
  String get selectTheDangerousOperationConfirmationFirst => '请先勾选“我已检查危险操作”。';

  @override
  String selected(String count) {
    return '已选 $count 项';
  }

  @override
  String selected2(String count) {
    return '已选择 $count 项';
  }

  @override
  String get settings2 => '设置';

  @override
  String get settingsDataDirectory => '设置数据目录';

  @override
  String get showInFileExplorer => '用文件资源打开';

  @override
  String get siDecimal => 'SI 十进制';

  @override
  String get size => '大小';

  @override
  String get sizeUnitSystem => '容量单位制';

  @override
  String get smallFile => '小文件';

  @override
  String get stageAll => '暂存全部';

  @override
  String staged(String count) {
    return '$count 项已暂存';
  }

  @override
  String get stash => 'Stash';

  @override
  String get stashManagement => 'Stash 管理';

  @override
  String get stashMessageOptional => 'Stash 说明（可选）';

  @override
  String get stateChangeDetails => '状态变化详情';

  @override
  String get stateChangedBeforeExecution => '执行前状态已变化';

  @override
  String get status => '状态';

  @override
  String step(String step, String title) {
    return '第 $step 步：$title';
  }

  @override
  String stepsTheRepositoryIsUnchangedUntilConfirmation(String count) {
    return '共 $count 步；确认前仓库不会发生任何改变';
  }

  @override
  String
  get supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst =>
      '支持 GitHub、Gitee、GitLab、Bitbucket 和任意标准 Git 远端。所有修改会先加入待执行计划。远端右侧红色垃圾桶用于清空该远端全部分支和标签。';

  @override
  String get switchBranch => '切换分支';

  @override
  String get sync => '同步';

  @override
  String get systemDefaultAutomatic => '系统默认（自动适配）';

  @override
  String get systemFonts => '系统自带';

  @override
  String get systemGit => '系统 Git';

  @override
  String textCanBeSelectedAndCopiedHereTheFullGuideIsIn(String path) {
    return '可在本窗口中选中并复制文字。完整指南保存在 $path。';
  }

  @override
  String
  get thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject =>
      '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。';

  @override
  String get theCloneDestinationFolderIsNotEmpty => '克隆目标目录不是空目录。';

  @override
  String get theCloneDestinationParentFolderDoesNotExist => '克隆目标父目录不存在。';

  @override
  String
  get theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText =>
      '配色方案会应用到按钮、选择状态、边框、图标和强调文字。';

  @override
  String get theCurrentBranchHasNoCommitAndCannotBePulled =>
      '当前分支尚无提交，不能 Pull。';

  @override
  String
  get theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking =>
      '当前分支没有 upstream。可获取全部远端，但 Pull 前需要配置跟踪分支。';

  @override
  String get theCurrentBranchIsSynchronizedWithUpstream =>
      '当前分支已经与 upstream 同步。';

  @override
  String get theDetailedReasonHasBeenWrittenToTheApplicationLog =>
      '详细原因已写入操作日志。';

  @override
  String get theGiteeSourceIsSuitedToMainlandChinaNetworks =>
      'Gitee 更新源适合中国大陆网络环境。';

  @override
  String
  get theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata =>
      '初始化目标必须存在且不能已经包含 Git 元数据。';

  @override
  String get theLanguageChangeTakesEffectImmediatelyAfterSaving =>
      '语言更改会在保存设置后立即生效。';

  @override
  String get theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull =>
      '本地分支有未推送提交，当前不需要 Pull。';

  @override
  String
  get theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone =>
      '下一步只创建克隆操作预览；取消不会创建任何文件，确认计划时才会再次检查目标目录并执行 git clone。';

  @override
  String thePlanPushesTo(String branch, String remotes) {
    return '执行计划时，当前分支 $branch 将依次推送到：\n$remotes';
  }

  @override
  String get theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated =>
      '远端当前没有分支或标签，将直接创建第一个空提交。';

  @override
  String get theRepositoryHasNoStashes => '当前仓库没有 Stash。';

  @override
  String get theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes =>
      '保存后会应用到菜单、资源面板、对话框和提交说明。';

  @override
  String get theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull =>
      '工作区或索引不干净。请先提交或 Stash 更改，再执行安全 Pull。';

  @override
  String get thereAreNoLocalBranchesToDisplay => '当前没有可显示的本地分支。';

  @override
  String get thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation =>
      '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。';

  @override
  String
  thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
    String branch,
  ) {
    return '这是不可撤销的高风险操作。软件会先备份远端引用，然后把 $branch 强制替换为一个不含文件的空根提交，删除其他分支和标签，并把本地同名分支与索引同步到该空提交。本地文件不会删除，刷新后会显示为未跟踪。';
  }

  @override
  String get thisOperationDeletesTheGitFolderInTheRepositoryRoot =>
      '此操作会删除仓库根目录中的 .git 文件夹。';

  @override
  String
  thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
    String count,
  ) {
    return '此计划包含 $count 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。';
  }

  @override
  String get thisProjectIsLicensedUnderTheMitLicense =>
      '本项目使用 MIT License 开源许可证。';

  @override
  String get threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge =>
      '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。';

  @override
  String today(String time) {
    return '今天 $time';
  }

  @override
  String get turnGitFileOperationsIntoAnIntuitiveWorkspace =>
      '把 Git 文件操作，\n变成一次直观的移动。';

  @override
  String get typeANameToFilter => '输入名称可快速筛选';

  @override
  String unableToOpenFile(String error) {
    return '无法打开文件：$error';
  }

  @override
  String unableToOpenLogsFolder(String error) {
    return '无法打开日志目录：$error';
  }

  @override
  String unableToOpenProjectFolder(String error) {
    return '无法打开项目目录：$error';
  }

  @override
  String unableToOpenTheGitDownloadPage(String error) {
    return '无法打开 Git 下载页面：$error';
  }

  @override
  String get unableToReadBranchSynchronizationStateRefreshAndTryAgain =>
      '无法读取分支同步状态。请刷新后重试。';

  @override
  String get unableToReadFolder => '无法读取目录';

  @override
  String unableToReadUserGuide(String error) {
    return '无法读取使用指南：$error';
  }

  @override
  String get unableToRetrieveTheOnlineVersion => '暂时无法获取线上版本';

  @override
  String get unitPreview => '单位预览';

  @override
  String get units => '单位设置';

  @override
  String get unstage => '取消暂存';

  @override
  String get updateAndRestartNow => '立即更新并重启';

  @override
  String get updateSource => '更新源';

  @override
  String updated(String scope) {
    return '已更新 $scope';
  }

  @override
  String get updates => '更新';

  @override
  String get updatesAndReleaseNotes => '更新与发布日志';

  @override
  String get updating => '更新中';

  @override
  String get updatingAutomatically => '正在自动更新';

  @override
  String get upstream => 'upstream';

  @override
  String
  usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
    String platform,
  ) {
    return '$platform 的默认分支通常受保护。如果服务器拒绝强制更新或删除，整个原子操作不会删除任何引用；需要先在托管平台临时解除默认分支保护。';
  }

  @override
  String get versionNotFoundOrUnreadable => '未找到或无法读取版本';

  @override
  String versionV(String version) {
    return '版本 v$version';
  }

  @override
  String versionVIsAvailable(String version) {
    return '发现新版本 v$version';
  }

  @override
  String get viewAndManageAllRemotes => '查看和管理全部远端仓库';

  @override
  String get viewBranchSynchronization => '查看分支同步状态';

  @override
  String get viewLogs => '查看日志';

  @override
  String
  get workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks =>
      '工作文件不会被删除，但以下 Git 内容会永久丢失：\n• 全部提交历史和 reflog\n• 本地分支、标签和当前分支状态\n• 暂存索引、Stash、未被工作文件保留的已提交内容\n• 引用、远端配置以及仓库级 Git 配置和 hooks';

  @override
  String get workingTreeClean => '工作区干净，没有待提交的更改';

  @override
  String get worktree => '工作区';

  @override
  String get youAreUpToDate => '已经是最新版本';

  @override
  String get followSystemLabel => '跟随系统';

  @override
  String get followSystemDescription => '使用操作系统设置的语言。';

  @override
  String get languageEnglishOptionLabel => 'English';

  @override
  String get languageEnglishDescription => '使用英文显示软件界面。';

  @override
  String get languageSimplifiedChineseOptionLabel => '简体中文';

  @override
  String get languageSimplifiedChineseDescription => '使用简体中文显示软件界面。';

  @override
  String get languageTraditionalChineseOptionLabel => '繁體中文';

  @override
  String get languageTraditionalChineseDescription => '使用繁體中文顯示軟體介面。';

  @override
  String get userPath => '用户 PATH';

  @override
  String get systemPath => '系统 PATH';

  @override
  String addPortableGitTo(String scope) {
    return '将 PortableGit 加入 $scope';
  }

  @override
  String removePortableGitFrom(String scope) {
    return '从 $scope 移除 PortableGit';
  }

  @override
  String get confirmAdd => '确认加入';

  @override
  String get confirmRemove => '确认移除';

  @override
  String get gitAvailable => 'Git 可用';

  @override
  String get gitUnavailable => 'Git 不可用';

  @override
  String get creatingShortcut => '正在创建快捷方式…';

  @override
  String get oneClickSendToDesktop => '一键发送到桌面';

  @override
  String get bundledLabel => '内置';

  @override
  String get iec1024BaseBit => 'IEC · 1024 进制 · bit';

  @override
  String get si1000BaseBit => 'SI · 1000 进制 · bit';

  @override
  String get iec1024BaseByte => 'IEC · 1024 进制 · Byte';

  @override
  String get si1000BaseByte => 'SI · 1000 进制 · Byte';

  @override
  String get classicGreen => '经典绿';

  @override
  String get oceanBlue => '海洋蓝';

  @override
  String get starryViolet => '星夜紫';

  @override
  String get amberGold => '琥珀金';

  @override
  String get roseRed => '玫瑰红';

  @override
  String get interUiDescription => '专为数字界面设计的开源无衬线字体，适合工具栏和高密度正文。';

  @override
  String get notoSansScDescription => '覆盖简体中文的现代界面字体，中英文混排清晰、字形稳定。';

  @override
  String get ibmPlexSansDescription => '为产品界面和企业信息设计，数字与英文阅读性突出。';

  @override
  String get fontDescription => '软件内置界面字体';

  @override
  String get operationCompleted => '操作已完成。';

  @override
  String operationCompletedFor(String target) {
    return '操作已完成：$target。';
  }

  @override
  String operationCompletedForItems(String count) {
    return '已完成 $count 项操作。';
  }

  @override
  String operationFailed(String error) {
    return '操作失败：$error';
  }

  @override
  String operationFailedFor(String error, String target) {
    return '$target 操作失败：$error';
  }

  @override
  String logInfo(String eventId) {
    return '信息事件：$eventId';
  }

  @override
  String logDetail(String eventId) {
    return '详细事件：$eventId';
  }

  @override
  String logWarning(String eventId) {
    return '警告事件：$eventId';
  }

  @override
  String logError(String eventId) {
    return '错误事件：$eventId';
  }

  @override
  String get logsTruncated => '… 仅显示最近日志 …';

  @override
  String logReadFailed(String error) {
    return '读取日志失败：$error';
  }

  @override
  String get noRepositoryOpen => '当前没有打开的仓库。';

  @override
  String get operationInProgress => '当前仍有操作正在执行。';

  @override
  String get emptyOperationPlan => '执行计划为空。';

  @override
  String get gitUnavailableHelp => '未检测到可用的 Git。请先安装 Git，或在设置中重新检测。';

  @override
  String get selectItemsFirst => '请先勾选文件或文件夹。';

  @override
  String get clipboardEmpty => '剪贴板为空。';

  @override
  String get clipboardCleared => '已清空剪贴板。';

  @override
  String clipboardPendingCut(String count) {
    return '待移动 $count 项';
  }

  @override
  String clipboardPendingCopy(String count) {
    return '待复制 $count 项';
  }

  @override
  String get operationPlanBusyEdit => '操作计划正在执行，暂时不能修改。';

  @override
  String get operationPlanBusyClear => '操作计划正在执行，暂时不能清空。';

  @override
  String get planOperationMissing => '待执行操作不存在。';

  @override
  String get planOperationRemoved => '已从执行计划移除该操作。';

  @override
  String planCleared(String count) {
    return '已清空 $count 步待执行操作。';
  }

  @override
  String planStrongConfirmationRequired(String confirmation) {
    return '请准确输入 $confirmation 以确认危险操作。';
  }

  @override
  String get planDangerousAcknowledgmentRequired => '请先勾选危险操作确认项。';

  @override
  String get planStateChanged => '仓库状态与确认预览不一致，已停止执行。请刷新并重新建立操作计划。';

  @override
  String planStepStateChanged(String step) {
    return '执行到第 $step 步前发现仓库状态已被修改，已停止。请刷新并重新建立操作计划。';
  }

  @override
  String planStepFailed(String error, String step) {
    return '第 $step 步失败：$error。后续步骤尚未执行，失败步骤仍保留在计划中。';
  }

  @override
  String planExecutionComplete(String count) {
    return '已按顺序执行全部 $count 步操作。';
  }

  @override
  String get planOperationAdded => '已加入待执行操作计划；尚未执行任何 Git 变更。';

  @override
  String planSnapshotFailed(String error) {
    return '无法建立操作预览的安全状态快照：$error';
  }

  @override
  String get clearRemoteMustRunAlone => '清空远端必须单独执行。请先移除或执行计划中的其他步骤。';

  @override
  String get commitMustRemainLast => '提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。';

  @override
  String get exclusiveOperationMustRunAlone => '此生命周期操作必须单独执行。';

  @override
  String get exclusiveOperationAlreadyQueued => '当前计划已包含必须单独执行的操作。';

  @override
  String get renameSelectOne => '重命名时请只勾选一个文件或文件夹。';

  @override
  String get nameCannotBeEmpty => '名称不能为空。';

  @override
  String get historyEntryRemoved => '已从最近仓库历史中移除。';

  @override
  String get gitMetadataClearAvailable => '当前仓库没有配置远端，可以清除 Git 元数据。';

  @override
  String get gitMetadataCleared => 'Git 元数据已清除，工作文件仍然保留。';

  @override
  String get gitMetadataRemoteForbidden => '当前仓库已连接远端，禁止清除 Git 元数据。';

  @override
  String fileRenamed(String name) {
    return '已重命名为 $name。';
  }

  @override
  String get bootstrapPlanAlreadyUsed => '此操作已经执行或正在执行，请重新打开预览。';

  @override
  String get bootstrapStateChanged => '目标状态与确认预览不一致，已停止执行。请刷新预览后重新确认。';

  @override
  String get unableToInspectRepository => '无法检查仓库。';

  @override
  String stepsCount(String count) {
    return '$count 步';
  }

  @override
  String get planKindInitialize => '初始化';

  @override
  String get planKindClone => '克隆';

  @override
  String get planKindMove => '移动';

  @override
  String get planKindCopy => '复制';

  @override
  String get planKindRename => '重命名';

  @override
  String get planKindDelete => '删除';

  @override
  String get planKindClearGitMetadata => '清除 Git 元数据';

  @override
  String get planKindStageAll => '暂存';

  @override
  String get planKindUnstageAll => '取消暂存';

  @override
  String get planKindCommit => '提交';

  @override
  String get planKindFetchCurrent => '获取 upstream';

  @override
  String get planKindFetchAll => '获取全部远端';

  @override
  String get planKindPull => '快进 Pull';

  @override
  String get planKindPush => '推送';

  @override
  String get planKindPushAll => '全部推送';

  @override
  String get planKindAddRemote => '添加远端';

  @override
  String get planKindUpdateRemote => '修改远端';

  @override
  String get planKindRemoveRemote => '移除远端';

  @override
  String get planKindClearRemote => '清空远端';

  @override
  String get planKindCreateBranch => '创建分支';

  @override
  String get planKindSwitchBranch => '切换分支';

  @override
  String get planKindRenameBranch => '重命名分支';

  @override
  String get planKindDeleteBranch => '删除分支';

  @override
  String get planKindCreateStash => '创建 Stash';

  @override
  String get planKindApplyStash => '应用 Stash';

  @override
  String get planKindPopStash => '弹出 Stash';

  @override
  String get planKindDropStash => '删除 Stash';

  @override
  String get planTitleInitializeRepository => '初始化 Git 仓库';

  @override
  String planDescriptionInitializeRepository(String path) {
    return '确认后在 $path 执行 git init，然后打开该仓库。';
  }

  @override
  String get planTitleCloneRepository => '克隆 Git 仓库';

  @override
  String planDescriptionCloneRepository(String path, String url) {
    return '把 $url 克隆到 $path。取消不会创建内容；确认后会重新检查目标并执行 git clone。';
  }

  @override
  String planTitleMove(String count, String destination) {
    return '移动 $count 项到 $destination';
  }

  @override
  String planDescriptionMove(String count, String destination) {
    return '使用 Git 将 $count 个项目移动到 $destination。';
  }

  @override
  String planTitleCopy(String count, String destination) {
    return '复制 $count 项到 $destination';
  }

  @override
  String planDescriptionCopy(String count, String destination) {
    return '使用 Git 将 $count 个项目复制到 $destination。';
  }

  @override
  String planTitleRename(String source) {
    return '重命名 $source';
  }

  @override
  String planDescriptionRename(String newName, String source) {
    return '把 $source 的名称改为 $newName。';
  }

  @override
  String planTitleDelete(String count) {
    return '删除 $count 个项目';
  }

  @override
  String planDescriptionDelete(String count, String paths) {
    return '将永久删除 $count 个项目：$paths。已跟踪内容使用 git rm，未跟踪或忽略内容使用 git clean。';
  }

  @override
  String get planTitleClearGitMetadata => '清除 Git 元数据';

  @override
  String planDescriptionClearGitMetadata(String path) {
    return '仓库：$path。将永久删除 .git 并保留工作文件。提交历史、分支、标签、索引、Stash、远端配置和仓库级设置都会丢失。此操作必须单独执行。';
  }

  @override
  String planTitleCreateBranch(String branch) {
    return '创建分支 $branch';
  }

  @override
  String planDescriptionCreateBranch(String branch) {
    return '执行 git branch -- $branch，从当前 HEAD 创建本地分支。';
  }

  @override
  String branchCreated(String branch) {
    return '已创建分支 $branch。';
  }

  @override
  String planTitleSwitchBranch(String branch) {
    return '切换到分支 $branch';
  }

  @override
  String planDescriptionSwitchBranch(String branch) {
    return '执行 git switch $branch。未提交修改发生冲突时 Git 会拒绝切换。';
  }

  @override
  String branchSwitched(String branch) {
    return '已切换到分支 $branch。';
  }

  @override
  String alreadyOnBranch(String branch) {
    return '已经位于分支 $branch。';
  }

  @override
  String planTitleRenameBranch(String from, String to) {
    return '重命名分支 $from 为 $to';
  }

  @override
  String planDescriptionRenameBranch(String from, String to) {
    return '执行 git branch -m $from $to。';
  }

  @override
  String branchRenamed(String from, String to) {
    return '已把分支 $from 重命名为 $to。';
  }

  @override
  String planTitleDeleteBranch(String branch) {
    return '删除分支 $branch';
  }

  @override
  String planDescriptionDeleteBranchForce(String branch) {
    return '执行 git branch -D $branch，强制删除未合并分支。';
  }

  @override
  String planDescriptionDeleteBranchSafe(String branch) {
    return '执行 git branch -d $branch，仅允许删除已合并分支。';
  }

  @override
  String branchDeleted(String branch) {
    return '已删除分支 $branch。';
  }

  @override
  String get cannotDeleteCurrentBranch => '不能删除当前分支，请先切换到其他分支。';

  @override
  String get planTitleCreateStash => '创建 Stash';

  @override
  String planTitleCreateStashNamed(String message) {
    return '创建 Stash：$message';
  }

  @override
  String planDescriptionCreateStash(String message) {
    return '执行 git stash push，提交说明为：$message';
  }

  @override
  String planDescriptionCreateStashIncludeUntracked(String message) {
    return '执行 git stash push --include-untracked，提交说明为：$message';
  }

  @override
  String get stashCreated => 'Stash 已创建。';

  @override
  String planTitleApplyStash(String selector) {
    return '应用 $selector';
  }

  @override
  String planDescriptionApplyStash(String selector) {
    return '执行 git stash apply $selector，并保留 Stash 记录。';
  }

  @override
  String stashApplied(String selector) {
    return '已应用 $selector。';
  }

  @override
  String planTitlePopStash(String selector) {
    return '弹出 $selector';
  }

  @override
  String planDescriptionPopStash(String selector) {
    return '执行 git stash pop $selector，应用后删除该 Stash。';
  }

  @override
  String stashPopped(String selector) {
    return '已弹出 $selector。';
  }

  @override
  String planTitleDropStash(String selector) {
    return '删除 $selector';
  }

  @override
  String planDescriptionDropStash(String selector) {
    return '执行 git stash drop $selector，此操作无法通过本软件撤销。';
  }

  @override
  String stashDropped(String selector) {
    return '已删除 $selector。';
  }

  @override
  String get invalidStashSelector => 'Stash 选择器无效。';

  @override
  String get planTitlePushCurrent => '推送当前分支';

  @override
  String planTitlePushBranch(String branch) {
    return '推送 $branch';
  }

  @override
  String get planDescriptionPushCurrent =>
      '把当前分支推送到 upstream；没有 upstream 时使用 origin 或首个远端并设置跟踪关系。';

  @override
  String planTitleFetchRemote(String remote) {
    return '获取远端 $remote';
  }

  @override
  String planDescriptionFetchRemote(String remote) {
    return '执行 git fetch --prune $remote；更新远端跟踪引用，不修改工作区文件。';
  }

  @override
  String planTitleFetchAllRemotes(String count) {
    return '获取全部 $count 个远端';
  }

  @override
  String planDescriptionFetchAllRemotes(String remotes) {
    return '依次为以下远端执行 git fetch --prune：$remotes。失败项会逐个报告。';
  }

  @override
  String remoteFetched(String remote) {
    return '已获取远端 $remote 的更新。';
  }

  @override
  String allRemotesFetched(String count) {
    return '已获取全部 $count 个远端。';
  }

  @override
  String remoteBatchPartialFailure(
    String details,
    String failed,
    String succeeded,
  ) {
    return '成功 $succeeded 个，失败 $failed 个。详情：$details';
  }

  @override
  String get syncStateUnavailable => '无法读取当前分支同步状态。';

  @override
  String get detachedCannotPull => '当前处于 detached HEAD，不能 Pull 分支。';

  @override
  String get unbornCannotPull => '当前分支尚无提交，不能 Pull。';

  @override
  String get upstreamMissing => '当前分支没有可用的 upstream，请先配置远端跟踪分支。';

  @override
  String get dirtyWorktreeCannotPull => '工作区或索引不干净，请先提交或 Stash 更改再 Pull。';

  @override
  String get pullUpToDate => '当前分支已经与 upstream 同步。';

  @override
  String get pullAhead => '当前分支包含 upstream 的全部提交，但有本地提交未推送。';

  @override
  String get pullDiverged => '本地分支与 upstream 已分叉，请先使用外部 Git 执行 Merge 或 Rebase。';

  @override
  String get pullRelationUnknown => '当前分支同步关系未知。';

  @override
  String get pullNoUpdate => '当前无需快进更新。';

  @override
  String planTitlePull(String branch) {
    return '安全快进 Pull $branch';
  }

  @override
  String planDescriptionPull(String branch, String remote, String upstream) {
    return '先从 $remote 获取更新并重新检查 ahead/behind；仅在 $branch 落后且未分叉时执行 git merge --ff-only $upstream，不会自动创建 Merge 提交。';
  }

  @override
  String pullCompleted(String branch, String upstream) {
    return '已快进更新 $branch 到 $upstream。';
  }

  @override
  String syncAuthenticationFailed(String error) {
    return 'Git 认证失败：$error';
  }

  @override
  String syncNetworkFailed(String error) {
    return 'Git 网络访问失败：$error';
  }

  @override
  String get pushedCurrentBranch => '已推送当前分支。';

  @override
  String pushedBranch(String branch) {
    return '已推送 $branch。';
  }

  @override
  String get noRemotesConfigured => '项目没有配置远端仓库。';

  @override
  String get remoteListRefreshed => '远端列表已刷新。';

  @override
  String planTitleAddRemote(String remote) {
    return '添加远端 $remote';
  }

  @override
  String planDescriptionAddRemote(String remote, String url) {
    return '添加远端 $remote，地址为 $url。';
  }

  @override
  String planTitleUpdateRemote(String remote) {
    return '修改远端 $remote';
  }

  @override
  String planDescriptionUpdateRemote(String remote, String url) {
    return '把远端 $remote 的地址改为 $url。';
  }

  @override
  String remoteAdded(String remote) {
    return '已添加远端 $remote。';
  }

  @override
  String remoteUpdated(String remote) {
    return '已更新远端 $remote。';
  }

  @override
  String remoteRemoved(String remote) {
    return '已删除远端 $remote。';
  }

  @override
  String planTitleRemoveRemote(String remote) {
    return '删除远端配置 $remote';
  }

  @override
  String get planDescriptionRemoveRemote =>
      '仅删除本仓库中的 Git remote 配置，不会删除远端平台上的仓库。';

  @override
  String planTitlePushRemote(String remote) {
    return '推送到远端 $remote';
  }

  @override
  String planDescriptionPushRemote(String branch, String remote) {
    return '把分支 $branch 推送到远端 $remote。';
  }

  @override
  String pushedToRemote(String remote) {
    return '已推送到 $remote。';
  }

  @override
  String planTitlePushAllRemotes(String count) {
    return '推送到全部 $count 个远端';
  }

  @override
  String planDescriptionPushAllRemotes(String remotes) {
    return '依次把当前分支推送到：$remotes。';
  }

  @override
  String pushedToAllRemotes(String count) {
    return '已推送到全部 $count 个远端。';
  }

  @override
  String remoteInspectionEmpty(String remote) {
    return '远端 $remote 当前没有分支或标签。';
  }

  @override
  String remoteInspectionCounts(String branches, String remote, String tags) {
    return '远端 $remote 有 $branches 个分支、$tags 个标签。';
  }

  @override
  String planTitleClearRemote(String remote) {
    return '清空远端历史 $remote';
  }

  @override
  String planDescriptionClearRemote(
    String branch,
    String branches,
    String message,
    String project,
    String tags,
  ) {
    return '项目 $project，目标分支 $branch。将备份并删除 $branches 个分支和 $tags 个标签，然后只保留一个空提交：“$message”。本地文件保留，但本地索引会重置为空，刷新后文件显示为未跟踪。';
  }

  @override
  String clearRemoteCompleted(String branch, String commit, String remote) {
    return '已清空远端 $remote。$branch 现指向空提交 $commit；本地文件保留并显示为未跟踪。';
  }

  @override
  String clearRemoteDrift(
    String branches,
    String error,
    String remote,
    String tags,
  ) {
    return '远端 $remote 的引用在确认后发生变化，已停止清空。当前有 $branches 个分支和 $tags 个标签。$error';
  }

  @override
  String get planTitleStageAll => '暂存全部更改';

  @override
  String get planDescriptionStageAll => '执行 git add -A，将当前全部更改加入 Git 索引。';

  @override
  String get stageAllCompleted => '已暂存全部更改。';

  @override
  String get planTitleUnstageAll => '取消暂存全部更改';

  @override
  String get planDescriptionUnstageAll => '把 Git 索引恢复到 HEAD，同时保留工作区文件。';

  @override
  String get unstageAllCompleted => '已取消暂存全部更改。';

  @override
  String get planTitleCommitAll => '提交全部更改';

  @override
  String planDescriptionCommitAll(String message) {
    return '提交说明：$message。执行时先运行 git add -A，再运行 git commit。';
  }

  @override
  String get commitMessageRequired => '请填写提交说明。';

  @override
  String get noChangesToCommit => '没有可提交的更改。';

  @override
  String get commitAlreadyQueued => '执行计划中已经有提交步骤。';

  @override
  String get commitIdentityUnavailable =>
      'Git 作者和提交者身份不可用。请配置 user.name 和 user.email 后重试。';

  @override
  String get commitSucceeded => '提交已创建。';

  @override
  String get settingsSaved => '设置已保存。';

  @override
  String get desktopShortcutWindowsOnly => '桌面快捷方式目前仅支持 Windows。';

  @override
  String desktopShortcutCreated(String path) {
    return '已创建桌面快捷方式：$path';
  }

  @override
  String get maintenanceKindOldVersion => '旧版本目录';

  @override
  String get maintenanceKindUpdateArchive => '更新安装包';

  @override
  String get maintenanceKindPartialDownload => '未完成下载';

  @override
  String get maintenanceKindStagingDirectory => '临时解压目录';

  @override
  String get maintenanceKindLegacyUpdater => '旧更新脚本';

  @override
  String get maintenanceKindLegacyFlatFile => '旧平铺程序文件';

  @override
  String get maintenanceKindLegacyFlatDirectory => '旧平铺程序目录';

  @override
  String get maintenanceKindObsoleteGitRuntime => '旧 PortableGit 运行时';

  @override
  String get maintenanceKindGitRuntimeArchive => 'PortableGit 更新包';

  @override
  String get maintenanceKindGitRuntimeStaging => 'PortableGit 暂存目录';

  @override
  String get driftRepositoryRoot => '仓库根目录';

  @override
  String get driftBranch => '分支';

  @override
  String get driftHead => 'HEAD';

  @override
  String get driftStatus => '工作区状态';

  @override
  String get driftRemotes => '远端配置';

  @override
  String get driftPathType => '路径类型';

  @override
  String get driftDestinationParent => '父目录';

  @override
  String get driftDestinationExists => '目标是否存在';

  @override
  String get driftDestinationEmpty => '目标是否为空';

  @override
  String get driftGitMetadata => 'Git 元数据';

  @override
  String get driftSource => '来源';

  @override
  String get driftRemoteName => '远端名称';

  @override
  String get driftRemoteTargetBranch => '目标分支';

  @override
  String get driftRemoteRefs => '远端引用';

  @override
  String get updateGithubNoRelease => '仓库暂未发布公开的 GitHub Release，可打开发布页查看。';

  @override
  String get updateGiteeNoRelease => '仓库暂未发布公开的 Gitee Release，可打开发布页查看。';

  @override
  String updateHttpError(String platform, String status) {
    return '$platform 返回 HTTP $status，请稍后重试。';
  }

  @override
  String get updateInvalidResponseGithub => 'GitHub 更新描述格式无法识别。';

  @override
  String get updateInvalidResponseGitee => 'Gitee 更新描述格式无法识别。';

  @override
  String get updateVersionMissingGithub => 'GitHub 公开 Release 没有可识别的版本号。';

  @override
  String get updateVersionMissingGitee => 'Gitee 公开 Release 没有可识别的版本号。';

  @override
  String get updateAssetMissingGithub =>
      '发现新版本，但 Release 缺少带 SHA-256 的 Windows x64 ZIP。';

  @override
  String get updateAvailableGithub => '发现可用的新版本，可直接下载、校验并自动重启更新。';

  @override
  String get updateAvailableGitee => '发现可用的 Gitee 新版本，可直接下载、校验并自动重启更新。';

  @override
  String updateUpToDate(String version) {
    return '当前版本 v$version 已是 GitHub 最新版本。';
  }

  @override
  String updateGiteeUpToDate(String version) {
    return '当前版本 v$version 已是 Gitee 最新版本。';
  }

  @override
  String get updateNetworkUnavailableGithub => '无法连接 GitHub，请检查网络后重试。';

  @override
  String get updateNetworkUnavailableGitee => '无法连接 Gitee，请检查网络后重试。';

  @override
  String get updateRequestFailed => '网络请求失败，请稍后重试。';

  @override
  String get updateGiteeRequestFailed => 'Gitee 网络请求失败，请稍后重试。';

  @override
  String get updateGiteeDigestMissing =>
      '发现 Gitee 新版本，但无法从 GitHub 资产元数据取得可信 SHA-256，已禁用自动安装。可打开发布页手动下载。';

  @override
  String get updateProgressPreparing => '正在准备自动更新…';

  @override
  String get updateProgressConnecting => '正在连接 Release 下载更新…';

  @override
  String updateProgressDownloading(String asset) {
    return '正在下载 $asset…';
  }

  @override
  String get updateProgressVerifying => '正在校验更新包 SHA-256…';

  @override
  String get updateProgressExtracting => '正在解压到独立版本目录…';

  @override
  String get updateProgressVerifyingRuntime => '正在验证安装包中的 PortableGit 运行时…';

  @override
  String get updateProgressNotifyingLauncher => '正在通知 Launcher 切换版本…';

  @override
  String get updatePackageMissing => '更新包不存在。';

  @override
  String get updateWindowsOnly => '当前自动更新仅支持 Windows。';

  @override
  String get updateNoNewVersion => '当前没有可安装的新版本。';

  @override
  String get updateAssetInvalid => '更新资产缺少下载地址或有效 SHA-256，已取消自动更新。';

  @override
  String get updateVersionInvalid => '更新版本号包含非法字符。';

  @override
  String updateInstallSuccess(String version) {
    return '新版本 v$version 已准备完成；应用退出后 Launcher 会切换并重启。';
  }

  @override
  String get changelog0100Title => '结构化运行消息、Markdown 指南与安全链接';

  @override
  String get changelog0100ItemMessages =>
      '操作结果、待执行计划和日志改用语义模板，并增加稳定事件 ID、写入时语言和凭据遮蔽。';

  @override
  String get changelog0100ItemMarkdown =>
      '内置指南改为真正的 Markdown 渲染，支持标题、列表、表格、引用、代码块、图片和行内格式。';

  @override
  String get changelog0100ItemLinks =>
      '指南链接仅允许 HTTPS、内置指南和标题锚点，并提供键盘焦点、选择复制和响应式布局。';

  @override
  String get changelog0100ItemTests => '新增三语指南资源、源码防回归检查和完整的结构化消息测试覆盖。';

  @override
  String get changelog099Title => '分支同步、安全快进 Pull 与提交身份预检';

  @override
  String get changelog099ItemSyncStatus => '显示 upstream、ahead、behind 和工作区同步状态。';

  @override
  String get changelog099ItemFetchPlan =>
      '新增当前 upstream 或全部远端 Fetch 计划，并逐项报告结果。';

  @override
  String get changelog099ItemFastForwardPull =>
      '新增仅快进 Pull，拒绝脏工作区、无 upstream 和分叉历史。';

  @override
  String get changelog099ItemGitIdentity => '提交前及执行前检查有效的 Git 作者和提交者身份。';

  @override
  String get guideLanguageEnglish => 'English';

  @override
  String get guideLanguageSimplifiedChinese => '简体中文';

  @override
  String get guideLanguageTraditionalChinese => '繁體中文';

  @override
  String unableToOpenGuideLink(String error) {
    return '无法打开指南链接：$error';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppL10nZhHant extends AppL10nZh {
  AppL10nZhHant() : super('zh_Hant');

  @override
  String get appName => 'Git GUI Expand';

  @override
  String get openRepository => '開啟 Git 儲存庫';

  @override
  String get settings => '設定';

  @override
  String get cancel => '取消';

  @override
  String get saveSettings => '儲存設定';

  @override
  String get aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata =>
      '目前有待執行操作計劃，請先清空或執行後再清除 Git。';

  @override
  String get aWindowsFirstFlutterGraphicalFileWorkspaceForGit =>
      'Windows 優先的 Flutter Git 圖形化檔案工作區。';

  @override
  String get about => '關於';

  @override
  String get aboutInformationDoesNotChangeSettings => '關於資訊不會修改設定';

  @override
  String get acknowledgements => '致謝';

  @override
  String get addClearOperationToPlan => '加入清除計劃';

  @override
  String get addClearToPlan => '加入清空計劃';

  @override
  String get addCloneToPlan => '加入克隆計劃';

  @override
  String get addCommitToPlan => '加入提交計劃';

  @override
  String addDeletionOfItemsToThePlan(String count) {
    return '將刪除 $count 個專案加入計劃';
  }

  @override
  String get addDeletionToPlan => '加入刪除計劃';

  @override
  String get addGitToPath => '將 Git 加入 PATH';

  @override
  String get addPushAllPlan => '加入全部推送計劃';

  @override
  String get addPushAllToThePlan => '將全部推送加入計劃';

  @override
  String addPushOfToThePlan(String branch) {
    return '將推送 $branch 加入計劃';
  }

  @override
  String get addPushToPlan => '加入推送計劃';

  @override
  String addPushToToThePlan(String remote) {
    return '將推送到 $remote 加入計劃';
  }

  @override
  String get addRemote => '新增遠端';

  @override
  String addRemovalOfRemoteToThePlan(String remote) {
    return '將移除遠端配置 $remote 加入計劃';
  }

  @override
  String get addRemovalToPlan => '加入移除計劃';

  @override
  String get addToAddPlan => '加入新增計劃';

  @override
  String get addToPlan => '加入執行計劃';

  @override
  String get addToSystemPath => '加入系統 PATH';

  @override
  String get addToUpdatePlan => '加入修改計劃';

  @override
  String get addToUserPath => '加入使用者 PATH';

  @override
  String
  addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
    String path,
    String url,
  ) {
    return '地址：$url\n目標目錄：$path\n取消不會建立任何檔案，確認計劃後才會再次檢查目標並執行 git clone。';
  }

  @override
  String
  get afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution =>
      '清理後該資料夾會變成普通目錄，仍可用“開啟空白資料夾”重新執行 git init。現在只加入清除計劃；還需要在操作計劃中輸入 CLEAR GIT 並確認執行。';

  @override
  String get ahead => '待推送';

  @override
  String allowedRange(String max, String min) {
    return '允許範圍：$min%–$max%';
  }

  @override
  String alreadyContainsPortablegit(String scope) {
    return '$scope 已包含 PortableGit';
  }

  @override
  String get alsoSaveUntrackedFilesGitStashIncludeUntracked =>
      '同時儲存未跟蹤檔案（git stash --include-untracked）';

  @override
  String andMore(String count) {
    return '以及其他 $count 項';
  }

  @override
  String get appearanceSettings => '外觀設定';

  @override
  String get applicationLogs => '軟體操作日誌';

  @override
  String get applyStash => '應用 Stash';

  @override
  String
  get automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved =>
      '自動更新會從 GitHub 下載 Windows x64 ZIP 並校驗 SHA-256，解壓到 versions/<版本>。應用退出後由 GitGuiExpandLauncher 切換版本並自動重啟；新版本啟動失敗時會回滾。根目錄 userdata 和正在執行的版本不會被覆蓋。';

  @override
  String get back => '返回';

  @override
  String get baseUnit => '基礎單位';

  @override
  String get behind => '待拉取';

  @override
  String get binaryUses1024StepsDecimalUses1000 =>
      '二進位制使用 1024 進位，十進位制使用 1000 進位。';

  @override
  String get bitB => 'bit（b）';

  @override
  String get branchManagement => '分支管理';

  @override
  String get branchSynchronization => '分支同步';

  @override
  String get browseIndependentlyAndMoveAcrossPanes => '獨立瀏覽，跨欄移動';

  @override
  String get browseMoveCopyDeleteCommitAndPushThroughTheGitCli =>
      '透過 Git CLI 完成雙欄瀏覽、移動、複製、刪除、提交與推送。';

  @override
  String
  get browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit =>
      '左右雙欄瀏覽同一儲存庫，勾選、剪下、貼上和重新命名。\n每一步檔案變更都透過 Git，最後填寫說明直接提交。';

  @override
  String get bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense =>
      '內建字型均來自 Google Fonts，使用 SIL Open Font License 並隨程式分發。';

  @override
  String get bundledPortablegit => '內建 PortableGit';

  @override
  String get bundledUiFonts => '軟體內建 UI 字型';

  @override
  String
  get byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts =>
      '預設使用內建的 Noto Sans SC / 思源黑體，也可搜尋系統字型或其他內建字型。';

  @override
  String get byteB => 'Byte（B）';

  @override
  String get byteDisplaysBKibOrKbBitIsMultipliedBy8First =>
      'Byte 顯示 B、KiB 或 KB；bit 會先乘以 8。';

  @override
  String get cancel2 => '取消';

  @override
  String get cancelEditing => '取消編輯';

  @override
  String get changed => '有更改';

  @override
  String changes(String count) {
    return '$count 項變更';
  }

  @override
  String get changesApplyAfterSaving => '設定將在點選儲存後應用到整個軟體';

  @override
  String
  get changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing =>
      '修改系統 PATH 會影響整臺電腦，並請求管理員許可權。取消提權不會修改任何內容。';

  @override
  String get checkAgain => '重新偵測';

  @override
  String get checkForUpdates => '檢查更新';

  @override
  String get checking => '檢查中';

  @override
  String get checking2 => '正在檢查…';

  @override
  String get checkingForGit => '正在偵測 Git…';

  @override
  String get checkingForUpdates => '正在檢查更新';

  @override
  String
  get chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst =>
      '先在檔案區、提交區或遠端管理中選擇操作；所有操作會先進入這裡。';

  @override
  String get chooseCloneParentFolder => '選擇克隆父目錄';

  @override
  String
  get chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors =>
      '選擇顯示模式和配色方案；介面圖示會跟隨目前配色方案變化。';

  @override
  String get chooseFolder => '選擇資料夾';

  @override
  String
  get chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup =>
      '可選擇目前使用者或系統環境變數。只新增軟體管理的 runtime/git/current/cmd，並在修改前自動備份。';

  @override
  String get chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem =>
      '選擇軟體顯示語言。預設跟隨作業系統語言。';

  @override
  String get clean => '乾淨';

  @override
  String get cleanAll => '一鍵清除';

  @override
  String get clearAllRemoteBranchesAndTagsDangerous => '清空遠端全部分支和標籤（危險）';

  @override
  String get clearGitMetadata => '清除 Git 後設資料';

  @override
  String get clearPlan => '清空計劃';

  @override
  String clearRemoteHistoryFor(String remote) {
    return '清空遠端歷史 $remote？';
  }

  @override
  String get clearSearch => '清除搜尋';

  @override
  String get clearSelection => '清除選擇';

  @override
  String get cloneGitRepository => '克隆 Git 儲存庫';

  @override
  String get cloneIntoParentFolder => '克隆到父目錄';

  @override
  String get close => '關閉';

  @override
  String get closeUserGuide => '關閉使用指南';

  @override
  String get closingTheRepository => '關閉儲存庫';

  @override
  String get colorScheme => '配色方案';

  @override
  String get commitMessage => '提交說明';

  @override
  String get commitWorkspace => '提交工作區';

  @override
  String get commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun =>
      '提交不會立即執行。請在待執行操作計劃中確認後，再執行 git add -A 和 git commit。';

  @override
  String get confirmAndExecute => '確認並逐步執行';

  @override
  String get confirmDangerousOperations => '危險操作確認';

  @override
  String get controlHowProjectAndIndividualFileSizesAreDisplayed =>
      '控制專案大小和每個檔案大小的顯示方式。';

  @override
  String get copy => '複製';

  @override
  String
  get createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher =>
      '在目前使用者桌面建立 Git GUI Expand 快捷方式，並透過穩定 Launcher 啟動。';

  @override
  String get createBranch => '建立分支';

  @override
  String get createStash => '建立 Stash';

  @override
  String get current => '目前';

  @override
  String get currentBranch => '目前分支';

  @override
  String currentBranch2(String branch) {
    return '目前分支：$branch';
  }

  @override
  String get currentReleaseHighlights => '目前版本亮點';

  @override
  String currentSelection(String theme) {
    return '目前選擇：$theme';
  }

  @override
  String currentV(String version) {
    return '目前 v$version';
  }

  @override
  String
  currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
    String version,
  ) {
    return '目前版本：$version。只清理舊版本、舊安裝包和舊平鋪程式檔案，不刪除 userdata 資料。';
  }

  @override
  String get cut => '剪下';

  @override
  String get cutCopyRenamePushAndCommit0123456789 =>
      '剪下、複製、重新命名、推送與提交   0123456789';

  @override
  String get dark => '深色';

  @override
  String get delete => '刪除';

  @override
  String get deleteBranch => '刪除分支';

  @override
  String get deleteStash => '刪除 Stash';

  @override
  String get desktopShortcut => '桌面快捷方式';

  @override
  String destinationFolder(String path) {
    return '目標目錄：$path';
  }

  @override
  String
  destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
    String path,
  ) {
    return '目標目錄：$path\n確認後在目標目錄執行 git init，然後開啟該儲存庫。';
  }

  @override
  String get detached => 'detached';

  @override
  String get detachedHead => 'detached HEAD';

  @override
  String get detachedHeadCannotFetchCurrentUpstreamOrPullABranch =>
      '目前處於 detached HEAD，不能 Fetch 目前 upstream 或 Pull。';

  @override
  String get detailedLog => '詳細日誌';

  @override
  String get detectTheGitRuntimeVersionSourceAndExecutableLocation =>
      '偵測 Git 執行時、版本、來源和安裝位置。';

  @override
  String detectionDetails(String error) {
    return '偵測詳情：$error';
  }

  @override
  String get discardPlanAndContinue => '放棄計劃並繼續';

  @override
  String get discardThePendingOperationPlan => '放棄待執行操作計劃？';

  @override
  String get displayMode => '顯示模式';

  @override
  String doesNotContainTheManagedPortablegitPath(String scope) {
    return '$scope 不包含軟體管理的 PortableGit 路徑';
  }

  @override
  String get doesNotExist => '不存在';

  @override
  String get done => '完成';

  @override
  String get doubleClickAFolderClickAPaneToChooseThePasteTarget =>
      '雙擊資料夾進入 · 點選面板切換貼上目標';

  @override
  String get doubleClickAFolderToOpen => '雙擊資料夾進入';

  @override
  String get downloadGit => '下載 Git';

  @override
  String get dualPaneOperations => '雙欄批次操作';

  @override
  String get editRemote => '編輯遠端';

  @override
  String get editUrl => '編輯 URL';

  @override
  String get enterACloneUrlParentFolderAndProjectName => '請填寫克隆地址、父目錄和專案名稱。';

  @override
  String get enterACommitMessage => '填寫本次提交說明…';

  @override
  String enterProjectBranchToConfirm(String confirmation) {
    return '輸入專案全稱/分支“$confirmation”以確認';
  }

  @override
  String enterProjectBranchToConfirmAgain(String confirmation) {
    return '請輸入遠端專案全稱/分支“$confirmation”進行二次確認。';
  }

  @override
  String get executing => '正在執行…';

  @override
  String get executingStepByStep => '正在逐步執行';

  @override
  String get executionComplete => '執行完成';

  @override
  String get executionIncomplete => '執行未全部完成';

  @override
  String get fetchAllRemotes => '取得全部遠端';

  @override
  String get fetchCurrentUpstream => '獲取目前 upstream';

  @override
  String get fileChangesArePendingInTheOperationPlan => '檔案變更尚未執行，請在待執行操作計劃中確認';

  @override
  String get files => '檔案';

  @override
  String
  get filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns =>
      '現在不會刪除檔案。此步驟加入計劃後，必須在“待執行操作計劃”中再次確認，才會使用 git rm 或 git clean 執行。';

  @override
  String get folder => '資料夾';

  @override
  String get followSystem => '跟隨系統';

  @override
  String get followSystemSwitchesWithTheDeviceLightOrDarkAppearance =>
      '跟隨系統會根據裝置目前的深色或淺色外觀自動切換。';

  @override
  String get followTheOperatingSystemWithoutAFixedFamily => '跟隨目前作業系統，不固定字型族';

  @override
  String get font => '字型';

  @override
  String get fontPreview => '字型預覽';

  @override
  String get fontSize => '字型大小';

  @override
  String get forExampleFeatureLogin => '例如 feature/login';

  @override
  String get forExampleOriginGiteeOrGitlab => '例如 origin、gitee、gitlab';

  @override
  String get forExampleTemporarilySaveUnfinishedChanges => '例如 臨時儲存未完成修改';

  @override
  String get forceGitBranchDWhenDeletingAnUnmergedBranch =>
      '刪除未合併分支時強制使用 git branch -D';

  @override
  String foundItemsAndCanBeFreed(String count, String size) {
    return '掃描到 $count 項，可釋放 $size。';
  }

  @override
  String get git => 'Git';

  @override
  String get gitExecutableLocation => 'Git 安裝位置';

  @override
  String get gitGuiExpandFileCommit => 'Git GUI Expand · 檔案提交';

  @override
  String get gitGuiExpandUserGuide => 'Git GUI Expand 使用指南';

  @override
  String
  get gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain =>
      '需要 Git 才能開啟或修改儲存庫。請安裝 Git for Windows，然後點選“重新偵測”。';

  @override
  String get gitIsUnavailableRepositoryActionsAreDisabled =>
      'Git 不可用，儲存庫操作已停用。';

  @override
  String get gitMetadata => 'Git 後設資料';

  @override
  String get gitMvIndexCommit => 'git mv · index · commit';

  @override
  String get gitNotDetected => '未偵測到 Git';

  @override
  String gitRepositories(String count) {
    return '$count 個 Git 儲存庫';
  }

  @override
  String get gitRepository => 'Git 儲存庫';

  @override
  String get gitRepositoryCloned => 'Git 儲存庫已克隆';

  @override
  String get gitRepositoryInitialized => 'Git 儲存庫已初始化';

  @override
  String get gitSettings => 'Git 設定';

  @override
  String get gitSource => 'Git 來源';

  @override
  String get gitVersion => 'Git 版本';

  @override
  String get gitee => 'Gitee';

  @override
  String get github => 'GitHub';

  @override
  String get githubUsuallyProvidesTheInternationalReleaseBuild =>
      'GitHub 更新源通常獲取國際釋出版本。';

  @override
  String get gotIt => '我知道了';

  @override
  String get guide => '指南';

  @override
  String get httpsOrGitHostOwnerRepoGit =>
      'https://... 或 git@host:owner/repo.git';

  @override
  String get iReviewedTheseOperationsAndWantToExecuteThemInOrder =>
      '我已檢查上述操作，確認後立即按順序執行';

  @override
  String get iecBinary => 'IEC 二進位制';

  @override
  String get iecSiOptionalBits => 'IEC / SI，可切換 bit';

  @override
  String get importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation =>
      '重點：所有 Git 修改先進入執行計劃，確認後才執行';

  @override
  String get initializeGitRepository => '初始化 Git 儲存庫';

  @override
  String get installedSystemFont => '系統已安裝字型';

  @override
  String get installing => '正在安裝…';

  @override
  String get interfaceLanguage => '介面語言';

  @override
  String items(String count) {
    return '$count 項';
  }

  @override
  String get language => '語言';

  @override
  String get language2 => '語言設定';

  @override
  String get largeFile => '大檔案';

  @override
  String get lastChecked => '最近偵測';

  @override
  String get leftExplorer => '左側資源';

  @override
  String get light => '淺色';

  @override
  String
  get localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst =>
      '本機分支與 upstream 已分叉。軟體不會自動 Merge 或 Rebase，請先使用外部 Git 處理分叉。';

  @override
  String get logs => '操作日誌';

  @override
  String get mediumFile => '中檔案';

  @override
  String get moreContentBelow => '此頁還有下方內容';

  @override
  String get name => '名稱';

  @override
  String get nativeGitChanges => 'Git 原生變更';

  @override
  String get newBranchNameOrRenamedBranchName => '新分支名稱或重新命名後的名稱';

  @override
  String get newName => '新名稱';

  @override
  String get noBranch => '無分支';

  @override
  String get noBundledFontMatches => '沒有匹配的內建字型';

  @override
  String get noCommittedBranchYet => '尚無可提交分支';

  @override
  String
  get noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere =>
      '還沒有詳細日誌。詳細日誌會記錄選擇、導航和每一條 Git 命令。';

  @override
  String get noFilesHere => '這裡沒有檔案';

  @override
  String get noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents =>
      '還沒有普通日誌。執行開啟儲存庫、檔案操作或提交後會記錄關鍵事件。';

  @override
  String get noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean =>
      '未發現舊版本或舊安裝包，目前目錄已經是乾淨狀態。';

  @override
  String get noPendingOperations => '沒有待執行操作';

  @override
  String get noPendingSteps => '目前沒有待執行步驟';

  @override
  String get noProjectIsOpen => '目前沒有開啟的專案。';

  @override
  String get noRemoteRepositoryWasDetected => '未偵測到任何遠端儲存庫。';

  @override
  String get noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote =>
      '尚未配置遠端儲存庫。請在右側新增 GitHub、Gitee、GitLab 或其他 Git 遠端。';

  @override
  String get noSystemFontMatches => '沒有匹配的系統字型';

  @override
  String get noUpstream => '無 upstream';

  @override
  String get noUsableGitWasDetectedInstallItAndCheckAgain =>
      '未偵測到可用的 Git。安裝後請重新偵測。';

  @override
  String get none => '無';

  @override
  String get normalLog => '普通日誌';

  @override
  String get notCheckedYet => '尚未偵測';

  @override
  String get notConfigured => '未配置';

  @override
  String get notDetected => '未偵測';

  @override
  String nothingIsPushedYetThePlanPushesTo(
    String branch,
    String platform,
    String url,
  ) {
    return '現在不會聯網推送。執行計劃時，將目前分支 $branch 推送到 $platform。\n$url';
  }

  @override
  String
  get nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded =>
      '現在不會聯網推送。執行計劃時，已配置 upstream 會執行 git push；否則優先使用 origin 並設定目前分支的 upstream。';

  @override
  String get oldVersionAndInstallerCleanup => '舊版本與安裝包清理';

  @override
  String get onlineReleaseNotes => '線上釋出說明';

  @override
  String
  get onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath =>
      '只修改目前使用者的 PATH，不需要管理員許可權。軟體只會新增或移除自己管理的穩定執行時路徑。';

  @override
  String get onlyTheLocalGitRemoteConfigurationIsRemoved =>
      '執行計劃時只刪除本機 Git remote 配置，不會刪除遠端平臺上的儲存庫。';

  @override
  String get onlyVerifiedRepositoryRootsAreSaved => '僅儲存驗證成功的儲存庫根目錄';

  @override
  String get open => '開啟';

  @override
  String
  get openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository =>
      '開啟現有儲存庫、初始化空白目錄，或克隆遠端儲存庫';

  @override
  String get openAnotherFolderOrRefreshToViewRepositoryContents =>
      '切換目錄或重新整理以檢視儲存庫內容。';

  @override
  String get openEmptyFolder => '開啟空白資料夾';

  @override
  String get openFolder => '開啟目錄';

  @override
  String get openGitRepository => '開啟 Git 儲存庫';

  @override
  String get openReleasePage => '開啟發布頁';

  @override
  String get openRepository2 => '開啟儲存庫';

  @override
  String get openWithDefaultApp => '用預設開啟方式開啟';

  @override
  String get openingAnotherRepository => '開啟另一個儲存庫';

  @override
  String get openingRepository => '正在讀取儲存庫…';

  @override
  String optionsFound(String count) {
    return '找到 $count 個選項';
  }

  @override
  String get parentFolder => '上一級';

  @override
  String get paste => '貼上';

  @override
  String get pasteTarget => '貼上目標';

  @override
  String get pasteToLeft => '貼上到左側';

  @override
  String get pasteToRight => '貼上到右側';

  @override
  String get pathChangeCancelled => '已取消修改 PATH';

  @override
  String pathChangeFailed(String error) {
    return 'PATH 修改失敗：$error';
  }

  @override
  String pending(String count) {
    return '待執行 $count';
  }

  @override
  String get pending2 => '待提交';

  @override
  String get pendingOperationPlan => '待執行操作計劃';

  @override
  String plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
    String action,
    String count,
  ) {
    return '目前有 $count 步操作尚未執行。$action會清除這些計劃，儲存庫不會發生這些變更。';
  }

  @override
  String get popStash => '彈出 Stash';

  @override
  String get preciseSizeView => '精確大小檢視';

  @override
  String get preparingToExecute => '準備執行';

  @override
  String get preparingUpdate => '正在準備更新…';

  @override
  String get projectFolder => '專案目錄';

  @override
  String get projectFolderName => '專案資料夾名稱';

  @override
  String get projectSize => '專案大小';

  @override
  String projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
    String branch,
    String confirmation,
    String message,
    String project,
    String target,
  ) {
    return '專案：$project\n目標分支：$branch\n目標提交：$target\n空提交說明：$message\n計劃執行確認：$confirmation';
  }

  @override
  String
  get pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex =>
      'Pull 會先 Fetch 並重新檢查 ahead/behind，只允許快進，不會自動建立 Merge 提交；工作區或索引不乾淨時禁止 Pull。';

  @override
  String get push => '推送';

  @override
  String get pushAll => '全部推送';

  @override
  String get pushCurrentBranchCtrlShiftU => '推送目前分支 (Ctrl+Shift+U)';

  @override
  String readingBranchesAndTagsFrom(String remote) {
    return '正在讀取遠端 $remote 的分支和標籤…';
  }

  @override
  String get readingSynchronizationState => '正在讀取同步狀態…';

  @override
  String get recentlyOpened => '最近開啟';

  @override
  String get refresh => '重新整理';

  @override
  String get refreshBranches => '重新整理分支';

  @override
  String get refreshLogs => '重新整理日誌';

  @override
  String get refreshRemotes => '重新整理遠端';

  @override
  String get refreshRepositoryAndRebuildPlan => '重新整理儲存庫並重建計劃';

  @override
  String get refreshRepositoryCtrlR => '重新整理儲存庫 (Ctrl+R)';

  @override
  String get refreshStashes => '重新整理 Stash';

  @override
  String get refreshSynchronizationState => '重新整理同步狀態';

  @override
  String get remoteCheck => '遠端檢查';

  @override
  String get remoteName => '遠端名稱';

  @override
  String get remoteRefList => '遠端引用列表';

  @override
  String remoteRepositoriesWereDetectedSoClearingIsDisabled(String remotes) {
    return '偵測到遠端儲存庫，已禁止清除：$remotes';
  }

  @override
  String get remoteRepositoryUrl => '遠端儲存庫地址';

  @override
  String get remoteUrl => '遠端 URL';

  @override
  String remotes(String count) {
    return '遠端 $count';
  }

  @override
  String get remotes2 => '遠端儲存庫';

  @override
  String get removeFromHistory => '從歷史記錄移除';

  @override
  String get removeFromPlan => '從計劃移除';

  @override
  String get removeFromSystemPath => '從系統 PATH 移除';

  @override
  String get removeFromUserPath => '從使用者 PATH 移除';

  @override
  String get removeLocalRemoteConfiguration => '移除本機遠端配置';

  @override
  String removedItemsAndFreed(String count, String size) {
    return '已清除 $count 項，共釋放 $size。';
  }

  @override
  String removedItemsCouldNotBeDeletedCheckTheDetailedLog(
    String failed,
    String removed,
  ) {
    return '已清除 $removed 項；$failed 項無法刪除，請檢視詳細日誌。';
  }

  @override
  String get rename => '重新命名';

  @override
  String get renameBranch => '重新命名分支';

  @override
  String repository(String path) {
    return '儲存庫：$path';
  }

  @override
  String get repositoryAndRemoteOperationsAreAvailable => '可執行儲存庫與遠端操作';

  @override
  String get repositoryViewRefreshed => '儲存庫檢視已重新整理';

  @override
  String get reviewRemoveOrExecutePendingOperations => '檢視、移除或確認執行所有待處理操作';

  @override
  String get rightExplorer => '右側資源';

  @override
  String get safeFastForwardPull => '安全快進 Pull';

  @override
  String get saveSettings2 => '儲存設定';

  @override
  String get scanAgain => '重新掃描';

  @override
  String get scanOldVersionsAndInstallers => '掃描舊版本與安裝包';

  @override
  String get scrollDownForFontPreviewAndFontSizeSettings =>
      '向下滾動可檢視字型預覽和字型大小設定。';

  @override
  String get searchFontNameOrPurposeEGInterOrNoto => '搜尋字型名稱或用途，例如 Inter、思源、中文';

  @override
  String get selectAnItemToRename => '請先勾選要重新命名的專案。';

  @override
  String get selectExactlyOneItemToRename => '重新命名時只能勾選一個專案。';

  @override
  String get selectFilesToCutOrCopy => '勾選檔案後可剪下或複製';

  @override
  String get selectItemsToDelete => '請先勾選要刪除的項目。';

  @override
  String get selectTheDangerousOperationConfirmationFirst => '請先勾選“我已檢查危險操作”。';

  @override
  String selected(String count) {
    return '已選 $count 項';
  }

  @override
  String selected2(String count) {
    return '已選擇 $count 項';
  }

  @override
  String get settings2 => '設定';

  @override
  String get settingsDataDirectory => '設定資料目錄';

  @override
  String get showInFileExplorer => '用檔案資源開啟';

  @override
  String get siDecimal => 'SI 十進位制';

  @override
  String get size => '大小';

  @override
  String get sizeUnitSystem => '容量單位制';

  @override
  String get smallFile => '小檔案';

  @override
  String get stageAll => '暫存全部';

  @override
  String staged(String count) {
    return '$count 項已暫存';
  }

  @override
  String get stash => 'Stash';

  @override
  String get stashManagement => 'Stash 管理';

  @override
  String get stashMessageOptional => 'Stash 說明（可選）';

  @override
  String get stateChangeDetails => '狀態變化詳情';

  @override
  String get stateChangedBeforeExecution => '執行前狀態已變化';

  @override
  String get status => '狀態';

  @override
  String step(String step, String title) {
    return '第 $step 步：$title';
  }

  @override
  String stepsTheRepositoryIsUnchangedUntilConfirmation(String count) {
    return '共 $count 步；確認前儲存庫不會發生任何改變';
  }

  @override
  String
  get supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst =>
      '支援 GitHub、Gitee、GitLab、Bitbucket 和任意標準 Git 遠端。所有修改會先加入待執行計劃。遠端右側紅色垃圾桶用於清空該遠端全部分支和標籤。';

  @override
  String get switchBranch => '切換分支';

  @override
  String get sync => '同步';

  @override
  String get systemDefaultAutomatic => '系統預設（自動適配）';

  @override
  String get systemFonts => '系統自帶';

  @override
  String get systemGit => '系統 Git';

  @override
  String textCanBeSelectedAndCopiedHereTheFullGuideIsIn(String path) {
    return '可在本視窗中選中並複製文字。完整指南儲存在 $path。';
  }

  @override
  String
  get thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject =>
      '感謝 DeepSeek 人工智慧和 ChatGPT Codex，兩者合力建立、編寫、修改此專案。';

  @override
  String get theCloneDestinationFolderIsNotEmpty => '克隆目標目錄不是空目錄。';

  @override
  String get theCloneDestinationParentFolderDoesNotExist => '克隆目標父目錄不存在。';

  @override
  String
  get theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText =>
      '配色方案會應用到按鈕、選擇狀態、邊框、圖示和強調文字。';

  @override
  String get theCurrentBranchHasNoCommitAndCannotBePulled =>
      '目前分支尚無提交，不能 Pull。';

  @override
  String
  get theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking =>
      '目前分支沒有 upstream。可獲取全部遠端，但 Pull 前需要配置跟蹤分支。';

  @override
  String get theCurrentBranchIsSynchronizedWithUpstream =>
      '目前分支已經與 upstream 同步。';

  @override
  String get theDetailedReasonHasBeenWrittenToTheApplicationLog =>
      '詳細原因已寫入操作日誌。';

  @override
  String get theGiteeSourceIsSuitedToMainlandChinaNetworks =>
      'Gitee 更新源適合中國大陸網路環境。';

  @override
  String
  get theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata =>
      '初始化目標必須存在且不能已經包含 Git 後設資料。';

  @override
  String get theLanguageChangeTakesEffectImmediatelyAfterSaving =>
      '語言更改會在儲存設定後立即生效。';

  @override
  String get theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull =>
      '本機分支有未推送提交，目前不需要 Pull。';

  @override
  String
  get theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone =>
      '下一步只建立克隆操作預覽；取消不會建立任何檔案，確認計劃時才會再次檢查目標目錄並執行 git clone。';

  @override
  String thePlanPushesTo(String branch, String remotes) {
    return '執行計劃時，目前分支 $branch 將依次推送到：\n$remotes';
  }

  @override
  String get theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated =>
      '遠端目前沒有分支或標籤，將直接建立第一個空提交。';

  @override
  String get theRepositoryHasNoStashes => '目前儲存庫沒有 Stash。';

  @override
  String get theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes =>
      '儲存後會應用到選單、資源面板、對話方塊和提交說明。';

  @override
  String get theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull =>
      '工作區或索引不乾淨。請先提交或 Stash 更改，再執行安全 Pull。';

  @override
  String get thereAreNoLocalBranchesToDisplay => '目前沒有可顯示的本機分支。';

  @override
  String get thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation =>
      '此操作只會加入待執行計劃。確認並執行計劃後，軟體才會執行 git mv。';

  @override
  String
  thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
    String branch,
  ) {
    return '這是不可撤銷的高風險操作。軟體會先備份遠端引用，然後把 $branch 強制替換為一個不含檔案的空根提交，刪除其他分支和標籤，並把本機同名分支與索引同步到該空提交。本機檔案不會刪除，重新整理後會顯示為未跟蹤。';
  }

  @override
  String get thisOperationDeletesTheGitFolderInTheRepositoryRoot =>
      '此操作會刪除儲存庫根目錄中的 .git 資料夾。';

  @override
  String
  thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
    String count,
  ) {
    return '此計劃包含 $count 個危險步驟。檔案刪除無法透過本軟體撤銷；清空遠端會替換全部分支歷史，只保留一個空提交併刪除其它分支和標籤。';
  }

  @override
  String get thisProjectIsLicensedUnderTheMitLicense =>
      '本專案使用 MIT License 開源許可證。';

  @override
  String get threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge =>
      '僅在安全範圍內提供三檔，避免出現過小或過大字號導致介面佈局異常。';

  @override
  String today(String time) {
    return '今天 $time';
  }

  @override
  String get turnGitFileOperationsIntoAnIntuitiveWorkspace =>
      '把 Git 檔案操作，\n變成一次直觀的移動。';

  @override
  String get typeANameToFilter => '輸入名稱可快速篩選';

  @override
  String unableToOpenFile(String error) {
    return '無法開啟檔案：$error';
  }

  @override
  String unableToOpenLogsFolder(String error) {
    return '無法開啟日誌目錄：$error';
  }

  @override
  String unableToOpenProjectFolder(String error) {
    return '無法開啟專案目錄：$error';
  }

  @override
  String unableToOpenTheGitDownloadPage(String error) {
    return '無法開啟 Git 下載頁面：$error';
  }

  @override
  String get unableToReadBranchSynchronizationStateRefreshAndTryAgain =>
      '無法讀取分支同步狀態。請重新整理後重試。';

  @override
  String get unableToReadFolder => '無法讀取目錄';

  @override
  String unableToReadUserGuide(String error) {
    return '無法讀取使用指南：$error';
  }

  @override
  String get unableToRetrieveTheOnlineVersion => '暫時無法獲取線上版本';

  @override
  String get unitPreview => '單位預覽';

  @override
  String get units => '單位設定';

  @override
  String get unstage => '取消暫存';

  @override
  String get updateAndRestartNow => '立即更新並重啟';

  @override
  String get updateSource => '更新源';

  @override
  String updated(String scope) {
    return '已更新 $scope';
  }

  @override
  String get updates => '更新';

  @override
  String get updatesAndReleaseNotes => '更新與釋出日誌';

  @override
  String get updating => '更新中';

  @override
  String get updatingAutomatically => '正在自動更新';

  @override
  String get upstream => 'upstream';

  @override
  String
  usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
    String platform,
  ) {
    return '$platform 的預設分支通常受保護。如果伺服器拒絕強制更新或刪除，整個原子操作不會刪除任何引用；需要先在託管平臺臨時解除預設分支保護。';
  }

  @override
  String get versionNotFoundOrUnreadable => '未找到或無法讀取版本';

  @override
  String versionV(String version) {
    return '版本 v$version';
  }

  @override
  String versionVIsAvailable(String version) {
    return '發現新版本 v$version';
  }

  @override
  String get viewAndManageAllRemotes => '檢視和管理全部遠端儲存庫';

  @override
  String get viewBranchSynchronization => '檢視分支同步狀態';

  @override
  String get viewLogs => '檢視日誌';

  @override
  String
  get workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks =>
      '工作檔案不會被刪除，但以下 Git 內容會永久丟失：\n• 全部提交歷史和 reflog\n• 本機分支、標籤和目前分支狀態\n• 暫存索引、Stash、未被工作檔案保留的已提交內容\n• 引用、遠端配置以及儲存庫級 Git 配置和 hooks';

  @override
  String get workingTreeClean => '工作區乾淨，沒有待提交的更改';

  @override
  String get worktree => '工作區';

  @override
  String get youAreUpToDate => '已經是最新版本';

  @override
  String get followSystemLabel => '跟隨系統';

  @override
  String get followSystemDescription => '使用作業系統設定的語言。';

  @override
  String get languageEnglishOptionLabel => 'English';

  @override
  String get languageEnglishDescription => '使用英文顯示軟體介面。';

  @override
  String get languageSimplifiedChineseOptionLabel => '简体中文';

  @override
  String get languageSimplifiedChineseDescription => '使用简体中文显示软件界面。';

  @override
  String get languageTraditionalChineseOptionLabel => '繁體中文';

  @override
  String get languageTraditionalChineseDescription => '使用繁體中文顯示軟體介面。';

  @override
  String get userPath => '使用者 PATH';

  @override
  String get systemPath => '系統 PATH';

  @override
  String addPortableGitTo(String scope) {
    return '將 PortableGit 加入 $scope';
  }

  @override
  String removePortableGitFrom(String scope) {
    return '從 $scope 移除 PortableGit';
  }

  @override
  String get confirmAdd => '確認加入';

  @override
  String get confirmRemove => '確認移除';

  @override
  String get gitAvailable => 'Git 可用';

  @override
  String get gitUnavailable => 'Git 無法使用';

  @override
  String get creatingShortcut => '正在建立捷徑…';

  @override
  String get oneClickSendToDesktop => '一鍵傳送到桌面';

  @override
  String get bundledLabel => '內建';

  @override
  String get iec1024BaseBit => 'IEC · 1024 進位 · bit';

  @override
  String get si1000BaseBit => 'SI · 1000 進位 · bit';

  @override
  String get iec1024BaseByte => 'IEC · 1024 進位 · Byte';

  @override
  String get si1000BaseByte => 'SI · 1000 進位 · Byte';

  @override
  String get classicGreen => '經典綠';

  @override
  String get oceanBlue => '海洋藍';

  @override
  String get starryViolet => '星夜紫';

  @override
  String get amberGold => '琥珀金';

  @override
  String get roseRed => '玫瑰紅';

  @override
  String get interUiDescription => '專為數位介面設計的開源無襯線字型，適合工具列和高密度正文。';

  @override
  String get notoSansScDescription => '涵蓋簡體中文的現代介面字型，中英文混排清晰、字形穩定。';

  @override
  String get ibmPlexSansDescription => '為產品介面和企業資訊設計，數字與英文閱讀性突出。';

  @override
  String get fontDescription => '軟體內建介面字型';

  @override
  String get operationCompleted => '操作已完成。';

  @override
  String operationCompletedFor(String target) {
    return '操作已完成：$target。';
  }

  @override
  String operationCompletedForItems(String count) {
    return '已完成 $count 項操作。';
  }

  @override
  String operationFailed(String error) {
    return '操作失敗：$error';
  }

  @override
  String operationFailedFor(String error, String target) {
    return '$target 操作失敗：$error';
  }

  @override
  String logInfo(String eventId) {
    return '資訊事件：$eventId';
  }

  @override
  String logDetail(String eventId) {
    return '詳細事件：$eventId';
  }

  @override
  String logWarning(String eventId) {
    return '警告事件：$eventId';
  }

  @override
  String logError(String eventId) {
    return '錯誤事件：$eventId';
  }

  @override
  String get logsTruncated => '… 僅顯示最近日誌 …';

  @override
  String logReadFailed(String error) {
    return '讀取日誌失敗：$error';
  }

  @override
  String get noRepositoryOpen => '目前沒有開啟的儲存庫。';

  @override
  String get operationInProgress => '目前仍有操作正在執行。';

  @override
  String get emptyOperationPlan => '執行計畫為空。';

  @override
  String get gitUnavailableHelp => '未偵測到可用的 Git。請先安裝 Git，或在設定中重新偵測。';

  @override
  String get selectItemsFirst => '請先勾選檔案或資料夾。';

  @override
  String get clipboardEmpty => '剪貼簿為空。';

  @override
  String get clipboardCleared => '已清空剪貼簿。';

  @override
  String clipboardPendingCut(String count) {
    return '待移動 $count 項';
  }

  @override
  String clipboardPendingCopy(String count) {
    return '待複製 $count 項';
  }

  @override
  String get operationPlanBusyEdit => '操作計畫正在執行，暫時不能修改。';

  @override
  String get operationPlanBusyClear => '操作計畫正在執行，暫時不能清空。';

  @override
  String get planOperationMissing => '待執行操作不存在。';

  @override
  String get planOperationRemoved => '已從執行計畫移除該操作。';

  @override
  String planCleared(String count) {
    return '已清空 $count 步待執行操作。';
  }

  @override
  String planStrongConfirmationRequired(String confirmation) {
    return '請準確輸入 $confirmation 以確認危險操作。';
  }

  @override
  String get planDangerousAcknowledgmentRequired => '請先勾選危險操作確認項。';

  @override
  String get planStateChanged => '儲存庫狀態與確認預覽不一致，已停止執行。請重新整理並重新建立操作計畫。';

  @override
  String planStepStateChanged(String step) {
    return '執行到第 $step 步前發現儲存庫狀態已被修改，已停止。請重新整理並重新建立操作計畫。';
  }

  @override
  String planStepFailed(String error, String step) {
    return '第 $step 步失敗：$error。後續步驟尚未執行，失敗步驟仍保留在計畫中。';
  }

  @override
  String planExecutionComplete(String count) {
    return '已依序執行全部 $count 步操作。';
  }

  @override
  String get planOperationAdded => '已加入待執行操作計畫；尚未執行任何 Git 變更。';

  @override
  String planSnapshotFailed(String error) {
    return '無法建立操作預覽的安全狀態快照：$error';
  }

  @override
  String get clearRemoteMustRunAlone => '清空遠端必須單獨執行。請先移除或執行計畫中的其他步驟。';

  @override
  String get commitMustRemainLast => '提交步驟已加入計畫末尾。若要繼續修改檔案，請先移除提交步驟。';

  @override
  String get exclusiveOperationMustRunAlone => '此生命週期操作必須單獨執行。';

  @override
  String get exclusiveOperationAlreadyQueued => '目前計畫已包含必須單獨執行的操作。';

  @override
  String get renameSelectOne => '重新命名時請只勾選一個檔案或資料夾。';

  @override
  String get nameCannotBeEmpty => '名稱不能為空。';

  @override
  String get historyEntryRemoved => '已從最近儲存庫歷史中移除。';

  @override
  String get gitMetadataClearAvailable => '目前儲存庫沒有設定遠端，可以清除 Git 中繼資料。';

  @override
  String get gitMetadataCleared => 'Git 中繼資料已清除，工作檔案仍然保留。';

  @override
  String get gitMetadataRemoteForbidden => '目前儲存庫已連線遠端，禁止清除 Git 中繼資料。';

  @override
  String fileRenamed(String name) {
    return '已重新命名為 $name。';
  }

  @override
  String get bootstrapPlanAlreadyUsed => '此操作已經執行或正在執行，請重新開啟預覽。';

  @override
  String get bootstrapStateChanged => '目標狀態與確認預覽不一致，已停止執行。請重新整理預覽後重新確認。';

  @override
  String get unableToInspectRepository => '無法檢查儲存庫。';

  @override
  String stepsCount(String count) {
    return '$count 步';
  }

  @override
  String get planKindInitialize => '初始化';

  @override
  String get planKindClone => '複製儲存庫';

  @override
  String get planKindMove => '移動';

  @override
  String get planKindCopy => '複製';

  @override
  String get planKindRename => '重新命名';

  @override
  String get planKindDelete => '刪除';

  @override
  String get planKindClearGitMetadata => '清除 Git 中繼資料';

  @override
  String get planKindStageAll => '暫存';

  @override
  String get planKindUnstageAll => '取消暫存';

  @override
  String get planKindCommit => '提交';

  @override
  String get planKindFetchCurrent => '取得 upstream';

  @override
  String get planKindFetchAll => '取得全部遠端';

  @override
  String get planKindPull => '快進 Pull';

  @override
  String get planKindPush => '推送';

  @override
  String get planKindPushAll => '全部推送';

  @override
  String get planKindAddRemote => '新增遠端';

  @override
  String get planKindUpdateRemote => '修改遠端';

  @override
  String get planKindRemoveRemote => '移除遠端';

  @override
  String get planKindClearRemote => '清空遠端';

  @override
  String get planKindCreateBranch => '建立分支';

  @override
  String get planKindSwitchBranch => '切換分支';

  @override
  String get planKindRenameBranch => '重新命名分支';

  @override
  String get planKindDeleteBranch => '刪除分支';

  @override
  String get planKindCreateStash => '建立 Stash';

  @override
  String get planKindApplyStash => '套用 Stash';

  @override
  String get planKindPopStash => '彈出 Stash';

  @override
  String get planKindDropStash => '刪除 Stash';

  @override
  String get planTitleInitializeRepository => '初始化 Git 儲存庫';

  @override
  String planDescriptionInitializeRepository(String path) {
    return '確認後在 $path 執行 git init，然後開啟該儲存庫。';
  }

  @override
  String get planTitleCloneRepository => '複製 Git 儲存庫';

  @override
  String planDescriptionCloneRepository(String path, String url) {
    return '把 $url 複製到 $path。取消不會建立內容；確認後會重新檢查目標並執行 git clone。';
  }

  @override
  String planTitleMove(String count, String destination) {
    return '移動 $count 項到 $destination';
  }

  @override
  String planDescriptionMove(String count, String destination) {
    return '使用 Git 將 $count 個項目移動到 $destination。';
  }

  @override
  String planTitleCopy(String count, String destination) {
    return '複製 $count 項到 $destination';
  }

  @override
  String planDescriptionCopy(String count, String destination) {
    return '使用 Git 將 $count 個項目複製到 $destination。';
  }

  @override
  String planTitleRename(String source) {
    return '重新命名 $source';
  }

  @override
  String planDescriptionRename(String newName, String source) {
    return '把 $source 的名稱改為 $newName。';
  }

  @override
  String planTitleDelete(String count) {
    return '刪除 $count 個項目';
  }

  @override
  String planDescriptionDelete(String count, String paths) {
    return '將永久刪除 $count 個項目：$paths。已追蹤內容使用 git rm，未追蹤或忽略內容使用 git clean。';
  }

  @override
  String get planTitleClearGitMetadata => '清除 Git 中繼資料';

  @override
  String planDescriptionClearGitMetadata(String path) {
    return '儲存庫：$path。將永久刪除 .git 並保留工作檔案。提交歷史、分支、標籤、索引、Stash、遠端設定和儲存庫層級設定都會遺失。此操作必須單獨執行。';
  }

  @override
  String planTitleCreateBranch(String branch) {
    return '建立分支 $branch';
  }

  @override
  String planDescriptionCreateBranch(String branch) {
    return '執行 git branch -- $branch，從目前 HEAD 建立本機分支。';
  }

  @override
  String branchCreated(String branch) {
    return '已建立分支 $branch。';
  }

  @override
  String planTitleSwitchBranch(String branch) {
    return '切換到分支 $branch';
  }

  @override
  String planDescriptionSwitchBranch(String branch) {
    return '執行 git switch $branch。未提交修改發生衝突時 Git 會拒絕切換。';
  }

  @override
  String branchSwitched(String branch) {
    return '已切換到分支 $branch。';
  }

  @override
  String alreadyOnBranch(String branch) {
    return '已經位於分支 $branch。';
  }

  @override
  String planTitleRenameBranch(String from, String to) {
    return '重新命名分支 $from 為 $to';
  }

  @override
  String planDescriptionRenameBranch(String from, String to) {
    return '執行 git branch -m $from $to。';
  }

  @override
  String branchRenamed(String from, String to) {
    return '已把分支 $from 重新命名為 $to。';
  }

  @override
  String planTitleDeleteBranch(String branch) {
    return '刪除分支 $branch';
  }

  @override
  String planDescriptionDeleteBranchForce(String branch) {
    return '執行 git branch -D $branch，強制刪除未合併分支。';
  }

  @override
  String planDescriptionDeleteBranchSafe(String branch) {
    return '執行 git branch -d $branch，僅允許刪除已合併分支。';
  }

  @override
  String branchDeleted(String branch) {
    return '已刪除分支 $branch。';
  }

  @override
  String get cannotDeleteCurrentBranch => '不能刪除目前分支，請先切換到其他分支。';

  @override
  String get planTitleCreateStash => '建立 Stash';

  @override
  String planTitleCreateStashNamed(String message) {
    return '建立 Stash：$message';
  }

  @override
  String planDescriptionCreateStash(String message) {
    return '執行 git stash push，提交說明為：$message';
  }

  @override
  String planDescriptionCreateStashIncludeUntracked(String message) {
    return '執行 git stash push --include-untracked，提交說明為：$message';
  }

  @override
  String get stashCreated => 'Stash 已建立。';

  @override
  String planTitleApplyStash(String selector) {
    return '套用 $selector';
  }

  @override
  String planDescriptionApplyStash(String selector) {
    return '執行 git stash apply $selector，並保留 Stash 記錄。';
  }

  @override
  String stashApplied(String selector) {
    return '已套用 $selector。';
  }

  @override
  String planTitlePopStash(String selector) {
    return '彈出 $selector';
  }

  @override
  String planDescriptionPopStash(String selector) {
    return '執行 git stash pop $selector，套用後刪除該 Stash。';
  }

  @override
  String stashPopped(String selector) {
    return '已彈出 $selector。';
  }

  @override
  String planTitleDropStash(String selector) {
    return '刪除 $selector';
  }

  @override
  String planDescriptionDropStash(String selector) {
    return '執行 git stash drop $selector，此操作無法透過本軟體復原。';
  }

  @override
  String stashDropped(String selector) {
    return '已刪除 $selector。';
  }

  @override
  String get invalidStashSelector => 'Stash 選擇器無效。';

  @override
  String get planTitlePushCurrent => '推送目前分支';

  @override
  String planTitlePushBranch(String branch) {
    return '推送 $branch';
  }

  @override
  String get planDescriptionPushCurrent =>
      '把目前分支推送到 upstream；沒有 upstream 時使用 origin 或首個遠端並設定追蹤關係。';

  @override
  String planTitleFetchRemote(String remote) {
    return '取得遠端 $remote';
  }

  @override
  String planDescriptionFetchRemote(String remote) {
    return '執行 git fetch --prune $remote；更新遠端追蹤參照，不修改工作區檔案。';
  }

  @override
  String planTitleFetchAllRemotes(String count) {
    return '取得全部 $count 個遠端';
  }

  @override
  String planDescriptionFetchAllRemotes(String remotes) {
    return '依序為以下遠端執行 git fetch --prune：$remotes。失敗項目會逐項回報。';
  }

  @override
  String remoteFetched(String remote) {
    return '已取得遠端 $remote 的更新。';
  }

  @override
  String allRemotesFetched(String count) {
    return '已取得全部 $count 個遠端。';
  }

  @override
  String remoteBatchPartialFailure(
    String details,
    String failed,
    String succeeded,
  ) {
    return '成功 $succeeded 個，失敗 $failed 個。詳情：$details';
  }

  @override
  String get syncStateUnavailable => '無法讀取目前分支同步狀態。';

  @override
  String get detachedCannotPull => '目前處於 detached HEAD，不能 Pull 分支。';

  @override
  String get unbornCannotPull => '目前分支尚無提交，不能 Pull。';

  @override
  String get upstreamMissing => '目前分支沒有可用的 upstream，請先設定遠端追蹤分支。';

  @override
  String get dirtyWorktreeCannotPull => '工作區或索引不乾淨，請先提交或 Stash 變更再 Pull。';

  @override
  String get pullUpToDate => '目前分支已經與 upstream 同步。';

  @override
  String get pullAhead => '目前分支包含 upstream 的全部提交，但有本機提交未推送。';

  @override
  String get pullDiverged => '本機分支與 upstream 已分叉，請先使用外部 Git 執行 Merge 或 Rebase。';

  @override
  String get pullRelationUnknown => '目前分支同步關係未知。';

  @override
  String get pullNoUpdate => '目前無需快進更新。';

  @override
  String planTitlePull(String branch) {
    return '安全快進 Pull $branch';
  }

  @override
  String planDescriptionPull(String branch, String remote, String upstream) {
    return '先從 $remote 取得更新並重新檢查 ahead/behind；僅在 $branch 落後且未分叉時執行 git merge --ff-only $upstream，不會自動建立 Merge 提交。';
  }

  @override
  String pullCompleted(String branch, String upstream) {
    return '已快進更新 $branch 到 $upstream。';
  }

  @override
  String syncAuthenticationFailed(String error) {
    return 'Git 驗證失敗：$error';
  }

  @override
  String syncNetworkFailed(String error) {
    return 'Git 網路存取失敗：$error';
  }

  @override
  String get pushedCurrentBranch => '已推送目前分支。';

  @override
  String pushedBranch(String branch) {
    return '已推送 $branch。';
  }

  @override
  String get noRemotesConfigured => '專案沒有設定遠端儲存庫。';

  @override
  String get remoteListRefreshed => '遠端清單已重新整理。';

  @override
  String planTitleAddRemote(String remote) {
    return '新增遠端 $remote';
  }

  @override
  String planDescriptionAddRemote(String remote, String url) {
    return '新增遠端 $remote，位址為 $url。';
  }

  @override
  String planTitleUpdateRemote(String remote) {
    return '修改遠端 $remote';
  }

  @override
  String planDescriptionUpdateRemote(String remote, String url) {
    return '把遠端 $remote 的位址改為 $url。';
  }

  @override
  String remoteAdded(String remote) {
    return '已新增遠端 $remote。';
  }

  @override
  String remoteUpdated(String remote) {
    return '已更新遠端 $remote。';
  }

  @override
  String remoteRemoved(String remote) {
    return '已刪除遠端 $remote。';
  }

  @override
  String planTitleRemoveRemote(String remote) {
    return '刪除遠端設定 $remote';
  }

  @override
  String get planDescriptionRemoveRemote =>
      '僅刪除本儲存庫中的 Git remote 設定，不會刪除遠端平台上的儲存庫。';

  @override
  String planTitlePushRemote(String remote) {
    return '推送到遠端 $remote';
  }

  @override
  String planDescriptionPushRemote(String branch, String remote) {
    return '把分支 $branch 推送到遠端 $remote。';
  }

  @override
  String pushedToRemote(String remote) {
    return '已推送到 $remote。';
  }

  @override
  String planTitlePushAllRemotes(String count) {
    return '推送到全部 $count 個遠端';
  }

  @override
  String planDescriptionPushAllRemotes(String remotes) {
    return '依序把目前分支推送到：$remotes。';
  }

  @override
  String pushedToAllRemotes(String count) {
    return '已推送到全部 $count 個遠端。';
  }

  @override
  String remoteInspectionEmpty(String remote) {
    return '遠端 $remote 目前沒有分支或標籤。';
  }

  @override
  String remoteInspectionCounts(String branches, String remote, String tags) {
    return '遠端 $remote 有 $branches 個分支、$tags 個標籤。';
  }

  @override
  String planTitleClearRemote(String remote) {
    return '清空遠端歷史 $remote';
  }

  @override
  String planDescriptionClearRemote(
    String branch,
    String branches,
    String message,
    String project,
    String tags,
  ) {
    return '專案 $project，目標分支 $branch。將備份並刪除 $branches 個分支和 $tags 個標籤，然後只保留一個空提交：「$message」。本機檔案保留，但本機索引會重設為空，重新整理後檔案顯示為未追蹤。';
  }

  @override
  String clearRemoteCompleted(String branch, String commit, String remote) {
    return '已清空遠端 $remote。$branch 現指向空提交 $commit；本機檔案保留並顯示為未追蹤。';
  }

  @override
  String clearRemoteDrift(
    String branches,
    String error,
    String remote,
    String tags,
  ) {
    return '遠端 $remote 的參照在確認後發生變化，已停止清空。目前有 $branches 個分支和 $tags 個標籤。$error';
  }

  @override
  String get planTitleStageAll => '暫存全部變更';

  @override
  String get planDescriptionStageAll => '執行 git add -A，將目前全部變更加入 Git 索引。';

  @override
  String get stageAllCompleted => '已暫存全部變更。';

  @override
  String get planTitleUnstageAll => '取消暫存全部變更';

  @override
  String get planDescriptionUnstageAll => '把 Git 索引還原到 HEAD，同時保留工作區檔案。';

  @override
  String get unstageAllCompleted => '已取消暫存全部變更。';

  @override
  String get planTitleCommitAll => '提交全部變更';

  @override
  String planDescriptionCommitAll(String message) {
    return '提交說明：$message。執行時先執行 git add -A，再執行 git commit。';
  }

  @override
  String get commitMessageRequired => '請填寫提交說明。';

  @override
  String get noChangesToCommit => '沒有可提交的變更。';

  @override
  String get commitAlreadyQueued => '執行計畫中已經有提交步驟。';

  @override
  String get commitIdentityUnavailable =>
      'Git 作者和提交者身分不可用。請設定 user.name 和 user.email 後重試。';

  @override
  String get commitSucceeded => '提交已建立。';

  @override
  String get settingsSaved => '設定已儲存。';

  @override
  String get desktopShortcutWindowsOnly => '桌面捷徑目前僅支援 Windows。';

  @override
  String desktopShortcutCreated(String path) {
    return '已建立桌面捷徑：$path';
  }

  @override
  String get maintenanceKindOldVersion => '舊版本目錄';

  @override
  String get maintenanceKindUpdateArchive => '更新安裝包';

  @override
  String get maintenanceKindPartialDownload => '未完成下載';

  @override
  String get maintenanceKindStagingDirectory => '臨時解壓目錄';

  @override
  String get maintenanceKindLegacyUpdater => '舊更新指令碼';

  @override
  String get maintenanceKindLegacyFlatFile => '舊平鋪程式檔案';

  @override
  String get maintenanceKindLegacyFlatDirectory => '舊平鋪程式目錄';

  @override
  String get maintenanceKindObsoleteGitRuntime => '舊 PortableGit 執行階段';

  @override
  String get maintenanceKindGitRuntimeArchive => 'PortableGit 更新包';

  @override
  String get maintenanceKindGitRuntimeStaging => 'PortableGit 暫存目錄';

  @override
  String get driftRepositoryRoot => '儲存庫根目錄';

  @override
  String get driftBranch => '分支';

  @override
  String get driftHead => 'HEAD';

  @override
  String get driftStatus => '工作區狀態';

  @override
  String get driftRemotes => '遠端設定';

  @override
  String get driftPathType => '路徑類型';

  @override
  String get driftDestinationParent => '父目錄';

  @override
  String get driftDestinationExists => '目標是否存在';

  @override
  String get driftDestinationEmpty => '目標是否為空';

  @override
  String get driftGitMetadata => 'Git 中繼資料';

  @override
  String get driftSource => '來源';

  @override
  String get driftRemoteName => '遠端名稱';

  @override
  String get driftRemoteTargetBranch => '目標分支';

  @override
  String get driftRemoteRefs => '遠端參照';

  @override
  String get updateGithubNoRelease => '儲存庫暫未發布公開的 GitHub Release，可開啟發布頁查看。';

  @override
  String get updateGiteeNoRelease => '儲存庫暫未發布公開的 Gitee Release，可開啟發布頁查看。';

  @override
  String updateHttpError(String platform, String status) {
    return '$platform 傳回 HTTP $status，請稍後重試。';
  }

  @override
  String get updateInvalidResponseGithub => 'GitHub 更新描述格式無法辨識。';

  @override
  String get updateInvalidResponseGitee => 'Gitee 更新描述格式無法辨識。';

  @override
  String get updateVersionMissingGithub => 'GitHub 公開 Release 沒有可辨識的版本號。';

  @override
  String get updateVersionMissingGitee => 'Gitee 公開 Release 沒有可辨識的版本號。';

  @override
  String get updateAssetMissingGithub =>
      '發現新版本，但 Release 缺少帶 SHA-256 的 Windows x64 ZIP。';

  @override
  String get updateAvailableGithub => '發現可用的新版本，可直接下載、驗證並自動重新啟動更新。';

  @override
  String get updateAvailableGitee => '發現可用的 Gitee 新版本，可直接下載、驗證並自動重新啟動更新。';

  @override
  String updateUpToDate(String version) {
    return '目前版本 v$version 已是 GitHub 最新版本。';
  }

  @override
  String updateGiteeUpToDate(String version) {
    return '目前版本 v$version 已是 Gitee 最新版本。';
  }

  @override
  String get updateNetworkUnavailableGithub => '無法連線 GitHub，請檢查網路後重試。';

  @override
  String get updateNetworkUnavailableGitee => '無法連線 Gitee，請檢查網路後重試。';

  @override
  String get updateRequestFailed => '網路請求失敗，請稍後重試。';

  @override
  String get updateGiteeRequestFailed => 'Gitee 網路請求失敗，請稍後重試。';

  @override
  String get updateGiteeDigestMissing =>
      '發現 Gitee 新版本，但無法從 GitHub 資產中繼資料取得可信 SHA-256，已停用自動安裝。可開啟發布頁手動下載。';

  @override
  String get updateProgressPreparing => '正在準備自動更新…';

  @override
  String get updateProgressConnecting => '正在連線 Release 下載更新…';

  @override
  String updateProgressDownloading(String asset) {
    return '正在下載 $asset…';
  }

  @override
  String get updateProgressVerifying => '正在驗證更新包 SHA-256…';

  @override
  String get updateProgressExtracting => '正在解壓到獨立版本目錄…';

  @override
  String get updateProgressVerifyingRuntime => '正在驗證安裝包中的 PortableGit 執行階段…';

  @override
  String get updateProgressNotifyingLauncher => '正在通知 Launcher 切換版本…';

  @override
  String get updatePackageMissing => '更新包不存在。';

  @override
  String get updateWindowsOnly => '目前自動更新僅支援 Windows。';

  @override
  String get updateNoNewVersion => '目前沒有可安裝的新版本。';

  @override
  String get updateAssetInvalid => '更新資產缺少下載位址或有效 SHA-256，已取消自動更新。';

  @override
  String get updateVersionInvalid => '更新版本號包含非法字元。';

  @override
  String updateInstallSuccess(String version) {
    return '新版本 v$version 已準備完成；應用程式結束後 Launcher 會切換並重新啟動。';
  }

  @override
  String get changelog0100Title => '結構化執行訊息、Markdown 指南與安全連結';

  @override
  String get changelog0100ItemMessages =>
      '操作結果、待執行計畫和日誌改用語意範本，並加入穩定事件 ID、寫入時語言和憑證遮蔽。';

  @override
  String get changelog0100ItemMarkdown =>
      '內建指南改為真正的 Markdown 呈現，支援標題、清單、表格、引用、程式碼區塊、圖片和行內格式。';

  @override
  String get changelog0100ItemLinks =>
      '指南連結僅允許 HTTPS、內建指南和標題錨點，並提供鍵盤焦點、選取複製和響應式版面。';

  @override
  String get changelog0100ItemTests => '新增三語指南資源、原始碼防回歸檢查和完整的結構化訊息測試涵蓋。';

  @override
  String get changelog099Title => '分支同步、安全快進 Pull 與提交身分預檢';

  @override
  String get changelog099ItemSyncStatus => '顯示 upstream、ahead、behind 和工作區同步狀態。';

  @override
  String get changelog099ItemFetchPlan =>
      '新增目前 upstream 或全部遠端 Fetch 計畫，並逐項回報結果。';

  @override
  String get changelog099ItemFastForwardPull =>
      '新增僅快進 Pull，拒絕髒工作區、無 upstream 和分叉歷史。';

  @override
  String get changelog099ItemGitIdentity => '提交前及執行前檢查有效的 Git 作者和提交者身分。';

  @override
  String get guideLanguageEnglish => 'English';

  @override
  String get guideLanguageSimplifiedChinese => '简体中文';

  @override
  String get guideLanguageTraditionalChinese => '繁體中文';

  @override
  String unableToOpenGuideLink(String error) {
    return '無法開啟指南連結：$error';
  }
}
