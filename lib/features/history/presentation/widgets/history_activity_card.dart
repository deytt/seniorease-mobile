import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/presentation/widgets/history_date_format.dart';
import 'package:mobile/features/history/presentation/widgets/history_visuals.dart';

/// Card de uma ação individual na lista "Atividade Recente".
class HistoryActivityCard extends StatelessWidget {
  const HistoryActivityCard({required this.event, super.key});

  final HistoryEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = historyVisual(event.type, category: event.category);
    final time = historyTime(event.occurredAt);

    return Semantics(
      label: '${visual.semanticLabel}. ${event.title}, às $time.',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md - 1),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: visual.background,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Icon(visual.icon, color: visual.color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      event.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
