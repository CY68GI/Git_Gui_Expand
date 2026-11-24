import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_en.dart';
import 'app_l10n_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Git GUI Expand'**
  String get appName;

  /// No description provided for @openRepository.
  ///
  /// In en, this message translates to:
  /// **'Open Git repository'**
  String get openRepository;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings;

  /// No description provided for @aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'A plan is pending. Clear or execute it before removing Git metadata.'**
  String get aPlanIsPendingClearOrExecuteItBeforeRemovingGitMetadata;

  /// No description provided for @aWindowsFirstFlutterGraphicalFileWorkspaceForGit.
  ///
  /// In en, this message translates to:
  /// **'A Windows-first Flutter graphical file workspace for Git.'**
  String get aWindowsFirstFlutterGraphicalFileWorkspaceForGit;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutInformationDoesNotChangeSettings.
  ///
  /// In en, this message translates to:
  /// **'About information does not change settings.'**
  String get aboutInformationDoesNotChangeSettings;

  /// No description provided for @acknowledgements.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get acknowledgements;

  /// No description provided for @addClearOperationToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add clear operation to plan'**
  String get addClearOperationToPlan;

  /// No description provided for @addClearToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add clear to plan'**
  String get addClearToPlan;

  /// No description provided for @addCloneToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add clone to plan'**
  String get addCloneToPlan;

  /// No description provided for @addCommitToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add commit to plan'**
  String get addCommitToPlan;

  /// No description provided for @addDeletionOfItemsToThePlan.
  ///
  /// In en, this message translates to:
  /// **'Add deletion of {count} items to the plan'**
  String addDeletionOfItemsToThePlan(String count);

  /// No description provided for @addDeletionToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add deletion to plan'**
  String get addDeletionToPlan;

  /// No description provided for @addGitToPath.
  ///
  /// In en, this message translates to:
  /// **'Add Git to PATH'**
  String get addGitToPath;

  /// No description provided for @addPushAllPlan.
  ///
  /// In en, this message translates to:
  /// **'Add push-all plan'**
  String get addPushAllPlan;

  /// No description provided for @addPushAllToThePlan.
  ///
  /// In en, this message translates to:
  /// **'Add push-all to the plan'**
  String get addPushAllToThePlan;

  /// No description provided for @addPushOfToThePlan.
  ///
  /// In en, this message translates to:
  /// **'Add push of {branch} to the plan'**
  String addPushOfToThePlan(String branch);

  /// No description provided for @addPushToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add push to plan'**
  String get addPushToPlan;

  /// No description provided for @addPushToToThePlan.
  ///
  /// In en, this message translates to:
  /// **'Add push to {remote} to the plan'**
  String addPushToToThePlan(String remote);

  /// No description provided for @addRemote.
  ///
  /// In en, this message translates to:
  /// **'Add remote'**
  String get addRemote;

  /// No description provided for @addRemovalOfRemoteToThePlan.
  ///
  /// In en, this message translates to:
  /// **'Add removal of remote {remote} to the plan'**
  String addRemovalOfRemoteToThePlan(String remote);

  /// No description provided for @addRemovalToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add removal to plan'**
  String get addRemovalToPlan;

  /// No description provided for @addToAddPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to add plan'**
  String get addToAddPlan;

  /// No description provided for @addToPlan.
  ///
  /// In en, this message translates to:
  /// **'Add to plan'**
  String get addToPlan;

  /// No description provided for @addToSystemPath.
  ///
  /// In en, this message translates to:
  /// **'Add to system PATH'**
  String get addToSystemPath;

  /// No description provided for @addToUpdatePlan.
  ///
  /// In en, this message translates to:
  /// **'Add to update plan'**
  String get addToUpdatePlan;

  /// No description provided for @addToUserPath.
  ///
  /// In en, this message translates to:
  /// **'Add to user PATH'**
  String get addToUserPath;

  /// No description provided for @addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone.
  ///
  /// In en, this message translates to:
  /// **'Address: {url}\nDestination folder: {path}\nCancel creates nothing. Confirming the plan rechecks the destination and runs git clone.'**
  String
  addressDestinationFolderCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone(
    String path,
    String url,
  );

  /// No description provided for @afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution.
  ///
  /// In en, this message translates to:
  /// **'After cleanup the folder becomes an ordinary directory that can be initialized again from Open empty folder. This now only adds a clear step; enter CLEAR GIT in the operation plan and confirm execution.'**
  String
  get afterCleanupTheFolderBecomesAnOrdinaryDirectoryThatCanBeInitializedAgainFromOpenEmptyFolderThisNowOnlyAddsAClearStepEnterClearGitInTheOperationPlanAndConfirmExecution;

  /// No description provided for @ahead.
  ///
  /// In en, this message translates to:
  /// **'Ahead'**
  String get ahead;

  /// No description provided for @allowedRange.
  ///
  /// In en, this message translates to:
  /// **'Allowed range: {min}%–{max}%'**
  String allowedRange(String max, String min);

  /// No description provided for @alreadyContainsPortablegit.
  ///
  /// In en, this message translates to:
  /// **'{scope} already contains PortableGit'**
  String alreadyContainsPortablegit(String scope);

  /// No description provided for @alsoSaveUntrackedFilesGitStashIncludeUntracked.
  ///
  /// In en, this message translates to:
  /// **'Also save untracked files (git stash --include-untracked)'**
  String get alsoSaveUntrackedFilesGitStashIncludeUntracked;

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andMore(String count);

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance settings'**
  String get appearanceSettings;

  /// No description provided for @applicationLogs.
  ///
  /// In en, this message translates to:
  /// **'Application logs'**
  String get applicationLogs;

  /// No description provided for @applyStash.
  ///
  /// In en, this message translates to:
  /// **'Apply Stash'**
  String get applyStash;

  /// No description provided for @automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates download the Windows x64 ZIP from GitHub, verify SHA-256 and extract it into versions/<version>. The Launcher switches versions after exit and rolls back if startup fails. userdata is preserved.'**
  String
  get automaticUpdatesDownloadTheWindowsX64ZipFromGithubVerifySha256AndExtractItIntoVersionsVersionTheLauncherSwitchesVersionsAfterExitAndRollsBackIfStartupFailsUserdataIsPreserved;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @baseUnit.
  ///
  /// In en, this message translates to:
  /// **'Base unit'**
  String get baseUnit;

  /// No description provided for @behind.
  ///
  /// In en, this message translates to:
  /// **'Behind'**
  String get behind;

  /// No description provided for @binaryUses1024StepsDecimalUses1000.
  ///
  /// In en, this message translates to:
  /// **'Binary uses 1024 steps; decimal uses 1000.'**
  String get binaryUses1024StepsDecimalUses1000;

  /// No description provided for @bitB.
  ///
  /// In en, this message translates to:
  /// **'bit (b)'**
  String get bitB;

  /// No description provided for @branchManagement.
  ///
  /// In en, this message translates to:
  /// **'Branch management'**
  String get branchManagement;

  /// No description provided for @branchSynchronization.
  ///
  /// In en, this message translates to:
  /// **'Branch synchronization'**
  String get branchSynchronization;

  /// No description provided for @browseIndependentlyAndMoveAcrossPanes.
  ///
  /// In en, this message translates to:
  /// **'Browse independently and move across panes'**
  String get browseIndependentlyAndMoveAcrossPanes;

  /// No description provided for @browseMoveCopyDeleteCommitAndPushThroughTheGitCli.
  ///
  /// In en, this message translates to:
  /// **'Browse, move, copy, delete, commit and push through the Git CLI.'**
  String get browseMoveCopyDeleteCommitAndPushThroughTheGitCli;

  /// No description provided for @browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit.
  ///
  /// In en, this message translates to:
  /// **'Browse one repository in two panes. Select, cut, paste and rename. Every change runs through Git.'**
  String
  get browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit;

  /// No description provided for @bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense.
  ///
  /// In en, this message translates to:
  /// **'Bundled fonts come from Google Fonts under the SIL Open Font License.'**
  String get bundledFontsComeFromGoogleFontsUnderTheSilOpenFontLicense;

  /// No description provided for @bundledPortablegit.
  ///
  /// In en, this message translates to:
  /// **'Bundled PortableGit'**
  String get bundledPortablegit;

  /// No description provided for @bundledUiFonts.
  ///
  /// In en, this message translates to:
  /// **'Bundled UI fonts'**
  String get bundledUiFonts;

  /// No description provided for @byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts.
  ///
  /// In en, this message translates to:
  /// **'By default the bundled Noto Sans SC font is used. Search bundled or system fonts.'**
  String get byDefaultTheBundledNotoSansScFontIsUsedSearchBundledOrSystemFonts;

  /// No description provided for @byteB.
  ///
  /// In en, this message translates to:
  /// **'Byte (B)'**
  String get byteB;

  /// No description provided for @byteDisplaysBKibOrKbBitIsMultipliedBy8First.
  ///
  /// In en, this message translates to:
  /// **'Byte displays B, KiB or KB; bit is multiplied by 8 first.'**
  String get byteDisplaysBKibOrKbBitIsMultipliedBy8First;

  /// No description provided for @cancel2.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel2;

  /// No description provided for @cancelEditing.
  ///
  /// In en, this message translates to:
  /// **'Cancel editing'**
  String get cancelEditing;

  /// No description provided for @changed.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get changed;

  /// No description provided for @changes.
  ///
  /// In en, this message translates to:
  /// **'{count} changes'**
  String changes(String count);

  /// No description provided for @changesApplyAfterSaving.
  ///
  /// In en, this message translates to:
  /// **'Changes apply after saving.'**
  String get changesApplyAfterSaving;

  /// No description provided for @changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing.
  ///
  /// In en, this message translates to:
  /// **'Changing the system PATH affects the whole computer and requests administrator permission. Cancelling elevation changes nothing.'**
  String
  get changingTheSystemPathAffectsTheWholeComputerAndRequestsAdministratorPermissionCancellingElevationChangesNothing;

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get checking;

  /// No description provided for @checking2.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking2;

  /// No description provided for @checkingForGit.
  ///
  /// In en, this message translates to:
  /// **'Checking for Git…'**
  String get checkingForGit;

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates'**
  String get checkingForUpdates;

  /// No description provided for @chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose actions in the explorer, commit area or remote manager. They appear here first.'**
  String
  get chooseActionsInTheExplorerCommitAreaOrRemoteManagerTheyAppearHereFirst;

  /// No description provided for @chooseCloneParentFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose clone parent folder'**
  String get chooseCloneParentFolder;

  /// No description provided for @chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors.
  ///
  /// In en, this message translates to:
  /// **'Choose display mode and color scheme; interface icons follow the selected colors.'**
  String
  get chooseDisplayModeAndColorSchemeInterfaceIconsFollowTheSelectedColors;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder'**
  String get chooseFolder;

  /// No description provided for @chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup.
  ///
  /// In en, this message translates to:
  /// **'Choose the current user or system environment. Only the managed runtime/git/current/cmd path is added, after creating a backup.'**
  String
  get chooseTheCurrentUserOrSystemEnvironmentOnlyTheManagedRuntimeGitCurrentCmdPathIsAddedAfterCreatingABackup;

  /// No description provided for @chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem.
  ///
  /// In en, this message translates to:
  /// **'Choose the interface language. By default it follows the operating system.'**
  String get chooseTheInterfaceLanguageByDefaultItFollowsTheOperatingSystem;

  /// No description provided for @clean.
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get clean;

  /// No description provided for @cleanAll.
  ///
  /// In en, this message translates to:
  /// **'Clean all'**
  String get cleanAll;

  /// No description provided for @clearAllRemoteBranchesAndTagsDangerous.
  ///
  /// In en, this message translates to:
  /// **'Clear all remote branches and tags (dangerous)'**
  String get clearAllRemoteBranchesAndTagsDangerous;

  /// No description provided for @clearGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Clear Git metadata'**
  String get clearGitMetadata;

  /// No description provided for @clearPlan.
  ///
  /// In en, this message translates to:
  /// **'Clear plan'**
  String get clearPlan;

  /// No description provided for @clearRemoteHistoryFor.
  ///
  /// In en, this message translates to:
  /// **'Clear remote history for {remote}?'**
  String clearRemoteHistoryFor(String remote);

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @cloneGitRepository.
  ///
  /// In en, this message translates to:
  /// **'Clone Git repository'**
  String get cloneGitRepository;

  /// No description provided for @cloneIntoParentFolder.
  ///
  /// In en, this message translates to:
  /// **'Clone into parent folder'**
  String get cloneIntoParentFolder;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeUserGuide.
  ///
  /// In en, this message translates to:
  /// **'Close user guide'**
  String get closeUserGuide;

  /// No description provided for @closingTheRepository.
  ///
  /// In en, this message translates to:
  /// **'closing the repository'**
  String get closingTheRepository;

  /// No description provided for @colorScheme.
  ///
  /// In en, this message translates to:
  /// **'Color scheme'**
  String get colorScheme;

  /// No description provided for @commitMessage.
  ///
  /// In en, this message translates to:
  /// **'Commit message'**
  String get commitMessage;

  /// No description provided for @commitWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Commit workspace'**
  String get commitWorkspace;

  /// No description provided for @commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun.
  ///
  /// In en, this message translates to:
  /// **'Commits are deferred. Confirm the plan before git add -A and git commit run.'**
  String get commitsAreDeferredConfirmThePlanBeforeGitAddAAndGitCommitRun;

  /// No description provided for @confirmAndExecute.
  ///
  /// In en, this message translates to:
  /// **'Confirm and execute'**
  String get confirmAndExecute;

  /// No description provided for @confirmDangerousOperations.
  ///
  /// In en, this message translates to:
  /// **'Confirm dangerous operations'**
  String get confirmDangerousOperations;

  /// No description provided for @controlHowProjectAndIndividualFileSizesAreDisplayed.
  ///
  /// In en, this message translates to:
  /// **'Control how project and individual file sizes are displayed.'**
  String get controlHowProjectAndIndividualFileSizesAreDisplayed;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher.
  ///
  /// In en, this message translates to:
  /// **'Create a Git GUI Expand shortcut on the current user\'s desktop that starts through the stable Launcher.'**
  String
  get createAGitGuiExpandShortcutOnTheCurrentUserSDesktopThatStartsThroughTheStableLauncher;

  /// No description provided for @createBranch.
  ///
  /// In en, this message translates to:
  /// **'Create branch'**
  String get createBranch;

  /// No description provided for @createStash.
  ///
  /// In en, this message translates to:
  /// **'Create Stash'**
  String get createStash;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @currentBranch.
  ///
  /// In en, this message translates to:
  /// **'Current branch'**
  String get currentBranch;

  /// No description provided for @currentBranch2.
  ///
  /// In en, this message translates to:
  /// **'Current branch: {branch}'**
  String currentBranch2(String branch);

  /// No description provided for @currentReleaseHighlights.
  ///
  /// In en, this message translates to:
  /// **'Current release highlights'**
  String get currentReleaseHighlights;

  /// No description provided for @currentSelection.
  ///
  /// In en, this message translates to:
  /// **'Current selection: {theme}'**
  String currentSelection(String theme);

  /// No description provided for @currentV.
  ///
  /// In en, this message translates to:
  /// **'Current v{version}'**
  String currentV(String version);

  /// No description provided for @currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained.
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}. Only old versions, installers, and legacy flat application files are removed; userdata is retained.'**
  String
  currentVersionOnlyOldVersionsInstallersAndLegacyFlatApplicationFilesAreRemovedUserdataIsRetained(
    String version,
  );

  /// No description provided for @cut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// No description provided for @cutCopyRenamePushAndCommit0123456789.
  ///
  /// In en, this message translates to:
  /// **'Cut, copy, rename, push and commit   0123456789'**
  String get cutCopyRenamePushAndCommit0123456789;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBranch.
  ///
  /// In en, this message translates to:
  /// **'Delete branch'**
  String get deleteBranch;

  /// No description provided for @deleteStash.
  ///
  /// In en, this message translates to:
  /// **'Delete Stash'**
  String get deleteStash;

  /// No description provided for @desktopShortcut.
  ///
  /// In en, this message translates to:
  /// **'Desktop shortcut'**
  String get desktopShortcut;

  /// No description provided for @destinationFolder.
  ///
  /// In en, this message translates to:
  /// **'Destination folder: {path}'**
  String destinationFolder(String path);

  /// No description provided for @destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository.
  ///
  /// In en, this message translates to:
  /// **'Destination folder: {path}\nAfter confirmation, run git init in the destination and open the repository.'**
  String
  destinationFolderAfterConfirmationRunGitInitInTheDestinationAndOpenTheRepository(
    String path,
  );

  /// No description provided for @detached.
  ///
  /// In en, this message translates to:
  /// **'detached'**
  String get detached;

  /// No description provided for @detachedHead.
  ///
  /// In en, this message translates to:
  /// **'detached HEAD'**
  String get detachedHead;

  /// No description provided for @detachedHeadCannotFetchCurrentUpstreamOrPullABranch.
  ///
  /// In en, this message translates to:
  /// **'Detached HEAD cannot fetch current upstream or pull a branch.'**
  String get detachedHeadCannotFetchCurrentUpstreamOrPullABranch;

  /// No description provided for @detailedLog.
  ///
  /// In en, this message translates to:
  /// **'Detailed log'**
  String get detailedLog;

  /// No description provided for @detectTheGitRuntimeVersionSourceAndExecutableLocation.
  ///
  /// In en, this message translates to:
  /// **'Detect the Git runtime, version, source, and executable location.'**
  String get detectTheGitRuntimeVersionSourceAndExecutableLocation;

  /// No description provided for @detectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Detection details: {error}'**
  String detectionDetails(String error);

  /// No description provided for @discardPlanAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Discard plan and continue'**
  String get discardPlanAndContinue;

  /// No description provided for @discardThePendingOperationPlan.
  ///
  /// In en, this message translates to:
  /// **'Discard the pending operation plan?'**
  String get discardThePendingOperationPlan;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display mode'**
  String get displayMode;

  /// No description provided for @doesNotContainTheManagedPortablegitPath.
  ///
  /// In en, this message translates to:
  /// **'{scope} does not contain the managed PortableGit path'**
  String doesNotContainTheManagedPortablegitPath(String scope);

  /// No description provided for @doesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Does not exist'**
  String get doesNotExist;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @doubleClickAFolderClickAPaneToChooseThePasteTarget.
  ///
  /// In en, this message translates to:
  /// **'Double-click a folder; click a pane to choose the paste target'**
  String get doubleClickAFolderClickAPaneToChooseThePasteTarget;

  /// No description provided for @doubleClickAFolderToOpen.
  ///
  /// In en, this message translates to:
  /// **'Double-click a folder to open'**
  String get doubleClickAFolderToOpen;

  /// No description provided for @downloadGit.
  ///
  /// In en, this message translates to:
  /// **'Download Git'**
  String get downloadGit;

  /// No description provided for @dualPaneOperations.
  ///
  /// In en, this message translates to:
  /// **'Dual-pane operations'**
  String get dualPaneOperations;

  /// No description provided for @editRemote.
  ///
  /// In en, this message translates to:
  /// **'Edit remote'**
  String get editRemote;

  /// No description provided for @editUrl.
  ///
  /// In en, this message translates to:
  /// **'Edit URL'**
  String get editUrl;

  /// No description provided for @enterACloneUrlParentFolderAndProjectName.
  ///
  /// In en, this message translates to:
  /// **'Enter a clone URL, parent folder, and project name.'**
  String get enterACloneUrlParentFolderAndProjectName;

  /// No description provided for @enterACommitMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a commit message…'**
  String get enterACommitMessage;

  /// No description provided for @enterProjectBranchToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enter project/branch \"{confirmation}\" to confirm'**
  String enterProjectBranchToConfirm(String confirmation);

  /// No description provided for @enterProjectBranchToConfirmAgain.
  ///
  /// In en, this message translates to:
  /// **'Enter project/branch \"{confirmation}\" to confirm again.'**
  String enterProjectBranchToConfirmAgain(String confirmation);

  /// No description provided for @executing.
  ///
  /// In en, this message translates to:
  /// **'Executing…'**
  String get executing;

  /// No description provided for @executingStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Executing step by step'**
  String get executingStepByStep;

  /// No description provided for @executionComplete.
  ///
  /// In en, this message translates to:
  /// **'Execution complete'**
  String get executionComplete;

  /// No description provided for @executionIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Execution incomplete'**
  String get executionIncomplete;

  /// No description provided for @fetchAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Fetch all remotes'**
  String get fetchAllRemotes;

  /// No description provided for @fetchCurrentUpstream.
  ///
  /// In en, this message translates to:
  /// **'Fetch current upstream'**
  String get fetchCurrentUpstream;

  /// No description provided for @fileChangesArePendingInTheOperationPlan.
  ///
  /// In en, this message translates to:
  /// **'File changes are pending in the operation plan'**
  String get fileChangesArePendingInTheOperationPlan;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns.
  ///
  /// In en, this message translates to:
  /// **'Files are not deleted yet. Confirm the operation plan before git rm or git clean runs.'**
  String
  get filesAreNotDeletedYetConfirmTheOperationPlanBeforeGitRmOrGitCleanRuns;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @followSystemSwitchesWithTheDeviceLightOrDarkAppearance.
  ///
  /// In en, this message translates to:
  /// **'Follow system switches with the device light or dark appearance.'**
  String get followSystemSwitchesWithTheDeviceLightOrDarkAppearance;

  /// No description provided for @followTheOperatingSystemWithoutAFixedFamily.
  ///
  /// In en, this message translates to:
  /// **'Follow the operating system without a fixed family'**
  String get followTheOperatingSystemWithoutAFixedFamily;

  /// No description provided for @font.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @fontPreview.
  ///
  /// In en, this message translates to:
  /// **'Font preview'**
  String get fontPreview;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @forExampleFeatureLogin.
  ///
  /// In en, this message translates to:
  /// **'For example: feature/login'**
  String get forExampleFeatureLogin;

  /// No description provided for @forExampleOriginGiteeOrGitlab.
  ///
  /// In en, this message translates to:
  /// **'For example origin, gitee or gitlab'**
  String get forExampleOriginGiteeOrGitlab;

  /// No description provided for @forExampleTemporarilySaveUnfinishedChanges.
  ///
  /// In en, this message translates to:
  /// **'For example: temporarily save unfinished changes'**
  String get forExampleTemporarilySaveUnfinishedChanges;

  /// No description provided for @forceGitBranchDWhenDeletingAnUnmergedBranch.
  ///
  /// In en, this message translates to:
  /// **'Force git branch -D when deleting an unmerged branch'**
  String get forceGitBranchDWhenDeletingAnUnmergedBranch;

  /// No description provided for @foundItemsAndCanBeFreed.
  ///
  /// In en, this message translates to:
  /// **'Found {count} items and {size} can be freed.'**
  String foundItemsAndCanBeFreed(String count, String size);

  /// No description provided for @git.
  ///
  /// In en, this message translates to:
  /// **'Git'**
  String get git;

  /// No description provided for @gitExecutableLocation.
  ///
  /// In en, this message translates to:
  /// **'Git executable location'**
  String get gitExecutableLocation;

  /// No description provided for @gitGuiExpandFileCommit.
  ///
  /// In en, this message translates to:
  /// **'Git GUI Expand · File commit'**
  String get gitGuiExpandFileCommit;

  /// No description provided for @gitGuiExpandUserGuide.
  ///
  /// In en, this message translates to:
  /// **'Git GUI Expand User Guide'**
  String get gitGuiExpandUserGuide;

  /// No description provided for @gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Git is required to open or modify repositories. Install Git for Windows, then select Check again.'**
  String
  get gitIsRequiredToOpenOrModifyRepositoriesInstallGitForWindowsThenSelectCheckAgain;

  /// No description provided for @gitIsUnavailableRepositoryActionsAreDisabled.
  ///
  /// In en, this message translates to:
  /// **'Git is unavailable. Repository actions are disabled.'**
  String get gitIsUnavailableRepositoryActionsAreDisabled;

  /// No description provided for @gitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Git metadata'**
  String get gitMetadata;

  /// No description provided for @gitMvIndexCommit.
  ///
  /// In en, this message translates to:
  /// **'git mv · index · commit'**
  String get gitMvIndexCommit;

  /// No description provided for @gitNotDetected.
  ///
  /// In en, this message translates to:
  /// **'Git not detected'**
  String get gitNotDetected;

  /// No description provided for @gitRepositories.
  ///
  /// In en, this message translates to:
  /// **'{count} Git repositories'**
  String gitRepositories(String count);

  /// No description provided for @gitRepository.
  ///
  /// In en, this message translates to:
  /// **'Git repository'**
  String get gitRepository;

  /// No description provided for @gitRepositoryCloned.
  ///
  /// In en, this message translates to:
  /// **'Git repository cloned'**
  String get gitRepositoryCloned;

  /// No description provided for @gitRepositoryInitialized.
  ///
  /// In en, this message translates to:
  /// **'Git repository initialized'**
  String get gitRepositoryInitialized;

  /// No description provided for @gitSettings.
  ///
  /// In en, this message translates to:
  /// **'Git settings'**
  String get gitSettings;

  /// No description provided for @gitSource.
  ///
  /// In en, this message translates to:
  /// **'Git source'**
  String get gitSource;

  /// No description provided for @gitVersion.
  ///
  /// In en, this message translates to:
  /// **'Git version'**
  String get gitVersion;

  /// No description provided for @gitee.
  ///
  /// In en, this message translates to:
  /// **'Gitee'**
  String get gitee;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get github;

  /// No description provided for @githubUsuallyProvidesTheInternationalReleaseBuild.
  ///
  /// In en, this message translates to:
  /// **'GitHub usually provides the international release build.'**
  String get githubUsuallyProvidesTheInternationalReleaseBuild;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @httpsOrGitHostOwnerRepoGit.
  ///
  /// In en, this message translates to:
  /// **'https://... or git@host:owner/repo.git'**
  String get httpsOrGitHostOwnerRepoGit;

  /// No description provided for @iReviewedTheseOperationsAndWantToExecuteThemInOrder.
  ///
  /// In en, this message translates to:
  /// **'I reviewed these operations and want to execute them in order'**
  String get iReviewedTheseOperationsAndWantToExecuteThemInOrder;

  /// No description provided for @iecBinary.
  ///
  /// In en, this message translates to:
  /// **'IEC binary'**
  String get iecBinary;

  /// No description provided for @iecSiOptionalBits.
  ///
  /// In en, this message translates to:
  /// **'IEC / SI, optional bits'**
  String get iecSiOptionalBits;

  /// No description provided for @importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Important: Git changes are planned first and run only after confirmation'**
  String get importantGitChangesArePlannedFirstAndRunOnlyAfterConfirmation;

  /// No description provided for @initializeGitRepository.
  ///
  /// In en, this message translates to:
  /// **'Initialize Git repository'**
  String get initializeGitRepository;

  /// No description provided for @installedSystemFont.
  ///
  /// In en, this message translates to:
  /// **'Installed system font'**
  String get installedSystemFont;

  /// No description provided for @installing.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get installing;

  /// No description provided for @interfaceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Interface language'**
  String get interfaceLanguage;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String items(String count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language2.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language2;

  /// No description provided for @largeFile.
  ///
  /// In en, this message translates to:
  /// **'Large file'**
  String get largeFile;

  /// No description provided for @lastChecked.
  ///
  /// In en, this message translates to:
  /// **'Last checked'**
  String get lastChecked;

  /// No description provided for @leftExplorer.
  ///
  /// In en, this message translates to:
  /// **'Left explorer'**
  String get leftExplorer;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst.
  ///
  /// In en, this message translates to:
  /// **'Local and upstream histories have diverged. The app will not merge or rebase automatically; resolve the divergence in external Git first.'**
  String
  get localAndUpstreamHistoriesHaveDivergedTheAppWillNotMergeOrRebaseAutomaticallyResolveTheDivergenceInExternalGitFirst;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @mediumFile.
  ///
  /// In en, this message translates to:
  /// **'Medium file'**
  String get mediumFile;

  /// No description provided for @moreContentBelow.
  ///
  /// In en, this message translates to:
  /// **'More content below'**
  String get moreContentBelow;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @nativeGitChanges.
  ///
  /// In en, this message translates to:
  /// **'Native Git changes'**
  String get nativeGitChanges;

  /// No description provided for @newBranchNameOrRenamedBranchName.
  ///
  /// In en, this message translates to:
  /// **'New branch name or renamed branch name'**
  String get newBranchNameOrRenamedBranchName;

  /// No description provided for @newName.
  ///
  /// In en, this message translates to:
  /// **'New name'**
  String get newName;

  /// No description provided for @noBranch.
  ///
  /// In en, this message translates to:
  /// **'No branch'**
  String get noBranch;

  /// No description provided for @noBundledFontMatches.
  ///
  /// In en, this message translates to:
  /// **'No bundled font matches'**
  String get noBundledFontMatches;

  /// No description provided for @noCommittedBranchYet.
  ///
  /// In en, this message translates to:
  /// **'No committed branch yet'**
  String get noCommittedBranchYet;

  /// No description provided for @noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere.
  ///
  /// In en, this message translates to:
  /// **'No detailed log yet. Selection, navigation and every Git command are recorded here.'**
  String
  get noDetailedLogYetSelectionNavigationAndEveryGitCommandAreRecordedHere;

  /// No description provided for @noFilesHere.
  ///
  /// In en, this message translates to:
  /// **'No files here'**
  String get noFilesHere;

  /// No description provided for @noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents.
  ///
  /// In en, this message translates to:
  /// **'No normal log yet. Opening a repository and Git actions create key events.'**
  String get noNormalLogYetOpeningARepositoryAndGitActionsCreateKeyEvents;

  /// No description provided for @noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean.
  ///
  /// In en, this message translates to:
  /// **'No old versions or installers were found; the directory is already clean.'**
  String get noOldVersionsOrInstallersWereFoundTheDirectoryIsAlreadyClean;

  /// No description provided for @noPendingOperations.
  ///
  /// In en, this message translates to:
  /// **'No pending operations'**
  String get noPendingOperations;

  /// No description provided for @noPendingSteps.
  ///
  /// In en, this message translates to:
  /// **'No pending steps'**
  String get noPendingSteps;

  /// No description provided for @noProjectIsOpen.
  ///
  /// In en, this message translates to:
  /// **'No project is open.'**
  String get noProjectIsOpen;

  /// No description provided for @noRemoteRepositoryWasDetected.
  ///
  /// In en, this message translates to:
  /// **'No remote repository was detected.'**
  String get noRemoteRepositoryWasDetected;

  /// No description provided for @noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote.
  ///
  /// In en, this message translates to:
  /// **'No remotes configured. Add GitHub, Gitee, GitLab or another Git remote.'**
  String get noRemotesConfiguredAddGithubGiteeGitlabOrAnotherGitRemote;

  /// No description provided for @noSystemFontMatches.
  ///
  /// In en, this message translates to:
  /// **'No system font matches'**
  String get noSystemFontMatches;

  /// No description provided for @noUpstream.
  ///
  /// In en, this message translates to:
  /// **'No upstream'**
  String get noUpstream;

  /// No description provided for @noUsableGitWasDetectedInstallItAndCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'No usable Git was detected. Install it and check again.'**
  String get noUsableGitWasDetectedInstallItAndCheckAgain;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @normalLog.
  ///
  /// In en, this message translates to:
  /// **'Normal log'**
  String get normalLog;

  /// No description provided for @notCheckedYet.
  ///
  /// In en, this message translates to:
  /// **'Not checked yet'**
  String get notCheckedYet;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get notConfigured;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not detected'**
  String get notDetected;

  /// No description provided for @nothingIsPushedYetThePlanPushesTo.
  ///
  /// In en, this message translates to:
  /// **'Nothing is pushed yet. The plan pushes {branch} to {platform}.\n{url}'**
  String nothingIsPushedYetThePlanPushesTo(
    String branch,
    String platform,
    String url,
  );

  /// No description provided for @nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded.
  ///
  /// In en, this message translates to:
  /// **'Nothing is pushed yet. The plan will run git push and configure upstream when needed.'**
  String
  get nothingIsPushedYetThePlanWillRunGitPushAndConfigureUpstreamWhenNeeded;

  /// No description provided for @oldVersionAndInstallerCleanup.
  ///
  /// In en, this message translates to:
  /// **'Old version and installer cleanup'**
  String get oldVersionAndInstallerCleanup;

  /// No description provided for @onlineReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Online release notes'**
  String get onlineReleaseNotes;

  /// No description provided for @onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath.
  ///
  /// In en, this message translates to:
  /// **'Only the current user PATH is changed and elevation is not required. The app only adds or removes its stable managed runtime path.'**
  String
  get onlyTheCurrentUserPathIsChangedAndElevationIsNotRequiredTheAppOnlyAddsOrRemovesItsStableManagedRuntimePath;

  /// No description provided for @onlyTheLocalGitRemoteConfigurationIsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Only the local Git remote configuration is removed.'**
  String get onlyTheLocalGitRemoteConfigurationIsRemoved;

  /// No description provided for @onlyVerifiedRepositoryRootsAreSaved.
  ///
  /// In en, this message translates to:
  /// **'Only verified repository roots are saved'**
  String get onlyVerifiedRepositoryRootsAreSaved;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository.
  ///
  /// In en, this message translates to:
  /// **'Open an existing repository, initialize an empty folder, or clone a remote repository'**
  String
  get openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository;

  /// No description provided for @openAnotherFolderOrRefreshToViewRepositoryContents.
  ///
  /// In en, this message translates to:
  /// **'Open another folder or refresh to view repository contents.'**
  String get openAnotherFolderOrRefreshToViewRepositoryContents;

  /// No description provided for @openEmptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Open empty folder'**
  String get openEmptyFolder;

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @openGitRepository.
  ///
  /// In en, this message translates to:
  /// **'Open Git repository'**
  String get openGitRepository;

  /// No description provided for @openReleasePage.
  ///
  /// In en, this message translates to:
  /// **'Open release page'**
  String get openReleasePage;

  /// No description provided for @openRepository2.
  ///
  /// In en, this message translates to:
  /// **'Open repository'**
  String get openRepository2;

  /// No description provided for @openWithDefaultApp.
  ///
  /// In en, this message translates to:
  /// **'Open with default app'**
  String get openWithDefaultApp;

  /// No description provided for @openingAnotherRepository.
  ///
  /// In en, this message translates to:
  /// **'opening another repository'**
  String get openingAnotherRepository;

  /// No description provided for @openingRepository.
  ///
  /// In en, this message translates to:
  /// **'Opening repository…'**
  String get openingRepository;

  /// No description provided for @optionsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} options found'**
  String optionsFound(String count);

  /// No description provided for @parentFolder.
  ///
  /// In en, this message translates to:
  /// **'Parent folder'**
  String get parentFolder;

  /// No description provided for @paste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// No description provided for @pasteTarget.
  ///
  /// In en, this message translates to:
  /// **'Paste target'**
  String get pasteTarget;

  /// No description provided for @pasteToLeft.
  ///
  /// In en, this message translates to:
  /// **'Paste to left'**
  String get pasteToLeft;

  /// No description provided for @pasteToRight.
  ///
  /// In en, this message translates to:
  /// **'Paste to right'**
  String get pasteToRight;

  /// No description provided for @pathChangeCancelled.
  ///
  /// In en, this message translates to:
  /// **'PATH change cancelled'**
  String get pathChangeCancelled;

  /// No description provided for @pathChangeFailed.
  ///
  /// In en, this message translates to:
  /// **'PATH change failed: {error}'**
  String pathChangeFailed(String error);

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String pending(String count);

  /// No description provided for @pending2.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending2;

  /// No description provided for @pendingOperationPlan.
  ///
  /// In en, this message translates to:
  /// **'Pending operation plan'**
  String get pendingOperationPlan;

  /// No description provided for @plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur.
  ///
  /// In en, this message translates to:
  /// **'{count} planned steps have not run. {action} will discard them; no repository changes will occur.'**
  String plannedStepsHaveNotRunWillDiscardThemNoRepositoryChangesWillOccur(
    String action,
    String count,
  );

  /// No description provided for @popStash.
  ///
  /// In en, this message translates to:
  /// **'Pop Stash'**
  String get popStash;

  /// No description provided for @preciseSizeView.
  ///
  /// In en, this message translates to:
  /// **'Precise size view'**
  String get preciseSizeView;

  /// No description provided for @preparingToExecute.
  ///
  /// In en, this message translates to:
  /// **'Preparing to execute'**
  String get preparingToExecute;

  /// No description provided for @preparingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Preparing update…'**
  String get preparingUpdate;

  /// No description provided for @projectFolder.
  ///
  /// In en, this message translates to:
  /// **'Project folder'**
  String get projectFolder;

  /// No description provided for @projectFolderName.
  ///
  /// In en, this message translates to:
  /// **'Project folder name'**
  String get projectFolderName;

  /// No description provided for @projectSize.
  ///
  /// In en, this message translates to:
  /// **'Project size'**
  String get projectSize;

  /// No description provided for @projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Project: {project}\nTarget branch: {branch}\nTarget commit: {target}\nEmpty commit message: {message}\nPlan confirmation: {confirmation}'**
  String projectTargetBranchTargetCommitEmptyCommitMessagePlanConfirmation(
    String branch,
    String confirmation,
    String message,
    String project,
    String target,
  );

  /// No description provided for @pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex.
  ///
  /// In en, this message translates to:
  /// **'Pull fetches and rechecks ahead/behind, allows fast-forward only, never creates a merge commit, and is disabled for a dirty worktree or index.'**
  String
  get pullFetchesAndRechecksAheadBehindAllowsFastForwardOnlyNeverCreatesAMergeCommitAndIsDisabledForADirtyWorktreeOrIndex;

  /// No description provided for @push.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get push;

  /// No description provided for @pushAll.
  ///
  /// In en, this message translates to:
  /// **'Push all'**
  String get pushAll;

  /// No description provided for @pushCurrentBranchCtrlShiftU.
  ///
  /// In en, this message translates to:
  /// **'Push current branch (Ctrl+Shift+U)'**
  String get pushCurrentBranchCtrlShiftU;

  /// No description provided for @readingBranchesAndTagsFrom.
  ///
  /// In en, this message translates to:
  /// **'Reading branches and tags from {remote}…'**
  String readingBranchesAndTagsFrom(String remote);

  /// No description provided for @readingSynchronizationState.
  ///
  /// In en, this message translates to:
  /// **'Reading synchronization state…'**
  String get readingSynchronizationState;

  /// No description provided for @recentlyOpened.
  ///
  /// In en, this message translates to:
  /// **'Recently opened'**
  String get recentlyOpened;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @refreshBranches.
  ///
  /// In en, this message translates to:
  /// **'Refresh branches'**
  String get refreshBranches;

  /// No description provided for @refreshLogs.
  ///
  /// In en, this message translates to:
  /// **'Refresh logs'**
  String get refreshLogs;

  /// No description provided for @refreshRemotes.
  ///
  /// In en, this message translates to:
  /// **'Refresh remotes'**
  String get refreshRemotes;

  /// No description provided for @refreshRepositoryAndRebuildPlan.
  ///
  /// In en, this message translates to:
  /// **'Refresh repository and rebuild plan'**
  String get refreshRepositoryAndRebuildPlan;

  /// No description provided for @refreshRepositoryCtrlR.
  ///
  /// In en, this message translates to:
  /// **'Refresh repository (Ctrl+R)'**
  String get refreshRepositoryCtrlR;

  /// No description provided for @refreshStashes.
  ///
  /// In en, this message translates to:
  /// **'Refresh Stashes'**
  String get refreshStashes;

  /// No description provided for @refreshSynchronizationState.
  ///
  /// In en, this message translates to:
  /// **'Refresh synchronization state'**
  String get refreshSynchronizationState;

  /// No description provided for @remoteCheck.
  ///
  /// In en, this message translates to:
  /// **'Remote check'**
  String get remoteCheck;

  /// No description provided for @remoteName.
  ///
  /// In en, this message translates to:
  /// **'Remote name'**
  String get remoteName;

  /// No description provided for @remoteRefList.
  ///
  /// In en, this message translates to:
  /// **'Remote ref list'**
  String get remoteRefList;

  /// No description provided for @remoteRepositoriesWereDetectedSoClearingIsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Remote repositories were detected, so clearing is disabled: {remotes}'**
  String remoteRepositoriesWereDetectedSoClearingIsDisabled(String remotes);

  /// No description provided for @remoteRepositoryUrl.
  ///
  /// In en, this message translates to:
  /// **'Remote repository URL'**
  String get remoteRepositoryUrl;

  /// No description provided for @remoteUrl.
  ///
  /// In en, this message translates to:
  /// **'Remote URL'**
  String get remoteUrl;

  /// No description provided for @remotes.
  ///
  /// In en, this message translates to:
  /// **'Remotes {count}'**
  String remotes(String count);

  /// No description provided for @remotes2.
  ///
  /// In en, this message translates to:
  /// **'Remotes'**
  String get remotes2;

  /// No description provided for @removeFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Remove from history'**
  String get removeFromHistory;

  /// No description provided for @removeFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Remove from plan'**
  String get removeFromPlan;

  /// No description provided for @removeFromSystemPath.
  ///
  /// In en, this message translates to:
  /// **'Remove from system PATH'**
  String get removeFromSystemPath;

  /// No description provided for @removeFromUserPath.
  ///
  /// In en, this message translates to:
  /// **'Remove from user PATH'**
  String get removeFromUserPath;

  /// No description provided for @removeLocalRemoteConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Remove local remote configuration'**
  String get removeLocalRemoteConfiguration;

  /// No description provided for @removedItemsAndFreed.
  ///
  /// In en, this message translates to:
  /// **'Removed {count} items and freed {size}.'**
  String removedItemsAndFreed(String count, String size);

  /// No description provided for @removedItemsCouldNotBeDeletedCheckTheDetailedLog.
  ///
  /// In en, this message translates to:
  /// **'Removed {removed} items; {failed} could not be deleted. Check the detailed log.'**
  String removedItemsCouldNotBeDeletedCheckTheDetailedLog(
    String failed,
    String removed,
  );

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameBranch.
  ///
  /// In en, this message translates to:
  /// **'Rename branch'**
  String get renameBranch;

  /// No description provided for @repository.
  ///
  /// In en, this message translates to:
  /// **'Repository: {path}'**
  String repository(String path);

  /// No description provided for @repositoryAndRemoteOperationsAreAvailable.
  ///
  /// In en, this message translates to:
  /// **'Repository and remote operations are available'**
  String get repositoryAndRemoteOperationsAreAvailable;

  /// No description provided for @repositoryViewRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Repository view refreshed'**
  String get repositoryViewRefreshed;

  /// No description provided for @reviewRemoveOrExecutePendingOperations.
  ///
  /// In en, this message translates to:
  /// **'Review, remove or execute pending operations'**
  String get reviewRemoveOrExecutePendingOperations;

  /// No description provided for @rightExplorer.
  ///
  /// In en, this message translates to:
  /// **'Right explorer'**
  String get rightExplorer;

  /// No description provided for @safeFastForwardPull.
  ///
  /// In en, this message translates to:
  /// **'Safe fast-forward pull'**
  String get safeFastForwardPull;

  /// No description provided for @saveSettings2.
  ///
  /// In en, this message translates to:
  /// **'Save settings'**
  String get saveSettings2;

  /// No description provided for @scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get scanAgain;

  /// No description provided for @scanOldVersionsAndInstallers.
  ///
  /// In en, this message translates to:
  /// **'Scan old versions and installers'**
  String get scanOldVersionsAndInstallers;

  /// No description provided for @scrollDownForFontPreviewAndFontSizeSettings.
  ///
  /// In en, this message translates to:
  /// **'Scroll down for font preview and font-size settings.'**
  String get scrollDownForFontPreviewAndFontSizeSettings;

  /// No description provided for @searchFontNameOrPurposeEGInterOrNoto.
  ///
  /// In en, this message translates to:
  /// **'Search font name or purpose, e.g. Inter or Noto'**
  String get searchFontNameOrPurposeEGInterOrNoto;

  /// No description provided for @selectAnItemToRename.
  ///
  /// In en, this message translates to:
  /// **'Select an item to rename.'**
  String get selectAnItemToRename;

  /// No description provided for @selectExactlyOneItemToRename.
  ///
  /// In en, this message translates to:
  /// **'Select exactly one item to rename.'**
  String get selectExactlyOneItemToRename;

  /// No description provided for @selectFilesToCutOrCopy.
  ///
  /// In en, this message translates to:
  /// **'Select files to cut or copy'**
  String get selectFilesToCutOrCopy;

  /// No description provided for @selectItemsToDelete.
  ///
  /// In en, this message translates to:
  /// **'Select items to delete first.'**
  String get selectItemsToDelete;

  /// No description provided for @selectTheDangerousOperationConfirmationFirst.
  ///
  /// In en, this message translates to:
  /// **'Select the dangerous-operation confirmation first.'**
  String get selectTheDangerousOperationConfirmationFirst;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected(String count);

  /// No description provided for @selected2.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selected2(String count);

  /// No description provided for @settings2.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings2;

  /// No description provided for @settingsDataDirectory.
  ///
  /// In en, this message translates to:
  /// **'Settings data directory'**
  String get settingsDataDirectory;

  /// No description provided for @showInFileExplorer.
  ///
  /// In en, this message translates to:
  /// **'Show in File Explorer'**
  String get showInFileExplorer;

  /// No description provided for @siDecimal.
  ///
  /// In en, this message translates to:
  /// **'SI decimal'**
  String get siDecimal;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @sizeUnitSystem.
  ///
  /// In en, this message translates to:
  /// **'Size unit system'**
  String get sizeUnitSystem;

  /// No description provided for @smallFile.
  ///
  /// In en, this message translates to:
  /// **'Small file'**
  String get smallFile;

  /// No description provided for @stageAll.
  ///
  /// In en, this message translates to:
  /// **'Stage all'**
  String get stageAll;

  /// No description provided for @staged.
  ///
  /// In en, this message translates to:
  /// **'{count} staged'**
  String staged(String count);

  /// No description provided for @stash.
  ///
  /// In en, this message translates to:
  /// **'Stash'**
  String get stash;

  /// No description provided for @stashManagement.
  ///
  /// In en, this message translates to:
  /// **'Stash management'**
  String get stashManagement;

  /// No description provided for @stashMessageOptional.
  ///
  /// In en, this message translates to:
  /// **'Stash message (optional)'**
  String get stashMessageOptional;

  /// No description provided for @stateChangeDetails.
  ///
  /// In en, this message translates to:
  /// **'State change details'**
  String get stateChangeDetails;

  /// No description provided for @stateChangedBeforeExecution.
  ///
  /// In en, this message translates to:
  /// **'State changed before execution'**
  String get stateChangedBeforeExecution;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @step.
  ///
  /// In en, this message translates to:
  /// **'Step {step}: {title}'**
  String step(String step, String title);

  /// No description provided for @stepsTheRepositoryIsUnchangedUntilConfirmation.
  ///
  /// In en, this message translates to:
  /// **'{count} steps; the repository is unchanged until confirmation'**
  String stepsTheRepositoryIsUnchangedUntilConfirmation(String count);

  /// No description provided for @supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst.
  ///
  /// In en, this message translates to:
  /// **'Supports GitHub, Gitee, GitLab, Bitbucket and standard Git remotes. Changes are planned first.'**
  String
  get supportsGithubGiteeGitlabBitbucketAndStandardGitRemotesChangesArePlannedFirst;

  /// No description provided for @switchBranch.
  ///
  /// In en, this message translates to:
  /// **'Switch branch'**
  String get switchBranch;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @systemDefaultAutomatic.
  ///
  /// In en, this message translates to:
  /// **'System default (automatic)'**
  String get systemDefaultAutomatic;

  /// No description provided for @systemFonts.
  ///
  /// In en, this message translates to:
  /// **'System fonts'**
  String get systemFonts;

  /// No description provided for @systemGit.
  ///
  /// In en, this message translates to:
  /// **'System Git'**
  String get systemGit;

  /// No description provided for @textCanBeSelectedAndCopiedHereTheFullGuideIsIn.
  ///
  /// In en, this message translates to:
  /// **'Text can be selected and copied here. The full guide is in {path}.'**
  String textCanBeSelectedAndCopiedHereTheFullGuideIsIn(String path);

  /// No description provided for @thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject.
  ///
  /// In en, this message translates to:
  /// **'Thanks to DeepSeek AI and ChatGPT Codex for creating and improving this project.'**
  String
  get thanksToDeepseekAiAndChatgptCodexForCreatingAndImprovingThisProject;

  /// No description provided for @theCloneDestinationFolderIsNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clone destination folder is not empty.'**
  String get theCloneDestinationFolderIsNotEmpty;

  /// No description provided for @theCloneDestinationParentFolderDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'The clone destination parent folder does not exist.'**
  String get theCloneDestinationParentFolderDoesNotExist;

  /// No description provided for @theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText.
  ///
  /// In en, this message translates to:
  /// **'The color scheme applies to buttons, selected states, borders, icons, and emphasized text.'**
  String
  get theColorSchemeAppliesToButtonsSelectedStatesBordersIconsAndEmphasizedText;

  /// No description provided for @theCurrentBranchHasNoCommitAndCannotBePulled.
  ///
  /// In en, this message translates to:
  /// **'The current branch has no commit and cannot be pulled.'**
  String get theCurrentBranchHasNoCommitAndCannotBePulled;

  /// No description provided for @theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking.
  ///
  /// In en, this message translates to:
  /// **'The current branch has no upstream. Fetch-all is available, but Pull requires tracking.'**
  String
  get theCurrentBranchHasNoUpstreamFetchAllIsAvailableButPullRequiresTracking;

  /// No description provided for @theCurrentBranchIsSynchronizedWithUpstream.
  ///
  /// In en, this message translates to:
  /// **'The current branch is synchronized with upstream.'**
  String get theCurrentBranchIsSynchronizedWithUpstream;

  /// No description provided for @theDetailedReasonHasBeenWrittenToTheApplicationLog.
  ///
  /// In en, this message translates to:
  /// **'The detailed reason has been written to the application log.'**
  String get theDetailedReasonHasBeenWrittenToTheApplicationLog;

  /// No description provided for @theGiteeSourceIsSuitedToMainlandChinaNetworks.
  ///
  /// In en, this message translates to:
  /// **'The Gitee source is suited to mainland China networks.'**
  String get theGiteeSourceIsSuitedToMainlandChinaNetworks;

  /// No description provided for @theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'The initialization target must exist and must not already contain Git metadata.'**
  String
  get theInitializationTargetMustExistAndMustNotAlreadyContainGitMetadata;

  /// No description provided for @theLanguageChangeTakesEffectImmediatelyAfterSaving.
  ///
  /// In en, this message translates to:
  /// **'The language change takes effect immediately after saving.'**
  String get theLanguageChangeTakesEffectImmediatelyAfterSaving;

  /// No description provided for @theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull.
  ///
  /// In en, this message translates to:
  /// **'The local branch has unpushed commits and does not need Pull.'**
  String get theLocalBranchHasUnpushedCommitsAndDoesNotNeedPull;

  /// No description provided for @theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone.
  ///
  /// In en, this message translates to:
  /// **'The next step only creates a clone preview. Cancel creates nothing; confirming the plan rechecks the destination and runs git clone.'**
  String
  get theNextStepOnlyCreatesAClonePreviewCancelCreatesNothingConfirmingThePlanRechecksTheDestinationAndRunsGitClone;

  /// No description provided for @thePlanPushesTo.
  ///
  /// In en, this message translates to:
  /// **'The plan pushes {branch} to:\n{remotes}'**
  String thePlanPushesTo(String branch, String remotes);

  /// No description provided for @theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated.
  ///
  /// In en, this message translates to:
  /// **'The remote has no branches or tags. The first empty commit will be created.'**
  String get theRemoteHasNoBranchesOrTagsTheFirstEmptyCommitWillBeCreated;

  /// No description provided for @theRepositoryHasNoStashes.
  ///
  /// In en, this message translates to:
  /// **'The repository has no Stashes.'**
  String get theRepositoryHasNoStashes;

  /// No description provided for @theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes.
  ///
  /// In en, this message translates to:
  /// **'The saved font applies to menus, explorers, dialogs and commit notes.'**
  String get theSavedFontAppliesToMenusExplorersDialogsAndCommitNotes;

  /// No description provided for @theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull.
  ///
  /// In en, this message translates to:
  /// **'The worktree or index is dirty. Commit or stash changes before safe Pull.'**
  String get theWorktreeOrIndexIsDirtyCommitOrStashChangesBeforeSafePull;

  /// No description provided for @thereAreNoLocalBranchesToDisplay.
  ///
  /// In en, this message translates to:
  /// **'There are no local branches to display.'**
  String get thereAreNoLocalBranchesToDisplay;

  /// No description provided for @thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This action is added to the plan. git mv runs only after confirmation.'**
  String get thisActionIsAddedToThePlanGitMvRunsOnlyAfterConfirmation;

  /// No description provided for @thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles.
  ///
  /// In en, this message translates to:
  /// **'This dangerous action cannot be undone. The remote is backed up, {branch} is replaced with an empty root commit, other refs are deleted, and the local branch/index are synchronized without deleting files.'**
  String
  thisDangerousActionCannotBeUndoneTheRemoteIsBackedUpIsReplacedWithAnEmptyRootCommitOtherRefsAreDeletedAndTheLocalBranchIndexAreSynchronizedWithoutDeletingFiles(
    String branch,
  );

  /// No description provided for @thisOperationDeletesTheGitFolderInTheRepositoryRoot.
  ///
  /// In en, this message translates to:
  /// **'This operation deletes the .git folder in the repository root.'**
  String get thisOperationDeletesTheGitFolderInTheRepositoryRoot;

  /// No description provided for @thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit.
  ///
  /// In en, this message translates to:
  /// **'This plan includes {count} dangerous steps. File deletion cannot be undone here; remote reset keeps only one empty commit.'**
  String
  thisPlanIncludesDangerousStepsFileDeletionCannotBeUndoneHereRemoteResetKeepsOnlyOneEmptyCommit(
    String count,
  );

  /// No description provided for @thisProjectIsLicensedUnderTheMitLicense.
  ///
  /// In en, this message translates to:
  /// **'This project is licensed under the MIT License.'**
  String get thisProjectIsLicensedUnderTheMitLicense;

  /// No description provided for @threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge.
  ///
  /// In en, this message translates to:
  /// **'Three safe sizes prevent layouts from becoming too small or large.'**
  String get threeSafeSizesPreventLayoutsFromBecomingTooSmallOrLarge;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String today(String time);

  /// No description provided for @turnGitFileOperationsIntoAnIntuitiveWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Turn Git file operations\ninto an intuitive workspace.'**
  String get turnGitFileOperationsIntoAnIntuitiveWorkspace;

  /// No description provided for @typeANameToFilter.
  ///
  /// In en, this message translates to:
  /// **'Type a name to filter'**
  String get typeANameToFilter;

  /// No description provided for @unableToOpenFile.
  ///
  /// In en, this message translates to:
  /// **'Unable to open file: {error}'**
  String unableToOpenFile(String error);

  /// No description provided for @unableToOpenLogsFolder.
  ///
  /// In en, this message translates to:
  /// **'Unable to open logs folder: {error}'**
  String unableToOpenLogsFolder(String error);

  /// No description provided for @unableToOpenProjectFolder.
  ///
  /// In en, this message translates to:
  /// **'Unable to open project folder: {error}'**
  String unableToOpenProjectFolder(String error);

  /// No description provided for @unableToOpenTheGitDownloadPage.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the Git download page: {error}'**
  String unableToOpenTheGitDownloadPage(String error);

  /// No description provided for @unableToReadBranchSynchronizationStateRefreshAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Unable to read branch synchronization state. Refresh and try again.'**
  String get unableToReadBranchSynchronizationStateRefreshAndTryAgain;

  /// No description provided for @unableToReadFolder.
  ///
  /// In en, this message translates to:
  /// **'Unable to read folder'**
  String get unableToReadFolder;

  /// No description provided for @unableToReadUserGuide.
  ///
  /// In en, this message translates to:
  /// **'Unable to read user guide: {error}'**
  String unableToReadUserGuide(String error);

  /// No description provided for @unableToRetrieveTheOnlineVersion.
  ///
  /// In en, this message translates to:
  /// **'Unable to retrieve the online version'**
  String get unableToRetrieveTheOnlineVersion;

  /// No description provided for @unitPreview.
  ///
  /// In en, this message translates to:
  /// **'Unit preview'**
  String get unitPreview;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unstage.
  ///
  /// In en, this message translates to:
  /// **'Unstage'**
  String get unstage;

  /// No description provided for @updateAndRestartNow.
  ///
  /// In en, this message translates to:
  /// **'Update and restart now'**
  String get updateAndRestartNow;

  /// No description provided for @updateSource.
  ///
  /// In en, this message translates to:
  /// **'Update source'**
  String get updateSource;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated {scope}'**
  String updated(String scope);

  /// No description provided for @updates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get updates;

  /// No description provided for @updatesAndReleaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Updates and release notes'**
  String get updatesAndReleaseNotes;

  /// No description provided for @updating.
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get updating;

  /// No description provided for @updatingAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Updating automatically'**
  String get updatingAutomatically;

  /// No description provided for @upstream.
  ///
  /// In en, this message translates to:
  /// **'upstream'**
  String get upstream;

  /// No description provided for @usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected.
  ///
  /// In en, this message translates to:
  /// **'{platform} usually protects the default branch. Remove protection temporarily if force update or deletion is rejected.'**
  String
  usuallyProtectsTheDefaultBranchRemoveProtectionTemporarilyIfForceUpdateOrDeletionIsRejected(
    String platform,
  );

  /// No description provided for @versionNotFoundOrUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Version not found or unreadable'**
  String get versionNotFoundOrUnreadable;

  /// No description provided for @versionV.
  ///
  /// In en, this message translates to:
  /// **'Version v{version}'**
  String versionV(String version);

  /// No description provided for @versionVIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version v{version} is available'**
  String versionVIsAvailable(String version);

  /// No description provided for @viewAndManageAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'View and manage all remotes'**
  String get viewAndManageAllRemotes;

  /// No description provided for @viewBranchSynchronization.
  ///
  /// In en, this message translates to:
  /// **'View branch synchronization'**
  String get viewBranchSynchronization;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View logs'**
  String get viewLogs;

  /// No description provided for @workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks.
  ///
  /// In en, this message translates to:
  /// **'Working files are retained, but the following Git data will be permanently lost:\n• All commit history and reflog\n• Local branches, tags, and current branch state\n• Staged index, Stashes, and committed content not retained in working files\n• Refs, remote configuration, and repository-level Git settings and hooks'**
  String
  get workingFilesAreRetainedButTheFollowingGitDataWillBePermanentlyLostAllCommitHistoryAndReflogLocalBranchesTagsAndCurrentBranchStateStagedIndexStashesAndCommittedContentNotRetainedInWorkingFilesRefsRemoteConfigurationAndRepositoryLevelGitSettingsAndHooks;

  /// No description provided for @workingTreeClean.
  ///
  /// In en, this message translates to:
  /// **'Working tree clean'**
  String get workingTreeClean;

  /// No description provided for @worktree.
  ///
  /// In en, this message translates to:
  /// **'Worktree'**
  String get worktree;

  /// No description provided for @youAreUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are up to date'**
  String get youAreUpToDate;

  /// No description provided for @followSystemLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get followSystemLabel;

  /// No description provided for @followSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the language selected in the operating system.'**
  String get followSystemDescription;

  /// No description provided for @languageEnglishOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishOptionLabel;

  /// No description provided for @languageEnglishDescription.
  ///
  /// In en, this message translates to:
  /// **'Use English for the application interface.'**
  String get languageEnglishDescription;

  /// No description provided for @languageSimplifiedChineseOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageSimplifiedChineseOptionLabel;

  /// No description provided for @languageSimplifiedChineseDescription.
  ///
  /// In en, this message translates to:
  /// **'使用简体中文显示软件界面。'**
  String get languageSimplifiedChineseDescription;

  /// No description provided for @languageTraditionalChineseOptionLabel.
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get languageTraditionalChineseOptionLabel;

  /// No description provided for @languageTraditionalChineseDescription.
  ///
  /// In en, this message translates to:
  /// **'使用繁體中文顯示軟體介面。'**
  String get languageTraditionalChineseDescription;

  /// No description provided for @userPath.
  ///
  /// In en, this message translates to:
  /// **'User PATH'**
  String get userPath;

  /// No description provided for @systemPath.
  ///
  /// In en, this message translates to:
  /// **'System PATH'**
  String get systemPath;

  /// No description provided for @addPortableGitTo.
  ///
  /// In en, this message translates to:
  /// **'Add PortableGit to {scope}'**
  String addPortableGitTo(String scope);

  /// No description provided for @removePortableGitFrom.
  ///
  /// In en, this message translates to:
  /// **'Remove PortableGit from {scope}'**
  String removePortableGitFrom(String scope);

  /// No description provided for @confirmAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get confirmAdd;

  /// No description provided for @confirmRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get confirmRemove;

  /// No description provided for @gitAvailable.
  ///
  /// In en, this message translates to:
  /// **'Git available'**
  String get gitAvailable;

  /// No description provided for @gitUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Git unavailable'**
  String get gitUnavailable;

  /// No description provided for @creatingShortcut.
  ///
  /// In en, this message translates to:
  /// **'Creating shortcut…'**
  String get creatingShortcut;

  /// No description provided for @oneClickSendToDesktop.
  ///
  /// In en, this message translates to:
  /// **'Send to desktop'**
  String get oneClickSendToDesktop;

  /// No description provided for @bundledLabel.
  ///
  /// In en, this message translates to:
  /// **'Bundled'**
  String get bundledLabel;

  /// No description provided for @iec1024BaseBit.
  ///
  /// In en, this message translates to:
  /// **'IEC · base 1024 · bit'**
  String get iec1024BaseBit;

  /// No description provided for @si1000BaseBit.
  ///
  /// In en, this message translates to:
  /// **'SI · base 1000 · bit'**
  String get si1000BaseBit;

  /// No description provided for @iec1024BaseByte.
  ///
  /// In en, this message translates to:
  /// **'IEC · base 1024 · Byte'**
  String get iec1024BaseByte;

  /// No description provided for @si1000BaseByte.
  ///
  /// In en, this message translates to:
  /// **'SI · base 1000 · Byte'**
  String get si1000BaseByte;

  /// No description provided for @classicGreen.
  ///
  /// In en, this message translates to:
  /// **'Classic green'**
  String get classicGreen;

  /// No description provided for @oceanBlue.
  ///
  /// In en, this message translates to:
  /// **'Ocean blue'**
  String get oceanBlue;

  /// No description provided for @starryViolet.
  ///
  /// In en, this message translates to:
  /// **'Starry violet'**
  String get starryViolet;

  /// No description provided for @amberGold.
  ///
  /// In en, this message translates to:
  /// **'Amber gold'**
  String get amberGold;

  /// No description provided for @roseRed.
  ///
  /// In en, this message translates to:
  /// **'Rose red'**
  String get roseRed;

  /// No description provided for @interUiDescription.
  ///
  /// In en, this message translates to:
  /// **'An open-source sans-serif designed for digital interfaces and dense text.'**
  String get interUiDescription;

  /// No description provided for @notoSansScDescription.
  ///
  /// In en, this message translates to:
  /// **'A modern interface font covering Simplified Chinese with stable mixed-script forms.'**
  String get notoSansScDescription;

  /// No description provided for @ibmPlexSansDescription.
  ///
  /// In en, this message translates to:
  /// **'Designed for product interfaces and business information with strong numeral readability.'**
  String get ibmPlexSansDescription;

  /// No description provided for @fontDescription.
  ///
  /// In en, this message translates to:
  /// **'Bundled interface font'**
  String get fontDescription;

  /// No description provided for @operationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Operation completed.'**
  String get operationCompleted;

  /// No description provided for @operationCompletedFor.
  ///
  /// In en, this message translates to:
  /// **'Operation completed: {target}.'**
  String operationCompletedFor(String target);

  /// No description provided for @operationCompletedForItems.
  ///
  /// In en, this message translates to:
  /// **'Operation completed for {count} item(s).'**
  String operationCompletedForItems(String count);

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed: {error}'**
  String operationFailed(String error);

  /// No description provided for @operationFailedFor.
  ///
  /// In en, this message translates to:
  /// **'Operation failed for {target}: {error}'**
  String operationFailedFor(String error, String target);

  /// No description provided for @logInfo.
  ///
  /// In en, this message translates to:
  /// **'Information event: {eventId}'**
  String logInfo(String eventId);

  /// No description provided for @logDetail.
  ///
  /// In en, this message translates to:
  /// **'Detailed event: {eventId}'**
  String logDetail(String eventId);

  /// No description provided for @logWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning event: {eventId}'**
  String logWarning(String eventId);

  /// No description provided for @logError.
  ///
  /// In en, this message translates to:
  /// **'Error event: {eventId}'**
  String logError(String eventId);

  /// No description provided for @logsTruncated.
  ///
  /// In en, this message translates to:
  /// **'… Showing only recent log entries …'**
  String get logsTruncated;

  /// No description provided for @logReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read logs: {error}'**
  String logReadFailed(String error);

  /// No description provided for @noRepositoryOpen.
  ///
  /// In en, this message translates to:
  /// **'No repository is open.'**
  String get noRepositoryOpen;

  /// No description provided for @operationInProgress.
  ///
  /// In en, this message translates to:
  /// **'Another operation is still running.'**
  String get operationInProgress;

  /// No description provided for @emptyOperationPlan.
  ///
  /// In en, this message translates to:
  /// **'The operation plan is empty.'**
  String get emptyOperationPlan;

  /// No description provided for @gitUnavailableHelp.
  ///
  /// In en, this message translates to:
  /// **'Git is unavailable. Install Git or check again in Settings.'**
  String get gitUnavailableHelp;

  /// No description provided for @selectItemsFirst.
  ///
  /// In en, this message translates to:
  /// **'Select files or folders first.'**
  String get selectItemsFirst;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clipboard is empty.'**
  String get clipboardEmpty;

  /// No description provided for @clipboardCleared.
  ///
  /// In en, this message translates to:
  /// **'Clipboard cleared.'**
  String get clipboardCleared;

  /// No description provided for @clipboardPendingCut.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) pending move'**
  String clipboardPendingCut(String count);

  /// No description provided for @clipboardPendingCopy.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s) pending copy'**
  String clipboardPendingCopy(String count);

  /// No description provided for @operationPlanBusyEdit.
  ///
  /// In en, this message translates to:
  /// **'The plan is running and cannot be edited.'**
  String get operationPlanBusyEdit;

  /// No description provided for @operationPlanBusyClear.
  ///
  /// In en, this message translates to:
  /// **'The plan is running and cannot be cleared.'**
  String get operationPlanBusyClear;

  /// No description provided for @planOperationMissing.
  ///
  /// In en, this message translates to:
  /// **'The planned operation no longer exists.'**
  String get planOperationMissing;

  /// No description provided for @planOperationRemoved.
  ///
  /// In en, this message translates to:
  /// **'The operation was removed from the plan.'**
  String get planOperationRemoved;

  /// No description provided for @planCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {count} planned step(s).'**
  String planCleared(String count);

  /// No description provided for @planStrongConfirmationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter {confirmation} exactly to confirm this dangerous operation.'**
  String planStrongConfirmationRequired(String confirmation);

  /// No description provided for @planDangerousAcknowledgmentRequired.
  ///
  /// In en, this message translates to:
  /// **'Select the dangerous-operation acknowledgement before executing.'**
  String get planDangerousAcknowledgmentRequired;

  /// No description provided for @planStateChanged.
  ///
  /// In en, this message translates to:
  /// **'The repository changed after confirmation. Refresh and rebuild the plan.'**
  String get planStateChanged;

  /// No description provided for @planStepStateChanged.
  ///
  /// In en, this message translates to:
  /// **'The repository changed before step {step}. Execution stopped; refresh and rebuild the plan.'**
  String planStepStateChanged(String step);

  /// No description provided for @planStepFailed.
  ///
  /// In en, this message translates to:
  /// **'Step {step} failed: {error}. Later steps did not run and the failed step remains in the plan.'**
  String planStepFailed(String error, String step);

  /// No description provided for @planExecutionComplete.
  ///
  /// In en, this message translates to:
  /// **'Executed all {count} planned step(s) in order.'**
  String planExecutionComplete(String count);

  /// No description provided for @planOperationAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the operation plan. No Git changes have run yet.'**
  String get planOperationAdded;

  /// No description provided for @planSnapshotFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not capture the safety snapshot: {error}'**
  String planSnapshotFailed(String error);

  /// No description provided for @clearRemoteMustRunAlone.
  ///
  /// In en, this message translates to:
  /// **'Clearing a remote must run alone. Remove or execute the other planned steps first.'**
  String get clearRemoteMustRunAlone;

  /// No description provided for @commitMustRemainLast.
  ///
  /// In en, this message translates to:
  /// **'Commit is already at the end of the plan. Remove it before editing files again.'**
  String get commitMustRemainLast;

  /// No description provided for @exclusiveOperationMustRunAlone.
  ///
  /// In en, this message translates to:
  /// **'This lifecycle operation must run alone.'**
  String get exclusiveOperationMustRunAlone;

  /// No description provided for @exclusiveOperationAlreadyQueued.
  ///
  /// In en, this message translates to:
  /// **'The plan already contains an operation that must run alone.'**
  String get exclusiveOperationAlreadyQueued;

  /// No description provided for @renameSelectOne.
  ///
  /// In en, this message translates to:
  /// **'Select exactly one file or folder to rename.'**
  String get renameSelectOne;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'The name cannot be empty.'**
  String get nameCannotBeEmpty;

  /// No description provided for @historyEntryRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed from recent repositories.'**
  String get historyEntryRemoved;

  /// No description provided for @gitMetadataClearAvailable.
  ///
  /// In en, this message translates to:
  /// **'No remote is configured; Git metadata may be cleared.'**
  String get gitMetadataClearAvailable;

  /// No description provided for @gitMetadataCleared.
  ///
  /// In en, this message translates to:
  /// **'Git metadata was cleared. Working files remain.'**
  String get gitMetadataCleared;

  /// No description provided for @gitMetadataRemoteForbidden.
  ///
  /// In en, this message translates to:
  /// **'Git metadata cannot be cleared while remotes are configured.'**
  String get gitMetadataRemoteForbidden;

  /// No description provided for @fileRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed to {name}.'**
  String fileRenamed(String name);

  /// No description provided for @bootstrapPlanAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This preview has already run or is running. Open a new preview.'**
  String get bootstrapPlanAlreadyUsed;

  /// No description provided for @bootstrapStateChanged.
  ///
  /// In en, this message translates to:
  /// **'The target changed after confirmation. Refresh the preview and confirm again.'**
  String get bootstrapStateChanged;

  /// No description provided for @unableToInspectRepository.
  ///
  /// In en, this message translates to:
  /// **'Unable to inspect the repository.'**
  String get unableToInspectRepository;

  /// No description provided for @stepsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String stepsCount(String count);

  /// No description provided for @planKindInitialize.
  ///
  /// In en, this message translates to:
  /// **'Initialize'**
  String get planKindInitialize;

  /// No description provided for @planKindClone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get planKindClone;

  /// No description provided for @planKindMove.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get planKindMove;

  /// No description provided for @planKindCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get planKindCopy;

  /// No description provided for @planKindRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get planKindRename;

  /// No description provided for @planKindDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get planKindDelete;

  /// No description provided for @planKindClearGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Clear Git metadata'**
  String get planKindClearGitMetadata;

  /// No description provided for @planKindStageAll.
  ///
  /// In en, this message translates to:
  /// **'Stage'**
  String get planKindStageAll;

  /// No description provided for @planKindUnstageAll.
  ///
  /// In en, this message translates to:
  /// **'Unstage'**
  String get planKindUnstageAll;

  /// No description provided for @planKindCommit.
  ///
  /// In en, this message translates to:
  /// **'Commit'**
  String get planKindCommit;

  /// No description provided for @planKindFetchCurrent.
  ///
  /// In en, this message translates to:
  /// **'Fetch upstream'**
  String get planKindFetchCurrent;

  /// No description provided for @planKindFetchAll.
  ///
  /// In en, this message translates to:
  /// **'Fetch all'**
  String get planKindFetchAll;

  /// No description provided for @planKindPull.
  ///
  /// In en, this message translates to:
  /// **'Fast-forward pull'**
  String get planKindPull;

  /// No description provided for @planKindPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get planKindPush;

  /// No description provided for @planKindPushAll.
  ///
  /// In en, this message translates to:
  /// **'Push all'**
  String get planKindPushAll;

  /// No description provided for @planKindAddRemote.
  ///
  /// In en, this message translates to:
  /// **'Add remote'**
  String get planKindAddRemote;

  /// No description provided for @planKindUpdateRemote.
  ///
  /// In en, this message translates to:
  /// **'Update remote'**
  String get planKindUpdateRemote;

  /// No description provided for @planKindRemoveRemote.
  ///
  /// In en, this message translates to:
  /// **'Remove remote'**
  String get planKindRemoveRemote;

  /// No description provided for @planKindClearRemote.
  ///
  /// In en, this message translates to:
  /// **'Clear remote'**
  String get planKindClearRemote;

  /// No description provided for @planKindCreateBranch.
  ///
  /// In en, this message translates to:
  /// **'Create branch'**
  String get planKindCreateBranch;

  /// No description provided for @planKindSwitchBranch.
  ///
  /// In en, this message translates to:
  /// **'Switch branch'**
  String get planKindSwitchBranch;

  /// No description provided for @planKindRenameBranch.
  ///
  /// In en, this message translates to:
  /// **'Rename branch'**
  String get planKindRenameBranch;

  /// No description provided for @planKindDeleteBranch.
  ///
  /// In en, this message translates to:
  /// **'Delete branch'**
  String get planKindDeleteBranch;

  /// No description provided for @planKindCreateStash.
  ///
  /// In en, this message translates to:
  /// **'Create Stash'**
  String get planKindCreateStash;

  /// No description provided for @planKindApplyStash.
  ///
  /// In en, this message translates to:
  /// **'Apply Stash'**
  String get planKindApplyStash;

  /// No description provided for @planKindPopStash.
  ///
  /// In en, this message translates to:
  /// **'Pop Stash'**
  String get planKindPopStash;

  /// No description provided for @planKindDropStash.
  ///
  /// In en, this message translates to:
  /// **'Drop Stash'**
  String get planKindDropStash;

  /// No description provided for @planTitleInitializeRepository.
  ///
  /// In en, this message translates to:
  /// **'Initialize Git repository'**
  String get planTitleInitializeRepository;

  /// No description provided for @planDescriptionInitializeRepository.
  ///
  /// In en, this message translates to:
  /// **'Run git init in {path} after confirmation, then open the repository.'**
  String planDescriptionInitializeRepository(String path);

  /// No description provided for @planTitleCloneRepository.
  ///
  /// In en, this message translates to:
  /// **'Clone Git repository'**
  String get planTitleCloneRepository;

  /// No description provided for @planDescriptionCloneRepository.
  ///
  /// In en, this message translates to:
  /// **'Clone {url} into {path}. Canceling creates nothing; confirming rechecks the destination and runs git clone.'**
  String planDescriptionCloneRepository(String path, String url);

  /// No description provided for @planTitleMove.
  ///
  /// In en, this message translates to:
  /// **'Move {count} item(s) to {destination}'**
  String planTitleMove(String count, String destination);

  /// No description provided for @planDescriptionMove.
  ///
  /// In en, this message translates to:
  /// **'Move {count} item(s) with Git into {destination}.'**
  String planDescriptionMove(String count, String destination);

  /// No description provided for @planTitleCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy {count} item(s) to {destination}'**
  String planTitleCopy(String count, String destination);

  /// No description provided for @planDescriptionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy {count} item(s) with Git into {destination}.'**
  String planDescriptionCopy(String count, String destination);

  /// No description provided for @planTitleRename.
  ///
  /// In en, this message translates to:
  /// **'Rename {source}'**
  String planTitleRename(String source);

  /// No description provided for @planDescriptionRename.
  ///
  /// In en, this message translates to:
  /// **'Change the name of {source} to {newName}.'**
  String planDescriptionRename(String newName, String source);

  /// No description provided for @planTitleDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} item(s)'**
  String planTitleDelete(String count);

  /// No description provided for @planDescriptionDelete.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete {count} item(s): {paths}. Tracked files use git rm; untracked or ignored files use git clean.'**
  String planDescriptionDelete(String count, String paths);

  /// No description provided for @planTitleClearGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Clear Git metadata'**
  String get planTitleClearGitMetadata;

  /// No description provided for @planDescriptionClearGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Repository: {path}. Permanently delete .git while keeping working files. Commit history, branches, tags, index, Stashes, remote configuration, and repository settings will be lost. This operation must run alone.'**
  String planDescriptionClearGitMetadata(String path);

  /// No description provided for @planTitleCreateBranch.
  ///
  /// In en, this message translates to:
  /// **'Create branch {branch}'**
  String planTitleCreateBranch(String branch);

  /// No description provided for @planDescriptionCreateBranch.
  ///
  /// In en, this message translates to:
  /// **'Run git branch -- {branch} to create a local branch from HEAD.'**
  String planDescriptionCreateBranch(String branch);

  /// No description provided for @branchCreated.
  ///
  /// In en, this message translates to:
  /// **'Created branch {branch}.'**
  String branchCreated(String branch);

  /// No description provided for @planTitleSwitchBranch.
  ///
  /// In en, this message translates to:
  /// **'Switch to branch {branch}'**
  String planTitleSwitchBranch(String branch);

  /// No description provided for @planDescriptionSwitchBranch.
  ///
  /// In en, this message translates to:
  /// **'Run git switch {branch}. Git refuses the switch if uncommitted changes conflict.'**
  String planDescriptionSwitchBranch(String branch);

  /// No description provided for @branchSwitched.
  ///
  /// In en, this message translates to:
  /// **'Switched to branch {branch}.'**
  String branchSwitched(String branch);

  /// No description provided for @alreadyOnBranch.
  ///
  /// In en, this message translates to:
  /// **'Already on branch {branch}.'**
  String alreadyOnBranch(String branch);

  /// No description provided for @planTitleRenameBranch.
  ///
  /// In en, this message translates to:
  /// **'Rename branch {from} to {to}'**
  String planTitleRenameBranch(String from, String to);

  /// No description provided for @planDescriptionRenameBranch.
  ///
  /// In en, this message translates to:
  /// **'Run git branch -m {from} {to}.'**
  String planDescriptionRenameBranch(String from, String to);

  /// No description provided for @branchRenamed.
  ///
  /// In en, this message translates to:
  /// **'Renamed branch {from} to {to}.'**
  String branchRenamed(String from, String to);

  /// No description provided for @planTitleDeleteBranch.
  ///
  /// In en, this message translates to:
  /// **'Delete branch {branch}'**
  String planTitleDeleteBranch(String branch);

  /// No description provided for @planDescriptionDeleteBranchForce.
  ///
  /// In en, this message translates to:
  /// **'Run git branch -D {branch} to force-delete an unmerged branch.'**
  String planDescriptionDeleteBranchForce(String branch);

  /// No description provided for @planDescriptionDeleteBranchSafe.
  ///
  /// In en, this message translates to:
  /// **'Run git branch -d {branch}. Only merged branches can be deleted.'**
  String planDescriptionDeleteBranchSafe(String branch);

  /// No description provided for @branchDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted branch {branch}.'**
  String branchDeleted(String branch);

  /// No description provided for @cannotDeleteCurrentBranch.
  ///
  /// In en, this message translates to:
  /// **'The current branch cannot be deleted. Switch branches first.'**
  String get cannotDeleteCurrentBranch;

  /// No description provided for @planTitleCreateStash.
  ///
  /// In en, this message translates to:
  /// **'Create Stash'**
  String get planTitleCreateStash;

  /// No description provided for @planTitleCreateStashNamed.
  ///
  /// In en, this message translates to:
  /// **'Create Stash: {message}'**
  String planTitleCreateStashNamed(String message);

  /// No description provided for @planDescriptionCreateStash.
  ///
  /// In en, this message translates to:
  /// **'Run git stash push for the supplied message: {message}'**
  String planDescriptionCreateStash(String message);

  /// No description provided for @planDescriptionCreateStashIncludeUntracked.
  ///
  /// In en, this message translates to:
  /// **'Run git stash push --include-untracked for the supplied message: {message}'**
  String planDescriptionCreateStashIncludeUntracked(String message);

  /// No description provided for @stashCreated.
  ///
  /// In en, this message translates to:
  /// **'Stash created.'**
  String get stashCreated;

  /// No description provided for @planTitleApplyStash.
  ///
  /// In en, this message translates to:
  /// **'Apply {selector}'**
  String planTitleApplyStash(String selector);

  /// No description provided for @planDescriptionApplyStash.
  ///
  /// In en, this message translates to:
  /// **'Run git stash apply {selector} and keep the Stash entry.'**
  String planDescriptionApplyStash(String selector);

  /// No description provided for @stashApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied {selector}.'**
  String stashApplied(String selector);

  /// No description provided for @planTitlePopStash.
  ///
  /// In en, this message translates to:
  /// **'Pop {selector}'**
  String planTitlePopStash(String selector);

  /// No description provided for @planDescriptionPopStash.
  ///
  /// In en, this message translates to:
  /// **'Run git stash pop {selector}; apply it and remove the Stash entry.'**
  String planDescriptionPopStash(String selector);

  /// No description provided for @stashPopped.
  ///
  /// In en, this message translates to:
  /// **'Popped {selector}.'**
  String stashPopped(String selector);

  /// No description provided for @planTitleDropStash.
  ///
  /// In en, this message translates to:
  /// **'Drop {selector}'**
  String planTitleDropStash(String selector);

  /// No description provided for @planDescriptionDropStash.
  ///
  /// In en, this message translates to:
  /// **'Run git stash drop {selector}. This cannot be undone in this app.'**
  String planDescriptionDropStash(String selector);

  /// No description provided for @stashDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped {selector}.'**
  String stashDropped(String selector);

  /// No description provided for @invalidStashSelector.
  ///
  /// In en, this message translates to:
  /// **'The Stash selector is invalid.'**
  String get invalidStashSelector;

  /// No description provided for @planTitlePushCurrent.
  ///
  /// In en, this message translates to:
  /// **'Push current branch'**
  String get planTitlePushCurrent;

  /// No description provided for @planTitlePushBranch.
  ///
  /// In en, this message translates to:
  /// **'Push {branch}'**
  String planTitlePushBranch(String branch);

  /// No description provided for @planDescriptionPushCurrent.
  ///
  /// In en, this message translates to:
  /// **'Push the current branch to its upstream, or configure origin/first remote as upstream when needed.'**
  String get planDescriptionPushCurrent;

  /// No description provided for @planTitleFetchRemote.
  ///
  /// In en, this message translates to:
  /// **'Fetch remote {remote}'**
  String planTitleFetchRemote(String remote);

  /// No description provided for @planDescriptionFetchRemote.
  ///
  /// In en, this message translates to:
  /// **'Run git fetch --prune {remote}. Tracked remote refs update; working files do not change.'**
  String planDescriptionFetchRemote(String remote);

  /// No description provided for @planTitleFetchAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Fetch all {count} remotes'**
  String planTitleFetchAllRemotes(String count);

  /// No description provided for @planDescriptionFetchAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Run git fetch --prune for each remote: {remotes}. Failures are reported per remote.'**
  String planDescriptionFetchAllRemotes(String remotes);

  /// No description provided for @remoteFetched.
  ///
  /// In en, this message translates to:
  /// **'Fetched updates from remote {remote}.'**
  String remoteFetched(String remote);

  /// No description provided for @allRemotesFetched.
  ///
  /// In en, this message translates to:
  /// **'Fetched all {count} remotes.'**
  String allRemotesFetched(String count);

  /// No description provided for @remoteBatchPartialFailure.
  ///
  /// In en, this message translates to:
  /// **'{succeeded} succeeded and {failed} failed. Details: {details}'**
  String remoteBatchPartialFailure(
    String details,
    String failed,
    String succeeded,
  );

  /// No description provided for @syncStateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unable to read the current branch synchronization state.'**
  String get syncStateUnavailable;

  /// No description provided for @detachedCannotPull.
  ///
  /// In en, this message translates to:
  /// **'The repository is on a detached HEAD and cannot pull a branch.'**
  String get detachedCannotPull;

  /// No description provided for @unbornCannotPull.
  ///
  /// In en, this message translates to:
  /// **'The current branch has no commit and cannot pull.'**
  String get unbornCannotPull;

  /// No description provided for @upstreamMissing.
  ///
  /// In en, this message translates to:
  /// **'The current branch has no usable upstream. Configure a tracked remote branch first.'**
  String get upstreamMissing;

  /// No description provided for @dirtyWorktreeCannotPull.
  ///
  /// In en, this message translates to:
  /// **'The worktree or index is dirty. Commit or Stash changes before pulling.'**
  String get dirtyWorktreeCannotPull;

  /// No description provided for @pullUpToDate.
  ///
  /// In en, this message translates to:
  /// **'The current branch is already synchronized with upstream.'**
  String get pullUpToDate;

  /// No description provided for @pullAhead.
  ///
  /// In en, this message translates to:
  /// **'The branch contains all upstream commits and has local commits to push.'**
  String get pullAhead;

  /// No description provided for @pullDiverged.
  ///
  /// In en, this message translates to:
  /// **'Local and upstream histories diverged. Use external Git to merge or rebase first.'**
  String get pullDiverged;

  /// No description provided for @pullRelationUnknown.
  ///
  /// In en, this message translates to:
  /// **'The current synchronization relation is unknown.'**
  String get pullRelationUnknown;

  /// No description provided for @pullNoUpdate.
  ///
  /// In en, this message translates to:
  /// **'No fast-forward update was needed.'**
  String get pullNoUpdate;

  /// No description provided for @planTitlePull.
  ///
  /// In en, this message translates to:
  /// **'Safely fast-forward {branch}'**
  String planTitlePull(String branch);

  /// No description provided for @planDescriptionPull.
  ///
  /// In en, this message translates to:
  /// **'Fetch {remote} and recheck ahead/behind. Run git merge --ff-only {upstream} only when {branch} is behind and not diverged; no merge commit is created automatically.'**
  String planDescriptionPull(String branch, String remote, String upstream);

  /// No description provided for @pullCompleted.
  ///
  /// In en, this message translates to:
  /// **'Fast-forwarded {branch} to {upstream}.'**
  String pullCompleted(String branch, String upstream);

  /// No description provided for @syncAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Git authentication failed: {error}'**
  String syncAuthenticationFailed(String error);

  /// No description provided for @syncNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Git network access failed: {error}'**
  String syncNetworkFailed(String error);

  /// No description provided for @pushedCurrentBranch.
  ///
  /// In en, this message translates to:
  /// **'Pushed the current branch.'**
  String get pushedCurrentBranch;

  /// No description provided for @pushedBranch.
  ///
  /// In en, this message translates to:
  /// **'Pushed {branch}.'**
  String pushedBranch(String branch);

  /// No description provided for @noRemotesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No remotes are configured.'**
  String get noRemotesConfigured;

  /// No description provided for @remoteListRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Remote list refreshed.'**
  String get remoteListRefreshed;

  /// No description provided for @planTitleAddRemote.
  ///
  /// In en, this message translates to:
  /// **'Add remote {remote}'**
  String planTitleAddRemote(String remote);

  /// No description provided for @planDescriptionAddRemote.
  ///
  /// In en, this message translates to:
  /// **'Add remote {remote} with URL {url}.'**
  String planDescriptionAddRemote(String remote, String url);

  /// No description provided for @planTitleUpdateRemote.
  ///
  /// In en, this message translates to:
  /// **'Update remote {remote}'**
  String planTitleUpdateRemote(String remote);

  /// No description provided for @planDescriptionUpdateRemote.
  ///
  /// In en, this message translates to:
  /// **'Change remote {remote} to {url}.'**
  String planDescriptionUpdateRemote(String remote, String url);

  /// No description provided for @remoteAdded.
  ///
  /// In en, this message translates to:
  /// **'Remote {remote} added.'**
  String remoteAdded(String remote);

  /// No description provided for @remoteUpdated.
  ///
  /// In en, this message translates to:
  /// **'Remote {remote} updated.'**
  String remoteUpdated(String remote);

  /// No description provided for @remoteRemoved.
  ///
  /// In en, this message translates to:
  /// **'Remote {remote} removed.'**
  String remoteRemoved(String remote);

  /// No description provided for @planTitleRemoveRemote.
  ///
  /// In en, this message translates to:
  /// **'Remove remote configuration {remote}'**
  String planTitleRemoveRemote(String remote);

  /// No description provided for @planDescriptionRemoveRemote.
  ///
  /// In en, this message translates to:
  /// **'Remove only the Git remote configuration in this repository; the hosted repository is not deleted.'**
  String get planDescriptionRemoveRemote;

  /// No description provided for @planTitlePushRemote.
  ///
  /// In en, this message translates to:
  /// **'Push to remote {remote}'**
  String planTitlePushRemote(String remote);

  /// No description provided for @planDescriptionPushRemote.
  ///
  /// In en, this message translates to:
  /// **'Push branch {branch} to remote {remote}.'**
  String planDescriptionPushRemote(String branch, String remote);

  /// No description provided for @pushedToRemote.
  ///
  /// In en, this message translates to:
  /// **'Pushed to {remote}.'**
  String pushedToRemote(String remote);

  /// No description provided for @planTitlePushAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Push to all {count} remotes'**
  String planTitlePushAllRemotes(String count);

  /// No description provided for @planDescriptionPushAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Push the current branch to: {remotes}.'**
  String planDescriptionPushAllRemotes(String remotes);

  /// No description provided for @pushedToAllRemotes.
  ///
  /// In en, this message translates to:
  /// **'Pushed to all {count} remotes.'**
  String pushedToAllRemotes(String count);

  /// No description provided for @remoteInspectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Remote {remote} currently has no branches or tags.'**
  String remoteInspectionEmpty(String remote);

  /// No description provided for @remoteInspectionCounts.
  ///
  /// In en, this message translates to:
  /// **'Remote {remote} has {branches} branch(es) and {tags} tag(s).'**
  String remoteInspectionCounts(String branches, String remote, String tags);

  /// No description provided for @planTitleClearRemote.
  ///
  /// In en, this message translates to:
  /// **'Clear remote history {remote}'**
  String planTitleClearRemote(String remote);

  /// No description provided for @planDescriptionClearRemote.
  ///
  /// In en, this message translates to:
  /// **'Project {project}, target branch {branch}. Back up and delete {branches} branch(es) and {tags} tag(s), then keep one empty commit: “{message}”. Local files remain, but the local index is reset to empty and files appear untracked after refresh.'**
  String planDescriptionClearRemote(
    String branch,
    String branches,
    String message,
    String project,
    String tags,
  );

  /// No description provided for @clearRemoteCompleted.
  ///
  /// In en, this message translates to:
  /// **'Cleared remote {remote}. Branch {branch} now points to empty commit {commit}; local files remain and appear untracked.'**
  String clearRemoteCompleted(String branch, String commit, String remote);

  /// No description provided for @clearRemoteDrift.
  ///
  /// In en, this message translates to:
  /// **'Clearing remote {remote} stopped because refs changed. It now has {branches} branch(es) and {tags} tag(s). {error}'**
  String clearRemoteDrift(
    String branches,
    String error,
    String remote,
    String tags,
  );

  /// No description provided for @planTitleStageAll.
  ///
  /// In en, this message translates to:
  /// **'Stage all changes'**
  String get planTitleStageAll;

  /// No description provided for @planDescriptionStageAll.
  ///
  /// In en, this message translates to:
  /// **'Run git add -A to add all current changes to the Git index.'**
  String get planDescriptionStageAll;

  /// No description provided for @stageAllCompleted.
  ///
  /// In en, this message translates to:
  /// **'Staged all changes.'**
  String get stageAllCompleted;

  /// No description provided for @planTitleUnstageAll.
  ///
  /// In en, this message translates to:
  /// **'Unstage all changes'**
  String get planTitleUnstageAll;

  /// No description provided for @planDescriptionUnstageAll.
  ///
  /// In en, this message translates to:
  /// **'Reset the Git index to HEAD while preserving working files.'**
  String get planDescriptionUnstageAll;

  /// No description provided for @unstageAllCompleted.
  ///
  /// In en, this message translates to:
  /// **'Unstaged all changes.'**
  String get unstageAllCompleted;

  /// No description provided for @planTitleCommitAll.
  ///
  /// In en, this message translates to:
  /// **'Commit all changes'**
  String get planTitleCommitAll;

  /// No description provided for @planDescriptionCommitAll.
  ///
  /// In en, this message translates to:
  /// **'Commit message: {message}. Execution runs git add -A and then git commit.'**
  String planDescriptionCommitAll(String message);

  /// No description provided for @commitMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a commit message.'**
  String get commitMessageRequired;

  /// No description provided for @noChangesToCommit.
  ///
  /// In en, this message translates to:
  /// **'There are no changes to commit.'**
  String get noChangesToCommit;

  /// No description provided for @commitAlreadyQueued.
  ///
  /// In en, this message translates to:
  /// **'A commit step is already in the plan.'**
  String get commitAlreadyQueued;

  /// No description provided for @commitIdentityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Git author and committer identity is unavailable. Configure user.name and user.email, then retry.'**
  String get commitIdentityUnavailable;

  /// No description provided for @commitSucceeded.
  ///
  /// In en, this message translates to:
  /// **'Commit created.'**
  String get commitSucceeded;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @desktopShortcutWindowsOnly.
  ///
  /// In en, this message translates to:
  /// **'Desktop shortcuts are currently supported only on Windows.'**
  String get desktopShortcutWindowsOnly;

  /// No description provided for @desktopShortcutCreated.
  ///
  /// In en, this message translates to:
  /// **'Desktop shortcut created: {path}'**
  String desktopShortcutCreated(String path);

  /// No description provided for @maintenanceKindOldVersion.
  ///
  /// In en, this message translates to:
  /// **'Old version directory'**
  String get maintenanceKindOldVersion;

  /// No description provided for @maintenanceKindUpdateArchive.
  ///
  /// In en, this message translates to:
  /// **'Update archive'**
  String get maintenanceKindUpdateArchive;

  /// No description provided for @maintenanceKindPartialDownload.
  ///
  /// In en, this message translates to:
  /// **'Incomplete download'**
  String get maintenanceKindPartialDownload;

  /// No description provided for @maintenanceKindStagingDirectory.
  ///
  /// In en, this message translates to:
  /// **'Temporary extraction directory'**
  String get maintenanceKindStagingDirectory;

  /// No description provided for @maintenanceKindLegacyUpdater.
  ///
  /// In en, this message translates to:
  /// **'Legacy updater script'**
  String get maintenanceKindLegacyUpdater;

  /// No description provided for @maintenanceKindLegacyFlatFile.
  ///
  /// In en, this message translates to:
  /// **'Legacy flat application file'**
  String get maintenanceKindLegacyFlatFile;

  /// No description provided for @maintenanceKindLegacyFlatDirectory.
  ///
  /// In en, this message translates to:
  /// **'Legacy flat application directory'**
  String get maintenanceKindLegacyFlatDirectory;

  /// No description provided for @maintenanceKindObsoleteGitRuntime.
  ///
  /// In en, this message translates to:
  /// **'Obsolete PortableGit runtime'**
  String get maintenanceKindObsoleteGitRuntime;

  /// No description provided for @maintenanceKindGitRuntimeArchive.
  ///
  /// In en, this message translates to:
  /// **'PortableGit update archive'**
  String get maintenanceKindGitRuntimeArchive;

  /// No description provided for @maintenanceKindGitRuntimeStaging.
  ///
  /// In en, this message translates to:
  /// **'PortableGit staging directory'**
  String get maintenanceKindGitRuntimeStaging;

  /// No description provided for @driftRepositoryRoot.
  ///
  /// In en, this message translates to:
  /// **'Repository root'**
  String get driftRepositoryRoot;

  /// No description provided for @driftBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get driftBranch;

  /// No description provided for @driftHead.
  ///
  /// In en, this message translates to:
  /// **'HEAD'**
  String get driftHead;

  /// No description provided for @driftStatus.
  ///
  /// In en, this message translates to:
  /// **'Worktree status'**
  String get driftStatus;

  /// No description provided for @driftRemotes.
  ///
  /// In en, this message translates to:
  /// **'Remote configuration'**
  String get driftRemotes;

  /// No description provided for @driftPathType.
  ///
  /// In en, this message translates to:
  /// **'Path type'**
  String get driftPathType;

  /// No description provided for @driftDestinationParent.
  ///
  /// In en, this message translates to:
  /// **'Parent directory'**
  String get driftDestinationParent;

  /// No description provided for @driftDestinationExists.
  ///
  /// In en, this message translates to:
  /// **'Target exists'**
  String get driftDestinationExists;

  /// No description provided for @driftDestinationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Target is empty'**
  String get driftDestinationEmpty;

  /// No description provided for @driftGitMetadata.
  ///
  /// In en, this message translates to:
  /// **'Git metadata'**
  String get driftGitMetadata;

  /// No description provided for @driftSource.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get driftSource;

  /// No description provided for @driftRemoteName.
  ///
  /// In en, this message translates to:
  /// **'Remote name'**
  String get driftRemoteName;

  /// No description provided for @driftRemoteTargetBranch.
  ///
  /// In en, this message translates to:
  /// **'Target branch'**
  String get driftRemoteTargetBranch;

  /// No description provided for @driftRemoteRefs.
  ///
  /// In en, this message translates to:
  /// **'Remote refs'**
  String get driftRemoteRefs;

  /// No description provided for @updateGithubNoRelease.
  ///
  /// In en, this message translates to:
  /// **'No public GitHub Release is available. Open the release page for details.'**
  String get updateGithubNoRelease;

  /// No description provided for @updateGiteeNoRelease.
  ///
  /// In en, this message translates to:
  /// **'No public Gitee Release is available. Open the release page for details.'**
  String get updateGiteeNoRelease;

  /// No description provided for @updateHttpError.
  ///
  /// In en, this message translates to:
  /// **'{platform} returned HTTP {status}. Try again later.'**
  String updateHttpError(String platform, String status);

  /// No description provided for @updateInvalidResponseGithub.
  ///
  /// In en, this message translates to:
  /// **'The GitHub update response could not be parsed.'**
  String get updateInvalidResponseGithub;

  /// No description provided for @updateInvalidResponseGitee.
  ///
  /// In en, this message translates to:
  /// **'The Gitee update response could not be parsed.'**
  String get updateInvalidResponseGitee;

  /// No description provided for @updateVersionMissingGithub.
  ///
  /// In en, this message translates to:
  /// **'The public GitHub Release has no recognizable version.'**
  String get updateVersionMissingGithub;

  /// No description provided for @updateVersionMissingGitee.
  ///
  /// In en, this message translates to:
  /// **'The public Gitee Release has no recognizable version.'**
  String get updateVersionMissingGitee;

  /// No description provided for @updateAssetMissingGithub.
  ///
  /// In en, this message translates to:
  /// **'A new version exists, but its Release has no Windows x64 ZIP with SHA-256.'**
  String get updateAssetMissingGithub;

  /// No description provided for @updateAvailableGithub.
  ///
  /// In en, this message translates to:
  /// **'A new version is available for automatic download, verification, and restart.'**
  String get updateAvailableGithub;

  /// No description provided for @updateAvailableGitee.
  ///
  /// In en, this message translates to:
  /// **'A new Gitee version is available for automatic download, verification, and restart.'**
  String get updateAvailableGitee;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'v{version} is the latest GitHub version.'**
  String updateUpToDate(String version);

  /// No description provided for @updateGiteeUpToDate.
  ///
  /// In en, this message translates to:
  /// **'v{version} is the latest Gitee version.'**
  String updateGiteeUpToDate(String version);

  /// No description provided for @updateNetworkUnavailableGithub.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to GitHub. Check the network and retry.'**
  String get updateNetworkUnavailableGithub;

  /// No description provided for @updateNetworkUnavailableGitee.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to Gitee. Check the network and retry.'**
  String get updateNetworkUnavailableGitee;

  /// No description provided for @updateRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'The network request failed. Try again later.'**
  String get updateRequestFailed;

  /// No description provided for @updateGiteeRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'The Gitee request failed. Try again later.'**
  String get updateGiteeRequestFailed;

  /// No description provided for @updateGiteeDigestMissing.
  ///
  /// In en, this message translates to:
  /// **'A Gitee update exists, but no trusted GitHub SHA-256 metadata is available. Automatic installation is disabled; open the release page to download manually.'**
  String get updateGiteeDigestMissing;

  /// No description provided for @updateProgressPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing automatic update…'**
  String get updateProgressPreparing;

  /// No description provided for @updateProgressConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to the Release download…'**
  String get updateProgressConnecting;

  /// No description provided for @updateProgressDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {asset}…'**
  String updateProgressDownloading(String asset);

  /// No description provided for @updateProgressVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying the update archive SHA-256…'**
  String get updateProgressVerifying;

  /// No description provided for @updateProgressExtracting.
  ///
  /// In en, this message translates to:
  /// **'Extracting into an independent version directory…'**
  String get updateProgressExtracting;

  /// No description provided for @updateProgressVerifyingRuntime.
  ///
  /// In en, this message translates to:
  /// **'Validating the packaged PortableGit runtime…'**
  String get updateProgressVerifyingRuntime;

  /// No description provided for @updateProgressNotifyingLauncher.
  ///
  /// In en, this message translates to:
  /// **'Notifying the Launcher to switch versions…'**
  String get updateProgressNotifyingLauncher;

  /// No description provided for @updatePackageMissing.
  ///
  /// In en, this message translates to:
  /// **'The update archive does not exist.'**
  String get updatePackageMissing;

  /// No description provided for @updateWindowsOnly.
  ///
  /// In en, this message translates to:
  /// **'Automatic updates currently support Windows only.'**
  String get updateWindowsOnly;

  /// No description provided for @updateNoNewVersion.
  ///
  /// In en, this message translates to:
  /// **'There is no new version to install.'**
  String get updateNoNewVersion;

  /// No description provided for @updateAssetInvalid.
  ///
  /// In en, this message translates to:
  /// **'The update asset is missing a download URL or valid SHA-256; automatic update was cancelled.'**
  String get updateAssetInvalid;

  /// No description provided for @updateVersionInvalid.
  ///
  /// In en, this message translates to:
  /// **'The update version contains invalid characters.'**
  String get updateVersionInvalid;

  /// No description provided for @updateInstallSuccess.
  ///
  /// In en, this message translates to:
  /// **'v{version} is ready. The Launcher will switch versions and restart after the application exits.'**
  String updateInstallSuccess(String version);

  /// No description provided for @changelog0100Title.
  ///
  /// In en, this message translates to:
  /// **'Structured runtime messages, Markdown guides, and safe links'**
  String get changelog0100Title;

  /// No description provided for @changelog0100ItemMessages.
  ///
  /// In en, this message translates to:
  /// **'Operation results, queued plans, and logs now use semantic templates, with stable event IDs, write-time locale, and credential redaction.'**
  String get changelog0100ItemMessages;

  /// No description provided for @changelog0100ItemMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Bundled guides now use native Markdown rendering for headings, lists, tables, quotes, code blocks, images, and inline formatting.'**
  String get changelog0100ItemMarkdown;

  /// No description provided for @changelog0100ItemLinks.
  ///
  /// In en, this message translates to:
  /// **'Guide links are limited to HTTPS, bundled guides, and heading anchors, with keyboard focus, text selection, and responsive layouts.'**
  String get changelog0100ItemLinks;

  /// No description provided for @changelog0100ItemTests.
  ///
  /// In en, this message translates to:
  /// **'Added three-language guide resources, source regression checks, and complete structured-message test coverage.'**
  String get changelog0100ItemTests;

  /// No description provided for @changelog099Title.
  ///
  /// In en, this message translates to:
  /// **'Branch sync, safe fast-forward pull, and commit identity checks'**
  String get changelog099Title;

  /// No description provided for @changelog099ItemSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Shows upstream, ahead, behind, and worktree synchronization state.'**
  String get changelog099ItemSyncStatus;

  /// No description provided for @changelog099ItemFetchPlan.
  ///
  /// In en, this message translates to:
  /// **'Adds fetch plans for the current upstream or all remotes with per-remote results.'**
  String get changelog099ItemFetchPlan;

  /// No description provided for @changelog099ItemFastForwardPull.
  ///
  /// In en, this message translates to:
  /// **'Adds fast-forward-only pull and rejects dirty worktrees, missing upstreams, and diverged histories.'**
  String get changelog099ItemFastForwardPull;

  /// No description provided for @changelog099ItemGitIdentity.
  ///
  /// In en, this message translates to:
  /// **'Checks valid Git author and committer identities before queueing and before execution.'**
  String get changelog099ItemGitIdentity;

  /// No description provided for @guideLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get guideLanguageEnglish;

  /// No description provided for @guideLanguageSimplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get guideLanguageSimplifiedChinese;

  /// No description provided for @guideLanguageTraditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get guideLanguageTraditionalChinese;

  /// No description provided for @unableToOpenGuideLink.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the guide link: {error}'**
  String unableToOpenGuideLink(String error);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppL10nZhHans();
          case 'Hant':
            return AppL10nZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'zh':
      return AppL10nZh();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
