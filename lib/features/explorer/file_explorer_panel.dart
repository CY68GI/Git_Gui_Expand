import 'package:flutter/material.dart';

import '../../core/models/app_models.dart';
import '../../core/models/settings_models.dart';
import '../../core/utils/path_utils.dart';
import '../../core/utils/size_formatter.dart';
import '../repository/repository_controller.dart';

class FileExplorerPanel extends StatefulWidget {
  const FileExplorerPanel({
    super.key,
    required this.side,
    required this.state,
    required this.rootPath,
    required this.settings,
    required this.isActive,
    required this.controller,
    required this.showOutcome,
  });

  final ExplorerSide side;
  final ExplorerPanelState state;
  final String rootPath;
  final AppSettings settings;
  final bool isActive;
  final RepositoryController controller;
  final ValueChanged<OperationOutcome> showOutcome;

  @override
  State<FileExplorerPanel> createState() => _FileExplorerPanelState();
}

class _FileExplorerPanelState extends State<FileExplorerPanel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = widget.side == ExplorerSide.left ? '左侧资源' : '右侧资源';
    final selectedCount = widget.state.selectedPaths.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.controller.setActiveSide(widget.side),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.isActive
                ? colors.primary.withValues(alpha: 0.55)
                : colors.outlineVariant,
            width: widget.isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(
                alpha: isDark
                    ? (widget.isActive ? 0.28 : 0.16)
                    : (widget.isActive ? 0.07 : 0.035),
              ),
              blurRadius: widget.isActive ? 24 : 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            _buildHeader(context, label, selectedCount),
            Divider(height: 1, color: colors.outlineVariant),
            _buildColumnHeader(context),
            Divider(
              height: 1,
              color: colors.outlineVariant.withValues(alpha: 0.55),
            ),
            Expanded(child: _buildBody(context)),
            _buildFooter(context, selectedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String label, int selectedCount) {
    final colors = Theme.of(context).colorScheme;
    final segments = widget.state.relativePath.isEmpty
        ? const <String>[]
        : widget.state.relativePath.split('/');
    return Container(
      color: widget.isActive
          ? colors.primary.withValues(alpha: 0.035)
          : colors.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(12, 10, 9, 10),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive ? colors.primary : colors.outline,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '粘贴目标',
                    style: TextStyle(
                      fontSize: 9,
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const Spacer(),
              _HeaderIconButton(
                icon: Icons.arrow_upward_rounded,
                tooltip: '上一级',
                onPressed: widget.state.relativePath.isEmpty
                    ? null
                    : () => widget.controller.goUp(widget.side),
              ),
              _HeaderIconButton(
                icon: Icons.refresh_rounded,
                tooltip: '刷新',
                onPressed: widget.controller.refresh,
              ),
              _HeaderIconButton(
                icon: Icons.deselect_rounded,
                tooltip: '清除选择',
                onPressed: selectedCount == 0
                    ? null
                    : () => widget.controller.clearSelection(widget.side),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 31,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _BreadcrumbPart(
                    label: repositoryBasename(widget.rootPath),
                    isLast: segments.isEmpty,
                    onTap: () => widget.controller.navigate(widget.side, ''),
                  ),
                  for (var index = 0; index < segments.length; index++) ...[
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 15,
                      color: colors.onSurfaceVariant,
                    ),
                    _BreadcrumbPart(
                      label: segments[index],
                      isLast: index == segments.length - 1,
                      onTap: () => widget.controller.navigate(
                        widget.side,
                        segments.take(index + 1).join('/'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: colors.surfaceContainerLow,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Checkbox(
              value:
                  widget.state.entries.isNotEmpty &&
                  widget.state.selectedPaths.length ==
                      widget.state.entries.length,
              tristate: true,
              onChanged: (_) {
                if (widget.state.selectedPaths.isEmpty) {
                  widget.controller.selectAll(widget.side);
                } else {
                  widget.controller.clearSelection(widget.side);
                }
              },
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: colors.outline),
            ),
          ),
          const SizedBox(width: 5),
          const Expanded(child: _ColumnLabel('名称')),
          const SizedBox(width: 100, child: _ColumnLabel('大小')),
          const SizedBox(width: 64, child: _ColumnLabel('状态')),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }
    if (widget.state.error != null) {
      return _ExplorerMessage(
        icon: Icons.error_outline_rounded,
        title: '无法读取目录',
        message: widget.state.error!,
      );
    }
    if (widget.state.entries.isEmpty) {
      return const _ExplorerMessage(
        icon: Icons.folder_off_outlined,
        title: '这里没有文件',
        message: '切换目录或刷新以查看仓库内容。',
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: false,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.state.entries.length,
        itemBuilder: (context, index) {
          final entry = widget.state.entries[index];
          return _ExplorerRow(
            entry: entry,
            selected: widget.state.selectedPaths.contains(entry.relativePath),
            settings: widget.settings,
            onToggle: () {
              widget.controller.setActiveSide(widget.side);
              widget.controller.toggleSelection(
                widget.side,
                entry.relativePath,
              );
            },
            onActivate: () => widget.controller.setActiveSide(widget.side),
            onOpen: entry.isDirectory
                ? () => widget.controller.navigate(
                    widget.side,
                    entry.relativePath,
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int selectedCount) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Row(
        children: [
          Text(
            '${widget.state.entries.length} 项',
            style: TextStyle(fontSize: 10.5, color: colors.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            selectedCount == 0 ? '双击文件夹进入' : '已选 $selectedCount 项',
            style: TextStyle(
              fontSize: 10.5,
              color: selectedCount == 0
                  ? colors.onSurfaceVariant
                  : colors.primary,
              fontWeight: selectedCount == 0
                  ? FontWeight.w400
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplorerRow extends StatefulWidget {
  const _ExplorerRow({
    required this.entry,
    required this.selected,
    required this.settings,
    required this.onToggle,
    required this.onActivate,
    this.onOpen,
  });

  final RepositoryEntry entry;
  final bool selected;
  final AppSettings settings;
  final VoidCallback onToggle;
  final VoidCallback onActivate;
  final VoidCallback? onOpen;

  @override
  State<_ExplorerRow> createState() => _ExplorerRowState();
}

class _ExplorerRowState extends State<_ExplorerRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entry = widget.entry;
    final isDirectory = entry.kind == EntryKind.directory;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => widget.onActivate(),
        onDoubleTap: widget.onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          height: 39,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? colors.primary.withValues(alpha: 0.075)
                : _hovered
                ? colors.surfaceContainerLow
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Checkbox(
                  value: widget.selected,
                  onChanged: (_) => widget.onToggle(),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: widget.selected ? colors.primary : colors.outline,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: _entryColor(entry, isDirectory).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  _entryIcon(entry, isDirectory),
                  size: 15,
                  color: _entryColor(entry, isDirectory),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Tooltip(
                  message: entry.relativePath,
                  child: Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isDirectory
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Text(
                  isDirectory || entry.size == null
                      ? '文件夹'
                      : formatFileSize(entry.size!, widget.settings),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(
                width: 64,
                child: entry.statusCode.isEmpty
                    ? const SizedBox.shrink()
                    : _StatusBadge(code: entry.statusCode),
              ),
              if (isDirectory)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: _hovered ? colors.primary : colors.outline,
                )
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _entryIcon(RepositoryEntry entry, bool isDirectory) {
    if (isDirectory) {
      return Icons.folder_rounded;
    }
    final name = entry.name.toLowerCase();
    if (name.endsWith('.dart')) return Icons.code_rounded;
    if (name.endsWith('.md') || name.endsWith('.txt')) {
      return Icons.article_outlined;
    }
    if (name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.svg') ||
        name.endsWith('.webp')) {
      return Icons.image_outlined;
    }
    if (name.endsWith('.yaml') ||
        name.endsWith('.yml') ||
        name.endsWith('.json') ||
        name.endsWith('.toml')) {
      return Icons.tune_rounded;
    }
    return Icons.insert_drive_file_outlined;
  }

  Color _entryColor(RepositoryEntry entry, bool isDirectory) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDirectory) {
      return isDark ? const Color(0xFFFFD27A) : const Color(0xFFD79A37);
    }
    final name = entry.name.toLowerCase();
    if (name.endsWith('.dart')) return const Color(0xFF1685B8);
    if (name.endsWith('.md') || name.endsWith('.txt')) {
      return isDark ? const Color(0xFFAEBDB5) : const Color(0xFF64736B);
    }
    if (name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.svg')) {
      return const Color(0xFF9B6AC7);
    }
    return const Color(0xFF74827A);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final first = code.isEmpty ? '?' : code.substring(0, 1);
    final labels = {
      'M': 'M',
      'A': 'A',
      'D': 'D',
      'R': 'R',
      'C': 'C',
      'U': 'U',
      '?': 'NEW',
      '!': 'IGN',
    };
    final color = switch (first) {
      'A' || '?' => isDark ? const Color(0xFF6FE7C3) : const Color(0xFF16836C),
      'D' => isDark ? const Color(0xFFFF9B8E) : const Color(0xFFC04E4E),
      'U' => isDark ? const Color(0xFFFFC56B) : const Color(0xFFC97914),
      'R' || 'C' => isDark ? const Color(0xFF9BB9FF) : const Color(0xFF466FBF),
      _ => isDark ? const Color(0xFFFFD27A) : const Color(0xFF9A7116),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          labels[first] ?? first,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 29, height: 29),
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class _BreadcrumbPart extends StatelessWidget {
  const _BreadcrumbPart({
    required this.label,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isLast ? FontWeight.w700 : FontWeight.w500,
            color: isLast ? colors.onSurface : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ExplorerMessage extends StatelessWidget {
  const _ExplorerMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: colors.outline),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
