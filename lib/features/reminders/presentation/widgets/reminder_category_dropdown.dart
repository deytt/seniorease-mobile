import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_visuals.dart';

/// Combo de seleção da categoria do lembrete, com ícone colorido por categoria.
class ReminderCategoryDropdown extends StatelessWidget {
  const ReminderCategoryDropdown({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final ReminderCategory value;
  final ValueChanged<ReminderCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<ReminderCategory>(
      initialValue: value,
      isExpanded: true,
      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurface,
      ),
      icon: const Icon(Icons.expand_more, color: AppColors.slate400),
      items: [
        for (final c in ReminderCategory.values)
          DropdownMenuItem(
            value: c,
            child: _CategoryRow(category: c),
          ),
      ],
      onChanged: (c) {
        if (c != null) onChanged(c);
      },
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category});

  final ReminderCategory category;

  @override
  Widget build(BuildContext context) {
    final style = reminderCategoryStyle(category);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: style.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(style.icon, color: style.color, size: 18),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            category.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
