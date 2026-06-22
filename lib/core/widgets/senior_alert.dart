import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

enum SeniorAlertVariant { info, success, warning, danger }

class SeniorAlert extends StatelessWidget {
  const SeniorAlert({
    required this.title,
    required this.message,
    super.key,
    this.variant = SeniorAlertVariant.info,
    this.onDismiss,
  });

  final String title;
  final String message;
  final SeniorAlertVariant variant;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: colors.border, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(colors.icon, color: colors.foreground, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.foreground,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colors.foreground.withValues(alpha: 0.85),
                        ),
                  ),
                ],
              ),
            ),
            if (onDismiss != null)
              Semantics(
                button: true,
                label: 'Fechar alerta',
                child: IconButton(
                  icon: Icon(Icons.close, color: colors.foreground, size: 20),
                  onPressed: onDismiss,
                  constraints: const BoxConstraints(
                    minWidth: AppTheme.minTouchTarget,
                    minHeight: AppTheme.minTouchTarget,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _AlertColors get _colors => switch (variant) {
        SeniorAlertVariant.info => _AlertColors(
            background: AppColors.primaryLight,
            border: AppColors.primary.withValues(alpha: 0.3),
            foreground: AppColors.primaryDark,
            icon: Icons.info_outline,
          ),
        SeniorAlertVariant.success => _AlertColors(
            background: AppColors.successLight,
            border: AppColors.success.withValues(alpha: 0.3),
            foreground: AppColors.successDark,
            icon: Icons.check_circle_outline,
          ),
        SeniorAlertVariant.warning => _AlertColors(
            background: AppColors.warningLight,
            border: AppColors.warning.withValues(alpha: 0.4),
            foreground: const Color(0xFF92400E),
            icon: Icons.warning_amber_outlined,
          ),
        SeniorAlertVariant.danger => _AlertColors(
            background: AppColors.dangerLight,
            border: AppColors.danger.withValues(alpha: 0.3),
            foreground: AppColors.dangerDark,
            icon: Icons.error_outline,
          ),
      };
}

class _AlertColors {
  const _AlertColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final IconData icon;
}
