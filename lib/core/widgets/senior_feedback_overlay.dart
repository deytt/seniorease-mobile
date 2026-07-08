import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';

/// Overlay de feedback (celebração) exibido ao criar, editar ou concluir
/// uma tarefa ou lembrete.
///
/// Mostra a animação Lottie "Check animation" + mensagem positiva.
/// Pode ser fechado manualmente (acessibilidade) e fecha-se sozinho após
/// alguns segundos.
class SeniorFeedbackOverlay extends StatefulWidget {
  const SeniorFeedbackOverlay({
    required this.onDismiss,
    required this.message,
    this.title = 'Parabéns! 🎉',
    super.key,
  });

  final VoidCallback onDismiss;
  final String message;
  final String title;

  /// Apresenta o overlay como dialog modal.
  static Future<void> show(
    BuildContext context, {
    required String message,
    String title = 'Parabéns! 🎉',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => SeniorFeedbackOverlay(
        message: message,
        title: title,
        onDismiss: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  State<SeniorFeedbackOverlay> createState() => _SeniorFeedbackOverlayState();
}

class _SeniorFeedbackOverlayState extends State<SeniorFeedbackOverlay> {
  @override
  void initState() {
    super.initState();
    // Fecho automático de segurança após 4 s.
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
                'assets/lottie/check_animation.json',
                repeat: false,
                errorBuilder: (context, error, stack) => const Icon(
                  Icons.check_circle_outline,
                  size: 96,
                  color: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              widget.title,
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
