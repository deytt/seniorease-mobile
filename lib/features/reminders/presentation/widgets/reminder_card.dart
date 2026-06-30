import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_completed_icon.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_visuals.dart';

/// Card de lembrete na lista (Figma `15:7912`).
class ReminderCard extends StatelessWidget {
  const ReminderCard({
    required this.reminder,
    required this.onMarkDone,
    this.showShell = true,
    super.key,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;

  /// Quando `false`, renderiza só o conteúdo (para swipe integrado no pai).
  final bool showShell;

  static BoxDecoration shellDecoration(BuildContext context, {required bool isDone}) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.colorScheme.surface,
      border: Border.all(
        color: isDone ? const Color(0xFFBBF7D0) : theme.colorScheme.outline,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDone = reminder.isDone;
    final content = _ReminderCardContent(
      reminder: reminder,
      onMarkDone: onMarkDone,
    );

    if (!showShell) return content;

    return Semantics(
      label: content.semanticsLabel,
      child: Opacity(
        opacity: isDone ? 0.7 : 1,
        child: Container(
          decoration: shellDecoration(context, isDone: isDone),
          child: content,
        ),
      ),
    );
  }
}

class _ReminderCardContent extends StatelessWidget {
  const _ReminderCardContent({
    required this.reminder,
    required this.onMarkDone,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;

  String get semanticsLabel {
    final time = formatReminderTime(reminder.scheduledAt);
    final period = formatReminderPeriod(reminder.scheduledAt);
    final isDone = reminder.isDone;
    return '${reminder.title}. ${reminder.message}. Às $time $period.'
        '${isDone ? ' Concluído.' : ' Pendente.'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = reminder.isDone;
    final style = reminderCategoryStyle(reminder.category);
    final time = formatReminderTime(reminder.scheduledAt);
    final period = formatReminderPeriod(reminder.scheduledAt);

    return Padding(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          _TimeBlock(
            time: time,
            period: period,
            muted: isDone,
          ),
          const SizedBox(width: 4),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(width: 12),
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
                    color: isDone
                        ? AppColors.slate400
                        : theme.colorScheme.onSurface,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (reminder.message.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reminder.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isDone)
            Semantics(
              label: 'Concluído',
              child: ReminderCompletedIcon(size: 20),
            )
          else
            _DoneButton(onPressed: onMarkDone),
        ],
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.time,
    required this.period,
    required this.muted,
  });

  final String time;
  final String period;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.slate400 : AppColors.slate900;

    return SizedBox(
      width: 52,
      child: Column(
        children: [
          Text(
            time,
            maxLines: 1,
            softWrap: false,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1.5,
            ),
          ),
          Text(
            period,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: muted ? AppColors.slate400 : AppColors.slate400,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Marcar como concluído',
      child: Material(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onPressed();
          },
          borderRadius: BorderRadius.circular(14),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              'Concluir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

