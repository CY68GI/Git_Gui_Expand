import 'package:flutter/material.dart';

import '../../core/services/app_log_service.dart';

class LogViewerDialog extends StatefulWidget {
  const LogViewerDialog({super.key, this.logService});

  final AppLogService? logService;

  @override
  State<LogViewerDialog> createState() => _LogViewerDialogState();
}

class _LogViewerDialogState extends State<LogViewerDialog> {
  late final AppLogService _log = widget.logService ?? AppLogService.instance;
  Future<_LogContents>? _contents;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _contents = _readLogs();
  }

  Future<_LogContents> _readLogs() async {
    await _log.flush();
    final normal = await _log.readRecent(AppLogType.normal);
    final detailed = await _log.readRecent(AppLogType.detailed);
    return _LogContents(normal: normal, detailed: detailed);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        contentPadding: EdgeInsets.zero,
        titlePadding: EdgeInsets.zero,
        actionsPadding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        content: SizedBox(
          width: 820,
          height: 590,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  border: Border(
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.terminal_rounded,
                        color: colors.primary,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '软件操作日志',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          SelectableText(
                            _log.logsDirectoryPath,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _refresh,
                      tooltip: '刷新日志',
                      icon: const Icon(Icons.refresh_rounded, size: 19),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      onPressed: _openFolder,
                      icon: const Icon(Icons.folder_open_rounded, size: 16),
                      label: const Text('打开目录'),
                    ),
                  ],
                ),
              ),
              Container(
                color: colors.surfaceContainerLowest,
                child: const TabBar(
                  tabs: [
                    Tab(
                      icon: Icon(Icons.receipt_long_outlined, size: 18),
                      text: '普通日志',
                    ),
                    Tab(
                      icon: Icon(Icons.manage_search_rounded, size: 18),
                      text: '详细日志',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<_LogContents>(
                  future: _contents,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.2),
                      );
                    }
                    final data = snapshot.data;
                    return TabBarView(
                      children: [
                        _LogPane(
                          text: data?.normal ?? '',
                          emptyMessage: '还没有普通日志。执行打开仓库、文件操作或提交后会记录关键事件。',
                        ),
                        _LogPane(
                          text: data?.detailed ?? '',
                          emptyMessage: '还没有详细日志。详细日志会记录选择、导航和每一条 Git 命令。',
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _refresh() {
    _log.detail('logs', '用户刷新日志查看器');
    setState(_load);
  }

  Future<void> _openFolder() async {
    try {
      await _log.openLogsDirectory();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('无法打开日志目录：$error')));
    }
  }
}

class _LogPane extends StatelessWidget {
  const _LogPane({required this.text, required this.emptyMessage});

  final String text;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.surfaceContainerLowest,
      child: text.trim().isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : Scrollbar(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: SelectableText(
                  text,
                  style: TextStyle(
                    fontFamily: 'Consolas',
                    fontSize: 10.5,
                    height: 1.55,
                    color: colors.onSurface,
                  ),
                ),
              ),
            ),
    );
  }
}

class _LogContents {
  const _LogContents({required this.normal, required this.detailed});

  final String normal;
  final String detailed;
}
