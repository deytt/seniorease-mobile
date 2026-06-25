import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/task_card.dart';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskStreamProvider(taskId));

    return SeniorScreenScaffold(
      title: 'Detalhes da Tarefa',
      trailing: taskAsync.asData != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              tooltip: 'Apagar tarefa',
              onPressed: () => _confirmDelete(context, ref),
            )
          : null,
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text('Não foi possível carregar a tarefa.'),
          ),
        ),
        data: (task) => _Content(task: task),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Apagar tarefa?',
      message:
          'Tem a certeza que deseja apagar esta tarefa? Esta ação não pode ser desfeita.',
      confirmLabel: 'Apagar',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(tasksControllerProvider.notifier).delete(taskId);
    if (!context.mounted) return;
    showSeniorToast(
      context,
      title: 'Tarefa apagada',
      message: 'A tarefa foi removida.',
      variant: SeniorToastVariant.info,
    );
    context.pop();
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pColor = priorityColor(task.priority);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          task.title,
          style: theme.textTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _Badge(
              label: task.priority.fullLabel,
              color: pColor,
              background: pColor.withValues(alpha: 0.12),
            ),
            const SizedBox(width: AppSpacing.sm),
            _Badge(
              label: task.category.label,
              color: AppColors.secondary,
              background: AppColors.secondaryLight,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (task.description.isNotEmpty) ...[
          _DescriptionCard(task: task),
          const SizedBox(height: AppSpacing.md),
        ],
        Text('Passos a Concluir', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 12),
        if (task.steps.isEmpty)
          Text(
            'Esta tarefa não tem passos.',
            style: theme.textTheme.bodyMedium,
          )
        else
          for (final step in task.steps) ...[
            _StepRow(task: task, step: step),
            const SizedBox(height: AppSpacing.sm),
          ],
        const SizedBox(height: AppSpacing.md),
        if (task.steps.isNotEmpty)
          SeniorButton(
            label: 'Iniciar Modo Guiado',
            icon: Icons.bolt,
            variant: SeniorButtonVariant.secondary,
            onPressed: () => context.push('/tasks/${task.id}/guided'),
          ),
        const SizedBox(height: 12),
        if (!task.isCompleted)
          _CompleteButton(task: task)
        else
          _CompletedBanner(),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate500,
              height: 1.6,
            ),
          ),
          if (task.reminderTime != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 16, color: AppColors.slate400),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${task.reminderTime} hoje',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate900,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends ConsumerWidget {
  const _StepRow({required this.task, required this.step});

  final Task task;
  final TaskStep step;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final done = step.isCompleted;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: done ? AppColors.successLight : theme.colorScheme.surface,
        border: Border.all(
          color: done ? const Color(0xFFBBF7D0) : theme.colorScheme.outline,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    '${step.order}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: done ? AppColors.slate400 : AppColors.slate900,
                decoration: done ? TextDecoration.lineThrough : null,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteButton extends ConsumerWidget {
  const _CompleteButton({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(tasksControllerProvider).isLoading;

    return SeniorButton(
      label: 'Marcar como Concluída',
      icon: Icons.check_circle_outline,
      isLoading: isLoading,
      onPressed: () => _confirmComplete(context, ref),
    );
  }

  Future<void> _confirmComplete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Concluir tarefa?',
      message:
          'Isto vai marcar a tarefa e todos os seus passos como concluídos.',
      confirmLabel: 'Concluir',
      cancelLabel: 'Cancelar',
    );

    if (confirmed != true || !context.mounted) return;

    HapticFeedback.lightImpact();
    await ref.read(tasksControllerProvider.notifier).completeTask(task.id);
    if (!context.mounted) return;
    showSeniorToast(
      context,
      title: 'Parabéns!',
      message: 'Concluiu esta tarefa. Muito bem!',
      variant: SeniorToastVariant.success,
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tarefa concluída!',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.successDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
