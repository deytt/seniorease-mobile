import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

enum SeniorButtonVariant { primary, secondary, outline, ghost, destructive }

enum SeniorButtonSize { medium, large }

class SeniorButton extends StatelessWidget {
  const SeniorButton({
    required this.label,
    super.key,
    this.onPressed,
    this.variant = SeniorButtonVariant.primary,
    this.size = SeniorButtonSize.large,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final SeniorButtonVariant variant;
  final SeniorButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final height = size == SeniorButtonSize.large
        ? AppTheme.buttonHeight
        : AppTheme.minTouchTarget;
    final isDisabled = onPressed == null || isLoading;

    final button = Semantics(
      button: true,
      enabled: !isDisabled,
      label: semanticLabel ?? label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              color: _backgroundColor(isDisabled),
              borderRadius: BorderRadius.circular(AppTheme.buttonBorderRadius),
              border: _border(isDisabled),
              boxShadow: variant == SeniorButtonVariant.primary && !isDisabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _foregroundColor(isDisabled),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: variant == SeniorButtonVariant.outline ? 16 : 20,
                              color: _foregroundColor(isDisabled),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: _fontSize,
                              fontWeight: _fontWeight,
                              color: _foregroundColor(isDisabled),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  double get _fontSize => switch (variant) {
        SeniorButtonVariant.outline => 14,
        _ => size == SeniorButtonSize.large ? 18 : 16,
      };

  FontWeight get _fontWeight => switch (variant) {
        SeniorButtonVariant.outline => FontWeight.w500,
        _ => FontWeight.w600,
      };

  Color _backgroundColor(bool isDisabled) {
    if (isDisabled) {
      return switch (variant) {
        SeniorButtonVariant.primary => AppColors.slate300,
        SeniorButtonVariant.destructive => AppColors.dangerLight,
        _ => AppColors.slate100,
      };
    }
    return switch (variant) {
      SeniorButtonVariant.primary => AppColors.primary,
      SeniorButtonVariant.secondary => Colors.white,
      SeniorButtonVariant.outline => Colors.white,
      SeniorButtonVariant.ghost => Colors.transparent,
      SeniorButtonVariant.destructive => AppColors.danger,
    };
  }

  Color _foregroundColor(bool isDisabled) {
    if (isDisabled) return AppColors.slate400;
    return switch (variant) {
      SeniorButtonVariant.primary => Colors.white,
      SeniorButtonVariant.secondary => AppColors.primary,
      SeniorButtonVariant.outline => AppColors.slate600,
      SeniorButtonVariant.ghost => AppColors.primary,
      SeniorButtonVariant.destructive => Colors.white,
    };
  }

  Border? _border(bool isDisabled) {
    if (variant == SeniorButtonVariant.secondary) {
      return Border.all(
        color: isDisabled ? AppColors.slate300 : AppColors.slate200,
        width: 2,
      );
    }
    if (variant == SeniorButtonVariant.outline) {
      return Border.all(
        color: isDisabled ? AppColors.slate300 : AppColors.slate200,
      );
    }
    return null;
  }
}
