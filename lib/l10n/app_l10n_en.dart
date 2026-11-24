// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Git GUI Expand';

  @override
  String get openRepository => 'Open Git repository';

  @override
  String get settings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveSettings => 'Save settings';

  @override
  String get aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata =>
      'A plan is pending. Clear or execute it before removing Git metadata.';

  @override
  String get aWindowsFirstFlutterGraphicalFileWorkspaceForGit =>
      'A Windows-first Flutter graphical file workspace for Git.';

  @override
  String get about => 'About';

  @override
  String get aboutInformationDoesNotChangeSettings =>
      'About information does not change settings.';

  @override
  String get acknowledgements => 'Acknowledgements';

  @override
  String get addClearOperationToPlan => 'Add clear operation to plan';

  @override
  String get addClearToPlan => 'Add clear to plan';

  @override
  String get addCloneToPlan => 'Add clone to plan';

  @override
  String get addCommitToPlan => 'Add commit to plan';

  @override
  String addDeletionOfItemsToThePlan(String count) {
    return 'Add deletion of $count items to the plan';
  }

  @override
  String get addDeletionToPlan => 'Add deletion to plan';

  @override
  String get addGitToPath => 'Add Git to PATH';

  @override
  String get addPushAllPlan => 'Add push-all plan';

  @override
  String get addPushAllToThePlan => 'Add push-all to the plan';

  @override
  String addPushOfToThePlan(String branch) {
    return 'Add push of $branch to the plan';
  }

  @override
  String get addPushToPlan => 'Add push to plan';

  @override
  String addPushToToThePlan(String remote) {
    return 'Add push to $remote to the plan';
  }

  @override
  String get addRemote => 'Add remote';

  @override
  String addRemovalOfRemoteToThePlan(String remote) {
    return 'Add removal of remote $remote to the plan';
  }

  @override
  String get addRemovalToPlan => 'Add removal to plan';

  @override
  String get addToAddPlan => 'Add to add plan';

  @override
  String get addToPlan => 'Add to plan';

  @override
  String get addToSystemPath => 'Add to system PATH';

  @override
  String get addToUpdatePlan => 'Add to update plan';

  @override
  String get addToUserPath => 'Add to user PATH';

  @override
  String
  addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
    String path,
    String url,
  ) {
    return 'Address: $url\nDestination folder: $path\nCancel creates nothing. Confirming the plan rechecks the destination and runs git clone.';
  }

  @override
  String
  get afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution =>
      'After cleanup the folder becomes an ordinary directory that can be initialized again from Open empty folder. This now only adds a clear step; enter CLEAR GIT in the operation plan and confirm execution.';

  @override
  String get ahead => 'Ahead';

  @override
  String allowedRange(String max, String min) {
    return 'Allowed range: $min%–$max%';
  }

  @override
  String alreadyContainsPortablegit(String scope) {
    return '$scope already contains PortableGit';
  }

  @override
  String get alsoSaveUntrackedFilesGitStashIncludeUntracked =>
      'Also save untracked files (git stash --include-untracked)';

  @override
  String andMore(String count) {
    return 'and $count more';
  }

  @override
  String get appearanceSettings => 'Appearance settings';

  @override
  String get applicationLogs => 'Application logs';

  @override
  String get applyStash => 'Apply Stash';

  @override
  String
  get automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved =>
      'Automatic updates download the Windows x64 ZIP from GitHub, verify SHA-256 and extract it into versions/<version>. The Launcher switches versions after exit and rolls back if startup fails. userdata is preserved.';

  @override
  String get back => 'Back';

  @override
  String get baseUnit => 'Base unit';

  @override
  String get behind => 'Behind';

  @override
  String get binaryUses1024StepsDecimalUses1000 =>
      'Binary uses 1024 steps; decimal uses 1000.';

  @override
  String get bitB => 'bit (b)';

  @override
  String get branchManagement => 'Branch management';

  @override
  String get branchSynchronization => 'Branch synchronization';

  @override
  String get browseIndependentlyAndMoveAcrossPanes =>
      'Browse independently and move across panes';

  @override
  String get browseMoveCopyDeleteCommitAndPushThroughTheGitCli =>
      'Browse, move, copy, delete, commit and push through the Git CLI.';

  @override
  String
  get browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit =>
      'Browse one repository in two panes. Select, cut, paste and rename. Every change runs through Git.';

  @override
  String get bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense =>
      'Bundled fonts come from Google Fonts under the SIL Open Font License.';

  @override
  String get bundledPortablegit => 'Bundled PortableGit';

  @override
  String get bundledUiFonts => 'Bundled UI fonts';

  @override
  String
  get byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts =>
      'By default the bundled Noto Sans SC font is used. Search bundled or system fonts.';

  @override
  String get byteB => 'Byte (B)';

  @override
  String get byteDisplaysBKibOrKbBitIsMultipliedBy8First =>
      'Byte displays B, KiB or KB; bit is multiplied by 8 first.';

  @override
  String get cancel2 => 'Cancel';

  @override
  String get cancelEditing => 'Cancel editing';

  @override
  String get changed => 'Changed';

  @override
  String changes(String count) {
    return '$count changes';
  }

  @override
  String get changesApplyAfterSaving => 'Changes apply after saving.';

  @override
  String
  get changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing =>
      'Changing the system PATH affects the whole computer and requests administrator permission. Cancelling elevation changes nothing.';

  @override
  String get checkAgain => 'Check again';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checking => 'Checking';

  @override
  String get checking2 => 'Checking…';

  @override
  String get checkingForGit => 'Checking for Git…';

  @override
  String get checkingForUpdates => 'Checking for updates';

  @override
  String
  get chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst =>
      'Choose actions in the explorer, commit area or remote manager. They appear here first.';

  @override
  String get chooseCloneParentFolder => 'Choose clone parent folder';

  @override
  String
  get chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors =>
      'Choose display mode and color scheme; interface icons follow the selected colors.';

  @override
  String get chooseFolder => 'Choose folder';

  @override
  String
  get chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup =>
      'Choose the current user or system environment. Only the managed runtime/git/current/cmd path is added, after creating a backup.';

  @override
  String get chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem =>
      'Choose the interface language. By default it follows the operating system.';

  @override
  String get clean => 'Clean';

  @override
  String get cleanAll => 'Clean all';

  @override
  String get clearAllRemoteBranchesAndTagsDangerous =>
      'Clear all remote branches and tags (dangerous)';

  @override
  String get clearGitMetadata => 'Clear Git metadata';

  @override
  String get clearPlan => 'Clear plan';

  @override
  String clearRemoteHistoryFor(String remote) {
    return 'Clear remote history for $remote?';
  }

  @override
  String get clearSearch => 'Clear search';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String get cloneGitRepository => 'Clone Git repository';

  @override
  String get cloneIntoParentFolder => 'Clone into parent folder';

  @override
  String get close => 'Close';

  @override
  String get closeUserGuide => 'Close user guide';

  @override
  String get closingTheRepository => 'closing the repository';

  @override
  String get colorScheme => 'Color scheme';

  @override
  String get commitMessage => 'Commit message';

  @override
  String get commitWorkspace => 'Commit workspace';

  @override
  String get commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun =>
      'Commits are deferred. Confirm the plan before git add -A and git commit run.';

  @override
  String get confirmAndExecute => 'Confirm and execute';

  @override
  String get confirmDangerousOperations => 'Confirm dangerous operations';

  @override
  String get controlHowProjectAndIndividualFileSizesAreDisplayed =>
      'Control how project and individual file sizes are displayed.';

  @override
  String get copy => 'Copy';

  @override
  String
  get createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher =>
      'Create a Git GUI Expand shortcut on the current user\'s desktop that starts through the stable Launcher.';

  @override
  String get createBranch => 'Create branch';

  @override
  String get createStash => 'Create Stash';

  @override
  String get current => 'Current';

  @override
  String get currentBranch => 'Current branch';

  @override
  String currentBranch2(String branch) {
    return 'Current branch: $branch';
  }

  @override
  String get currentReleaseHighlights => 'Current release highlights';

  @override
  String currentSelection(String theme) {
    return 'Current selection: $theme';
  }

  @override
  String currentV(String version) {
    return 'Current v$version';
  }

  @override
  String
  currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
    String version,
  ) {
    return 'Current version: $version. Only old versions, installers, and legacy flat application files are removed; userdata is retained.';
  }

  @override
  String get cut => 'Cut';

  @override
  String get cutCopyRenamePushAndCommit0123456789 =>
      'Cut, copy, rename, push and commit   0123456789';

  @override
  String get dark => 'Dark';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBranch => 'Delete branch';

  @override
  String get deleteStash => 'Delete Stash';

  @override
  String get desktopShortcut => 'Desktop shortcut';

  @override
  String destinationFolder(String path) {
    return 'Destination folder: $path';
  }

  @override
  String
  destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
    String path,
  ) {
    return 'Destination folder: $path\nAfter confirmation, run git init in the destination and open the repository.';
  }

  @override
  String get detached => 'detached';

  @override
  String get detachedHead => 'detached HEAD';

  @override
  String get detachedHeadCannotFetchCurrentUpstreamOrPullABranch =>
      'Detached HEAD cannot fetch current upstream or pull a branch.';

  @override
  String get detailedLog => 'Detailed log';

  @override
  String get detectTheGitRuntimeVersionSourceAndExecutableLocation =>
      'Detect the Git runtime, version, source, and executable location.';

  @override
  String detectionDetails(String error) {
    return 'Detection details: $error';
  }

  @override
  String get discardPlanAndContinue => 'Discard plan and continue';

  @override
  String get discardThePendingOperationPlan =>
      'Discard the pending operation plan?';

  @override
  String get displayMode => 'Display mode';

  @override
  String doesNotContainTheManagedPortablegitPath(String scope) {
    return '$scope does not contain the managed PortableGit path';
  }

  @override
  String get doesNotExist => 'Does not exist';

  @override
  String get done => 'Done';

  @override
  String get doubleClickAFolderClickAPaneToChooseThePasteTarget =>
      'Double-click a folder; click a pane to choose the paste target';

  @override
  String get doubleClickAFolderToOpen => 'Double-click a folder to open';

  @override
  String get downloadGit => 'Download Git';

  @override
  String get dualPaneOperations => 'Dual-pane operations';

  @override
  String get editRemote => 'Edit remote';

  @override
  String get editUrl => 'Edit URL';

  @override
  String get enterACloneUrlParentFolderAndProjectName =>
      'Enter a clone URL, parent folder, and project name.';

  @override
  String get enterACommitMessage => 'Enter a commit message…';

  @override
  String enterProjectBranchToConfirm(String confirmation) {
    return 'Enter project/branch \"$confirmation\" to confirm';
  }

  @override
  String enterProjectBranchToConfirmAgain(String confirmation) {
    return 'Enter project/branch \"$confirmation\" to confirm again.';
  }

  @override
  String get executing => 'Executing…';

  @override
  String get executingStepByStep => 'Executing step by step';

  @override
  String get executionComplete => 'Execution complete';

  @override
  String get executionIncomplete => 'Execution incomplete';

  @override
  String get fetchAllRemotes => 'Fetch all remotes';

  @override
  String get fetchCurrentUpstream => 'Fetch current upstream';

  @override
  String get fileChangesArePendingInTheOperationPlan =>
      'File changes are pending in the operation plan';

  @override
  String get files => 'Files';

  @override
  String
  get filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns =>
      'Files are not deleted yet. Confirm the operation plan before git rm or git clean runs.';

  @override
  String get folder => 'Folder';

  @override
  String get followSystem => 'Follow system';

  @override
  String get followSystemSwitchesWithTheDeviceLightOrDarkAppearance =>
      'Follow system switches with the device light or dark appearance.';

  @override
  String get followTheOperatingSystemWithoutAFixedFamily =>
      'Follow the operating system without a fixed family';

  @override
  String get font => 'Font';

  @override
  String get fontPreview => 'Font preview';

  @override
  String get fontSize => 'Font size';

  @override
  String get forExampleFeatureLogin => 'For example: feature/login';

  @override
  String get forExampleOriginGiteeOrGitlab =>
      'For example origin, gitee or gitlab';

  @override
  String get forExampleTemporarilySaveUnfinishedChanges =>
      'For example: temporarily save unfinished changes';

  @override
  String get forceGitBranchDWhenDeletingAnUnmergedBranch =>
      'Force git branch -D when deleting an unmerged branch';

  @override
  String foundItemsAndCanBeFreed(String count, String size) {
    return 'Found $count items and $size can be freed.';
  }

  @override
  String get git => 'Git';

  @override
  String get gitExecutableLocation => 'Git executable location';

  @override
  String get gitGuiExpandFileCommit => 'Git GUI Expand · File commit';

  @override
  String get gitGuiExpandUserGuide => 'Git GUI Expand User Guide';

  @override
  String
  get gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain =>
      'Git is required to open or modify repositories. Install Git for Windows, then select Check again.';

  @override
  String get gitIsUnavailableRepositoryActionsAreDisabled =>
      'Git is unavailable. Repository actions are disabled.';

  @override
  String get gitMetadata => 'Git metadata';

  @override
  String get gitMvIndexCommit => 'git mv · index · commit';

  @override
  String get gitNotDetected => 'Git not detected';

  @override
  String gitRepositories(String count) {
    return '$count Git repositories';
  }

  @override
  String get gitRepository => 'Git repository';

  @override
  String get gitRepositoryCloned => 'Git repository cloned';

  @override
  String get gitRepositoryInitialized => 'Git repository initialized';

  @override
  String get gitSettings => 'Git settings';

  @override
  String get gitSource => 'Git source';

  @override
  String get gitVersion => 'Git version';

  @override
  String get gitee => 'Gitee';

  @override
  String get github => 'GitHub';

  @override
  String get githubUsuallyProvidesTheInternationalReleaseBuild =>
      'GitHub usually provides the international release build.';

  @override
  String get gotIt => 'Got it';

  @override
  String get guide => 'Guide';

  @override
  String get httpsOrGitHostOwnerRepoGit =>
      'https://... or git@host:owner/repo.git';

  @override
  String get iReviewedTheseOperationsAndWantToExecuteThemInOrder =>
      'I reviewed these operations and want to execute them in order';

  @override
  String get iecBinary => 'IEC binary';

  @override
  String get iecSiOptionalBits => 'IEC / SI, optional bits';

  @override
  String get importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation =>
      'Important: Git changes are planned first and run only after confirmation';

  @override
  String get initializeGitRepository => 'Initialize Git repository';

  @override
  String get installedSystemFont => 'Installed system font';

  @override
  String get installing => 'Installing…';

  @override
  String get interfaceLanguage => 'Interface language';

  @override
  String items(String count) {
    return '$count items';
  }

  @override
  String get language => 'Language';

  @override
  String get language2 => 'Language';

  @override
  String get largeFile => 'Large file';

  @override
  String get lastChecked => 'Last checked';

  @override
  String get leftExplorer => 'Left explorer';

  @override
  String get light => 'Light';

  @override
  String
  get localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst =>
      'Local and upstream histories have diverged. The app will not merge or rebase automatically; resolve the divergence in external Git first.';

  @override
  String get logs => 'Logs';

  @override
  String get mediumFile => 'Medium file';

  @override
  String get moreContentBelow => 'More content below';

  @override
  String get name => 'Name';

  @override
  String get nativeGitChanges => 'Native Git changes';

  @override
  String get newBranchNameOrRenamedBranchName =>
      'New branch name or renamed branch name';

  @override
  String get newName => 'New name';

  @override
  String get noBranch => 'No branch';

  @override
  String get noBundledFontMatches => 'No bundled font matches';

  @override
  String get noCommittedBranchYet => 'No committed branch yet';

  @override
  String
  get noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere =>
      'No detailed log yet. Selection, navigation and every Git command are recorded here.';

  @override
  String get noFilesHere => 'No files here';

  @override
  String get noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents =>
      'No normal log yet. Opening a repository and Git actions create key events.';

  @override
  String get noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean =>
      'No old versions or installers were found; the directory is already clean.';

  @override
  String get noPendingOperations => 'No pending operations';

  @override
  String get noPendingSteps => 'No pending steps';

  @override
  String get noProjectIsOpen => 'No project is open.';

  @override
  String get noRemoteRepositoryWasDetected =>
      'No remote repository was detected.';

  @override
  String get noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote =>
      'No remotes configured. Add GitHub, Gitee, GitLab or another Git remote.';

  @override
  String get noSystemFontMatches => 'No system font matches';

  @override
  String get noUpstream => 'No upstream';

  @override
  String get noUsableGitWasDetectedInstallItAndCheckAgain =>
      'No usable Git was detected. Install it and check again.';

  @override
  String get none => 'None';

  @override
  String get normalLog => 'Normal log';

  @override
  String get notCheckedYet => 'Not checked yet';

  @override
  String get notConfigured => 'Not configured';

  @override
  String get notDetected => 'Not detected';

  @override
  String nothingIsPushedYetThePlanPushesTo(
    String branch,
    String platform,
    String url,
  ) {
    return 'Nothing is pushed yet. The plan pushes $branch to $platform.\n$url';
  }

  @override
  String
  get nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded =>
      'Nothing is pushed yet. The plan will run git push and configure upstream when needed.';

  @override
  String get oldVersionAndInstallerCleanup =>
      'Old version and installer cleanup';

  @override
  String get onlineReleaseNotes => 'Online release notes';

  @override
  String
  get onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath =>
      'Only the current user PATH is changed and elevation is not required. The app only adds or removes its stable managed runtime path.';

  @override
  String get onlyTheLocalGitRemoteConfigurationIsRemoved =>
      'Only the local Git remote configuration is removed.';

  @override
  String get onlyVerifiedRepositoryRootsAreSaved =>
      'Only verified repository roots are saved';

  @override
  String get open => 'Open';

  @override
  String
  get openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository =>
      'Open an existing repository, initialize an empty folder, or clone a remote repository';

  @override
  String get openAnotherFolderOrRefreshToViewRepositoryContents =>
      'Open another folder or refresh to view repository contents.';

  @override
  String get openEmptyFolder => 'Open empty folder';

  @override
  String get openFolder => 'Open folder';

  @override
  String get openGitRepository => 'Open Git repository';

  @override
  String get openReleasePage => 'Open release page';

  @override
  String get openRepository2 => 'Open repository';

  @override
  String get openWithDefaultApp => 'Open with default app';

  @override
  String get openingAnotherRepository => 'opening another repository';

  @override
  String get openingRepository => 'Opening repository…';

  @override
  String optionsFound(String count) {
    return '$count options found';
  }

  @override
  String get parentFolder => 'Parent folder';

  @override
  String get paste => 'Paste';

  @override
  String get pasteTarget => 'Paste target';

  @override
  String get pasteToLeft => 'Paste to left';

  @override
  String get pasteToRight => 'Paste to right';

  @override
  String get pathChangeCancelled => 'PATH change cancelled';

  @override
  String pathChangeFailed(String error) {
    return 'PATH change failed: $error';
  }

  @override
  String pending(String count) {
    return '$count pending';
  }

  @override
  String get pending2 => 'Pending';

  @override
  String get pendingOperationPlan => 'Pending operation plan';

  @override
  String plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
    String action,
    String count,
  ) {
    return '$count planned steps have not run. $action will discard them; no repository changes will occur.';
  }

  @override
  String get popStash => 'Pop Stash';

  @override
  String get preciseSizeView => 'Precise size view';

  @override
  String get preparingToExecute => 'Preparing to execute';

  @override
  String get preparingUpdate => 'Preparing update…';

  @override
  String get projectFolder => 'Project folder';

  @override
  String get projectFolderName => 'Project folder name';

  @override
  String get projectSize => 'Project size';

  @override
  String projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
    String branch,
    String confirmation,
    String message,
    String project,
    String target,
  ) {
    return 'Project: $project\nTarget branch: $branch\nTarget commit: $target\nEmpty commit message: $message\nPlan confirmation: $confirmation';
  }

  @override
  String
  get pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex =>
      'Pull fetches and rechecks ahead/behind, allows fast-forward only, never creates a merge commit, and is disabled for a dirty worktree or index.';

  @override
  String get push => 'Push';

  @override
  String get pushAll => 'Push all';

  @override
  String get pushCurrentBranchCtrlShiftU =>
      'Push current branch (Ctrl+Shift+U)';

  @override
  String readingBranchesAndTagsFrom(String remote) {
    return 'Reading branches and tags from $remote…';
  }

  @override
  String get readingSynchronizationState => 'Reading synchronization state…';

  @override
  String get recentlyOpened => 'Recently opened';

  @override
  String get refresh => 'Refresh';

  @override
  String get refreshBranches => 'Refresh branches';

  @override
  String get refreshLogs => 'Refresh logs';

  @override
  String get refreshRemotes => 'Refresh remotes';

  @override
  String get refreshRepositoryAndRebuildPlan =>
      'Refresh repository and rebuild plan';

  @override
  String get refreshRepositoryCtrlR => 'Refresh repository (Ctrl+R)';

  @override
  String get refreshStashes => 'Refresh Stashes';

  @override
  String get refreshSynchronizationState => 'Refresh synchronization state';

  @override
  String get remoteCheck => 'Remote check';

  @override
  String get remoteName => 'Remote name';

  @override
  String get remoteRefList => 'Remote ref list';

  @override
  String remoteRepositoriesWereDetectedSoClearingIsDisabled(String remotes) {
    return 'Remote repositories were detected, so clearing is disabled: $remotes';
  }

  @override
  String get remoteRepositoryUrl => 'Remote repository URL';

  @override
  String get remoteUrl => 'Remote URL';

  @override
  String remotes(String count) {
    return 'Remotes $count';
  }

  @override
  String get remotes2 => 'Remotes';

  @override
  String get removeFromHistory => 'Remove from history';

  @override
  String get removeFromPlan => 'Remove from plan';

  @override
  String get removeFromSystemPath => 'Remove from system PATH';

  @override
  String get removeFromUserPath => 'Remove from user PATH';

  @override
  String get removeLocalRemoteConfiguration =>
      'Remove local remote configuration';

  @override
  String removedItemsAndFreed(String count, String size) {
    return 'Removed $count items and freed $size.';
  }

  @override
  String removedItemsCouldNotBeDeletedCheckTheDetailedLog(
    String failed,
    String removed,
  ) {
    return 'Removed $removed items; $failed could not be deleted. Check the detailed log.';
  }

  @override
  String get rename => 'Rename';

  @override
  String get renameBranch => 'Rename branch';

  @override
  String repository(String path) {
    return 'Repository: $path';
  }

  @override
  String get repositoryAndRemoteOperationsAreAvailable =>
      'Repository and remote operations are available';

  @override
  String get repositoryViewRefreshed => 'Repository view refreshed';

  @override
  String get reviewRemoveOrExecutePendingOperations =>
      'Review, remove or execute pending operations';

  @override
  String get rightExplorer => 'Right explorer';

  @override
  String get safeFastForwardPull => 'Safe fast-forward pull';

  @override
  String get saveSettings2 => 'Save settings';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get scanOldVersionsAndInstallers => 'Scan old versions and installers';

  @override
  String get scrollDownForFontPreviewAndFontSizeSettings =>
      'Scroll down for font preview and font-size settings.';

  @override
  String get searchFontNameOrPurposeEGInterOrNoto =>
      'Search font name or purpose, e.g. Inter or Noto';

  @override
  String get selectAnItemToRename => 'Select an item to rename.';

  @override
  String get selectExactlyOneItemToRename =>
      'Select exactly one item to rename.';

  @override
  String get selectFilesToCutOrCopy => 'Select files to cut or copy';

  @override
  String get selectItemsToDelete => 'Select items to delete first.';

  @override
  String get selectTheDangerousOperationConfirmationFirst =>
      'Select the dangerous-operation confirmation first.';

  @override
  String selected(String count) {
    return '$count selected';
  }

  @override
  String selected2(String count) {
    return '$count selected';
  }

  @override
  String get settings2 => 'Settings';

  @override
  String get settingsDataDirectory => 'Settings data directory';

  @override
  String get showInFileExplorer => 'Show in File Explorer';

  @override
  String get siDecimal => 'SI decimal';

  @override
  String get size => 'Size';

  @override
  String get sizeUnitSystem => 'Size unit system';

  @override
  String get smallFile => 'Small file';

  @override
  String get stageAll => 'Stage all';

  @override
  String staged(String count) {
    return '$count staged';
  }

  @override
  String get stash => 'Stash';

  @override
  String get stashManagement => 'Stash management';

  @override
  String get stashMessageOptional => 'Stash message (optional)';

  @override
  String get stateChangeDetails => 'State change details';

  @override
  String get stateChangedBeforeExecution => 'State changed before execution';

  @override
  String get status => 'Status';

  @override
  String step(String step, String title) {
    return 'Step $step: $title';
  }

  @override
  String stepsTheRepositoryIsUnchangedUntilConfirmation(String count) {
    return '$count steps; the repository is unchanged until confirmation';
  }

  @override
  String
  get supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst =>
      'Supports GitHub, Gitee, GitLab, Bitbucket and standard Git remotes. Changes are planned first.';

  @override
  String get switchBranch => 'Switch branch';

  @override
  String get sync => 'Sync';

  @override
  String get systemDefaultAutomatic => 'System default (automatic)';

  @override
  String get systemFonts => 'System fonts';

  @override
  String get systemGit => 'System Git';

  @override
  String textCanBeSelectedAndCopiedHereTheFullGuideIsIn(String path) {
    return 'Text can be selected and copied here. The full guide is in $path.';
  }

  @override
  String
  get thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject =>
      'Thanks to DeepSeek AI and ChatGPT Codex for creating and improving this project.';

  @override
  String get theCloneDestinationFolderIsNotEmpty =>
      'The clone destination folder is not empty.';

  @override
  String get theCloneDestinationParentFolderDoesNotExist =>
      'The clone destination parent folder does not exist.';

  @override
  String
  get theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText =>
      'The color scheme applies to buttons, selected states, borders, icons, and emphasized text.';

  @override
  String get theCurrentBranchHasNoCommitAndCannotBePulled =>
      'The current branch has no commit and cannot be pulled.';

  @override
  String
  get theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking =>
      'The current branch has no upstream. Fetch-all is available, but Pull requires tracking.';

  @override
  String get theCurrentBranchIsSynchronizedWithUpstream =>
      'The current branch is synchronized with upstream.';

  @override
  String get theDetailedReasonHasBeenWrittenToTheApplicationLog =>
      'The detailed reason has been written to the application log.';

  @override
  String get theGiteeSourceIsSuitedToMainlandChinaNetworks =>
      'The Gitee source is suited to mainland China networks.';

  @override
  String
  get theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata =>
      'The initialization target must exist and must not already contain Git metadata.';

  @override
  String get theLanguageChangeTakesEffectImmediatelyAfterSaving =>
      'The language change takes effect immediately after saving.';

  @override
  String get theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull =>
      'The local branch has unpushed commits and does not need Pull.';

  @override
  String
  get theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone =>
      'The next step only creates a clone preview. Cancel creates nothing; confirming the plan rechecks the destination and runs git clone.';

  @override
  String thePlanPushesTo(String branch, String remotes) {
    return 'The plan pushes $branch to:\n$remotes';
  }

  @override
  String get theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated =>
      'The remote has no branches or tags. The first empty commit will be created.';

  @override
  String get theRepositoryHasNoStashes => 'The repository has no Stashes.';

  @override
  String get theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes =>
      'The saved font applies to menus, explorers, dialogs and commit notes.';

  @override
  String get theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull =>
      'The worktree or index is dirty. Commit or stash changes before safe Pull.';

  @override
  String get thereAreNoLocalBranchesToDisplay =>
      'There are no local branches to display.';

  @override
  String get thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation =>
      'This action is added to the plan. git mv runs only after confirmation.';

  @override
  String
  thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
    String branch,
  ) {
    return 'This dangerous action cannot be undone. The remote is backed up, $branch is replaced with an empty root commit, other refs are deleted, and the local branch/index are synchronized without deleting files.';
  }

  @override
  String get thisOperationDeletesTheGitFolderInTheRepositoryRoot =>
      'This operation deletes the .git folder in the repository root.';

  @override
  String
  thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
    String count,
  ) {
    return 'This plan includes $count dangerous steps. File deletion cannot be undone here; remote reset keeps only one empty commit.';
  }

  @override
  String get thisProjectIsLicensedUnderTheMitLicense =>
      'This project is licensed under the MIT License.';

  @override
  String get threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge =>
      'Three safe sizes prevent layouts from becoming too small or large.';

  @override
  String today(String time) {
    return 'Today $time';
  }

  @override
  String get turnGitFileOperationsIntoAnIntuitiveWorkspace =>
      'Turn Git file operations\ninto an intuitive workspace.';

  @override
  String get typeANameToFilter => 'Type a name to filter';

  @override
  String unableToOpenFile(String error) {
    return 'Unable to open file: $error';
  }

  @override
  String unableToOpenLogsFolder(String error) {
    return 'Unable to open logs folder: $error';
  }

  @override
  String unableToOpenProjectFolder(String error) {
    return 'Unable to open project folder: $error';
  }

  @override
  String unableToOpenTheGitDownloadPage(String error) {
    return 'Unable to open the Git download page: $error';
  }

  @override
  String get unableToReadBranchSynchronizationStateRefreshAndTryAgain =>
      'Unable to read branch synchronization state. Refresh and try again.';

  @override
  String get unableToReadFolder => 'Unable to read folder';

  @override
  String unableToReadUserGuide(String error) {
    return 'Unable to read user guide: $error';
  }

  @override
  String get unableToRetrieveTheOnlineVersion =>
      'Unable to retrieve the online version';

  @override
  String get unitPreview => 'Unit preview';

  @override
  String get units => 'Units';

  @override
  String get unstage => 'Unstage';

  @override
  String get updateAndRestartNow => 'Update and restart now';

  @override
  String get updateSource => 'Update source';

  @override
  String updated(String scope) {
    return 'Updated $scope';
  }

  @override
  String get updates => 'Updates';

  @override
  String get updatesAndReleaseNotes => 'Updates and release notes';

  @override
  String get updating => 'Updating';

  @override
  String get updatingAutomatically => 'Updating automatically';

  @override
  String get upstream => 'upstream';

  @override
  String
  usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
    String platform,
  ) {
    return '$platform usually protects the default branch. Remove protection temporarily if force update or deletion is rejected.';
  }

  @override
  String get versionNotFoundOrUnreadable => 'Version not found or unreadable';

  @override
  String versionV(String version) {
    return 'Version v$version';
  }

  @override
  String versionVIsAvailable(String version) {
    return 'Version v$version is available';
  }

  @override
  String get viewAndManageAllRemotes => 'View and manage all remotes';

  @override
  String get viewBranchSynchronization => 'View branch synchronization';

  @override
  String get viewLogs => 'View logs';

  @override
  String
  get workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks =>
      'Working files are retained, but the following Git data will be permanently lost:\n• All commit history and reflog\n• Local branches, tags, and current branch state\n• Staged index, Stashes, and committed content not retained in working files\n• Refs, remote configuration, and repository-level Git settings and hooks';

  @override
  String get workingTreeClean => 'Working tree clean';

  @override
  String get worktree => 'Worktree';

  @override
  String get youAreUpToDate => 'You are up to date';

  @override
  String get followSystemLabel => 'Follow system';

  @override
  String get followSystemDescription =>
      'Use the language selected in the operating system.';

  @override
  String get languageEnglishOptionLabel => 'English';

  @override
  String get languageEnglishDescription =>
      'Use English for the application interface.';

  @override
  String get languageSimplifiedChineseOptionLabel => '简体中文';

  @override
  String get languageSimplifiedChineseDescription => '使用简体中文显示软件界面。';

  @override
  String get languageTraditionalChineseOptionLabel => '繁體中文';

  @override
  String get languageTraditionalChineseDescription => '使用繁體中文顯示軟體介面。';

  @override
  String get userPath => 'User PATH';

  @override
  String get systemPath => 'System PATH';

  @override
  String addPortableGitTo(String scope) {
    return 'Add PortableGit to $scope';
  }

  @override
  String removePortableGitFrom(String scope) {
    return 'Remove PortableGit from $scope';
  }

  @override
  String get confirmAdd => 'Add';

  @override
  String get confirmRemove => 'Remove';

  @override
  String get gitAvailable => 'Git available';

  @override
  String get gitUnavailable => 'Git unavailable';

  @override
  String get creatingShortcut => 'Creating shortcut…';

  @override
  String get oneClickSendToDesktop => 'Send to desktop';

  @override
  String get bundledLabel => 'Bundled';

  @override
  String get iec1024BaseBit => 'IEC · base 1024 · bit';

  @override
  String get si1000BaseBit => 'SI · base 1000 · bit';

  @override
  String get iec1024BaseByte => 'IEC · base 1024 · Byte';

  @override
  String get si1000BaseByte => 'SI · base 1000 · Byte';

  @override
  String get classicGreen => 'Classic green';

  @override
  String get oceanBlue => 'Ocean blue';

  @override
  String get starryViolet => 'Starry violet';

  @override
  String get amberGold => 'Amber gold';

  @override
  String get roseRed => 'Rose red';

  @override
  String get interUiDescription =>
      'An open-source sans-serif designed for digital interfaces and dense text.';

  @override
  String get notoSansScDescription =>
      'A modern interface font covering Simplified Chinese with stable mixed-script forms.';

  @override
  String get ibmPlexSansDescription =>
      'Designed for product interfaces and business information with strong numeral readability.';

  @override
  String get fontDescription => 'Bundled interface font';

  @override
  String get operationCompleted => 'Operation completed.';

  @override
  String operationCompletedFor(String target) {
    return 'Operation completed: $target.';
  }

  @override
  String operationCompletedForItems(String count) {
    return 'Operation completed for $count item(s).';
  }

  @override
  String operationFailed(String error) {
    return 'Operation failed: $error';
  }

  @override
  String operationFailedFor(String error, String target) {
    return 'Operation failed for $target: $error';
  }

  @override
  String logInfo(String eventId) {
    return 'Information event: $eventId';
  }

  @override
  String logDetail(String eventId) {
    return 'Detailed event: $eventId';
  }

  @override
  String logWarning(String eventId) {
    return 'Warning event: $eventId';
  }

  @override
  String logError(String eventId) {
    return 'Error event: $eventId';
  }

  @override
  String get logsTruncated => '… Showing only recent log entries …';

  @override
  String logReadFailed(String error) {
    return 'Failed to read logs: $error';
  }

  @override
  String get noRepositoryOpen => 'No repository is open.';

  @override
  String get operationInProgress => 'Another operation is still running.';

  @override
  String get emptyOperationPlan => 'The operation plan is empty.';

  @override
  String get gitUnavailableHelp =>
      'Git is unavailable. Install Git or check again in Settings.';

  @override
  String get selectItemsFirst => 'Select files or folders first.';

  @override
  String get clipboardEmpty => 'The clipboard is empty.';

  @override
  String get clipboardCleared => 'Clipboard cleared.';

  @override
  String clipboardPendingCut(String count) {
    return '$count item(s) pending move';
  }

  @override
  String clipboardPendingCopy(String count) {
    return '$count item(s) pending copy';
  }

  @override
  String get operationPlanBusyEdit =>
      'The plan is running and cannot be edited.';

  @override
  String get operationPlanBusyClear =>
      'The plan is running and cannot be cleared.';

  @override
  String get planOperationMissing => 'The planned operation no longer exists.';

  @override
  String get planOperationRemoved => 'The operation was removed from the plan.';

  @override
  String planCleared(String count) {
    return 'Cleared $count planned step(s).';
  }

  @override
  String planStrongConfirmationRequired(String confirmation) {
    return 'Enter $confirmation exactly to confirm this dangerous operation.';
  }

  @override
  String get planDangerousAcknowledgmentRequired =>
      'Select the dangerous-operation acknowledgement before executing.';

  @override
  String get planStateChanged =>
      'The repository changed after confirmation. Refresh and rebuild the plan.';

  @override
  String planStepStateChanged(String step) {
    return 'The repository changed before step $step. Execution stopped; refresh and rebuild the plan.';
  }

  @override
  String planStepFailed(String error, String step) {
    return 'Step $step failed: $error. Later steps did not run and the failed step remains in the plan.';
  }

  @override
  String planExecutionComplete(String count) {
    return 'Executed all $count planned step(s) in order.';
  }

  @override
  String get planOperationAdded =>
      'Added to the operation plan. No Git changes have run yet.';

  @override
  String planSnapshotFailed(String error) {
    return 'Could not capture the safety snapshot: $error';
  }

  @override
  String get clearRemoteMustRunAlone =>
      'Clearing a remote must run alone. Remove or execute the other planned steps first.';

  @override
  String get commitMustRemainLast =>
      'Commit is already at the end of the plan. Remove it before editing files again.';

  @override
  String get exclusiveOperationMustRunAlone =>
      'This lifecycle operation must run alone.';

  @override
  String get exclusiveOperationAlreadyQueued =>
      'The plan already contains an operation that must run alone.';

  @override
  String get renameSelectOne => 'Select exactly one file or folder to rename.';

  @override
  String get nameCannotBeEmpty => 'The name cannot be empty.';

  @override
  String get historyEntryRemoved => 'Removed from recent repositories.';

  @override
  String get gitMetadataClearAvailable =>
      'No remote is configured; Git metadata may be cleared.';

  @override
  String get gitMetadataCleared =>
      'Git metadata was cleared. Working files remain.';

  @override
  String get gitMetadataRemoteForbidden =>
      'Git metadata cannot be cleared while remotes are configured.';

  @override
  String fileRenamed(String name) {
    return 'Renamed to $name.';
  }

  @override
  String get bootstrapPlanAlreadyUsed =>
      'This preview has already run or is running. Open a new preview.';

  @override
  String get bootstrapStateChanged =>
      'The target changed after confirmation. Refresh the preview and confirm again.';

  @override
  String get unableToInspectRepository => 'Unable to inspect the repository.';

  @override
  String stepsCount(String count) {
    return '$count steps';
  }

  @override
  String get planKindInitialize => 'Initialize';

  @override
  String get planKindClone => 'Clone';

  @override
  String get planKindMove => 'Move';

  @override
  String get planKindCopy => 'Copy';

  @override
  String get planKindRename => 'Rename';

  @override
  String get planKindDelete => 'Delete';

  @override
  String get planKindClearGitMetadata => 'Clear Git metadata';

  @override
  String get planKindStageAll => 'Stage';

  @override
  String get planKindUnstageAll => 'Unstage';

  @override
  String get planKindCommit => 'Commit';

  @override
  String get planKindFetchCurrent => 'Fetch upstream';

  @override
  String get planKindFetchAll => 'Fetch all';

  @override
  String get planKindPull => 'Fast-forward pull';

  @override
  String get planKindPush => 'Push';

  @override
  String get planKindPushAll => 'Push all';

  @override
  String get planKindAddRemote => 'Add remote';

  @override
  String get planKindUpdateRemote => 'Update remote';

  @override
  String get planKindRemoveRemote => 'Remove remote';

  @override
  String get planKindClearRemote => 'Clear remote';

  @override
  String get planKindCreateBranch => 'Create branch';

  @override
  String get planKindSwitchBranch => 'Switch branch';

  @override
  String get planKindRenameBranch => 'Rename branch';

  @override
  String get planKindDeleteBranch => 'Delete branch';

  @override
  String get planKindCreateStash => 'Create Stash';

  @override
  String get planKindApplyStash => 'Apply Stash';

  @override
  String get planKindPopStash => 'Pop Stash';

  @override
  String get planKindDropStash => 'Drop Stash';

  @override
  String get planTitleInitializeRepository => 'Initialize Git repository';

  @override
  String planDescriptionInitializeRepository(String path) {
    return 'Run git init in $path after confirmation, then open the repository.';
  }

  @override
  String get planTitleCloneRepository => 'Clone Git repository';

  @override
  String planDescriptionCloneRepository(String path, String url) {
    return 'Clone $url into $path. Canceling creates nothing; confirming rechecks the destination and runs git clone.';
  }

  @override
  String planTitleMove(String count, String destination) {
    return 'Move $count item(s) to $destination';
  }

  @override
  String planDescriptionMove(String count, String destination) {
    return 'Move $count item(s) with Git into $destination.';
  }

  @override
  String planTitleCopy(String count, String destination) {
    return 'Copy $count item(s) to $destination';
  }

  @override
  String planDescriptionCopy(String count, String destination) {
    return 'Copy $count item(s) with Git into $destination.';
  }

  @override
  String planTitleRename(String source) {
    return 'Rename $source';
  }

  @override
  String planDescriptionRename(String newName, String source) {
    return 'Change the name of $source to $newName.';
  }

  @override
  String planTitleDelete(String count) {
    return 'Delete $count item(s)';
  }

  @override
  String planDescriptionDelete(String count, String paths) {
    return 'Permanently delete $count item(s): $paths. Tracked files use git rm; untracked or ignored files use git clean.';
  }

  @override
  String get planTitleClearGitMetadata => 'Clear Git metadata';

  @override
  String planDescriptionClearGitMetadata(String path) {
    return 'Repository: $path. Permanently delete .git while keeping working files. Commit history, branches, tags, index, Stashes, remote configuration, and repository settings will be lost. This operation must run alone.';
  }

  @override
  String planTitleCreateBranch(String branch) {
    return 'Create branch $branch';
  }

  @override
  String planDescriptionCreateBranch(String branch) {
    return 'Run git branch -- $branch to create a local branch from HEAD.';
  }

  @override
  String branchCreated(String branch) {
    return 'Created branch $branch.';
  }

  @override
  String planTitleSwitchBranch(String branch) {
    return 'Switch to branch $branch';
  }

  @override
  String planDescriptionSwitchBranch(String branch) {
    return 'Run git switch $branch. Git refuses the switch if uncommitted changes conflict.';
  }

  @override
  String branchSwitched(String branch) {
    return 'Switched to branch $branch.';
  }

  @override
  String alreadyOnBranch(String branch) {
    return 'Already on branch $branch.';
  }

  @override
  String planTitleRenameBranch(String from, String to) {
    return 'Rename branch $from to $to';
  }

  @override
  String planDescriptionRenameBranch(String from, String to) {
    return 'Run git branch -m $from $to.';
  }

  @override
  String branchRenamed(String from, String to) {
    return 'Renamed branch $from to $to.';
  }

  @override
  String planTitleDeleteBranch(String branch) {
    return 'Delete branch $branch';
  }

  @override
  String planDescriptionDeleteBranchForce(String branch) {
    return 'Run git branch -D $branch to force-delete an unmerged branch.';
  }

  @override
  String planDescriptionDeleteBranchSafe(String branch) {
    return 'Run git branch -d $branch. Only merged branches can be deleted.';
  }

  @override
  String branchDeleted(String branch) {
    return 'Deleted branch $branch.';
  }

  @override
  String get cannotDeleteCurrentBranch =>
      'The current branch cannot be deleted. Switch branches first.';

  @override
  String get planTitleCreateStash => 'Create Stash';

  @override
  String planTitleCreateStashNamed(String message) {
    return 'Create Stash: $message';
  }

  @override
  String planDescriptionCreateStash(String message) {
    return 'Run git stash push for the supplied message: $message';
  }

  @override
  String planDescriptionCreateStashIncludeUntracked(String message) {
    return 'Run git stash push --include-untracked for the supplied message: $message';
  }

  @override
  String get stashCreated => 'Stash created.';

  @override
  String planTitleApplyStash(String selector) {
    return 'Apply $selector';
  }

  @override
  String planDescriptionApplyStash(String selector) {
    return 'Run git stash apply $selector and keep the Stash entry.';
  }

  @override
  String stashApplied(String selector) {
    return 'Applied $selector.';
  }

  @override
  String planTitlePopStash(String selector) {
    return 'Pop $selector';
  }

  @override
  String planDescriptionPopStash(String selector) {
    return 'Run git stash pop $selector; apply it and remove the Stash entry.';
  }

  @override
  String stashPopped(String selector) {
    return 'Popped $selector.';
  }

  @override
  String planTitleDropStash(String selector) {
    return 'Drop $selector';
  }

  @override
  String planDescriptionDropStash(String selector) {
    return 'Run git stash drop $selector. This cannot be undone in this app.';
  }

  @override
  String stashDropped(String selector) {
    return 'Dropped $selector.';
  }

  @override
  String get invalidStashSelector => 'The Stash selector is invalid.';

  @override
  String get planTitlePushCurrent => 'Push current branch';

  @override
  String planTitlePushBranch(String branch) {
    return 'Push $branch';
  }

  @override
  String get planDescriptionPushCurrent =>
      'Push the current branch to its upstream, or configure origin/first remote as upstream when needed.';

  @override
  String planTitleFetchRemote(String remote) {
    return 'Fetch remote $remote';
  }

  @override
  String planDescriptionFetchRemote(String remote) {
    return 'Run git fetch --prune $remote. Tracked remote refs update; working files do not change.';
  }

  @override
  String planTitleFetchAllRemotes(String count) {
    return 'Fetch all $count remotes';
  }

  @override
  String planDescriptionFetchAllRemotes(String remotes) {
    return 'Run git fetch --prune for each remote: $remotes. Failures are reported per remote.';
  }

  @override
  String remoteFetched(String remote) {
    return 'Fetched updates from remote $remote.';
  }

  @override
  String allRemotesFetched(String count) {
    return 'Fetched all $count remotes.';
  }

  @override
  String remoteBatchPartialFailure(
    String details,
    String failed,
    String succeeded,
  ) {
    return '$succeeded succeeded and $failed failed. Details: $details';
  }

  @override
  String get syncStateUnavailable =>
      'Unable to read the current branch synchronization state.';

  @override
  String get detachedCannotPull =>
      'The repository is on a detached HEAD and cannot pull a branch.';

  @override
  String get unbornCannotPull =>
      'The current branch has no commit and cannot pull.';

  @override
  String get upstreamMissing =>
      'The current branch has no usable upstream. Configure a tracked remote branch first.';

  @override
  String get dirtyWorktreeCannotPull =>
      'The worktree or index is dirty. Commit or Stash changes before pulling.';

  @override
  String get pullUpToDate =>
      'The current branch is already synchronized with upstream.';

  @override
  String get pullAhead =>
      'The branch contains all upstream commits and has local commits to push.';

  @override
  String get pullDiverged =>
      'Local and upstream histories diverged. Use external Git to merge or rebase first.';

  @override
  String get pullRelationUnknown =>
      'The current synchronization relation is unknown.';

  @override
  String get pullNoUpdate => 'No fast-forward update was needed.';

  @override
  String planTitlePull(String branch) {
    return 'Safely fast-forward $branch';
  }

  @override
  String planDescriptionPull(String branch, String remote, String upstream) {
    return 'Fetch $remote and recheck ahead/behind. Run git merge --ff-only $upstream only when $branch is behind and not diverged; no merge commit is created automatically.';
  }

  @override
  String pullCompleted(String branch, String upstream) {
    return 'Fast-forwarded $branch to $upstream.';
  }

  @override
  String syncAuthenticationFailed(String error) {
    return 'Git authentication failed: $error';
  }

  @override
  String syncNetworkFailed(String error) {
    return 'Git network access failed: $error';
  }

  @override
  String get pushedCurrentBranch => 'Pushed the current branch.';

  @override
  String pushedBranch(String branch) {
    return 'Pushed $branch.';
  }

  @override
  String get noRemotesConfigured => 'No remotes are configured.';

  @override
  String get remoteListRefreshed => 'Remote list refreshed.';

  @override
  String planTitleAddRemote(String remote) {
    return 'Add remote $remote';
  }

  @override
  String planDescriptionAddRemote(String remote, String url) {
    return 'Add remote $remote with URL $url.';
  }

  @override
  String planTitleUpdateRemote(String remote) {
    return 'Update remote $remote';
  }

  @override
  String planDescriptionUpdateRemote(String remote, String url) {
    return 'Change remote $remote to $url.';
  }

  @override
  String remoteAdded(String remote) {
    return 'Remote $remote added.';
  }

  @override
  String remoteUpdated(String remote) {
    return 'Remote $remote updated.';
  }

  @override
  String remoteRemoved(String remote) {
    return 'Remote $remote removed.';
  }

  @override
  String planTitleRemoveRemote(String remote) {
    return 'Remove remote configuration $remote';
  }

  @override
  String get planDescriptionRemoveRemote =>
      'Remove only the Git remote configuration in this repository; the hosted repository is not deleted.';

  @override
  String planTitlePushRemote(String remote) {
    return 'Push to remote $remote';
  }

  @override
  String planDescriptionPushRemote(String branch, String remote) {
    return 'Push branch $branch to remote $remote.';
  }

  @override
  String pushedToRemote(String remote) {
    return 'Pushed to $remote.';
  }

  @override
  String planTitlePushAllRemotes(String count) {
    return 'Push to all $count remotes';
  }

  @override
  String planDescriptionPushAllRemotes(String remotes) {
    return 'Push the current branch to: $remotes.';
  }

  @override
  String pushedToAllRemotes(String count) {
    return 'Pushed to all $count remotes.';
  }

  @override
  String remoteInspectionEmpty(String remote) {
    return 'Remote $remote currently has no branches or tags.';
  }

  @override
  String remoteInspectionCounts(String branches, String remote, String tags) {
    return 'Remote $remote has $branches branch(es) and $tags tag(s).';
  }

  @override
  String planTitleClearRemote(String remote) {
    return 'Clear remote history $remote';
  }

  @override
  String planDescriptionClearRemote(
    String branch,
    String branches,
    String message,
    String project,
    String tags,
  ) {
    return 'Project $project, target branch $branch. Back up and delete $branches branch(es) and $tags tag(s), then keep one empty commit: “$message”. Local files remain, but the local index is reset to empty and files appear untracked after refresh.';
  }

  @override
  String clearRemoteCompleted(String branch, String commit, String remote) {
    return 'Cleared remote $remote. Branch $branch now points to empty commit $commit; local files remain and appear untracked.';
  }

  @override
  String clearRemoteDrift(
    String branches,
    String error,
    String remote,
    String tags,
  ) {
    return 'Clearing remote $remote stopped because refs changed. It now has $branches branch(es) and $tags tag(s). $error';
  }

  @override
  String get planTitleStageAll => 'Stage all changes';

  @override
  String get planDescriptionStageAll =>
      'Run git add -A to add all current changes to the Git index.';

  @override
  String get stageAllCompleted => 'Staged all changes.';

  @override
  String get planTitleUnstageAll => 'Unstage all changes';

  @override
  String get planDescriptionUnstageAll =>
      'Reset the Git index to HEAD while preserving working files.';

  @override
  String get unstageAllCompleted => 'Unstaged all changes.';

  @override
  String get planTitleCommitAll => 'Commit all changes';

  @override
  String planDescriptionCommitAll(String message) {
    return 'Commit message: $message. Execution runs git add -A and then git commit.';
  }

  @override
  String get commitMessageRequired => 'Enter a commit message.';

  @override
  String get noChangesToCommit => 'There are no changes to commit.';

  @override
  String get commitAlreadyQueued => 'A commit step is already in the plan.';

  @override
  String get commitIdentityUnavailable =>
      'Git author and committer identity is unavailable. Configure user.name and user.email, then retry.';

  @override
  String get commitSucceeded => 'Commit created.';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String get desktopShortcutWindowsOnly =>
      'Desktop shortcuts are currently supported only on Windows.';

  @override
  String desktopShortcutCreated(String path) {
    return 'Desktop shortcut created: $path';
  }

  @override
  String get maintenanceKindOldVersion => 'Old version directory';

  @override
  String get maintenanceKindUpdateArchive => 'Update archive';

  @override
  String get maintenanceKindPartialDownload => 'Incomplete download';

  @override
  String get maintenanceKindStagingDirectory =>
      'Temporary extraction directory';

  @override
  String get maintenanceKindLegacyUpdater => 'Legacy updater script';

  @override
  String get maintenanceKindLegacyFlatFile => 'Legacy flat application file';

  @override
  String get maintenanceKindLegacyFlatDirectory =>
      'Legacy flat application directory';

  @override
  String get maintenanceKindObsoleteGitRuntime =>
      'Obsolete PortableGit runtime';

  @override
  String get maintenanceKindGitRuntimeArchive => 'PortableGit update archive';

  @override
  String get maintenanceKindGitRuntimeStaging =>
      'PortableGit staging directory';

  @override
  String get driftRepositoryRoot => 'Repository root';

  @override
  String get driftBranch => 'Branch';

  @override
  String get driftHead => 'HEAD';

  @override
  String get driftStatus => 'Worktree status';

  @override
  String get driftRemotes => 'Remote configuration';

  @override
  String get driftPathType => 'Path type';

  @override
  String get driftDestinationParent => 'Parent directory';

  @override
  String get driftDestinationExists => 'Target exists';

  @override
  String get driftDestinationEmpty => 'Target is empty';

  @override
  String get driftGitMetadata => 'Git metadata';

  @override
  String get driftSource => 'Source';

  @override
  String get driftRemoteName => 'Remote name';

  @override
  String get driftRemoteTargetBranch => 'Target branch';

  @override
  String get driftRemoteRefs => 'Remote refs';

  @override
  String get updateGithubNoRelease =>
      'No public GitHub Release is available. Open the release page for details.';

  @override
  String get updateGiteeNoRelease =>
      'No public Gitee Release is available. Open the release page for details.';

  @override
  String updateHttpError(String platform, String status) {
    return '$platform returned HTTP $status. Try again later.';
  }

  @override
  String get updateInvalidResponseGithub =>
      'The GitHub update response could not be parsed.';

  @override
  String get updateInvalidResponseGitee =>
      'The Gitee update response could not be parsed.';

  @override
  String get updateVersionMissingGithub =>
      'The public GitHub Release has no recognizable version.';

  @override
  String get updateVersionMissingGitee =>
      'The public Gitee Release has no recognizable version.';

  @override
  String get updateAssetMissingGithub =>
      'A new version exists, but its Release has no Windows x64 ZIP with SHA-256.';

  @override
  String get updateAvailableGithub =>
      'A new version is available for automatic download, verification, and restart.';

  @override
  String get updateAvailableGitee =>
      'A new Gitee version is available for automatic download, verification, and restart.';

  @override
  String updateUpToDate(String version) {
    return 'v$version is the latest GitHub version.';
  }

  @override
  String updateGiteeUpToDate(String version) {
    return 'v$version is the latest Gitee version.';
  }

  @override
  String get updateNetworkUnavailableGithub =>
      'Cannot connect to GitHub. Check the network and retry.';

  @override
  String get updateNetworkUnavailableGitee =>
      'Cannot connect to Gitee. Check the network and retry.';

  @override
  String get updateRequestFailed =>
      'The network request failed. Try again later.';

  @override
  String get updateGiteeRequestFailed =>
      'The Gitee request failed. Try again later.';

  @override
  String get updateGiteeDigestMissing =>
      'A Gitee update exists, but no trusted GitHub SHA-256 metadata is available. Automatic installation is disabled; open the release page to download manually.';

  @override
  String get updateProgressPreparing => 'Preparing automatic update…';

  @override
  String get updateProgressConnecting => 'Connecting to the Release download…';

  @override
  String updateProgressDownloading(String asset) {
    return 'Downloading $asset…';
  }

  @override
  String get updateProgressVerifying => 'Verifying the update archive SHA-256…';

  @override
  String get updateProgressExtracting =>
      'Extracting into an independent version directory…';

  @override
  String get updateProgressVerifyingRuntime =>
      'Validating the packaged PortableGit runtime…';

  @override
  String get updateProgressNotifyingLauncher =>
      'Notifying the Launcher to switch versions…';

  @override
  String get updatePackageMissing => 'The update archive does not exist.';

  @override
  String get updateWindowsOnly =>
      'Automatic updates currently support Windows only.';

  @override
  String get updateNoNewVersion => 'There is no new version to install.';

  @override
  String get updateAssetInvalid =>
      'The update asset is missing a download URL or valid SHA-256; automatic update was cancelled.';

  @override
  String get updateVersionInvalid =>
      'The update version contains invalid characters.';

  @override
  String updateInstallSuccess(String version) {
    return 'v$version is ready. The Launcher will switch versions and restart after the application exits.';
  }

  @override
  String get changelog0100Title =>
      'Structured runtime messages, Markdown guides, and safe links';

  @override
  String get changelog0100ItemMessages =>
      'Operation results, queued plans, and logs now use semantic templates, with stable event IDs, write-time locale, and credential redaction.';

  @override
  String get changelog0100ItemMarkdown =>
      'Bundled guides now use native Markdown rendering for headings, lists, tables, quotes, code blocks, images, and inline formatting.';

  @override
  String get changelog0100ItemLinks =>
      'Guide links are limited to HTTPS, bundled guides, and heading anchors, with keyboard focus, text selection, and responsive layouts.';

  @override
  String get changelog0100ItemTests =>
      'Added three-language guide resources, source regression checks, and complete structured-message test coverage.';

  @override
  String get changelog099Title =>
      'Branch sync, safe fast-forward pull, and commit identity checks';

  @override
  String get changelog099ItemSyncStatus =>
      'Shows upstream, ahead, behind, and worktree synchronization state.';

  @override
  String get changelog099ItemFetchPlan =>
      'Adds fetch plans for the current upstream or all remotes with per-remote results.';

  @override
  String get changelog099ItemFastForwardPull =>
      'Adds fast-forward-only pull and rejects dirty worktrees, missing upstreams, and diverged histories.';

  @override
  String get changelog099ItemGitIdentity =>
      'Checks valid Git author and committer identities before queueing and before execution.';

  @override
  String get guideLanguageEnglish => 'English';

  @override
  String get guideLanguageSimplifiedChinese => 'Simplified Chinese';

  @override
  String get guideLanguageTraditionalChinese => 'Traditional Chinese';

  @override
  String unableToOpenGuideLink(String error) {
    return 'Unable to open the guide link: $error';
  }
}
