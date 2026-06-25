import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';

/// Overlay de celebração exibido ao concluir uma tarefa.
///
/// Mostra uma animação Lottie + mensagem positiva. Pode ser fechado
/// manualmente (acessibilidade) e fecha-se sozinho após alguns segundos.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    required this.onDismiss,
    this.message = 'Concluiu esta tarefa. Muito bem!',
    super.key,
  });

  final VoidCallback onDismiss;
  final String message;

  /// Apresenta o overlay como dialog modal.
  static Future<void> show(
    BuildContext context, {
    String message = 'Concluiu esta tarefa. Muito bem!',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => CelebrationOverlay(
        message: message,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class _CelebrationOverlayState extends State<CelebrationOverlay> {
  @override
  void initState() {
    super.initState();
    // Fecho automático de segurança após 4s.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Lottie.asset(
                'assets/lottie/celebration.json',
                repeat: false,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.celebration,
                  size: 96,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Parabéns! 🎉',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.message,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SeniorButton(
              label: 'Continuar',
              onPressed: widget.onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
