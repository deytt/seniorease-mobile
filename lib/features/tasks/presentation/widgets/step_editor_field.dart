import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Campo editável de um passo: número + texto + botão remover (X).
///
/// Replica o comportamento da versão Web (campo único por passo, com X para
/// apagar um passo adicionado por engano).
class StepEditorField extends StatelessWidget {
  const StepEditorField({
    required this.index,
    required this.controller,
    required this.onRemove,
    super.key,
    this.canRemove = true,
  });

  /// Posição do passo (1-indexed) exibida no círculo.
  final int index;
  final TextEditingController controller;
  final VoidCallback onRemove;

  /// Quando false, o botão de remover fica oculto (ex: último passo obrigatório).
  final bool canRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$index',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(
          child: TextField(
            controller: controller,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Passo $index',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
              ),
            ),
          ),
        ),
        if (canRemove) ...[
          const SizedBox(width: AppSpacing.xs),
          Semantics(
            button: true,
            label: 'Remover passo $index',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.close, color: AppColors.danger, size: 22),
                ),
              ),
            ),
          ),
        ] else
          const SizedBox(width: 44),
      ],
    );
  }
}
