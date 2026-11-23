import 'package:flutter_test/flutter_test.dart';
import 'package:git_gui_expand/core/localization/app_localizations.dart';
import 'package:git_gui_expand/core/models/repository_sync.dart';

void main() {
  test(
    'tracked branch derives up-to-date ahead behind and diverged states',
    () {
      BranchSyncState state(int ahead, int behind) => BranchSyncState(
        kind: BranchSyncKind.tracked,
        branch: 'main',
        upstreamRef: 'origin/main',
        upstreamRemote: 'origin',
        upstreamBranch: 'main',
        ahead: ahead,
        behind: behind,
        worktreeClean: true,
      );

      expect(state(0, 0).relation, BranchSyncRelation.upToDate);
      expect(state(2, 0).relation, BranchSyncRelation.ahead);
      expect(state(0, 3).relation, BranchSyncRelation.behind);
      expect(state(1, 2).relation, BranchSyncRelation.diverged);
      expect(state(0, 3).canPull, isTrue);
      expect(state(1, 2).canPull, isFalse);
    },
  );

  test('missing upstream and detached states disable pull', () {
    const noUpstream = BranchSyncState.noUpstream(
      branch: 'feature',
      worktreeClean: true,
    );
    const detached = BranchSyncState.detached(worktreeClean: true);
    const unborn = BranchSyncState.unborn(worktreeClean: true);

    expect(noUpstream.hasUpstream, isFalse);
    expect(noUpstream.canFetchCurrent, isFalse);
    expect(noUpstream.canPull, isFalse);
    expect(detached.isDetached, isTrue);
    expect(detached.canPull, isFalse);
    expect(unborn.isUnborn, isTrue);
    expect(unborn.canPull, isFalse);
  });

  test('sync state equality includes counts and cleanliness', () {
    const first = BranchSyncState(
      kind: BranchSyncKind.tracked,
      branch: 'main',
      upstreamRef: 'origin/main',
      upstreamRemote: 'origin',
      upstreamBranch: 'main',
      ahead: 1,
      behind: 2,
      worktreeClean: true,
    );
    const repeated = BranchSyncState(
      kind: BranchSyncKind.tracked,
      branch: 'main',
      upstreamRef: 'origin/main',
      upstreamRemote: 'origin',
      upstreamBranch: 'main',
      ahead: 1,
      behind: 2,
      worktreeClean: true,
    );
    const dirty = BranchSyncState(
      kind: BranchSyncKind.tracked,
      branch: 'main',
      upstreamRef: 'origin/main',
      upstreamRemote: 'origin',
      upstreamBranch: 'main',
      ahead: 1,
      behind: 2,
      worktreeClean: false,
    );

    expect(first, repeated);
    expect(first.hashCode, repeated.hashCode);
    expect(first, isNot(dirty));
  });

  test('fetch actions and errors are localized', () {
    const english = AppLocalizations(AppLocalizations.english);
    const traditional = AppLocalizations(AppLocalizations.traditionalChinese);
    AppLocalizations.validateTranslations();

    expect(english.tr('获取远端 origin'), 'Fetch remote origin');
    expect(english.tr('获取全部远端'), 'Fetch all remotes');
    expect(
      english.tr('认证失败：请检查 Git 凭据、SSH Key 或远端访问权限。'),
      contains('Authentication failed'),
    );
    expect(traditional.tr('获取全部远端'), '取得全部遠端');
  });
}
