import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';

/// Dropdown de seleção de categoria da tarefa.
class CategoryDropdown extends StatelessWidget {
  const CategoryDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final TaskCategory value;
  final ValueChanged<TaskCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<TaskCategory>(
      initialValue: value,
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      icon: const Icon(Icons.expand_more, color: AppColors.slate400),
      items: [
        for (final c in TaskCategory.values)
          DropdownMenuItem(
            value: c,
            child: Text(c.label),
          ),
      ],
      onChanged: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}
