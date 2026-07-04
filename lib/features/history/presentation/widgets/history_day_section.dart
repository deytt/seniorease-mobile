import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';

/// Cabeçalho de um grupo diário na lista de atividade (ex.: "Hoje", "Ontem").
class HistoryDaySection extends StatelessWidget {
  const HistoryDaySection({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.slate500,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
