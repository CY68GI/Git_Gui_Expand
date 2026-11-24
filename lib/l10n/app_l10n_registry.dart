import 'app_l10n.dart';

String localizeAppMessage(
  AppL10n l10n,
  String key, [
  Map<String, Object?> values = const {},
]) {
  switch (key) {
    case 'aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata':
      return l10n.aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata;
    case 'aWindowsFirstFlutterGraphicalFileWorkspaceForGit':
      return l10n.aWindowsFirstFlutterGraphicalFileWorkspaceForGit;
    case 'about':
      return l10n.about;
    case 'aboutInformationDoesNotChangeSettings':
      return l10n.aboutInformationDoesNotChangeSettings;
    case 'acknowledgements':
      return l10n.acknowledgements;
    case 'addClearOperationToPlan':
      return l10n.addClearOperationToPlan;
    case 'addClearToPlan':
      return l10n.addClearToPlan;
    case 'addCloneToPlan':
      return l10n.addCloneToPlan;
    case 'addCommitToPlan':
      return l10n.addCommitToPlan;
    case 'addDeletionOfItemsToThePlan':
      return l10n.addDeletionOfItemsToThePlan(
        values['count']?.toString() ?? '',
      );
    case 'addDeletionToPlan':
      return l10n.addDeletionToPlan;
    case 'addGitToPath':
      return l10n.addGitToPath;
    case 'addPortableGitTo':
      return l10n.addPortableGitTo(values['scope']?.toString() ?? '');
    case 'addPushAllPlan':
      return l10n.addPushAllPlan;
    case 'addPushAllToThePlan':
      return l10n.addPushAllToThePlan;
    case 'addPushOfToThePlan':
      return l10n.addPushOfToThePlan(values['branch']?.toString() ?? '');
    case 'addPushToPlan':
      return l10n.addPushToPlan;
    case 'addPushToToThePlan':
      return l10n.addPushToToThePlan(values['remote']?.toString() ?? '');
    case 'addRemote':
      return l10n.addRemote;
    case 'addRemovalOfRemoteToThePlan':
      return l10n.addRemovalOfRemoteToThePlan(
        values['remote']?.toString() ?? '',
      );
    case 'addRemovalToPlan':
      return l10n.addRemovalToPlan;
    case 'addToAddPlan':
      return l10n.addToAddPlan;
    case 'addToPlan':
      return l10n.addToPlan;
    case 'addToSystemPath':
      return l10n.addToSystemPath;
    case 'addToUpdatePlan':
      return l10n.addToUpdatePlan;
    case 'addToUserPath':
      return l10n.addToUserPath;
    case 'addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone':
      return l10n
          .addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
            values['path']?.toString() ?? '',
            values['url']?.toString() ?? '',
          );
    case 'afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution':
      return l10n
          .afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution;
    case 'ahead':
      return l10n.ahead;
    case 'allRemotesFetched':
      return l10n.allRemotesFetched(values['count']?.toString() ?? '');
    case 'allowedRange':
      return l10n.allowedRange(
        values['max']?.toString() ?? '',
        values['min']?.toString() ?? '',
      );
    case 'alreadyContainsPortablegit':
      return l10n.alreadyContainsPortablegit(values['scope']?.toString() ?? '');
    case 'alreadyOnBranch':
      return l10n.alreadyOnBranch(values['branch']?.toString() ?? '');
    case 'alsoSaveUntrackedFilesGitStashIncludeUntracked':
      return l10n.alsoSaveUntrackedFilesGitStashIncludeUntracked;
    case 'amberGold':
      return l10n.amberGold;
    case 'andMore':
      return l10n.andMore(values['count']?.toString() ?? '');
    case 'appName':
      return l10n.appName;
    case 'appearanceSettings':
      return l10n.appearanceSettings;
    case 'applicationLogs':
      return l10n.applicationLogs;
    case 'applyStash':
      return l10n.applyStash;
    case 'automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved':
      return l10n
          .automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved;
    case 'back':
      return l10n.back;
    case 'baseUnit':
      return l10n.baseUnit;
    case 'behind':
      return l10n.behind;
    case 'binaryUses1024StepsDecimalUses1000':
      return l10n.binaryUses1024StepsDecimalUses1000;
    case 'bitB':
      return l10n.bitB;
    case 'bootstrapPlanAlreadyUsed':
      return l10n.bootstrapPlanAlreadyUsed;
    case 'bootstrapStateChanged':
      return l10n.bootstrapStateChanged;
    case 'branchCreated':
      return l10n.branchCreated(values['branch']?.toString() ?? '');
    case 'branchDeleted':
      return l10n.branchDeleted(values['branch']?.toString() ?? '');
    case 'branchManagement':
      return l10n.branchManagement;
    case 'branchRenamed':
      return l10n.branchRenamed(
        values['from']?.toString() ?? '',
        values['to']?.toString() ?? '',
      );
    case 'branchSwitched':
      return l10n.branchSwitched(values['branch']?.toString() ?? '');
    case 'branchSynchronization':
      return l10n.branchSynchronization;
    case 'browseIndependentlyAndMoveAcrossPanes':
      return l10n.browseIndependentlyAndMoveAcrossPanes;
    case 'browseMoveCopyDeleteCommitAndPushThroughTheGitCli':
      return l10n.browseMoveCopyDeleteCommitAndPushThroughTheGitCli;
    case 'browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit':
      return l10n
          .browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit;
    case 'bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense':
      return l10n.bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense;
    case 'bundledLabel':
      return l10n.bundledLabel;
    case 'bundledPortablegit':
      return l10n.bundledPortablegit;
    case 'bundledUiFonts':
      return l10n.bundledUiFonts;
    case 'byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts':
      return l10n
          .byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts;
    case 'byteB':
      return l10n.byteB;
    case 'byteDisplaysBKibOrKbBitIsMultipliedBy8First':
      return l10n.byteDisplaysBKibOrKbBitIsMultipliedBy8First;
    case 'cancel':
      return l10n.cancel;
    case 'cancel2':
      return l10n.cancel2;
    case 'cancelEditing':
      return l10n.cancelEditing;
    case 'cannotDeleteCurrentBranch':
      return l10n.cannotDeleteCurrentBranch;
    case 'changed':
      return l10n.changed;
    case 'changelog0100ItemLinks':
      return l10n.changelog0100ItemLinks;
    case 'changelog0100ItemMarkdown':
      return l10n.changelog0100ItemMarkdown;
    case 'changelog0100ItemMessages':
      return l10n.changelog0100ItemMessages;
    case 'changelog0100ItemTests':
      return l10n.changelog0100ItemTests;
    case 'changelog0100Title':
      return l10n.changelog0100Title;
    case 'changelog099ItemFastForwardPull':
      return l10n.changelog099ItemFastForwardPull;
    case 'changelog099ItemFetchPlan':
      return l10n.changelog099ItemFetchPlan;
    case 'changelog099ItemGitIdentity':
      return l10n.changelog099ItemGitIdentity;
    case 'changelog099ItemSyncStatus':
      return l10n.changelog099ItemSyncStatus;
    case 'changelog099Title':
      return l10n.changelog099Title;
    case 'changes':
      return l10n.changes(values['count']?.toString() ?? '');
    case 'changesApplyAfterSaving':
      return l10n.changesApplyAfterSaving;
    case 'changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing':
      return l10n
          .changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing;
    case 'checkAgain':
      return l10n.checkAgain;
    case 'checkForUpdates':
      return l10n.checkForUpdates;
    case 'checking':
      return l10n.checking;
    case 'checking2':
      return l10n.checking2;
    case 'checkingForGit':
      return l10n.checkingForGit;
    case 'checkingForUpdates':
      return l10n.checkingForUpdates;
    case 'chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst':
      return l10n
          .chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst;
    case 'chooseCloneParentFolder':
      return l10n.chooseCloneParentFolder;
    case 'chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors':
      return l10n
          .chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors;
    case 'chooseFolder':
      return l10n.chooseFolder;
    case 'chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup':
      return l10n
          .chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup;
    case 'chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem':
      return l10n
          .chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem;
    case 'classicGreen':
      return l10n.classicGreen;
    case 'clean':
      return l10n.clean;
    case 'cleanAll':
      return l10n.cleanAll;
    case 'clearAllRemoteBranchesAndTagsDangerous':
      return l10n.clearAllRemoteBranchesAndTagsDangerous;
    case 'clearGitMetadata':
      return l10n.clearGitMetadata;
    case 'clearPlan':
      return l10n.clearPlan;
    case 'clearRemoteCompleted':
      return l10n.clearRemoteCompleted(
        values['branch']?.toString() ?? '',
        values['commit']?.toString() ?? '',
        values['remote']?.toString() ?? '',
      );
    case 'clearRemoteDrift':
      return l10n.clearRemoteDrift(
        values['branches']?.toString() ?? '',
        values['error']?.toString() ?? '',
        values['remote']?.toString() ?? '',
        values['tags']?.toString() ?? '',
      );
    case 'clearRemoteHistoryFor':
      return l10n.clearRemoteHistoryFor(values['remote']?.toString() ?? '');
    case 'clearRemoteMustRunAlone':
      return l10n.clearRemoteMustRunAlone;
    case 'clearSearch':
      return l10n.clearSearch;
    case 'clearSelection':
      return l10n.clearSelection;
    case 'clipboardCleared':
      return l10n.clipboardCleared;
    case 'clipboardEmpty':
      return l10n.clipboardEmpty;
    case 'clipboardPendingCopy':
      return l10n.clipboardPendingCopy(values['count']?.toString() ?? '');
    case 'clipboardPendingCut':
      return l10n.clipboardPendingCut(values['count']?.toString() ?? '');
    case 'cloneGitRepository':
      return l10n.cloneGitRepository;
    case 'cloneIntoParentFolder':
      return l10n.cloneIntoParentFolder;
    case 'close':
      return l10n.close;
    case 'closeUserGuide':
      return l10n.closeUserGuide;
    case 'closingTheRepository':
      return l10n.closingTheRepository;
    case 'colorScheme':
      return l10n.colorScheme;
    case 'commitAlreadyQueued':
      return l10n.commitAlreadyQueued;
    case 'commitIdentityUnavailable':
      return l10n.commitIdentityUnavailable;
    case 'commitMessage':
      return l10n.commitMessage;
    case 'commitMessageRequired':
      return l10n.commitMessageRequired;
    case 'commitMustRemainLast':
      return l10n.commitMustRemainLast;
    case 'commitSucceeded':
      return l10n.commitSucceeded;
    case 'commitWorkspace':
      return l10n.commitWorkspace;
    case 'commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun':
      return l10n.commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun;
    case 'confirmAdd':
      return l10n.confirmAdd;
    case 'confirmAndExecute':
      return l10n.confirmAndExecute;
    case 'confirmDangerousOperations':
      return l10n.confirmDangerousOperations;
    case 'confirmRemove':
      return l10n.confirmRemove;
    case 'controlHowProjectAndIndividualFileSizesAreDisplayed':
      return l10n.controlHowProjectAndIndividualFileSizesAreDisplayed;
    case 'copy':
      return l10n.copy;
    case 'createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher':
      return l10n
          .createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher;
    case 'createBranch':
      return l10n.createBranch;
    case 'createStash':
      return l10n.createStash;
    case 'creatingShortcut':
      return l10n.creatingShortcut;
    case 'current':
      return l10n.current;
    case 'currentBranch':
      return l10n.currentBranch;
    case 'currentBranch2':
      return l10n.currentBranch2(values['branch']?.toString() ?? '');
    case 'currentReleaseHighlights':
      return l10n.currentReleaseHighlights;
    case 'currentSelection':
      return l10n.currentSelection(values['theme']?.toString() ?? '');
    case 'currentV':
      return l10n.currentV(values['version']?.toString() ?? '');
    case 'currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained':
      return l10n
          .currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
            values['version']?.toString() ?? '',
          );
    case 'cut':
      return l10n.cut;
    case 'cutCopyRenamePushAndCommit0123456789':
      return l10n.cutCopyRenamePushAndCommit0123456789;
    case 'dark':
      return l10n.dark;
    case 'delete':
      return l10n.delete;
    case 'deleteBranch':
      return l10n.deleteBranch;
    case 'deleteStash':
      return l10n.deleteStash;
    case 'desktopShortcut':
      return l10n.desktopShortcut;
    case 'desktopShortcutCreated':
      return l10n.desktopShortcutCreated(values['path']?.toString() ?? '');
    case 'desktopShortcutWindowsOnly':
      return l10n.desktopShortcutWindowsOnly;
    case 'destinationFolder':
      return l10n.destinationFolder(values['path']?.toString() ?? '');
    case 'destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository':
      return l10n
          .destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
            values['path']?.toString() ?? '',
          );
    case 'detached':
      return l10n.detached;
    case 'detachedCannotPull':
      return l10n.detachedCannotPull;
    case 'detachedHead':
      return l10n.detachedHead;
    case 'detachedHeadCannotFetchCurrentUpstreamOrPullABranch':
      return l10n.detachedHeadCannotFetchCurrentUpstreamOrPullABranch;
    case 'detailedLog':
      return l10n.detailedLog;
    case 'detectTheGitRuntimeVersionSourceAndExecutableLocation':
      return l10n.detectTheGitRuntimeVersionSourceAndExecutableLocation;
    case 'detectionDetails':
      return l10n.detectionDetails(values['error']?.toString() ?? '');
    case 'dirtyWorktreeCannotPull':
      return l10n.dirtyWorktreeCannotPull;
    case 'discardPlanAndContinue':
      return l10n.discardPlanAndContinue;
    case 'discardThePendingOperationPlan':
      return l10n.discardThePendingOperationPlan;
    case 'displayMode':
      return l10n.displayMode;
    case 'doesNotContainTheManagedPortablegitPath':
      return l10n.doesNotContainTheManagedPortablegitPath(
        values['scope']?.toString() ?? '',
      );
    case 'doesNotExist':
      return l10n.doesNotExist;
    case 'done':
      return l10n.done;
    case 'doubleClickAFolderClickAPaneToChooseThePasteTarget':
      return l10n.doubleClickAFolderClickAPaneToChooseThePasteTarget;
    case 'doubleClickAFolderToOpen':
      return l10n.doubleClickAFolderToOpen;
    case 'downloadGit':
      return l10n.downloadGit;
    case 'driftBranch':
      return l10n.driftBranch;
    case 'driftDestinationEmpty':
      return l10n.driftDestinationEmpty;
    case 'driftDestinationExists':
      return l10n.driftDestinationExists;
    case 'driftDestinationParent':
      return l10n.driftDestinationParent;
    case 'driftGitMetadata':
      return l10n.driftGitMetadata;
    case 'driftHead':
      return l10n.driftHead;
    case 'driftPathType':
      return l10n.driftPathType;
    case 'driftRemoteName':
      return l10n.driftRemoteName;
    case 'driftRemoteRefs':
      return l10n.driftRemoteRefs;
    case 'driftRemoteTargetBranch':
      return l10n.driftRemoteTargetBranch;
    case 'driftRemotes':
      return l10n.driftRemotes;
    case 'driftRepositoryRoot':
      return l10n.driftRepositoryRoot;
    case 'driftSource':
      return l10n.driftSource;
    case 'driftStatus':
      return l10n.driftStatus;
    case 'dualPaneOperations':
      return l10n.dualPaneOperations;
    case 'editRemote':
      return l10n.editRemote;
    case 'editUrl':
      return l10n.editUrl;
    case 'emptyOperationPlan':
      return l10n.emptyOperationPlan;
    case 'enterACloneUrlParentFolderAndProjectName':
      return l10n.enterACloneUrlParentFolderAndProjectName;
    case 'enterACommitMessage':
      return l10n.enterACommitMessage;
    case 'enterProjectBranchToConfirm':
      return l10n.enterProjectBranchToConfirm(
        values['confirmation']?.toString() ?? '',
      );
    case 'enterProjectBranchToConfirmAgain':
      return l10n.enterProjectBranchToConfirmAgain(
        values['confirmation']?.toString() ?? '',
      );
    case 'exclusiveOperationAlreadyQueued':
      return l10n.exclusiveOperationAlreadyQueued;
    case 'exclusiveOperationMustRunAlone':
      return l10n.exclusiveOperationMustRunAlone;
    case 'executing':
      return l10n.executing;
    case 'executingStepByStep':
      return l10n.executingStepByStep;
    case 'executionComplete':
      return l10n.executionComplete;
    case 'executionIncomplete':
      return l10n.executionIncomplete;
    case 'fetchAllRemotes':
      return l10n.fetchAllRemotes;
    case 'fetchCurrentUpstream':
      return l10n.fetchCurrentUpstream;
    case 'fileChangesArePendingInTheOperationPlan':
      return l10n.fileChangesArePendingInTheOperationPlan;
    case 'fileRenamed':
      return l10n.fileRenamed(values['name']?.toString() ?? '');
    case 'files':
      return l10n.files;
    case 'filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns':
      return l10n
          .filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns;
    case 'folder':
      return l10n.folder;
    case 'followSystem':
      return l10n.followSystem;
    case 'followSystemDescription':
      return l10n.followSystemDescription;
    case 'followSystemLabel':
      return l10n.followSystemLabel;
    case 'followSystemSwitchesWithTheDeviceLightOrDarkAppearance':
      return l10n.followSystemSwitchesWithTheDeviceLightOrDarkAppearance;
    case 'followTheOperatingSystemWithoutAFixedFamily':
      return l10n.followTheOperatingSystemWithoutAFixedFamily;
    case 'font':
      return l10n.font;
    case 'fontDescription':
      return l10n.fontDescription;
    case 'fontPreview':
      return l10n.fontPreview;
    case 'fontSize':
      return l10n.fontSize;
    case 'forExampleFeatureLogin':
      return l10n.forExampleFeatureLogin;
    case 'forExampleOriginGiteeOrGitlab':
      return l10n.forExampleOriginGiteeOrGitlab;
    case 'forExampleTemporarilySaveUnfinishedChanges':
      return l10n.forExampleTemporarilySaveUnfinishedChanges;
    case 'forceGitBranchDWhenDeletingAnUnmergedBranch':
      return l10n.forceGitBranchDWhenDeletingAnUnmergedBranch;
    case 'foundItemsAndCanBeFreed':
      return l10n.foundItemsAndCanBeFreed(
        values['count']?.toString() ?? '',
        values['size']?.toString() ?? '',
      );
    case 'git':
      return l10n.git;
    case 'gitAvailable':
      return l10n.gitAvailable;
    case 'gitExecutableLocation':
      return l10n.gitExecutableLocation;
    case 'gitGuiExpandFileCommit':
      return l10n.gitGuiExpandFileCommit;
    case 'gitGuiExpandUserGuide':
      return l10n.gitGuiExpandUserGuide;
    case 'gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain':
      return l10n
          .gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain;
    case 'gitIsUnavailableRepositoryActionsAreDisabled':
      return l10n.gitIsUnavailableRepositoryActionsAreDisabled;
    case 'gitMetadata':
      return l10n.gitMetadata;
    case 'gitMetadataClearAvailable':
      return l10n.gitMetadataClearAvailable;
    case 'gitMetadataCleared':
      return l10n.gitMetadataCleared;
    case 'gitMetadataRemoteForbidden':
      return l10n.gitMetadataRemoteForbidden;
    case 'gitMvIndexCommit':
      return l10n.gitMvIndexCommit;
    case 'gitNotDetected':
      return l10n.gitNotDetected;
    case 'gitRepositories':
      return l10n.gitRepositories(values['count']?.toString() ?? '');
    case 'gitRepository':
      return l10n.gitRepository;
    case 'gitRepositoryCloned':
      return l10n.gitRepositoryCloned;
    case 'gitRepositoryInitialized':
      return l10n.gitRepositoryInitialized;
    case 'gitSettings':
      return l10n.gitSettings;
    case 'gitSource':
      return l10n.gitSource;
    case 'gitUnavailable':
      return l10n.gitUnavailable;
    case 'gitUnavailableHelp':
      return l10n.gitUnavailableHelp;
    case 'gitVersion':
      return l10n.gitVersion;
    case 'gitee':
      return l10n.gitee;
    case 'github':
      return l10n.github;
    case 'githubUsuallyProvidesTheInternationalReleaseBuild':
      return l10n.githubUsuallyProvidesTheInternationalReleaseBuild;
    case 'gotIt':
      return l10n.gotIt;
    case 'guide':
      return l10n.guide;
    case 'guideLanguageEnglish':
      return l10n.guideLanguageEnglish;
    case 'guideLanguageSimplifiedChinese':
      return l10n.guideLanguageSimplifiedChinese;
    case 'guideLanguageTraditionalChinese':
      return l10n.guideLanguageTraditionalChinese;
    case 'historyEntryRemoved':
      return l10n.historyEntryRemoved;
    case 'httpsOrGitHostOwnerRepoGit':
      return l10n.httpsOrGitHostOwnerRepoGit;
    case 'iReviewedTheseOperationsAndWantToExecuteThemInOrder':
      return l10n.iReviewedTheseOperationsAndWantToExecuteThemInOrder;
    case 'ibmPlexSansDescription':
      return l10n.ibmPlexSansDescription;
    case 'iec1024BaseBit':
      return l10n.iec1024BaseBit;
    case 'iec1024BaseByte':
      return l10n.iec1024BaseByte;
    case 'iecBinary':
      return l10n.iecBinary;
    case 'iecSiOptionalBits':
      return l10n.iecSiOptionalBits;
    case 'importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation':
      return l10n.importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation;
    case 'initializeGitRepository':
      return l10n.initializeGitRepository;
    case 'installedSystemFont':
      return l10n.installedSystemFont;
    case 'installing':
      return l10n.installing;
    case 'interUiDescription':
      return l10n.interUiDescription;
    case 'interfaceLanguage':
      return l10n.interfaceLanguage;
    case 'invalidStashSelector':
      return l10n.invalidStashSelector;
    case 'items':
      return l10n.items(values['count']?.toString() ?? '');
    case 'language':
      return l10n.language;
    case 'language2':
      return l10n.language2;
    case 'languageEnglishDescription':
      return l10n.languageEnglishDescription;
    case 'languageEnglishOptionLabel':
      return l10n.languageEnglishOptionLabel;
    case 'languageSimplifiedChineseDescription':
      return l10n.languageSimplifiedChineseDescription;
    case 'languageSimplifiedChineseOptionLabel':
      return l10n.languageSimplifiedChineseOptionLabel;
    case 'languageTraditionalChineseDescription':
      return l10n.languageTraditionalChineseDescription;
    case 'languageTraditionalChineseOptionLabel':
      return l10n.languageTraditionalChineseOptionLabel;
    case 'largeFile':
      return l10n.largeFile;
    case 'lastChecked':
      return l10n.lastChecked;
    case 'leftExplorer':
      return l10n.leftExplorer;
    case 'light':
      return l10n.light;
    case 'localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst':
      return l10n
          .localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst;
    case 'logDetail':
      return l10n.logDetail(values['eventId']?.toString() ?? '');
    case 'logError':
      return l10n.logError(values['eventId']?.toString() ?? '');
    case 'logInfo':
      return l10n.logInfo(values['eventId']?.toString() ?? '');
    case 'logReadFailed':
      return l10n.logReadFailed(values['error']?.toString() ?? '');
    case 'logWarning':
      return l10n.logWarning(values['eventId']?.toString() ?? '');
    case 'logs':
      return l10n.logs;
    case 'logsTruncated':
      return l10n.logsTruncated;
    case 'maintenanceKindGitRuntimeArchive':
      return l10n.maintenanceKindGitRuntimeArchive;
    case 'maintenanceKindGitRuntimeStaging':
      return l10n.maintenanceKindGitRuntimeStaging;
    case 'maintenanceKindLegacyFlatDirectory':
      return l10n.maintenanceKindLegacyFlatDirectory;
    case 'maintenanceKindLegacyFlatFile':
      return l10n.maintenanceKindLegacyFlatFile;
    case 'maintenanceKindLegacyUpdater':
      return l10n.maintenanceKindLegacyUpdater;
    case 'maintenanceKindObsoleteGitRuntime':
      return l10n.maintenanceKindObsoleteGitRuntime;
    case 'maintenanceKindOldVersion':
      return l10n.maintenanceKindOldVersion;
    case 'maintenanceKindPartialDownload':
      return l10n.maintenanceKindPartialDownload;
    case 'maintenanceKindStagingDirectory':
      return l10n.maintenanceKindStagingDirectory;
    case 'maintenanceKindUpdateArchive':
      return l10n.maintenanceKindUpdateArchive;
    case 'mediumFile':
      return l10n.mediumFile;
    case 'moreContentBelow':
      return l10n.moreContentBelow;
    case 'name':
      return l10n.name;
    case 'nameCannotBeEmpty':
      return l10n.nameCannotBeEmpty;
    case 'nativeGitChanges':
      return l10n.nativeGitChanges;
    case 'newBranchNameOrRenamedBranchName':
      return l10n.newBranchNameOrRenamedBranchName;
    case 'newName':
      return l10n.newName;
    case 'noBranch':
      return l10n.noBranch;
    case 'noBundledFontMatches':
      return l10n.noBundledFontMatches;
    case 'noChangesToCommit':
      return l10n.noChangesToCommit;
    case 'noCommittedBranchYet':
      return l10n.noCommittedBranchYet;
    case 'noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere':
      return l10n
          .noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere;
    case 'noFilesHere':
      return l10n.noFilesHere;
    case 'noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents':
      return l10n.noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents;
    case 'noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean':
      return l10n.noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean;
    case 'noPendingOperations':
      return l10n.noPendingOperations;
    case 'noPendingSteps':
      return l10n.noPendingSteps;
    case 'noProjectIsOpen':
      return l10n.noProjectIsOpen;
    case 'noRemoteRepositoryWasDetected':
      return l10n.noRemoteRepositoryWasDetected;
    case 'noRemotesConfigured':
      return l10n.noRemotesConfigured;
    case 'noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote':
      return l10n.noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote;
    case 'noRepositoryOpen':
      return l10n.noRepositoryOpen;
    case 'noSystemFontMatches':
      return l10n.noSystemFontMatches;
    case 'noUpstream':
      return l10n.noUpstream;
    case 'noUsableGitWasDetectedInstallItAndCheckAgain':
      return l10n.noUsableGitWasDetectedInstallItAndCheckAgain;
    case 'none':
      return l10n.none;
    case 'normalLog':
      return l10n.normalLog;
    case 'notCheckedYet':
      return l10n.notCheckedYet;
    case 'notConfigured':
      return l10n.notConfigured;
    case 'notDetected':
      return l10n.notDetected;
    case 'nothingIsPushedYetThePlanPushesTo':
      return l10n.nothingIsPushedYetThePlanPushesTo(
        values['branch']?.toString() ?? '',
        values['platform']?.toString() ?? '',
        values['url']?.toString() ?? '',
      );
    case 'nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded':
      return l10n
          .nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded;
    case 'notoSansScDescription':
      return l10n.notoSansScDescription;
    case 'oceanBlue':
      return l10n.oceanBlue;
    case 'oldVersionAndInstallerCleanup':
      return l10n.oldVersionAndInstallerCleanup;
    case 'oneClickSendToDesktop':
      return l10n.oneClickSendToDesktop;
    case 'onlineReleaseNotes':
      return l10n.onlineReleaseNotes;
    case 'onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath':
      return l10n
          .onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath;
    case 'onlyTheLocalGitRemoteConfigurationIsRemoved':
      return l10n.onlyTheLocalGitRemoteConfigurationIsRemoved;
    case 'onlyVerifiedRepositoryRootsAreSaved':
      return l10n.onlyVerifiedRepositoryRootsAreSaved;
    case 'open':
      return l10n.open;
    case 'openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository':
      return l10n
          .openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository;
    case 'openAnotherFolderOrRefreshToViewRepositoryContents':
      return l10n.openAnotherFolderOrRefreshToViewRepositoryContents;
    case 'openEmptyFolder':
      return l10n.openEmptyFolder;
    case 'openFolder':
      return l10n.openFolder;
    case 'openGitRepository':
      return l10n.openGitRepository;
    case 'openReleasePage':
      return l10n.openReleasePage;
    case 'openRepository':
      return l10n.openRepository;
    case 'openRepository2':
      return l10n.openRepository2;
    case 'openWithDefaultApp':
      return l10n.openWithDefaultApp;
    case 'openingAnotherRepository':
      return l10n.openingAnotherRepository;
    case 'openingRepository':
      return l10n.openingRepository;
    case 'operationCompleted':
      return l10n.operationCompleted;
    case 'operationCompletedFor':
      return l10n.operationCompletedFor(values['target']?.toString() ?? '');
    case 'operationCompletedForItems':
      return l10n.operationCompletedForItems(values['count']?.toString() ?? '');
    case 'operationFailed':
      return l10n.operationFailed(values['error']?.toString() ?? '');
    case 'operationFailedFor':
      return l10n.operationFailedFor(
        values['error']?.toString() ?? '',
        values['target']?.toString() ?? '',
      );
    case 'operationInProgress':
      return l10n.operationInProgress;
    case 'operationPlanBusyClear':
      return l10n.operationPlanBusyClear;
    case 'operationPlanBusyEdit':
      return l10n.operationPlanBusyEdit;
    case 'optionsFound':
      return l10n.optionsFound(values['count']?.toString() ?? '');
    case 'parentFolder':
      return l10n.parentFolder;
    case 'paste':
      return l10n.paste;
    case 'pasteTarget':
      return l10n.pasteTarget;
    case 'pasteToLeft':
      return l10n.pasteToLeft;
    case 'pasteToRight':
      return l10n.pasteToRight;
    case 'pathChangeCancelled':
      return l10n.pathChangeCancelled;
    case 'pathChangeFailed':
      return l10n.pathChangeFailed(values['error']?.toString() ?? '');
    case 'pending':
      return l10n.pending(values['count']?.toString() ?? '');
    case 'pending2':
      return l10n.pending2;
    case 'pendingOperationPlan':
      return l10n.pendingOperationPlan;
    case 'planCleared':
      return l10n.planCleared(values['count']?.toString() ?? '');
    case 'planDangerousAcknowledgmentRequired':
      return l10n.planDangerousAcknowledgmentRequired;
    case 'planDescriptionAddRemote':
      return l10n.planDescriptionAddRemote(
        values['remote']?.toString() ?? '',
        values['url']?.toString() ?? '',
      );
    case 'planDescriptionApplyStash':
      return l10n.planDescriptionApplyStash(
        values['selector']?.toString() ?? '',
      );
    case 'planDescriptionClearGitMetadata':
      return l10n.planDescriptionClearGitMetadata(
        values['path']?.toString() ?? '',
      );
    case 'planDescriptionClearRemote':
      return l10n.planDescriptionClearRemote(
        values['branch']?.toString() ?? '',
        values['branches']?.toString() ?? '',
        values['message']?.toString() ?? '',
        values['project']?.toString() ?? '',
        values['tags']?.toString() ?? '',
      );
    case 'planDescriptionCloneRepository':
      return l10n.planDescriptionCloneRepository(
        values['path']?.toString() ?? '',
        values['url']?.toString() ?? '',
      );
    case 'planDescriptionCommitAll':
      return l10n.planDescriptionCommitAll(values['message']?.toString() ?? '');
    case 'planDescriptionCopy':
      return l10n.planDescriptionCopy(
        values['count']?.toString() ?? '',
        values['destination']?.toString() ?? '',
      );
    case 'planDescriptionCreateBranch':
      return l10n.planDescriptionCreateBranch(
        values['branch']?.toString() ?? '',
      );
    case 'planDescriptionCreateStash':
      return l10n.planDescriptionCreateStash(
        values['message']?.toString() ?? '',
      );
    case 'planDescriptionCreateStashIncludeUntracked':
      return l10n.planDescriptionCreateStashIncludeUntracked(
        values['message']?.toString() ?? '',
      );
    case 'planDescriptionDelete':
      return l10n.planDescriptionDelete(
        values['count']?.toString() ?? '',
        values['paths']?.toString() ?? '',
      );
    case 'planDescriptionDeleteBranchForce':
      return l10n.planDescriptionDeleteBranchForce(
        values['branch']?.toString() ?? '',
      );
    case 'planDescriptionDeleteBranchSafe':
      return l10n.planDescriptionDeleteBranchSafe(
        values['branch']?.toString() ?? '',
      );
    case 'planDescriptionDropStash':
      return l10n.planDescriptionDropStash(
        values['selector']?.toString() ?? '',
      );
    case 'planDescriptionFetchAllRemotes':
      return l10n.planDescriptionFetchAllRemotes(
        values['remotes']?.toString() ?? '',
      );
    case 'planDescriptionFetchRemote':
      return l10n.planDescriptionFetchRemote(
        values['remote']?.toString() ?? '',
      );
    case 'planDescriptionInitializeRepository':
      return l10n.planDescriptionInitializeRepository(
        values['path']?.toString() ?? '',
      );
    case 'planDescriptionMove':
      return l10n.planDescriptionMove(
        values['count']?.toString() ?? '',
        values['destination']?.toString() ?? '',
      );
    case 'planDescriptionPopStash':
      return l10n.planDescriptionPopStash(values['selector']?.toString() ?? '');
    case 'planDescriptionPull':
      return l10n.planDescriptionPull(
        values['branch']?.toString() ?? '',
        values['remote']?.toString() ?? '',
        values['upstream']?.toString() ?? '',
      );
    case 'planDescriptionPushAllRemotes':
      return l10n.planDescriptionPushAllRemotes(
        values['remotes']?.toString() ?? '',
      );
    case 'planDescriptionPushCurrent':
      return l10n.planDescriptionPushCurrent;
    case 'planDescriptionPushRemote':
      return l10n.planDescriptionPushRemote(
        values['branch']?.toString() ?? '',
        values['remote']?.toString() ?? '',
      );
    case 'planDescriptionRemoveRemote':
      return l10n.planDescriptionRemoveRemote;
    case 'planDescriptionRename':
      return l10n.planDescriptionRename(
        values['newName']?.toString() ?? '',
        values['source']?.toString() ?? '',
      );
    case 'planDescriptionRenameBranch':
      return l10n.planDescriptionRenameBranch(
        values['from']?.toString() ?? '',
        values['to']?.toString() ?? '',
      );
    case 'planDescriptionStageAll':
      return l10n.planDescriptionStageAll;
    case 'planDescriptionSwitchBranch':
      return l10n.planDescriptionSwitchBranch(
        values['branch']?.toString() ?? '',
      );
    case 'planDescriptionUnstageAll':
      return l10n.planDescriptionUnstageAll;
    case 'planDescriptionUpdateRemote':
      return l10n.planDescriptionUpdateRemote(
        values['remote']?.toString() ?? '',
        values['url']?.toString() ?? '',
      );
    case 'planExecutionComplete':
      return l10n.planExecutionComplete(values['count']?.toString() ?? '');
    case 'planKindAddRemote':
      return l10n.planKindAddRemote;
    case 'planKindApplyStash':
      return l10n.planKindApplyStash;
    case 'planKindClearGitMetadata':
      return l10n.planKindClearGitMetadata;
    case 'planKindClearRemote':
      return l10n.planKindClearRemote;
    case 'planKindClone':
      return l10n.planKindClone;
    case 'planKindCommit':
      return l10n.planKindCommit;
    case 'planKindCopy':
      return l10n.planKindCopy;
    case 'planKindCreateBranch':
      return l10n.planKindCreateBranch;
    case 'planKindCreateStash':
      return l10n.planKindCreateStash;
    case 'planKindDelete':
      return l10n.planKindDelete;
    case 'planKindDeleteBranch':
      return l10n.planKindDeleteBranch;
    case 'planKindDropStash':
      return l10n.planKindDropStash;
    case 'planKindFetchAll':
      return l10n.planKindFetchAll;
    case 'planKindFetchCurrent':
      return l10n.planKindFetchCurrent;
    case 'planKindInitialize':
      return l10n.planKindInitialize;
    case 'planKindMove':
      return l10n.planKindMove;
    case 'planKindPopStash':
      return l10n.planKindPopStash;
    case 'planKindPull':
      return l10n.planKindPull;
    case 'planKindPush':
      return l10n.planKindPush;
    case 'planKindPushAll':
      return l10n.planKindPushAll;
    case 'planKindRemoveRemote':
      return l10n.planKindRemoveRemote;
    case 'planKindRename':
      return l10n.planKindRename;
    case 'planKindRenameBranch':
      return l10n.planKindRenameBranch;
    case 'planKindStageAll':
      return l10n.planKindStageAll;
    case 'planKindSwitchBranch':
      return l10n.planKindSwitchBranch;
    case 'planKindUnstageAll':
      return l10n.planKindUnstageAll;
    case 'planKindUpdateRemote':
      return l10n.planKindUpdateRemote;
    case 'planOperationAdded':
      return l10n.planOperationAdded;
    case 'planOperationMissing':
      return l10n.planOperationMissing;
    case 'planOperationRemoved':
      return l10n.planOperationRemoved;
    case 'planSnapshotFailed':
      return l10n.planSnapshotFailed(values['error']?.toString() ?? '');
    case 'planStateChanged':
      return l10n.planStateChanged;
    case 'planStepFailed':
      return l10n.planStepFailed(
        values['error']?.toString() ?? '',
        values['step']?.toString() ?? '',
      );
    case 'planStepStateChanged':
      return l10n.planStepStateChanged(values['step']?.toString() ?? '');
    case 'planStrongConfirmationRequired':
      return l10n.planStrongConfirmationRequired(
        values['confirmation']?.toString() ?? '',
      );
    case 'planTitleAddRemote':
      return l10n.planTitleAddRemote(values['remote']?.toString() ?? '');
    case 'planTitleApplyStash':
      return l10n.planTitleApplyStash(values['selector']?.toString() ?? '');
    case 'planTitleClearGitMetadata':
      return l10n.planTitleClearGitMetadata;
    case 'planTitleClearRemote':
      return l10n.planTitleClearRemote(values['remote']?.toString() ?? '');
    case 'planTitleCloneRepository':
      return l10n.planTitleCloneRepository;
    case 'planTitleCommitAll':
      return l10n.planTitleCommitAll;
    case 'planTitleCopy':
      return l10n.planTitleCopy(
        values['count']?.toString() ?? '',
        values['destination']?.toString() ?? '',
      );
    case 'planTitleCreateBranch':
      return l10n.planTitleCreateBranch(values['branch']?.toString() ?? '');
    case 'planTitleCreateStash':
      return l10n.planTitleCreateStash;
    case 'planTitleCreateStashNamed':
      return l10n.planTitleCreateStashNamed(
        values['message']?.toString() ?? '',
      );
    case 'planTitleDelete':
      return l10n.planTitleDelete(values['count']?.toString() ?? '');
    case 'planTitleDeleteBranch':
      return l10n.planTitleDeleteBranch(values['branch']?.toString() ?? '');
    case 'planTitleDropStash':
      return l10n.planTitleDropStash(values['selector']?.toString() ?? '');
    case 'planTitleFetchAllRemotes':
      return l10n.planTitleFetchAllRemotes(values['count']?.toString() ?? '');
    case 'planTitleFetchRemote':
      return l10n.planTitleFetchRemote(values['remote']?.toString() ?? '');
    case 'planTitleInitializeRepository':
      return l10n.planTitleInitializeRepository;
    case 'planTitleMove':
      return l10n.planTitleMove(
        values['count']?.toString() ?? '',
        values['destination']?.toString() ?? '',
      );
    case 'planTitlePopStash':
      return l10n.planTitlePopStash(values['selector']?.toString() ?? '');
    case 'planTitlePull':
      return l10n.planTitlePull(values['branch']?.toString() ?? '');
    case 'planTitlePushAllRemotes':
      return l10n.planTitlePushAllRemotes(values['count']?.toString() ?? '');
    case 'planTitlePushBranch':
      return l10n.planTitlePushBranch(values['branch']?.toString() ?? '');
    case 'planTitlePushCurrent':
      return l10n.planTitlePushCurrent;
    case 'planTitlePushRemote':
      return l10n.planTitlePushRemote(values['remote']?.toString() ?? '');
    case 'planTitleRemoveRemote':
      return l10n.planTitleRemoveRemote(values['remote']?.toString() ?? '');
    case 'planTitleRename':
      return l10n.planTitleRename(values['source']?.toString() ?? '');
    case 'planTitleRenameBranch':
      return l10n.planTitleRenameBranch(
        values['from']?.toString() ?? '',
        values['to']?.toString() ?? '',
      );
    case 'planTitleStageAll':
      return l10n.planTitleStageAll;
    case 'planTitleSwitchBranch':
      return l10n.planTitleSwitchBranch(values['branch']?.toString() ?? '');
    case 'planTitleUnstageAll':
      return l10n.planTitleUnstageAll;
    case 'planTitleUpdateRemote':
      return l10n.planTitleUpdateRemote(values['remote']?.toString() ?? '');
    case 'plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur':
      return l10n
          .plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
            values['action']?.toString() ?? '',
            values['count']?.toString() ?? '',
          );
    case 'popStash':
      return l10n.popStash;
    case 'preciseSizeView':
      return l10n.preciseSizeView;
    case 'preparingToExecute':
      return l10n.preparingToExecute;
    case 'preparingUpdate':
      return l10n.preparingUpdate;
    case 'projectFolder':
      return l10n.projectFolder;
    case 'projectFolderName':
      return l10n.projectFolderName;
    case 'projectSize':
      return l10n.projectSize;
    case 'projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation':
      return l10n
          .projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
            values['branch']?.toString() ?? '',
            values['confirmation']?.toString() ?? '',
            values['message']?.toString() ?? '',
            values['project']?.toString() ?? '',
            values['target']?.toString() ?? '',
          );
    case 'pullAhead':
      return l10n.pullAhead;
    case 'pullCompleted':
      return l10n.pullCompleted(
        values['branch']?.toString() ?? '',
        values['upstream']?.toString() ?? '',
      );
    case 'pullDiverged':
      return l10n.pullDiverged;
    case 'pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex':
      return l10n
          .pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex;
    case 'pullNoUpdate':
      return l10n.pullNoUpdate;
    case 'pullRelationUnknown':
      return l10n.pullRelationUnknown;
    case 'pullUpToDate':
      return l10n.pullUpToDate;
    case 'push':
      return l10n.push;
    case 'pushAll':
      return l10n.pushAll;
    case 'pushCurrentBranchCtrlShiftU':
      return l10n.pushCurrentBranchCtrlShiftU;
    case 'pushedBranch':
      return l10n.pushedBranch(values['branch']?.toString() ?? '');
    case 'pushedCurrentBranch':
      return l10n.pushedCurrentBranch;
    case 'pushedToAllRemotes':
      return l10n.pushedToAllRemotes(values['count']?.toString() ?? '');
    case 'pushedToRemote':
      return l10n.pushedToRemote(values['remote']?.toString() ?? '');
    case 'readingBranchesAndTagsFrom':
      return l10n.readingBranchesAndTagsFrom(
        values['remote']?.toString() ?? '',
      );
    case 'readingSynchronizationState':
      return l10n.readingSynchronizationState;
    case 'recentlyOpened':
      return l10n.recentlyOpened;
    case 'refresh':
      return l10n.refresh;
    case 'refreshBranches':
      return l10n.refreshBranches;
    case 'refreshLogs':
      return l10n.refreshLogs;
    case 'refreshRemotes':
      return l10n.refreshRemotes;
    case 'refreshRepositoryAndRebuildPlan':
      return l10n.refreshRepositoryAndRebuildPlan;
    case 'refreshRepositoryCtrlR':
      return l10n.refreshRepositoryCtrlR;
    case 'refreshStashes':
      return l10n.refreshStashes;
    case 'refreshSynchronizationState':
      return l10n.refreshSynchronizationState;
    case 'remoteAdded':
      return l10n.remoteAdded(values['remote']?.toString() ?? '');
    case 'remoteBatchPartialFailure':
      return l10n.remoteBatchPartialFailure(
        values['details']?.toString() ?? '',
        values['failed']?.toString() ?? '',
        values['succeeded']?.toString() ?? '',
      );
    case 'remoteCheck':
      return l10n.remoteCheck;
    case 'remoteFetched':
      return l10n.remoteFetched(values['remote']?.toString() ?? '');
    case 'remoteInspectionCounts':
      return l10n.remoteInspectionCounts(
        values['branches']?.toString() ?? '',
        values['remote']?.toString() ?? '',
        values['tags']?.toString() ?? '',
      );
    case 'remoteInspectionEmpty':
      return l10n.remoteInspectionEmpty(values['remote']?.toString() ?? '');
    case 'remoteListRefreshed':
      return l10n.remoteListRefreshed;
    case 'remoteName':
      return l10n.remoteName;
    case 'remoteRefList':
      return l10n.remoteRefList;
    case 'remoteRemoved':
      return l10n.remoteRemoved(values['remote']?.toString() ?? '');
    case 'remoteRepositoriesWereDetectedSoClearingIsDisabled':
      return l10n.remoteRepositoriesWereDetectedSoClearingIsDisabled(
        values['remotes']?.toString() ?? '',
      );
    case 'remoteRepositoryUrl':
      return l10n.remoteRepositoryUrl;
    case 'remoteUpdated':
      return l10n.remoteUpdated(values['remote']?.toString() ?? '');
    case 'remoteUrl':
      return l10n.remoteUrl;
    case 'remotes':
      return l10n.remotes(values['count']?.toString() ?? '');
    case 'remotes2':
      return l10n.remotes2;
    case 'removeFromHistory':
      return l10n.removeFromHistory;
    case 'removeFromPlan':
      return l10n.removeFromPlan;
    case 'removeFromSystemPath':
      return l10n.removeFromSystemPath;
    case 'removeFromUserPath':
      return l10n.removeFromUserPath;
    case 'removeLocalRemoteConfiguration':
      return l10n.removeLocalRemoteConfiguration;
    case 'removePortableGitFrom':
      return l10n.removePortableGitFrom(values['scope']?.toString() ?? '');
    case 'removedItemsAndFreed':
      return l10n.removedItemsAndFreed(
        values['count']?.toString() ?? '',
        values['size']?.toString() ?? '',
      );
    case 'removedItemsCouldNotBeDeletedCheckTheDetailedLog':
      return l10n.removedItemsCouldNotBeDeletedCheckTheDetailedLog(
        values['failed']?.toString() ?? '',
        values['removed']?.toString() ?? '',
      );
    case 'rename':
      return l10n.rename;
    case 'renameBranch':
      return l10n.renameBranch;
    case 'renameSelectOne':
      return l10n.renameSelectOne;
    case 'repository':
      return l10n.repository(values['path']?.toString() ?? '');
    case 'repositoryAndRemoteOperationsAreAvailable':
      return l10n.repositoryAndRemoteOperationsAreAvailable;
    case 'repositoryViewRefreshed':
      return l10n.repositoryViewRefreshed;
    case 'reviewRemoveOrExecutePendingOperations':
      return l10n.reviewRemoveOrExecutePendingOperations;
    case 'rightExplorer':
      return l10n.rightExplorer;
    case 'roseRed':
      return l10n.roseRed;
    case 'safeFastForwardPull':
      return l10n.safeFastForwardPull;
    case 'saveSettings':
      return l10n.saveSettings;
    case 'saveSettings2':
      return l10n.saveSettings2;
    case 'scanAgain':
      return l10n.scanAgain;
    case 'scanOldVersionsAndInstallers':
      return l10n.scanOldVersionsAndInstallers;
    case 'scrollDownForFontPreviewAndFontSizeSettings':
      return l10n.scrollDownForFontPreviewAndFontSizeSettings;
    case 'searchFontNameOrPurposeEGInterOrNoto':
      return l10n.searchFontNameOrPurposeEGInterOrNoto;
    case 'selectAnItemToRename':
      return l10n.selectAnItemToRename;
    case 'selectExactlyOneItemToRename':
      return l10n.selectExactlyOneItemToRename;
    case 'selectFilesToCutOrCopy':
      return l10n.selectFilesToCutOrCopy;
    case 'selectItemsFirst':
      return l10n.selectItemsFirst;
    case 'selectItemsToDelete':
      return l10n.selectItemsToDelete;
    case 'selectTheDangerousOperationConfirmationFirst':
      return l10n.selectTheDangerousOperationConfirmationFirst;
    case 'selected':
      return l10n.selected(values['count']?.toString() ?? '');
    case 'selected2':
      return l10n.selected2(values['count']?.toString() ?? '');
    case 'settings':
      return l10n.settings;
    case 'settings2':
      return l10n.settings2;
    case 'settingsDataDirectory':
      return l10n.settingsDataDirectory;
    case 'settingsSaved':
      return l10n.settingsSaved;
    case 'showInFileExplorer':
      return l10n.showInFileExplorer;
    case 'si1000BaseBit':
      return l10n.si1000BaseBit;
    case 'si1000BaseByte':
      return l10n.si1000BaseByte;
    case 'siDecimal':
      return l10n.siDecimal;
    case 'size':
      return l10n.size;
    case 'sizeUnitSystem':
      return l10n.sizeUnitSystem;
    case 'smallFile':
      return l10n.smallFile;
    case 'stageAll':
      return l10n.stageAll;
    case 'stageAllCompleted':
      return l10n.stageAllCompleted;
    case 'staged':
      return l10n.staged(values['count']?.toString() ?? '');
    case 'starryViolet':
      return l10n.starryViolet;
    case 'stash':
      return l10n.stash;
    case 'stashApplied':
      return l10n.stashApplied(values['selector']?.toString() ?? '');
    case 'stashCreated':
      return l10n.stashCreated;
    case 'stashDropped':
      return l10n.stashDropped(values['selector']?.toString() ?? '');
    case 'stashManagement':
      return l10n.stashManagement;
    case 'stashMessageOptional':
      return l10n.stashMessageOptional;
    case 'stashPopped':
      return l10n.stashPopped(values['selector']?.toString() ?? '');
    case 'stateChangeDetails':
      return l10n.stateChangeDetails;
    case 'stateChangedBeforeExecution':
      return l10n.stateChangedBeforeExecution;
    case 'status':
      return l10n.status;
    case 'step':
      return l10n.step(
        values['step']?.toString() ?? '',
        values['title']?.toString() ?? '',
      );
    case 'stepsCount':
      return l10n.stepsCount(values['count']?.toString() ?? '');
    case 'stepsTheRepositoryIsUnchangedUntilConfirmation':
      return l10n.stepsTheRepositoryIsUnchangedUntilConfirmation(
        values['count']?.toString() ?? '',
      );
    case 'supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst':
      return l10n
          .supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst;
    case 'switchBranch':
      return l10n.switchBranch;
    case 'sync':
      return l10n.sync;
    case 'syncAuthenticationFailed':
      return l10n.syncAuthenticationFailed(values['error']?.toString() ?? '');
    case 'syncNetworkFailed':
      return l10n.syncNetworkFailed(values['error']?.toString() ?? '');
    case 'syncStateUnavailable':
      return l10n.syncStateUnavailable;
    case 'systemDefaultAutomatic':
      return l10n.systemDefaultAutomatic;
    case 'systemFonts':
      return l10n.systemFonts;
    case 'systemGit':
      return l10n.systemGit;
    case 'systemPath':
      return l10n.systemPath;
    case 'textCanBeSelectedAndCopiedHereTheFullGuideIsIn':
      return l10n.textCanBeSelectedAndCopiedHereTheFullGuideIsIn(
        values['path']?.toString() ?? '',
      );
    case 'thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject':
      return l10n
          .thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject;
    case 'theCloneDestinationFolderIsNotEmpty':
      return l10n.theCloneDestinationFolderIsNotEmpty;
    case 'theCloneDestinationParentFolderDoesNotExist':
      return l10n.theCloneDestinationParentFolderDoesNotExist;
    case 'theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText':
      return l10n
          .theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText;
    case 'theCurrentBranchHasNoCommitAndCannotBePulled':
      return l10n.theCurrentBranchHasNoCommitAndCannotBePulled;
    case 'theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking':
      return l10n
          .theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking;
    case 'theCurrentBranchIsSynchronizedWithUpstream':
      return l10n.theCurrentBranchIsSynchronizedWithUpstream;
    case 'theDetailedReasonHasBeenWrittenToTheApplicationLog':
      return l10n.theDetailedReasonHasBeenWrittenToTheApplicationLog;
    case 'theGiteeSourceIsSuitedToMainlandChinaNetworks':
      return l10n.theGiteeSourceIsSuitedToMainlandChinaNetworks;
    case 'theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata':
      return l10n
          .theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata;
    case 'theLanguageChangeTakesEffectImmediatelyAfterSaving':
      return l10n.theLanguageChangeTakesEffectImmediatelyAfterSaving;
    case 'theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull':
      return l10n.theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull;
    case 'theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone':
      return l10n
          .theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone;
    case 'thePlanPushesTo':
      return l10n.thePlanPushesTo(
        values['branch']?.toString() ?? '',
        values['remotes']?.toString() ?? '',
      );
    case 'theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated':
      return l10n.theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated;
    case 'theRepositoryHasNoStashes':
      return l10n.theRepositoryHasNoStashes;
    case 'theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes':
      return l10n.theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes;
    case 'theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull':
      return l10n.theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull;
    case 'thereAreNoLocalBranchesToDisplay':
      return l10n.thereAreNoLocalBranchesToDisplay;
    case 'thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation':
      return l10n.thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation;
    case 'thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles':
      return l10n
          .thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
            values['branch']?.toString() ?? '',
          );
    case 'thisOperationDeletesTheGitFolderInTheRepositoryRoot':
      return l10n.thisOperationDeletesTheGitFolderInTheRepositoryRoot;
    case 'thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit':
      return l10n
          .thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
            values['count']?.toString() ?? '',
          );
    case 'thisProjectIsLicensedUnderTheMitLicense':
      return l10n.thisProjectIsLicensedUnderTheMitLicense;
    case 'threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge':
      return l10n.threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge;
    case 'today':
      return l10n.today(values['time']?.toString() ?? '');
    case 'turnGitFileOperationsIntoAnIntuitiveWorkspace':
      return l10n.turnGitFileOperationsIntoAnIntuitiveWorkspace;
    case 'typeANameToFilter':
      return l10n.typeANameToFilter;
    case 'unableToInspectRepository':
      return l10n.unableToInspectRepository;
    case 'unableToOpenFile':
      return l10n.unableToOpenFile(values['error']?.toString() ?? '');
    case 'unableToOpenGuideLink':
      return l10n.unableToOpenGuideLink(values['error']?.toString() ?? '');
    case 'unableToOpenLogsFolder':
      return l10n.unableToOpenLogsFolder(values['error']?.toString() ?? '');
    case 'unableToOpenProjectFolder':
      return l10n.unableToOpenProjectFolder(values['error']?.toString() ?? '');
    case 'unableToOpenTheGitDownloadPage':
      return l10n.unableToOpenTheGitDownloadPage(
        values['error']?.toString() ?? '',
      );
    case 'unableToReadBranchSynchronizationStateRefreshAndTryAgain':
      return l10n.unableToReadBranchSynchronizationStateRefreshAndTryAgain;
    case 'unableToReadFolder':
      return l10n.unableToReadFolder;
    case 'unableToReadUserGuide':
      return l10n.unableToReadUserGuide(values['error']?.toString() ?? '');
    case 'unableToRetrieveTheOnlineVersion':
      return l10n.unableToRetrieveTheOnlineVersion;
    case 'unbornCannotPull':
      return l10n.unbornCannotPull;
    case 'unitPreview':
      return l10n.unitPreview;
    case 'units':
      return l10n.units;
    case 'unstage':
      return l10n.unstage;
    case 'unstageAllCompleted':
      return l10n.unstageAllCompleted;
    case 'updateAndRestartNow':
      return l10n.updateAndRestartNow;
    case 'updateAssetInvalid':
      return l10n.updateAssetInvalid;
    case 'updateAssetMissingGithub':
      return l10n.updateAssetMissingGithub;
    case 'updateAvailableGitee':
      return l10n.updateAvailableGitee;
    case 'updateAvailableGithub':
      return l10n.updateAvailableGithub;
    case 'updateGiteeDigestMissing':
      return l10n.updateGiteeDigestMissing;
    case 'updateGiteeNoRelease':
      return l10n.updateGiteeNoRelease;
    case 'updateGiteeRequestFailed':
      return l10n.updateGiteeRequestFailed;
    case 'updateGiteeUpToDate':
      return l10n.updateGiteeUpToDate(values['version']?.toString() ?? '');
    case 'updateGithubNoRelease':
      return l10n.updateGithubNoRelease;
    case 'updateHttpError':
      return l10n.updateHttpError(
        values['platform']?.toString() ?? '',
        values['status']?.toString() ?? '',
      );
    case 'updateInstallSuccess':
      return l10n.updateInstallSuccess(values['version']?.toString() ?? '');
    case 'updateInvalidResponseGitee':
      return l10n.updateInvalidResponseGitee;
    case 'updateInvalidResponseGithub':
      return l10n.updateInvalidResponseGithub;
    case 'updateNetworkUnavailableGitee':
      return l10n.updateNetworkUnavailableGitee;
    case 'updateNetworkUnavailableGithub':
      return l10n.updateNetworkUnavailableGithub;
    case 'updateNoNewVersion':
      return l10n.updateNoNewVersion;
    case 'updatePackageMissing':
      return l10n.updatePackageMissing;
    case 'updateProgressConnecting':
      return l10n.updateProgressConnecting;
    case 'updateProgressDownloading':
      return l10n.updateProgressDownloading(values['asset']?.toString() ?? '');
    case 'updateProgressExtracting':
      return l10n.updateProgressExtracting;
    case 'updateProgressNotifyingLauncher':
      return l10n.updateProgressNotifyingLauncher;
    case 'updateProgressPreparing':
      return l10n.updateProgressPreparing;
    case 'updateProgressVerifying':
      return l10n.updateProgressVerifying;
    case 'updateProgressVerifyingRuntime':
      return l10n.updateProgressVerifyingRuntime;
    case 'updateRequestFailed':
      return l10n.updateRequestFailed;
    case 'updateSource':
      return l10n.updateSource;
    case 'updateUpToDate':
      return l10n.updateUpToDate(values['version']?.toString() ?? '');
    case 'updateVersionInvalid':
      return l10n.updateVersionInvalid;
    case 'updateVersionMissingGitee':
      return l10n.updateVersionMissingGitee;
    case 'updateVersionMissingGithub':
      return l10n.updateVersionMissingGithub;
    case 'updateWindowsOnly':
      return l10n.updateWindowsOnly;
    case 'updated':
      return l10n.updated(values['scope']?.toString() ?? '');
    case 'updates':
      return l10n.updates;
    case 'updatesAndReleaseNotes':
      return l10n.updatesAndReleaseNotes;
    case 'updating':
      return l10n.updating;
    case 'updatingAutomatically':
      return l10n.updatingAutomatically;
    case 'upstream':
      return l10n.upstream;
    case 'upstreamMissing':
      return l10n.upstreamMissing;
    case 'userPath':
      return l10n.userPath;
    case 'usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected':
      return l10n
          .usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
            values['platform']?.toString() ?? '',
          );
    case 'versionNotFoundOrUnreadable':
      return l10n.versionNotFoundOrUnreadable;
    case 'versionV':
      return l10n.versionV(values['version']?.toString() ?? '');
    case 'versionVIsAvailable':
      return l10n.versionVIsAvailable(values['version']?.toString() ?? '');
    case 'viewAndManageAllRemotes':
      return l10n.viewAndManageAllRemotes;
    case 'viewBranchSynchronization':
      return l10n.viewBranchSynchronization;
    case 'viewLogs':
      return l10n.viewLogs;
    case 'workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks':
      return l10n
          .workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks;
    case 'workingTreeClean':
      return l10n.workingTreeClean;
    case 'worktree':
      return l10n.worktree;
    case 'youAreUpToDate':
      return l10n.youAreUpToDate;
    default:
      throw ArgumentError.value(key, 'key', 'Unknown localization key');
  }
}

Set<String> appMessageParameters(String key) {
  switch (key) {
    case 'addDeletionOfItemsToThePlan':
      return const {'count'};
    case 'addPortableGitTo':
      return const {'scope'};
    case 'addPushOfToThePlan':
      return const {'branch'};
    case 'addPushToToThePlan':
      return const {'remote'};
    case 'addRemovalOfRemoteToThePlan':
      return const {'remote'};
    case 'addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone':
      return const {'path', 'url'};
    case 'allRemotesFetched':
      return const {'count'};
    case 'allowedRange':
      return const {'max', 'min'};
    case 'alreadyContainsPortablegit':
      return const {'scope'};
    case 'alreadyOnBranch':
      return const {'branch'};
    case 'andMore':
      return const {'count'};
    case 'branchCreated':
      return const {'branch'};
    case 'branchDeleted':
      return const {'branch'};
    case 'branchRenamed':
      return const {'from', 'to'};
    case 'branchSwitched':
      return const {'branch'};
    case 'changes':
      return const {'count'};
    case 'clearRemoteCompleted':
      return const {'branch', 'commit', 'remote'};
    case 'clearRemoteDrift':
      return const {'branches', 'error', 'remote', 'tags'};
    case 'clearRemoteHistoryFor':
      return const {'remote'};
    case 'clipboardPendingCopy':
      return const {'count'};
    case 'clipboardPendingCut':
      return const {'count'};
    case 'currentBranch2':
      return const {'branch'};
    case 'currentSelection':
      return const {'theme'};
    case 'currentV':
      return const {'version'};
    case 'currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained':
      return const {'version'};
    case 'desktopShortcutCreated':
      return const {'path'};
    case 'destinationFolder':
      return const {'path'};
    case 'destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository':
      return const {'path'};
    case 'detectionDetails':
      return const {'error'};
    case 'doesNotContainTheManagedPortablegitPath':
      return const {'scope'};
    case 'enterProjectBranchToConfirm':
      return const {'confirmation'};
    case 'enterProjectBranchToConfirmAgain':
      return const {'confirmation'};
    case 'fileRenamed':
      return const {'name'};
    case 'foundItemsAndCanBeFreed':
      return const {'count', 'size'};
    case 'gitRepositories':
      return const {'count'};
    case 'items':
      return const {'count'};
    case 'logDetail':
      return const {'eventId'};
    case 'logError':
      return const {'eventId'};
    case 'logInfo':
      return const {'eventId'};
    case 'logReadFailed':
      return const {'error'};
    case 'logWarning':
      return const {'eventId'};
    case 'nothingIsPushedYetThePlanPushesTo':
      return const {'branch', 'platform', 'url'};
    case 'operationCompletedFor':
      return const {'target'};
    case 'operationCompletedForItems':
      return const {'count'};
    case 'operationFailed':
      return const {'error'};
    case 'operationFailedFor':
      return const {'error', 'target'};
    case 'optionsFound':
      return const {'count'};
    case 'pathChangeFailed':
      return const {'error'};
    case 'pending':
      return const {'count'};
    case 'planCleared':
      return const {'count'};
    case 'planDescriptionAddRemote':
      return const {'remote', 'url'};
    case 'planDescriptionApplyStash':
      return const {'selector'};
    case 'planDescriptionClearGitMetadata':
      return const {'path'};
    case 'planDescriptionClearRemote':
      return const {'branch', 'branches', 'message', 'project', 'tags'};
    case 'planDescriptionCloneRepository':
      return const {'path', 'url'};
    case 'planDescriptionCommitAll':
      return const {'message'};
    case 'planDescriptionCopy':
      return const {'count', 'destination'};
    case 'planDescriptionCreateBranch':
      return const {'branch'};
    case 'planDescriptionCreateStash':
      return const {'message'};
    case 'planDescriptionCreateStashIncludeUntracked':
      return const {'message'};
    case 'planDescriptionDelete':
      return const {'count', 'paths'};
    case 'planDescriptionDeleteBranchForce':
      return const {'branch'};
    case 'planDescriptionDeleteBranchSafe':
      return const {'branch'};
    case 'planDescriptionDropStash':
      return const {'selector'};
    case 'planDescriptionFetchAllRemotes':
      return const {'remotes'};
    case 'planDescriptionFetchRemote':
      return const {'remote'};
    case 'planDescriptionInitializeRepository':
      return const {'path'};
    case 'planDescriptionMove':
      return const {'count', 'destination'};
    case 'planDescriptionPopStash':
      return const {'selector'};
    case 'planDescriptionPull':
      return const {'branch', 'remote', 'upstream'};
    case 'planDescriptionPushAllRemotes':
      return const {'remotes'};
    case 'planDescriptionPushRemote':
      return const {'branch', 'remote'};
    case 'planDescriptionRename':
      return const {'newName', 'source'};
    case 'planDescriptionRenameBranch':
      return const {'from', 'to'};
    case 'planDescriptionSwitchBranch':
      return const {'branch'};
    case 'planDescriptionUpdateRemote':
      return const {'remote', 'url'};
    case 'planExecutionComplete':
      return const {'count'};
    case 'planSnapshotFailed':
      return const {'error'};
    case 'planStepFailed':
      return const {'error', 'step'};
    case 'planStepStateChanged':
      return const {'step'};
    case 'planStrongConfirmationRequired':
      return const {'confirmation'};
    case 'planTitleAddRemote':
      return const {'remote'};
    case 'planTitleApplyStash':
      return const {'selector'};
    case 'planTitleClearRemote':
      return const {'remote'};
    case 'planTitleCopy':
      return const {'count', 'destination'};
    case 'planTitleCreateBranch':
      return const {'branch'};
    case 'planTitleCreateStashNamed':
      return const {'message'};
    case 'planTitleDelete':
      return const {'count'};
    case 'planTitleDeleteBranch':
      return const {'branch'};
    case 'planTitleDropStash':
      return const {'selector'};
    case 'planTitleFetchAllRemotes':
      return const {'count'};
    case 'planTitleFetchRemote':
      return const {'remote'};
    case 'planTitleMove':
      return const {'count', 'destination'};
    case 'planTitlePopStash':
      return const {'selector'};
    case 'planTitlePull':
      return const {'branch'};
    case 'planTitlePushAllRemotes':
      return const {'count'};
    case 'planTitlePushBranch':
      return const {'branch'};
    case 'planTitlePushRemote':
      return const {'remote'};
    case 'planTitleRemoveRemote':
      return const {'remote'};
    case 'planTitleRename':
      return const {'source'};
    case 'planTitleRenameBranch':
      return const {'from', 'to'};
    case 'planTitleSwitchBranch':
      return const {'branch'};
    case 'planTitleUpdateRemote':
      return const {'remote'};
    case 'plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur':
      return const {'action', 'count'};
    case 'projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation':
      return const {'branch', 'confirmation', 'message', 'project', 'target'};
    case 'pullCompleted':
      return const {'branch', 'upstream'};
    case 'pushedBranch':
      return const {'branch'};
    case 'pushedToAllRemotes':
      return const {'count'};
    case 'pushedToRemote':
      return const {'remote'};
    case 'readingBranchesAndTagsFrom':
      return const {'remote'};
    case 'remoteAdded':
      return const {'remote'};
    case 'remoteBatchPartialFailure':
      return const {'details', 'failed', 'succeeded'};
    case 'remoteFetched':
      return const {'remote'};
    case 'remoteInspectionCounts':
      return const {'branches', 'remote', 'tags'};
    case 'remoteInspectionEmpty':
      return const {'remote'};
    case 'remoteRemoved':
      return const {'remote'};
    case 'remoteRepositoriesWereDetectedSoClearingIsDisabled':
      return const {'remotes'};
    case 'remoteUpdated':
      return const {'remote'};
    case 'remotes':
      return const {'count'};
    case 'removePortableGitFrom':
      return const {'scope'};
    case 'removedItemsAndFreed':
      return const {'count', 'size'};
    case 'removedItemsCouldNotBeDeletedCheckTheDetailedLog':
      return const {'failed', 'removed'};
    case 'repository':
      return const {'path'};
    case 'selected':
      return const {'count'};
    case 'selected2':
      return const {'count'};
    case 'staged':
      return const {'count'};
    case 'stashApplied':
      return const {'selector'};
    case 'stashDropped':
      return const {'selector'};
    case 'stashPopped':
      return const {'selector'};
    case 'step':
      return const {'step', 'title'};
    case 'stepsCount':
      return const {'count'};
    case 'stepsTheRepositoryIsUnchangedUntilConfirmation':
      return const {'count'};
    case 'syncAuthenticationFailed':
      return const {'error'};
    case 'syncNetworkFailed':
      return const {'error'};
    case 'textCanBeSelectedAndCopiedHereTheFullGuideIsIn':
      return const {'path'};
    case 'thePlanPushesTo':
      return const {'branch', 'remotes'};
    case 'thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles':
      return const {'branch'};
    case 'thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit':
      return const {'count'};
    case 'today':
      return const {'time'};
    case 'unableToOpenFile':
      return const {'error'};
    case 'unableToOpenGuideLink':
      return const {'error'};
    case 'unableToOpenLogsFolder':
      return const {'error'};
    case 'unableToOpenProjectFolder':
      return const {'error'};
    case 'unableToOpenTheGitDownloadPage':
      return const {'error'};
    case 'unableToReadUserGuide':
      return const {'error'};
    case 'updateGiteeUpToDate':
      return const {'version'};
    case 'updateHttpError':
      return const {'platform', 'status'};
    case 'updateInstallSuccess':
      return const {'version'};
    case 'updateProgressDownloading':
      return const {'asset'};
    case 'updateUpToDate':
      return const {'version'};
    case 'updated':
      return const {'scope'};
    case 'usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected':
      return const {'platform'};
    case 'versionV':
      return const {'version'};
    case 'versionVIsAvailable':
      return const {'version'};
    default:
      return const <String>{};
  }
}
