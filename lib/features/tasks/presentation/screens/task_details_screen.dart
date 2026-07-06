import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/task_card.dart';

class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen>
    with TourHost<TaskDetailsScreen> {
  static const String _scope = 'taskDetails';

  final _deleteShowcaseKey = GlobalKey();
  final _descriptionShowcaseKey = GlobalKey();
  final _stepsShowcaseKey = GlobalKey();
  final _actionsShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.taskDetails;

  @override
  List<GlobalKey> get tourKeys => [
        _deleteShowcaseKey,
        _descriptionShowcaseKey,
        _stepsShowcaseKey,
        _actionsShowcaseKey,
      ];

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskStreamProvider(widget.taskId));
    final task = taskAsync.asData?.value;

    return SeniorScreenScaffold(
      title: task?.title ?? 'Detalhes da Tarefa',
      subtitleWidget: task != null ? _HeaderBadges(task: task) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TourHelpButton(onPressed: startTour),
          if (task != null)
            SeniorShowcase(
              showcaseKey: _deleteShowcaseKey,
              scope: _scope,
              title: 'Excluir tarefa',
              description:
                  'Toque aqui para excluir esta tarefa permanentemente. Será pedida confirmação antes.',
              child: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                tooltip: 'Excluir tarefa',
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
        ],
      ),
      body: taskAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: Text('Não foi possível carregar a tarefa.'),
          ),
        ),
        data: (task) => _Content(
          task: task,
          descriptionShowcaseKey: _descriptionShowcaseKey,
          stepsShowcaseKey: _stepsShowcaseKey,
          actionsShowcaseKey: _actionsShowcaseKey,
          scope: _scope,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showSeniorConfirmDialog(
      context: context,
      title: 'Excluir tarefa?',
      message:
          'Tem certeza de que deseja excluir esta tarefa? Essa ação não pode ser desfeita.',
      confirmLabel: 'Excluir',
      cancelLabel: 'Cancelar',
      isDestructive: true,
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(tasksControllerProvider.notifier).delete(widget.taskId);
    if (!context.mounted) return;
    showSeniorToast(
      context,
      title: 'Tarefa excluída',
      message: 'A tarefa foi removida.',
      variant: SeniorToastVariant.info,
    );
    context.pop();
  }
}

// ------------------------------------------------------------------ Header badges

class _HeaderBadges extends StatelessWidget {
  const _HeaderBadges({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final pColor = priorityColor(task.priority);
    return Row(
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
    );
  }
}

// ------------------------------------------------------------------ Conteúdo

class _Content extends StatelessWidget {
  const _Content({
    required this.task,
    required this.descriptionShowcaseKey,
    required this.stepsShowcaseKey,
    required this.actionsShowcaseKey,
    required this.scope,
  });

  final Task task;
  final GlobalKey descriptionShowcaseKey;
  final GlobalKey stepsShowcaseKey;
  final GlobalKey actionsShowcaseKey;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (task.description.isNotEmpty || task.dueDate != null) ...[
          SeniorShowcase(
            showcaseKey: descriptionShowcaseKey,
            scope: scope,
            title: 'Detalhes da tarefa',
            description:
                'Aqui estão a descrição e a data de entrega desta tarefa.',
            child: _DescriptionCard(task: task),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        SeniorShowcase(
          showcaseKey: stepsShowcaseKey,
          scope: scope,
          title: 'Passos a concluir',
          description:
              'Cada passo mostra o que precisa de fazer. Use o Modo Guiado para os concluir um a um.',
          child: Text('Passos a Concluir', style: theme.textTheme.headlineMedium),
        ),
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
        SeniorShowcase(
          showcaseKey: actionsShowcaseKey,
          scope: scope,
          title: 'Como concluir a tarefa',
          description:
              'Use o Modo Guiado para ir passo a passo, ou toque em "Marcar como Concluída" para concluir tudo de uma vez.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (task.steps.isNotEmpty) ...[
                _GuidedModeCard(task: task),
                const SizedBox(height: 12),
              ],
              if (!task.isCompleted)
                _CompleteButton(task: task)
              else
                _CompletedBanner(),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ------------------------------------------------------------------ Description card

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.task});

  final Task task;

  String _formatDueDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isTomorrow = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day + 1;

    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final time = '$hour:$min';

    if (isToday) return '$time · Hoje';
    if (isTomorrow) return '$time · Amanhã';

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$time · $day/$month/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDueDate = task.dueDate != null;
    final hasDescription = task.description.isNotEmpty;

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
          if (hasDescription)
            Text(
              task.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate500,
                height: 1.6,
              ),
            ),
          if (hasDescription && hasDueDate) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
          ],
          if (hasDueDate) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.slate400),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _formatDueDate(task.dueDate!),
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

// ------------------------------------------------------------------ Step row

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

// ------------------------------------------------------------------ Card Modo Guiado

class _GuidedModeCard extends ConsumerWidget {
  const _GuidedModeCard({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        border: Border.all(color: const Color(0xFF99F6E4)),
        borderRadius: BorderRadius.circular(AppSpacing.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Color(0xFF0F766E), size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Modo Guiado',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ajuda passo a passo para concluir esta tarefa com facilidade.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              child: InkWell(
                onTap: () {
                  SeniorFeedback.light(ref);
                  context.push('/tasks/${task.id}/guided');
                },
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: const SizedBox(
                  height: 44,
                  child: Center(
                    child: Text(
                      'Iniciar Modo Guiado →',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ Botões

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
      customBackgroundColor: AppColors.success,
      customForegroundColor: Colors.white,
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

    await SeniorFeedback.success(ref);
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

// ------------------------------------------------------------------ Badge

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
