import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_visuals.dart';

/// Secção "Lembretes de Hoje" na Home, ligada ao Firestore.
class RemindersSection extends ConsumerWidget {
  const RemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(todayRemindersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Lembretes de Hoje',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.reminders),
              child: Text(
                'Ver todos',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (items.isEmpty)
          Text(
            'Não tem lembretes para hoje.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate500,
            ),
          )
        else
          ...items.map(
            (reminder) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _HomeReminderCard(reminder: reminder),
            ),
          ),
      ],
    );
  }
}

class _HomeReminderCard extends StatelessWidget {
  const _HomeReminderCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = reminderCategoryStyle(reminder.category);
    final time = formatReminderTime(reminder.scheduledAt);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: style.bg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(style.icon, color: style.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    decoration:
                        reminder.isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
