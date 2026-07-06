import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_spacing_theme.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_dialogs.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/accessibility/presentation/widgets/font_size_slider_card.dart';
import 'package:mobile/features/accessibility/presentation/widgets/interface_mode_card.dart';
import 'package:mobile/features/accessibility/presentation/widgets/preference_toggle_tile.dart';
import 'package:mobile/features/accessibility/presentation/widgets/spacing_mode_card.dart';

class AccessibilityScreen extends ConsumerStatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  ConsumerState<AccessibilityScreen> createState() =>
      _AccessibilityScreenState();
}

class _AccessibilityScreenState extends ConsumerState<AccessibilityScreen>
    with TourHost<AccessibilityScreen> {
  static const String _scope = 'accessibility';

  UserPreferences? _draft;

  // Alvos do tutorial guiado (na ordem de exibição; o 1.º está no topo).
  final _fontShowcaseKey = GlobalKey();
  final _modeShowcaseKey = GlobalKey();
  final _spacingShowcaseKey = GlobalKey();
  final _togglesShowcaseKey = GlobalKey();
  final _saveShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.accessibility;

  @override
  List<GlobalKey> get tourKeys => [
        _fontShowcaseKey,
        _modeShowcaseKey,
        _spacingShowcaseKey,
        _togglesShowcaseKey,
        _saveShowcaseKey,
      ];

  UserPreferences get _current =>
      _draft ?? ref.read(preferencesProvider).value ?? UserPreferences.defaults();

  @override
  void initState() {
    super.initState();
    // Inicializa o draft quando as preferências estiverem disponíveis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider).value;
      if (prefs != null && _draft == null) {
        setState(() => _draft = prefs);
      }
      _maybeOfferFirstUse();
    });
  }

  /// Na primeira utilização (apenas em Modo Básico), pergunta se pode mostrar
  /// como ajustar a acessibilidade. A decisão de "quando" é toda do [TourGate].
  Future<void> _maybeOfferFirstUse() async {
    if (!mounted) return;
    if (ref.read(tourSessionProvider)) return;

    final gate = ref.read(tourGateProvider);
    if (!await gate.shouldOfferFirstUse(TourId.accessibility)) return;
    if (!mounted) return;

    ref.read(tourSessionProvider.notifier).markAutoOffered();
    await gate.markOffered(TourId.accessibility);
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Vamos fazer juntos?',
      message: 'Posso mostrar rapidamente como ajustar a acessibilidade?',
      acceptLabel: 'Sim',
      declineLabel: 'Agora não',
    );
    if (accepted && mounted) startTour();
  }

  void _update(UserPreferences updated) => setState(() => _draft = updated);

  Future<void> _save() async {
    if (_draft == null) return;

    final prefs = ref.read(preferencesProvider).value;
    if (prefs != null) {
      final toSave = _draft!.copyWith(userId: prefs.userId);
      await ref.read(accessibilityControllerProvider.notifier).save(toSave);
    }

    if (!mounted) return;
    final saveState = ref.read(accessibilityControllerProvider);
    if (saveState is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar as configurações. Tente novamente.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configurações salvas com sucesso.'),
          backgroundColor: AppColors.successDark,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(preferencesProvider);
    final saveState = ref.watch(accessibilityControllerProvider);
    final isSaving = saveState is AsyncLoading;

    prefsAsync.whenData((prefs) {
      if (_draft == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _draft = prefs),
        );
      }
    });

    final current = _current;
    final theme = Theme.of(context);

    return SeniorScreenScaffold(
      title: 'Configurações de Acessibilidade',
      backIcon: Icons.chevron_left,
      onBack: () => Navigator.of(context).pop(),
      trailing: TourHelpButton(onPressed: startTour),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar as configurações.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        data: (_) => _Body(
          current: current,
          isSaving: isSaving,
          onUpdate: _update,
          onSave: _save,
          tourScope: _scope,
          fontShowcaseKey: _fontShowcaseKey,
          modeShowcaseKey: _modeShowcaseKey,
          spacingShowcaseKey: _spacingShowcaseKey,
          togglesShowcaseKey: _togglesShowcaseKey,
          saveShowcaseKey: _saveShowcaseKey,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Body

class _Body extends StatelessWidget {
  const _Body({
    required this.current,
    required this.isSaving,
    required this.onUpdate,
    required this.onSave,
    required this.tourScope,
    required this.fontShowcaseKey,
    required this.modeShowcaseKey,
    required this.spacingShowcaseKey,
    required this.togglesShowcaseKey,
    required this.saveShowcaseKey,
  });

  final UserPreferences current;
  final bool isSaving;
  final ValueChanged<UserPreferences> onUpdate;
  final VoidCallback onSave;

  final String tourScope;
  final GlobalKey fontShowcaseKey;
  final GlobalKey modeShowcaseKey;
  final GlobalKey spacingShowcaseKey;
  final GlobalKey togglesShowcaseKey;
  final GlobalKey saveShowcaseKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.extension<SeniorSpacingTheme>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing?.screenPadding ?? AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1 — Tamanho da Letra
          SeniorShowcase(
            showcaseKey: fontShowcaseKey,
            scope: tourScope,
            title: 'Tamanho da letra',
            description:
                'Arraste para deixar o texto maior ou menor, do jeito que ler melhor.',
            child: FontSizeSliderCard(
              value: current.fontSize,
              onChanged: (v) => onUpdate(current.copyWith(fontSize: v)),
            ),
          ),

          SizedBox(height: spacing?.itemGap ?? 12),

          // Card 2 — Modo de Interface
          SeniorShowcase(
            showcaseKey: modeShowcaseKey,
            scope: tourScope,
            title: 'Modo de uso',
            description:
                'Escolha o Modo Básico para uma tela mais simples, ou o Avançado para ver tudo.',
            child: InterfaceModeCard(
              value: current.interfaceMode,
              onChanged: (v) => onUpdate(current.copyWith(interfaceMode: v)),
            ),
          ),

          SizedBox(height: spacing?.itemGap ?? 12),

          // Card 3 — Espaçamento
          SeniorShowcase(
            showcaseKey: spacingShowcaseKey,
            scope: tourScope,
            title: 'Espaçamento',
            description:
                'Escolha quanto espaço quer entre os elementos. "Espaçoso" dá mais respiro à tela.',
            child: SpacingModeCard(
              value: current.spacing,
              onChanged: (v) => onUpdate(current.copyWith(spacing: v)),
            ),
          ),

          SizedBox(height: spacing?.itemGap ?? 12),

          // Card 4 — Toggles
          SeniorShowcase(
            showcaseKey: togglesShowcaseKey,
            scope: tourScope,
            title: 'Ajustes rápidos',
            description:
                'Ligue ou desligue o modo escuro, o alto contraste, os sons e os botões maiores.',
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  PreferenceToggleTile(
                    emoji: '🌙',
                    label: 'Modo Escuro',
                    value: current.darkMode,
                    onChanged: (v) => onUpdate(current.copyWith(darkMode: v)),
                  ),
                  PreferenceToggleTile(
                    emoji: '◑',
                    label: 'Alto Contraste',
                    value: current.contrast != ContrastMode.defaultMode,
                    onChanged: (v) => onUpdate(
                      current.copyWith(
                        contrast:
                            v ? ContrastMode.high : ContrastMode.defaultMode,
                      ),
                    ),
                  ),
                  PreferenceToggleTile(
                    emoji: '🔊',
                    label: 'Feedback de Áudio e Tátil',
                    value: current.audioFeedbackEnabled,
                    onChanged: (v) =>
                        onUpdate(current.copyWith(audioFeedbackEnabled: v)),
                  ),
                  PreferenceToggleTile(
                    emoji: '👆',
                    label: 'Botões Maiores',
                    value: current.largeTouchTargets,
                    onChanged: (v) =>
                        onUpdate(current.copyWith(largeTouchTargets: v)),
                    showDivider: false,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),

          SizedBox(height: spacing?.sectionGap ?? AppSpacing.lg),

          SeniorShowcase(
            showcaseKey: saveShowcaseKey,
            scope: tourScope,
            title: 'Salvar suas escolhas',
            description:
                'No fim, toque aqui para salvar. As mudanças passam a valer em todo o app.',
            child: SeniorButton(
              label: 'Salvar configurações',
              isLoading: isSaving,
              onPressed: onSave,
            ),
          ),

          SizedBox(height: spacing?.cardPadding ?? AppSpacing.md),
        ],
      ),
    );
  }
}
