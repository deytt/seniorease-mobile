import 'package:flutter/material.dart';
import 'package:mobile/presentation/theme/app_colors.dart';
import 'package:mobile/presentation/theme/app_spacing.dart';
import 'package:mobile/presentation/theme/app_theme.dart';

class SeniorLogo extends StatelessWidget {
  const SeniorLogo({
    super.key,
    this.size = 72,
    this.showLabel = false,
  });

  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            'SE',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.35,
              fontWeight: FontWeight.bold,
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
