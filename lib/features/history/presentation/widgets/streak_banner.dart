import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Banner motivador de sequência (streak), exibido apenas quando o utilizador
/// tem uma sequência relevante (≥ 3 dias). A mensagem varia por faixa.
///
/// Contraste âmbar validado contra os tokens do Design System (texto
/// `warningDark`/`#92400E` sobre `warningLight`/`#FFFBEB` → WCAG AA).
class StreakBanner extends StatelessWidget {
  const StreakBanner({required this.streak, super.key});

  final int streak;

  /// Faixa mínima para exibir o banner.
  static const int minStreakToShow = 3;

  static const Color _amberText = Color(0xFF92400E);
  static const Color _amberSubtitle = Color(0xFFB45309);
  static const Color _amberBorder = Color(0xFFFDE68A);

  (String title, String subtitle) _message() {
    if (streak >= 14) {
      return (
        'Sequência de $streak dias!',
        'Incrível! Já são duas semanas sem parar.',
      );
    }
    if (streak >= 7) {
      return (
        'Sequência de $streak dias!',
        'Uma semana inteira de dedicação. Parabéns!',
      );
    }
    return (
      'Sequência de $streak dias!',
      'Está a criar um bom hábito. Continue assim!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, subtitle) = _message();

    return Semantics(
      label: '$title $subtitle',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.warningLight,
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: Border.all(color: _amberBorder, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: _amberText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: _amberSubtitle),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
