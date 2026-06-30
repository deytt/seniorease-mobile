import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Linha de toggle reutilizável: emoji/ícone + label + Flutter Switch.
/// Usada no card de toggles da tela de Acessibilidade.
class PreferenceToggleTile extends StatelessWidget {
  const PreferenceToggleTile({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.onChanged,
    this.showDivider = true,
  });

  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  emoji,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.slate300,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }
}
