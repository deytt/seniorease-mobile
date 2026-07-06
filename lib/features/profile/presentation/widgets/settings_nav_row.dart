import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';

/// Row de navegação reutilizável para o ecrã de Definições.
class SettingsNavRow extends ConsumerWidget {
  const SettingsNavRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.showDivider = true,
    this.showAlert = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showDivider;

  /// Exibe um ícone de alerta (exclamação) à esquerda do chevron, sinalizando
  /// que há ações pendentes nesta tela (ex.: conta por verificar).
  final bool showAlert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap == null
              ? null
              : () {
                  SeniorFeedback.light(ref);
                  onTap!();
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (showAlert) ...[
                  Semantics(
                    label: 'Tem ações pendentes',
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.warning,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: AppSpacing.md + 44 + AppSpacing.md,
            endIndent: AppSpacing.md,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }
}
