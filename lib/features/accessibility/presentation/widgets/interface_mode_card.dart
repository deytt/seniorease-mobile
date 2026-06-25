import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

/// Card com dois botões para selecionar o modo de interface: Básico ou Avançado.
class InterfaceModeCard extends StatelessWidget {
  const InterfaceModeCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final InterfaceMode value;
  final ValueChanged<InterfaceMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          Text(
            'Modo de Interface',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'O modo básico simplifica a interface para uma experiência mais calma',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          // IntrinsicHeight garante que os dois cards têm sempre a mesma altura
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'Básico',
                    sublabel: 'Elementos maiores e simplificados',
                    selected: value == InterfaceMode.basic,
                    selectedBg: AppColors.secondaryLight,
                    selectedBorder: AppColors.secondary,
                    selectedTextColor: AppColors.secondary,
                    onTap: () => onChanged(InterfaceMode.basic),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModeButton(
                    label: 'Avançado',
                    sublabel: 'Todas as funcionalidades',
                    selected: value == InterfaceMode.advanced,
                    selectedBg: AppColors.primaryLight,
                    selectedBorder: AppColors.primary,
                    selectedTextColor: AppColors.primary,
                    onTap: () => onChanged(InterfaceMode.advanced),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.selectedBg,
    required this.selectedBorder,
    required this.selectedTextColor,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final Color selectedBg;
  final Color selectedBorder;
  final Color selectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected ? selectedBg : theme.colorScheme.surface;
    final border = selected ? selectedBorder : theme.colorScheme.outline;
    final labelColor =
        selected ? selectedTextColor : theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
