import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';

/// Dropdown de seleção de prioridade da tarefa.
class PriorityDropdown extends StatelessWidget {
  const PriorityDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final TaskPriority value;
  final ValueChanged<TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<TaskPriority>(
      initialValue: value,
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      icon: const Icon(Icons.expand_more, color: AppColors.slate400),
      items: [
        for (final p in TaskPriority.values)
          DropdownMenuItem(
            value: p,
            child: Text(
              switch (p) {
                TaskPriority.low => 'Baixa',
                TaskPriority.medium => 'Média',
                TaskPriority.high => 'Alta',
              },
            ),
          ),
      ],
      onChanged: (p) {
        if (p != null) onChanged(p);
      },
    );
  }
}
