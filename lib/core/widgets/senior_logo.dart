import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

class SeniorLogo extends StatelessWidget {
  const SeniorLogo({
    super.key,
    this.size = 72,
    this.showLabel = false,
    this.useGradient = true,
  });

  final double size;
  final bool showLabel;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: useGradient ? null : AppColors.primary,
            gradient: useGradient
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primaryDark],
                  )
                : null,
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'SE',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.3125,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'SeniorEase',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ],
    );
  }
}
