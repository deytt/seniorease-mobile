import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

/// Card com slider discreto de 4 passos para selecionar a escala de fonte.
class FontSizeSliderCard extends StatelessWidget {
  const FontSizeSliderCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final FontSizeScale value;
  final ValueChanged<FontSizeScale> onChanged;

  static const _steps = FontSizeScale.values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = _steps.indexOf(value).toDouble();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tamanho da Letra',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                value.label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.slate200,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: currentIndex,
              min: 0,
              max: (_steps.length - 1).toDouble(),
              divisions: _steps.length - 1,
              onChanged: (v) => onChanged(_steps[v.round()]),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pequeno',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                'Grande',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
