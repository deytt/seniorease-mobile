import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_completed_icon.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_visuals.dart';

/// Card de lembrete na lista (Figma `15:7912`).
class ReminderCard extends ConsumerWidget {
  const ReminderCard({
    required this.reminder,
    required this.onMarkDone,
    this.showShell = true,
    this.expanded = false,
    super.key,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;

  /// Quando `false`, renderiza só o conteúdo (para swipe integrado no pai).
  final bool showShell;

  /// Quando `true`, mostra a descrição completa (card expandido).
  final bool expanded;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = reminder.isDone;
    final content = _ReminderCardContent(
      reminder: reminder,
      onMarkDone: onMarkDone,
      expanded: expanded,
      ref: ref,
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
    required this.ref,
    this.expanded = false,
  });

  final Reminder reminder;
  final VoidCallback onMarkDone;
  final WidgetRef ref;
  final bool expanded;

  String get semanticsLabel {
    final time = formatReminderTime(reminder.scheduledAt);
    final period = formatReminderPeriod(reminder.scheduledAt);
    final date = formatReminderDate(reminder.scheduledAt);
    final isDone = reminder.isDone;
    final msg = reminder.message.isEmpty ? '' : '${reminder.message}. ';
    return '${reminder.title}. $msg$date às $time $period.'
        '${isDone ? ' Concluído.' : ' Pendente.'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = reminder.isDone;
    final style = reminderCategoryStyle(reminder.category);
    final time = formatReminderTime(reminder.scheduledAt);
    final period = formatReminderPeriod(reminder.scheduledAt);
    final dayMonth = formatReminderDayMonth(reminder.scheduledAt);
    final hasMessage = reminder.message.isNotEmpty;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                reminder.title,
                maxLines: expanded ? null : 1,
                overflow: expanded ? null : TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDone
                      ? AppColors.slate400
                      : theme.colorScheme.onSurface,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (hasMessage)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: AppColors.slate400,
                ),
              ),
          ],
        ),
        if (hasMessage) ...[
          const SizedBox(height: 4),
          Text(
            reminder.message,
            maxLines: expanded ? null : 2,
            overflow: expanded ? null : TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.slate500,
            ),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(17),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: _TimeBlock(
                dayMonth: dayMonth,
                time: time,
                period: period,
                muted: isDone,
              ),
            ),
            const SizedBox(width: 10),
            // Divisor de altura total do card (divisão interna clara).
            Container(width: 1.5, color: theme.colorScheme.outline),
            const SizedBox(width: 12),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(style.icon, color: style.color, size: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(alignment: Alignment.topLeft, child: content),
            ),
            const SizedBox(width: 8),
            Align(
              alignment: Alignment.topCenter,
              child: isDone
                  ? Semantics(
                      label: 'Concluído',
                      child: ReminderCompletedIcon(size: 20),
                    )
                  : _DoneButton(onPressed: onMarkDone, ref: ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.dayMonth,
    required this.time,
    required this.period,
    required this.muted,
  });

  final String dayMonth;
  final String time;
  final String period;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.slate400 : AppColors.slate900;

    return SizedBox(
      width: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Data (dd/MM) acima da hora.
          Text(
            dayMonth,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: muted ? AppColors.slate400 : AppColors.slate500,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          // A hora nunca deve estourar a coluna: encolhe em fontes grandes.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1.2,
              ),
            ),
          ),
          Text(
            period,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: muted ? AppColors.slate400 : AppColors.slate500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoneButton extends StatelessWidget {
  const _DoneButton({required this.onPressed, required this.ref});

  final VoidCallback onPressed;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Em fontes grandes o rótulo "Concluir" empurraria o layout e sobreporia os
    // textos; nesses casos usamos um botão de ícone compacto (mesmo alvo 48px).
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = textScale >= 1.3;

    return Semantics(
      button: true,
      label: 'Marcar como concluído',
      child: Material(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: InkWell(
          onTap: () {
            SeniorFeedback.success(ref);
            onPressed();
          },
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          // Área de toque mínima de 48px (WCAG / persona idosa).
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppTheme.minTouchTarget,
              minWidth: AppTheme.minTouchTarget,
            ),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: compact
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.check, color: Colors.white, size: 24),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Concluir',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

