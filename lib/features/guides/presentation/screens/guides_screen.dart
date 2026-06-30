import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/features/guides/presentation/tutorial_catalog.dart';

/// Central "Guias do aplicativo": lista todos os tutoriais disponíveis para o
/// utilizador (re)ver quando quiser. Cada item inicia o respetivo tutorial na
/// sua tela.
class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen>
    with TourHost<GuidesScreen> {
  static const String _scope = 'guides';

  // Alvos do tutorial guiado (na ordem de exibição).
  final _introShowcaseKey = GlobalKey();
  final _firstTutorialShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.guides;

  @override
  List<GlobalKey> get tourKeys =>
      [_introShowcaseKey, _firstTutorialShowcaseKey];

  @override
  Widget build(BuildContext context) {
    return SeniorScreenScaffold(
      title: 'Guias do aplicativo',
      subtitle: 'Aprenda a usar cada parte com calma',
      trailing: TourHelpButton(onPressed: startTour),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          SeniorShowcase(
            showcaseKey: _introShowcaseKey,
            scope: _scope,
            title: 'Central de guias',
            description:
                'Aqui estão todos os guias. Escolha um quando precisar.',
            child: const _IntroCard(),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final entry in kTutorials.asMap().entries) ...[
            if (entry.key == 0)
              SeniorShowcase(
                showcaseKey: _firstTutorialShowcaseKey,
                scope: _scope,
                title: 'Começar um guia',
                description:
                    'Toque num guia e eu mostro-lhe na própria tela, passo a passo.',
                child: _TutorialCard(
                  info: entry.value,
                  onStart: () => _startTutorial(entry.value),
                ),
              )
            else
              _TutorialCard(
                info: entry.value,
                onStart: () => _startTutorial(entry.value),
              ),
            const SizedBox(height: AppSpacing.sm + 4),
          ],
        ],
      ),
    );
  }

  void _startTutorial(TutorialInfo info) {
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
