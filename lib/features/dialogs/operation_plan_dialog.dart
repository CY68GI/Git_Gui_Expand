import 'package:flutter/material.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/models/operation_plan.dart';
import '../../core/models/operation_safety.dart';

class OperationPlanDialog extends StatefulWidget {
  const OperationPlanDialog({super.key, required this.planHost});

  final OperationPlanHost planHost;

  @override
  State<OperationPlanDialog> createState() => _OperationPlanDialogState();
}

class _OperationPlanDialogState extends State<OperationPlanDialog> {
  final TextEditingController _confirmationController = TextEditingController();
  bool _dangerousConfirmed = false;
  bool _executing = false;
  String? _validationMessage;
  OperationPlanResult? _result;
  int _currentStep = 0;
  int _totalSteps = 0;
  String? _currentTitle;

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final operations = widget.planHost.pendingOperations;
    final dangerous = operations
        .where((operation) => operation.isDangerous)
        .toList();
    final strongOperation = operations
        .where((operation) => operation.strongConfirmationText != null)
        .firstOrNull;
    final screen = MediaQuery.sizeOf(context);

    return AlertDialog(
      clipBehavior: Clip.antiAlias,
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      actionsPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      content: SizedBox(
        width: 780,
        height: (screen.height * 0.72).clamp(420.0, 680.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(22, 18, 18, 16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.07),
                border: Border(
                  bottom: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      Icons.playlist_add_check_circle_outlined,
                      color: colors.primary,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _executing ? l10n.tr('正在逐步执行') : l10n.tr('待执行操作计划'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          operations.isEmpty
                              ? l10n.tr('当前没有待执行步骤')
                              : l10n.tr('共 {count} 步；确认前仓库不会发生任何改变', {
                                  'count': operations.length,
                                }),
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (operations.isNotEmpty)
                    _CountBadge(text: '${operations.length} 步'),
                ],
              ),
            ),
            if (_executing)
              LinearProgressIndicator(
                value: operations.isEmpty
                    ? null
                    : (_currentStep / _totalSteps).clamp(0.0, 1.0),
                minHeight: 3,
              ),
            Expanded(
              child: operations.isEmpty
                  ? _buildEmptyOrResult(context)
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      children: [
                        if (_executing) ...[
                          _ProgressBanner(
                            step: _currentStep,
                            title: _currentTitle ?? l10n.tr('准备执行'),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (_result != null) ...[
                          _ResultBanner(
                            result: _result!,
                            onRecover: _recoverFromSafetyRejection,
                          ),
                          const SizedBox(height: 12),
                        ],
                        for (var index = 0; index < operations.length; index++)
                          _OperationCard(
                            index: index,
                            operation: operations[index],
                            executing: _executing,
                            onRemove: () => _removeOperation(operations[index]),
                          ),
                        if (dangerous.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _DangerConfirmation(
                            operations: dangerous,
                            confirmationController: _confirmationController,
                            strongOperation: strongOperation,
                            checked: _dangerousConfirmed,
                            enabled: !_executing,
                            onChecked: (value) {
                              setState(() {
                                _dangerousConfirmed = value ?? false;
                                _validationMessage = null;
                              });
                            },
                          ),
                        ],
                        if (_validationMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _validationMessage!,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: colors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        if (!_executing && operations.isNotEmpty)
          TextButton.icon(
            onPressed: _clearPlan,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(l10n.tr('清空计划')),
          ),
        TextButton(
          onPressed: _executing ? null : () => Navigator.pop(context),
          child: Text(
            _result?.isSuccess == true ? l10n.tr('完成') : l10n.tr('关闭'),
          ),
        ),
        if (operations.isNotEmpty)
          FilledButton.icon(
            onPressed: _executing ? null : _execute,
            icon: _executing
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.onPrimary,
                    ),
                  )
                : const Icon(Icons.play_arrow_rounded, size: 19),
            label: Text(_executing ? l10n.tr('正在执行…') : l10n.tr('确认并逐步执行')),
            style: FilledButton.styleFrom(
              backgroundColor: dangerous.isEmpty ? null : colors.error,
              foregroundColor: dangerous.isEmpty ? null : colors.onError,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyOrResult(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final result = _result;
    if (result != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                result.isSuccess
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
                size: 48,
                color: result.isSuccess ? colors.primary : colors.error,
              ),
              const SizedBox(height: 14),
              Text(
                result.isSuccess ? l10n.tr('执行完成') : l10n.tr('执行未全部完成'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                context.l10n.tr(result.message),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.playlist_add_rounded, size: 46, color: colors.outline),
            const SizedBox(height: 12),
            Text(
              l10n.tr('没有待执行操作'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.tr('先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeOperation(PlannedRepositoryOperation operation) {
    final outcome = widget.planHost.removePendingOperation(operation.id);
    setState(() {
      _validationMessage = outcome.isSuccess ? null : outcome.message;
    });
  }

  void _clearPlan() {
    final outcome = widget.planHost.clearPendingOperations();
    setState(() {
      _result = null;
      _dangerousConfirmed = false;
      _confirmationController.clear();
      _validationMessage = outcome.isSuccess ? null : outcome.message;
    });
  }

  Future<void> _recoverFromSafetyRejection() async {
    await widget.planHost.recoverFromSafetyRejection();
    if (!mounted) return;
    setState(() {
      _result = null;
      _dangerousConfirmed = false;
      _confirmationController.clear();
      _validationMessage = null;
    });
  }

  Future<void> _execute() async {
    final operations = widget.planHost.pendingOperations;
    final strongOperation = operations
        .where((operation) => operation.strongConfirmationText != null)
        .firstOrNull;
    final hasDangerous = operations.any((operation) => operation.isDangerous);
    if (hasDangerous && !_dangerousConfirmed) {
      setState(() {
        _validationMessage = context.l10n.tr('请先勾选“我已检查危险操作”。');
      });
      return;
    }
    if (strongOperation != null &&
        _confirmationController.text.trim() !=
            strongOperation.strongConfirmationText) {
      setState(() {
        _validationMessage = context.l10n.tr(
          '请输入远端项目全称/分支“{confirmation}”进行二次确认。',
          {'confirmation': strongOperation.strongConfirmationText},
        );
      });
      return;
    }

    setState(() {
      _executing = true;
      _result = null;
      _validationMessage = null;
      _currentStep = 0;
      _totalSteps = operations.length;
      _currentTitle = null;
    });
    final result = await widget.planHost.executePendingOperations(
      confirmedDangerous: _dangerousConfirmed,
      strongConfirmationText: _confirmationController.text.trim(),
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _currentStep = progress.step;
          _currentTitle = progress.title;
        });
      },
    );
    if (!mounted) return;
    setState(() {
      _executing = false;
      _result = result;
      _dangerousConfirmed = false;
      _confirmationController.clear();
    });
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({
    required this.index,
    required this.operation,
    required this.executing,
    required this.onRemove,
  });

  final int index;
  final PlannedRepositoryOperation operation;
  final bool executing;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = operation.isDangerous ? colors.error : colors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(13, 12, 8, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        context.l10n.tr(operation.title),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _OperationTag(
                      label: _kindLabel(context, operation.kind),
                      dangerous: operation.isDangerous,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.tr(operation.description),
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: executing ? null : onRemove,
            tooltip: context.l10n.tr('从计划移除'),
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 19),
          ),
        ],
      ),
    );
  }

  String _kindLabel(BuildContext context, PlannedOperationKind kind) {
    final label = switch (kind) {
      PlannedOperationKind.initializeRepository => '初始化仓库',
      PlannedOperationKind.cloneRepository => '克隆仓库',
      PlannedOperationKind.move => '移动',
      PlannedOperationKind.copy => '复制',
      PlannedOperationKind.rename => '重命名',
      PlannedOperationKind.delete => '删除',
      PlannedOperationKind.clearGitMetadata => '清除 Git 元数据',
      PlannedOperationKind.stageAll => '暂存',
      PlannedOperationKind.unstageAll => '取消暂存',
      PlannedOperationKind.commit => '提交',
      PlannedOperationKind.fetchCurrentRemote => '获取 upstream',
      PlannedOperationKind.fetchAllRemotes => '获取全部远端',
      PlannedOperationKind.pullFastForward => '安全快进 Pull',
      PlannedOperationKind.pushCurrentBranch => '推送',
      PlannedOperationKind.pushRemote => '推送',
      PlannedOperationKind.pushAllRemotes => '全部推送',
      PlannedOperationKind.addRemote => '添加远端',
      PlannedOperationKind.updateRemote => '修改远端',
      PlannedOperationKind.removeRemoteConfig => '移除配置',
      PlannedOperationKind.clearRemote => '清空远端',
      PlannedOperationKind.createBranch => '创建分支',
      PlannedOperationKind.switchBranch => '切换分支',
      PlannedOperationKind.renameBranch => '重命名分支',
      PlannedOperationKind.deleteBranch => '删除分支',
      PlannedOperationKind.createStash => '创建 Stash',
      PlannedOperationKind.applyStash => '应用 Stash',
      PlannedOperationKind.popStash => '弹出 Stash',
      PlannedOperationKind.dropStash => '删除 Stash',
    };
    return context.l10n.tr(label);
  }
}

class _DangerConfirmation extends StatelessWidget {
  const _DangerConfirmation({
    required this.operations,
    required this.confirmationController,
    required this.strongOperation,
    required this.checked,
    required this.enabled,
    required this.onChecked,
  });

  final List<PlannedRepositoryOperation> operations;
  final TextEditingController confirmationController;
  final PlannedRepositoryOperation? strongOperation;
  final bool checked;
  final bool enabled;
  final ValueChanged<bool?> onChecked;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final confirmationText = strongOperation?.strongConfirmationText;
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: colors.error, size: 21),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.tr('危险操作确认'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            l10n.tr(
              '此计划包含 {count} 个危险步骤。文件删除无法通过本软件撤销；'
              '清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。',
              {'count': operations.length},
            ),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: colors.onSurface,
            ),
          ),
          if (confirmationText != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: confirmationController,
              enabled: enabled,
              decoration: InputDecoration(
                labelText: l10n.tr('输入项目全称/分支“{confirmation}”以确认', {
                  'confirmation': confirmationText,
                }),
                hintText: confirmationText,
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
          const SizedBox(height: 8),
          Material(
            type: MaterialType.transparency,
            child: CheckboxListTile(
              value: checked,
              onChanged: enabled ? onChecked : null,
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                l10n.tr('我已检查上述操作，确认后立即按顺序执行'),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              context.l10n.tr('第 {step} 步：{title}', {
                'step': step,
                'title': context.l10n.tr(title),
              }),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result, required this.onRecover});

  final OperationPlanResult result;
  final VoidCallback onRecover;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = result.isSuccess ? colors.primary : colors.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result.validation?.isSuccess == false) ...[
            Text(
              context.l10n.tr('执行前状态已变化'),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
          ],
          SelectableText(
            context.l10n.tr(result.message),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (result.validation?.isSuccess == false)
            _SafetyDriftDetails(validation: result.validation!),
          if (result.validation?.isSuccess == false) ...[
            const SizedBox(height: 9),
            OutlinedButton.icon(
              onPressed: onRecover,
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: Text(context.l10n.tr('刷新仓库并重建计划')),
            ),
          ],
        ],
      ),
    );
  }
}

class _SafetyDriftDetails extends StatelessWidget {
  const _SafetyDriftDetails({required this.validation});

  final OperationValidationResult validation;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.error.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('状态变化详情'),
            style: TextStyle(
              color: colors.error,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          for (final drift in validation.drifts)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: SelectableText(
                '${_driftLabel(context, drift.kind)}: '
                '${drift.expected} -> ${drift.actual}',
                style: const TextStyle(fontSize: 11.5, height: 1.4),
              ),
            ),
        ],
      ),
    );
  }

  String _driftLabel(BuildContext context, OperationDriftKind kind) {
    final label = switch (kind) {
      OperationDriftKind.repositoryRoot => '仓库根目录',
      OperationDriftKind.branch => '分支',
      OperationDriftKind.head => 'HEAD',
      OperationDriftKind.status => '工作区状态',
      OperationDriftKind.remotes => '远端配置',
      OperationDriftKind.pathType => '路径类型',
      OperationDriftKind.destinationParent => '父目录',
      OperationDriftKind.destinationExists => '目标是否存在',
      OperationDriftKind.destinationEmpty => '目标是否为空',
      OperationDriftKind.gitMetadata => 'Git 元数据',
      OperationDriftKind.source => '来源',
      OperationDriftKind.remoteName => '远端名称',
      OperationDriftKind.remoteTargetBranch => '目标分支',
      OperationDriftKind.remoteRefs => '远端引用',
    };
    return context.l10n.tr(label);
  }
}

class _OperationTag extends StatelessWidget {
  const _OperationTag({required this.label, required this.dangerous});

  final String label;
  final bool dangerous;

  @override
  Widget build(BuildContext context) {
    final color = dangerous
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
