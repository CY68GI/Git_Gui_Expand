import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/recent_repository.dart';
import '../../core/utils/path_utils.dart';

class StartView extends StatelessWidget {
  const StartView({
    super.key,
    required this.onOpenRepository,
    required this.onOpenEmptyFolder,
    required this.onCloneRepository,
    required this.isOpening,
    required this.recentRepositories,
    required this.onOpenRecent,
    required this.onRemoveRecent,
    this.isGitAvailable = true,
    this.error,
  });

  final VoidCallback onOpenRepository;
  final VoidCallback onOpenEmptyFolder;
  final VoidCallback onCloneRepository;
  final bool isOpening;
  final List<RecentRepository> recentRepositories;
  final Future<void> Function(String path) onOpenRecent;
  final Future<void> Function(String path) onRemoveRecent;
  final bool isGitAvailable;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Stack(
      children: [
        Positioned(
          left: -120,
          top: -150,
          child: _Glow(
            size: 430,
            color: colors.primary.withValues(alpha: 0.09),
          ),
        ),
        Positioned(
          right: -110,
          bottom: -180,
          child: _Glow(
            size: 500,
            color: colors.tertiary.withValues(alpha: 0.09),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      'WINDOWS  ·  FLUTTER  ·  GIT CLI',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.primary,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    l10n.tr('turnGitFileOperationsIntoAnIntuitiveWorkspace'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    l10n.tr(
                      'browseOneRepositoryInTwoPanesSelectCutPasteAndRenameEveryChangeRunsThroughGit',
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.65,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: isOpening || !isGitAvailable
                            ? null
                            : onOpenRepository,
                        icon: isOpening
                            ? SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colors.onPrimary,
                                ),
                              )
                            : const Icon(Icons.folder_open_rounded, size: 20),
                        label: Text(
                          isOpening
                              ? l10n.tr('openingRepository')
                              : l10n.tr('openGitRepository'),
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(200, 52),
                          backgroundColor: colors.primary,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: isOpening || !isGitAvailable
                            ? null
                            : onOpenEmptyFolder,
                        icon: const Icon(Icons.create_new_folder_outlined),
                        label: Text(l10n.tr('openEmptyFolder')),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(180, 52),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: isOpening || !isGitAvailable
                            ? null
                            : onCloneRepository,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(l10n.tr('cloneGitRepository')),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(180, 52),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tr(
                      'openAnExistingRepositoryInitializeAnEmptyFolderOrCloneARemoteRepository',
                    ),
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 22),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 620),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.error.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: colors.error,
                            size: 19,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              error!,
                              style: TextStyle(color: colors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (recentRepositories.isNotEmpty) ...[
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Text(
                          l10n.tr('recentlyOpened'),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            l10n.tr('gitRepositories', {
                              'count': recentRepositories.length,
                            }),
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.tr('onlyVerifiedRepositoryRootsAreSaved'),
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final repository in recentRepositories)
                          _RecentRepositoryCard(
                            repository: repository,
                            disabled: isOpening || !isGitAvailable,
                            onOpen: () => onOpenRecent(repository.path),
                            onRemove: () => onRemoveRecent(repository.path),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 42),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _FeatureCard(
                        icon: Icons.splitscreen_rounded,
                        title: l10n.tr('dualPaneOperations'),
                        caption: l10n.tr(
                          'browseIndependentlyAndMoveAcrossPanes',
                        ),
                      ),
                      _FeatureCard(
                        icon: Icons.drive_file_rename_outline_rounded,
                        title: l10n.tr('nativeGitChanges'),
                        caption: l10n.tr('gitMvIndexCommit'),
                      ),
                      _FeatureCard(
                        icon: Icons.straighten_rounded,
                        title: l10n.tr('preciseSizeView'),
                        caption: l10n.tr('iecSiOptionalBits'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _ShortcutHint(
                        keys: 'Ctrl O',
                        label: l10n.tr('openRepository2'),
                      ),
                      _ShortcutHint(
                        keys: 'Ctrl X / C / V',
                        label:
                            '${l10n.tr('cut')} · ${l10n.tr('copy')} · ${l10n.tr('paste')}',
                      ),
                      _ShortcutHint(keys: 'F2', label: l10n.tr('rename')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentRepositoryCard extends StatelessWidget {
  const _RecentRepositoryCard({
    required this.repository,
    required this.disabled,
    required this.onOpen,
    required this.onRemove,
  });

  final RecentRepository repository;
  final bool disabled;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final name = repositoryBasename(repository.path);
    return SizedBox(
      width: 405,
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: disabled ? null : onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Tooltip(
                        message: repository.path,
                        child: Text(
                          toPosixPath(repository.path),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatRecentTime(repository.lastOpened, l10n),
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                IconButton(
                  onPressed: disabled ? null : onRemove,
                  tooltip: l10n.tr('removeFromHistory'),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 15),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRecentTime(DateTime value, AppLocalizations l10n) {
    final local = value.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return l10n.tr('today', {
        'time':
            '${local.hour.toString().padLeft(2, '0')}:'
            '${local.minute.toString().padLeft(2, '0')}',
      });
    }
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 210,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: colors.primary, size: 19),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShortcutHint extends StatelessWidget {
  const _ShortcutHint({required this.keys, required this.label});

  final String keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Text(
            keys,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
