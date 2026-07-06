import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';

/// Cor associada à prioridade da tarefa.
Color priorityColor(TaskPriority priority) => switch (priority) {
      TaskPriority.high => AppColors.danger,
      TaskPriority.medium => AppColors.warning,
      TaskPriority.low => AppColors.success,
    };

/// Formata a data/hora da tarefa de forma legível.
String _formatDueDate(DateTime dt) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  final isTomorrow =
      dt.year == now.year && dt.month == now.month && dt.day == now.day + 1;

  final hour = dt.hour.toString().padLeft(2, '0');
  final min = dt.minute.toString().padLeft(2, '0');
  final time = '$hour:$min';

  if (isToday) return '$time · Hoje';
  if (isTomorrow) return '$time · Amanhã';

  final day = dt.day.toString().padLeft(2, '0');
  final month = dt.month.toString().padLeft(2, '0');
  return '$time · $day/$month/${dt.year}';
}

/// Card de tarefa na lista (node 15:7134).
///
/// [onToggleComplete] é opcional. Quando `null` o círculo fica apenas como
/// indicador visual (sem InkWell), forçando o utilizador a abrir a tarefa.
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onTap,
    this.onToggleComplete,
    super.key,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;
    final pColor = priorityColor(task.priority);

    return Semantics(
      button: true,
      label: '${task.title}. ${task.priority.fullLabel}. Categoria: ${task.category.label}.'
          '${task.dueDate != null ? ' Data: ${_formatDueDate(task.dueDate!)}.' : ''}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSpacing.md),
          child: Ink(
            decoration: BoxDecoration(
              color: isDone ? AppColors.successLight : theme.colorScheme.surface,
              border: Border.all(
                color: isDone ? const Color(0xFFBBF7D0) : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.md),
            ),
            padding: const EdgeInsets.all(17),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _CompletionCircle(isDone: isDone, onTap: onToggleComplete),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDone ? AppColors.slate400 : AppColors.slate900,
                          decoration:
                              isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Linha 1: Prioridade + Categoria
                      Row(
                        children: [
                          _CardBadge(
                            label: task.priority.fullLabel,
                            color: pColor,
                            background: pColor.withValues(alpha: 0.12),
                          ),
                          const SizedBox(width: AppSpacing.xs + 2),
                          _CardBadge(
                            label: task.category.label,
                            color: AppColors.secondary,
                            background: AppColors.secondaryLight,
                          ),
                        ],
                      ),
                      // Linha 2: Data e hora (se definida)
                      if (task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: isDone
                                  ? AppColors.slate400
                                  : AppColors.slate500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDueDate(task.dueDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDone
                                    ? AppColors.slate400
                                    : AppColors.slate500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.slate400,
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

class _CardBadge extends StatelessWidget {
  const _CardBadge({
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({required this.isDone, required this.onTap});

  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final circle = Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDone ? AppColors.success : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDone ? AppColors.success : AppColors.slate200,
            width: 2,
          ),
        ),
        child: isDone
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : null,
      ),
    );

    if (onTap == null) {
      return Semantics(
        checked: isDone,
        label: isDone ? 'Concluída' : 'Abra a tarefa para concluir',
        child: circle,
      );
    }

    return Semantics(
      button: true,
      checked: isDone,
      label: isDone ? 'Concluída' : 'Marcar como concluída',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!();
          },
          customBorder: const CircleBorder(),
          child: circle,
        ),
      ),
    );
  }
}
