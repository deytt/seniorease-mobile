import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Tag de categoria selecionável — estilo pill horizontal.
/// A área de toque respeita o mínimo de 44×44px (WCAG AA),
/// mas o visual é compacto (pill) para listar várias categorias lado a lado.
class CategoryChip extends ConsumerWidget {
  const CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    // Padding vertical cresce com a acessibilidade para garantir que o pill
    // nunca fique menor que 44 px na direção de toque.
    final verticalPadding = (textScale > 1.3) ? 10.0 : 6.0;

    return Semantics(
      button: true,
      selected: selected,
      label: selected ? '$label, selecionado' : label,
      child: GestureDetector(
        onTap: () {
          SeniorFeedback.selection(ref);
          onTap();
        },
        // SizedBox garante área de toque mínima de 44px em altura
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: verticalPadding,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : theme.colorScheme.outline,
                  width: 1.5,
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.slate600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
