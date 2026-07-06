import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';

/// Bottom sheet de filtros para a lista de tarefas.
///
/// Recebe o [initialFilter] activo e devolve o novo [TaskFilter] via [onApply].
/// O estado local do sheet não afecta a lista até o utilizador tocar em "Aplicar".
class TaskFilterSheet extends ConsumerStatefulWidget {
  const TaskFilterSheet({
    required this.initialFilter,
    required this.onApply,
    super.key,
  });

  final TaskFilter initialFilter;
  final ValueChanged<TaskFilter> onApply;

  /// Abre o sheet e aguarda o resultado. Retorna o filtro aplicado ou `null`
  /// se o utilizador fechou sem aplicar.
  static Future<void> show(
    BuildContext context, {
    required TaskFilter initialFilter,
    required ValueChanged<TaskFilter> onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskFilterSheet(
        initialFilter: initialFilter,
        onApply: onApply,
      ),
    );
  }

  @override
  ConsumerState<TaskFilterSheet> createState() => _TaskFilterSheetState();
}

class _TaskFilterSheetState extends ConsumerState<TaskFilterSheet> {
  late TaskFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  void _toggleToday() {
    SeniorFeedback.selection(ref);
    setState(() => _filter = _filter.copyWith(isToday: !_filter.isToday));
  }

  void _toggleCategory(TaskCategory cat) {
    SeniorFeedback.selection(ref);
    setState(() {
      _filter = _filter.copyWith(
        category: _filter.category == cat ? null : cat,
      );
    });
  }

  void _togglePriority(TaskPriority prio) {
    SeniorFeedback.selection(ref);
    setState(() {
      _filter = _filter.copyWith(
        priority: _filter.priority == prio ? null : prio,
      );
    });
  }

  void _clear() {
    SeniorFeedback.light(ref);
    setState(() => _filter = TaskFilter.empty);
  }

  void _apply() {
    SeniorFeedback.light(ref);
    widget.onApply(_filter);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.slate300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Título
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtrar Tarefas',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (!_filter.isEmpty)
                  TextButton(
                    onPressed: _clear,
                    child: Text(
                      'Limpar',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Secção Hoje ---
                _SectionLabel(label: 'Data'),
                const SizedBox(height: AppSpacing.sm),
                _FilterToggleTile(
                  icon: Icons.today_rounded,
                  label: 'Tarefas de Hoje',
                  subtitle: 'Mostrar apenas tarefas agendadas para hoje',
                  selected: _filter.isToday,
                  onTap: _toggleToday,
                ),
                const SizedBox(height: AppSpacing.lg),

                // --- Secção Categoria ---
                _SectionLabel(label: 'Categoria'),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: TaskCategory.values
                      .map(
                        (cat) => _FilterChip(
                          label: cat.label,
                          selected: _filter.category == cat,
                          onTap: () => _toggleCategory(cat),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // --- Secção Prioridade ---
                _SectionLabel(label: 'Prioridade'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    _PriorityChip(
                      priority: TaskPriority.high,
                      selected: _filter.priority == TaskPriority.high,
                      onTap: () => _togglePriority(TaskPriority.high),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _PriorityChip(
                      priority: TaskPriority.medium,
                      selected: _filter.priority == TaskPriority.medium,
                      onTap: () => _togglePriority(TaskPriority.medium),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _PriorityChip(
                      priority: TaskPriority.low,
                      selected: _filter.priority == TaskPriority.low,
                      onTap: () => _togglePriority(TaskPriority.low),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
          // Footer com botões
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md + bottomPadding,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    label: 'Cancelar',
                    variant: _SheetButtonVariant.outline,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: _SheetButton(
                    label: _filter.isEmpty
                        ? 'Mostrar Tudo'
                        : 'Aplicar Filtros',
                    variant: _SheetButtonVariant.primary,
                    onTap: _apply,
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

// ---------------------------------------------------------------------------
// Widgets internos
// ---------------------------------------------------------------------------

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        color: AppColors.slate500,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Tile com toggle de texto longo (ex: "Tarefas de Hoje").
class _FilterToggleTile extends StatelessWidget {
  const _FilterToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, ativo' : label,
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.slate200,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected ? AppColors.primary : AppColors.slate500,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de filtro genérico para categorias.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, seleccionado' : label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.slate300,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip de prioridade com cor indicativa.
class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.priority,
    required this.selected,
    required this.onTap,
  });

  final TaskPriority priority;
  final bool selected;
  final VoidCallback onTap;

  Color get _accentColor => switch (priority) {
        TaskPriority.high => AppColors.danger,
        TaskPriority.medium => AppColors.warning,
        TaskPriority.low => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _accentColor;

    return Semantics(
      button: true,
      selected: selected,
      label: selected
          ? '${priority.label}, seleccionado'
          : 'Prioridade ${priority.label}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: selected ? color : AppColors.slate300,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _capitalize(priority.label),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? color : AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

enum _SheetButtonVariant { primary, outline }

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.variant,
    required this.onTap,
  });

  final String label;
  final _SheetButtonVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrimary = variant == _SheetButtonVariant.primary;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: isPrimary ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Container(
            height: 50,
            decoration: isPrimary
                ? null
                : BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadius),
                    border: Border.all(color: AppColors.slate300, width: 1.5),
                  ),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white : AppColors.slate600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
