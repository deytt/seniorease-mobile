import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_spacing_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
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

  // Passo 1: sininho de notificações (header — topo, passo 0 sem auto-scroll)
  final _notificationBellShowcaseKey = GlobalKey();
  // Passo 2: próxima atividade (header)
  final _nextActivityShowcaseKey = GlobalKey();
  // Passo 3: ação rápida Nova Tarefa
  final _newTaskShowcaseKey = GlobalKey();
  // Passo 4: ação rápida Acessibilidade
  final _accessibilityShowcaseKey = GlobalKey();
  // Passo 5: ação rápida Lembretes
  final _remindersActionShowcaseKey = GlobalKey();
  // Passo 6: ação rápida Ajuda Rápida
  final _quickHelpShowcaseKey = GlobalKey();
  // Passo 7: seção "Próximos Lembretes"
  final _remindersSectionShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.home;

  @override
  List<GlobalKey> get tourKeys => [
        _notificationBellShowcaseKey,
        _nextActivityShowcaseKey,
        _newTaskShowcaseKey,
        _accessibilityShowcaseKey,
        _remindersActionShowcaseKey,
        _quickHelpShowcaseKey,
        _remindersSectionShowcaseKey,
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferWelcome());
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
              notificationBellShowcaseKey: _notificationBellShowcaseKey,
              onHelp: startTour,
              tourId: tourId,
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
                          remindersShowcaseKey: _remindersActionShowcaseKey,
                          quickHelpShowcaseKey: _quickHelpShowcaseKey,
                        ),
                        SizedBox(
                          height: spacing?.sectionGap ?? AppSpacing.lg,
                        ),
                        SeniorShowcase(
                          showcaseKey: _remindersSectionShowcaseKey,
                          scope: _scope,
                          title: 'Próximos Lembretes',
                          description:
                              'Aqui aparecem os seus próximos lembretes pendentes. Toque num para ver na lista.',
                          targetBorderRadius: BorderRadius.circular(16),
                          child: const RemindersSection(),
                        ),
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
