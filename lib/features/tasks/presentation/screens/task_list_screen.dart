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
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/task_card.dart';
import 'package:mobile/features/tasks/presentation/widgets/task_filter_sheet.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(filteredTasksStreamProvider);
    final filter = ref.watch(taskFilterProvider);

    // Contagens baseadas na lista sem filtro para o subtítulo do header.
    final allTasks = ref.watch(tasksStreamProvider).asData?.value ?? const [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(
              doneCount: allTasks.where((t) => t.isCompleted).length,
              totalCount: allTasks.length,
              activeFilterCount: filter.activeCount,
              onCreate: () => context.push(AppRoutes.createTask),
              onOpenFilter: () => _openFilterSheet(context, ref, filter),
            ),
            // Chips de filtros activos (visível apenas quando há filtro)
            if (!filter.isEmpty) _ActiveFilterBar(filter: filter, ref: ref),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => _onRefresh(context, ref),
                child: tasksAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const _ErrorState(),
                  data: (tasks) => tasks.isEmpty
                      ? _EmptyState(hasFilter: !filter.isEmpty)
                      : _TaskList(tasks: tasks),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context, WidgetRef ref) async {
    final hadFilters =
        ref.read(taskFilterProvider) != TaskFilter.empty;

    // Reset do filtro e refetch completo (sem filtro, ordenação padrão mantida).
    ref.read(taskFilterProvider.notifier).update(TaskFilter.empty);
    ref.invalidate(tasksStreamProvider);
    ref.invalidate(filteredTasksStreamProvider);

    // Aguarda o novo fetch concluir para terminar o indicador de refresh.
    await ref
        .read(filteredTasksStreamProvider.future)
        .catchError((_) => <Task>[]);

    if (hadFilters && context.mounted) {
      showSeniorToast(
        context,
        title: 'Filtros removidos',
        message: 'A lista foi atualizada com todas as tarefas.',
        variant: SeniorToastVariant.info,
      );
    }
  }

  void _openFilterSheet(
    BuildContext context,
    WidgetRef ref,
    TaskFilter current,
  ) {
    HapticFeedback.lightImpact();
    TaskFilterSheet.show(
      context,
      initialFilter: current,
      onApply: (newFilter) {
        ref.read(taskFilterProvider.notifier).update(newFilter);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.doneCount,
    required this.totalCount,
    required this.activeFilterCount,
    required this.onCreate,
    required this.onOpenFilter,
  });

  final int doneCount;
  final int totalCount;
  final int activeFilterCount;
  final VoidCallback onCreate;
  final VoidCallback onOpenFilter;

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
                // Botão de filtro com badge
                Semantics(
                  button: true,
                  label: activeFilterCount > 0
                      ? 'Filtros ($activeFilterCount activos)'
                      : 'Filtrar tarefas',
                  child: _FilterButton(
                    activeCount: activeFilterCount,
                    onTap: onOpenFilter,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Botão nova tarefa
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
                        child:
                            Icon(Icons.add, color: Colors.white, size: 22),
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

/// Botão de filtro com badge numérico quando há filtros activos.
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActive = activeCount > 0;

    return Material(
      color: hasActive
          ? AppColors.primary
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: hasActive
                ? null
                : Border.all(color: AppColors.slate200, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: hasActive ? Colors.white : AppColors.slate500,
              ),
              if (hasActive)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de filtros activos
// ---------------------------------------------------------------------------

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({required this.filter, required this.ref});

  final TaskFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              8,
              AppSpacing.md,
              8,
            ),
            child: Row(
              children: [
                // Chip "Hoje"
                if (filter.isToday)
                  _ActiveChip(
                    label: 'Hoje',
                    onRemove: () {
                      ref.read(taskFilterProvider.notifier).update(
                            filter.removeToday(),
                          );
                    },
                  ),
                if (filter.isToday && filter.category != null)
                  const SizedBox(width: 6),
                // Chip de categoria
                if (filter.category != null)
                  _ActiveChip(
                    label: filter.category!.label,
                    onRemove: () {
                      ref.read(taskFilterProvider.notifier).update(
                            filter.removeCategory(),
                          );
                    },
                  ),
                if ((filter.isToday || filter.category != null) &&
                    filter.priority != null)
                  const SizedBox(width: 6),
                // Chip de prioridade
                if (filter.priority != null)
                  _ActiveChip(
                    label: _capitalized(filter.priority!.label),
                    onRemove: () {
                      ref.read(taskFilterProvider.notifier).update(
                            filter.removePriority(),
                          );
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }

  String _capitalized(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filtro activo: $label. Toque para remover.',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onRemove();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista de tarefas
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Promo modo guiado
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// Empty / Error states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      // ListView em vez de Center para o RefreshIndicator funcionar corretamente.
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.45,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasFilter
                        ? Icons.filter_list_off_rounded
                        : Icons.check_circle_outline,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    hasFilter
                        ? 'Nenhuma tarefa com estes filtros'
                        : 'Ainda não tem tarefas',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hasFilter
                        ? 'Tente remover ou alterar os filtros activos.'
                        : 'Toque no botão "+" para criar a sua primeira tarefa.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
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

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.45,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Algo deu errado ao carregar as suas tarefas. Tente novamente.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
