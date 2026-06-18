import 'package:flutter/material.dart';
import 'package:mobile/presentation/theme/app_colors.dart';
import 'package:mobile/presentation/theme/app_spacing.dart';
import 'package:mobile/presentation/theme/app_theme.dart';

enum SeniorCardVariant { basic, featured, success, primary }

class SeniorCard extends StatelessWidget {
  const SeniorCard({
    required this.child,
    super.key,
    this.variant = SeniorCardVariant.basic,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final SeniorCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      border: Border.all(color: _borderColor, width: 1.5),
      boxShadow: variant == SeniorCardVariant.basic
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    final content = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        button: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Ink(decoration: decoration, child: content),
          ),
        ),
      );
    }

    return DecoratedBox(decoration: decoration, child: content);
  }

  Color get _backgroundColor => switch (variant) {
        SeniorCardVariant.basic => Colors.white,
        SeniorCardVariant.featured => AppColors.primaryLight,
        SeniorCardVariant.success => AppColors.successLight,
        SeniorCardVariant.primary => AppColors.primary,
      };

  Color get _borderColor => switch (variant) {
        SeniorCardVariant.basic => AppColors.slate200,
        SeniorCardVariant.featured => AppColors.primary.withValues(alpha: 0.3),
        SeniorCardVariant.success => AppColors.success.withValues(alpha: 0.3),
        SeniorCardVariant.primary => AppColors.primaryDark,
      };
}
