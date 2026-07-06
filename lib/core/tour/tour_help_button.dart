import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Botão de ajuda (?) sempre acessível no header de cada tela.
///
/// Toca para (re)ver o tutorial daquela tela. Touch target ≥44px e rótulo
/// semântico, conforme as regras de acessibilidade do projeto.
class TourHelpButton extends ConsumerWidget {
  const TourHelpButton({
    required this.onPressed,
    super.key,
    this.tooltip = 'Ver como funciona esta tela',
  });

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: tooltip,
      child: GestureDetector(
        onTap: () {
          SeniorFeedback.light(ref);
          onPressed();
        },
        child: Container(
          width: AppTheme.minTouchTarget,
          height: AppTheme.minTouchTarget,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.help_outline,
            size: AppTheme.backButtonIconSize + 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
