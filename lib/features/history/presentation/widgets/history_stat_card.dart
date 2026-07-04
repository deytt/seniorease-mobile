import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Card de estatística do topo do Histórico (ex.: "18 tarefas / Esta semana").
///
/// O valor grande usa [FittedBox] para nunca transbordar quando a preferência
/// de tamanho de letra está no máximo (acessibilidade).
class HistoryStatCard extends StatelessWidget {
  const HistoryStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: theme.dividerColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: AppSpacing.sm),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.slate500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
