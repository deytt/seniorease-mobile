import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/features/guides/presentation/tutorial_catalog.dart';

/// Central "Guias do aplicativo": lista todos os tutoriais disponíveis para o
/// utilizador (re)ver quando quiser. Cada item inicia o respetivo tutorial na
/// sua tela.
class GuidesScreen extends ConsumerWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SeniorScreenScaffold(
      title: 'Guias do aplicativo',
      subtitle: 'Aprenda a usar cada parte com calma',
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          const _IntroCard(),
          const SizedBox(height: AppSpacing.md),
          for (final tutorial in kTutorials) ...[
            _TutorialCard(
              info: tutorial,
              onStart: () => _startTutorial(context, ref, tutorial),
            ),
            const SizedBox(height: AppSpacing.sm + 4),
          ],
        ],
      ),
    );
  }

  void _startTutorial(
    BuildContext context,
    WidgetRef ref,
    TutorialInfo info,
  ) {
    HapticFeedback.lightImpact();
    // Pede para iniciar o tutorial e navega para a tela alvo. O `TourHost` da
    // tela consome o sinal e inicia o showcase no próximo frame.
    ref.read(tourSignalProvider.notifier).request(info.id);
    if (info.isShellTab) {
      context.go(info.route);
    } else {
      context.push(info.route);
    }
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_outlined,
              color: AppColors.primary, size: 24),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Escolha um guia e eu mostro-lhe como funciona, passo a passo.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialCard extends StatelessWidget {
  const _TutorialCard({required this.info, required this.onStart});

  final TutorialInfo info;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Começar guia: ${info.title}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onStart,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(info.icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.play_circle_outline,
                    color: AppColors.primary, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
