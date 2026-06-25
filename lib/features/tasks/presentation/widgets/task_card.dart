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

/// Card de tarefa na lista (node 15:7134).
class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    super.key,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;
    final pColor = priorityColor(task.priority);

    return Semantics(
      button: true,
      label: task.title,
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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task.reminderTime != null) ...[
                            Text(
                              task.reminderTime!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.slate400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: pColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            task.priority.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: pColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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

class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({required this.isDone, required this.onTap});

  final bool isDone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      checked: isDone,
      label: isDone ? 'Concluída' : 'Marcar como concluída',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          customBorder: const CircleBorder(),
          child: Padding(
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
          ),
        ),
      ),
    );
  }
}
