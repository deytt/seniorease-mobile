import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/task_card.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(
              doneCount: tasksAsync.asData?.value
                      .where((t) => t.isCompleted)
                      .length ??
                  0,
              totalCount: tasksAsync.asData?.value.length ?? 0,
              onCreate: () => context.push(AppRoutes.createTask),
            ),
            Expanded(
              child: tasksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _ErrorState(),
                data: (tasks) => tasks.isEmpty
                    ? const _EmptyState()
                    : _TaskList(tasks: tasks),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.doneCount,
    required this.totalCount,
    required this.onCreate,
  });

  final int doneCount;
  final int totalCount;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              MediaQuery.paddingOf(context).top + 12,
              AppSpacing.md,
              13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Minhas Tarefas',
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$doneCount de $totalCount concluídas hoje',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Semantics(
                  button: true,
                  label: 'Nova tarefa',
                  child: Material(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onCreate();
                      },
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      child: const SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            onTap: () => context.push('/tasks/${task.id}'),
            onToggleComplete: () {
              if (!task.isCompleted) {
                ref
                    .read(tasksControllerProvider.notifier)
                    .completeTask(task.id);
              }
            },
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 4),
        _GuidedModePromo(tasks: tasks),
      ],
    );
  }
}

class _GuidedModePromo extends StatelessWidget {
  const _GuidedModePromo({required this.tasks});

  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
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
            'Ajuda passo a passo para concluir qualquer tarefa com facilidade.',
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
                onTap: () => _startGuided(context),
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

  void _startGuided(BuildContext context) {
    HapticFeedback.lightImpact();
    final pending = tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) {
      showSeniorToast(
        context,
        title: 'Tudo concluído!',
        message: 'Não há tarefas pendentes para o modo guiado.',
        variant: SeniorToastVariant.info,
      );
      return;
    }
    context.push('/tasks/${pending.first.id}/guided');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ainda não tem tarefas',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Toque no botão "+" para criar a sua primeira tarefa.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Algo deu errado ao carregar as suas tarefas. Tente novamente.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
