import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_spacing_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/tour_dialogs.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/home/presentation/widgets/home_header.dart';
import 'package:mobile/features/home/presentation/widgets/quick_actions_grid.dart';
import 'package:mobile/features/home/presentation/widgets/reminders_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TourHost<HomeScreen> {
  static const String _scope = 'home';

  final _nextActivityShowcaseKey = GlobalKey();
  final _newTaskShowcaseKey = GlobalKey();
  final _accessibilityShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.home;

  @override
  List<GlobalKey> get tourKeys => [
        _nextActivityShowcaseKey,
        _newTaskShowcaseKey,
        _accessibilityShowcaseKey,
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _maybeOfferWelcome();
      if (mounted) await _maybeOfferFirstUse();
    });
  }

  /// Boas-vindas no primeiro arranque (cross-device, Firestore): pergunta se
  /// pode mostrar o essencial. Marca também [TourId.home] como oferecido para
  /// evitar um segundo modal de primeira utilização nesta mesma tela.
  Future<void> _maybeOfferWelcome() async {
    if (!mounted) return;
    final gate = ref.read(tourGateProvider);
    if (!await gate.isInitialOnboardingPending()) return;
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Bem-vindo ao SeniorEase!',
      message:
          'Quer que eu mostre, com calma, como usar as funções principais? Pode rever este guia quando quiser.',
      acceptLabel: 'Começar agora',
      declineLabel: 'Agora não',
    );

    // Concluído quer aceite ou recuse — não volta a aparecer automaticamente.
    await gate.completeInitialOnboarding();
    // Evita que _maybeOfferFirstUse mostre outro modal para esta mesma tela.
    await gate.markOffered(TourId.home);
    if (accepted && mounted) startTour();
  }

  /// Na primeira visita (apenas em Modo Básico), pergunta se pode mostrar
  /// como funciona a tela inicial. Só dispara se o onboarding já foi concluído
  /// noutro dispositivo mas o tour da Home ainda não foi oferecido neste.
  Future<void> _maybeOfferFirstUse() async {
    if (!mounted) return;
    final gate = ref.read(tourGateProvider);
    if (!await gate.shouldOfferFirstUse(TourId.home)) return;
    if (!mounted) return;

    await gate.markOffered(TourId.home);
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Quer conhecer esta tela?',
      message: 'Posso mostrar como tudo funciona aqui em poucos passos.',
    );
    if (accepted && mounted) startTour();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.blueHeaderOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            // Header gradiente — estende-se para trás do status bar (edge-to-edge)
            HomeHeader(
              tourScope: _scope,
              nextActivityShowcaseKey: _nextActivityShowcaseKey,
              onHelp: startTour,
            ),
            // Corpo com scroll
            Expanded(
              child: Builder(
                builder: (context) {
                  final spacing =
                      Theme.of(context).extension<SeniorSpacingTheme>();
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(
                      spacing?.screenPadding ?? AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: spacing?.itemGap ?? AppSpacing.sm),
                        QuickActionsGrid(
                          tourScope: _scope,
                          newTaskShowcaseKey: _newTaskShowcaseKey,
                          accessibilityShowcaseKey: _accessibilityShowcaseKey,
                        ),
                        SizedBox(
                          height: spacing?.sectionGap ?? AppSpacing.lg,
                        ),
                        const RemindersSection(),
                        SizedBox(
                          height: spacing?.cardPadding ?? AppSpacing.md,
                        ),
                        _SuccessBanner(),
                        SizedBox(
                          height: spacing?.cardPadding ?? AppSpacing.md,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Success Banner

class _SuccessBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        border: Border.all(color: const Color(0xFFBBF7D0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.celebration_outlined,
              color: AppColors.successDark,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
              Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Muito bem! 🎉',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.successDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Continua assim — cada pequeno passo conta!',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.successDark,
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
