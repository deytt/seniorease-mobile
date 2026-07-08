import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

/// Card de seleção de modo de espaçamento.
/// Visualmente alinhado ao [InterfaceModeCard]; exibe 3 opções:
/// Compacto / Confortável / Espaçoso.
class SpacingModeCard extends StatelessWidget {
  const SpacingModeCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SpacingMode value;
  final ValueChanged<SpacingMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Espaçamento',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajuste o espaço entre os elementos da tela',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _SpacingButton(
                    label: 'Compacto',
                    sublabel: 'Menos espaço',
                    selected: value == SpacingMode.compact,
                    onTap: () => onChanged(SpacingMode.compact),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SpacingButton(
                    label: 'Confortável',
                    sublabel: 'Espaço padrão',
                    selected: value == SpacingMode.comfortable,
                    onTap: () => onChanged(SpacingMode.comfortable),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SpacingButton(
                    label: 'Espaçoso',
                    sublabel: 'Mais espaço',
                    selected: value == SpacingMode.spacious,
                    onTap: () => onChanged(SpacingMode.spacious),
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

class _SpacingButton extends StatelessWidget {
  const _SpacingButton({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? theme.colorScheme.primary.withValues(alpha: 0.15)
        : theme.colorScheme.surface;
    final border = selected ? AppColors.primary : theme.colorScheme.outline;
    final labelColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
      ),
    );
  }
}
