import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/accessibility/presentation/widgets/font_size_slider_card.dart';
import 'package:mobile/features/accessibility/presentation/widgets/interface_mode_card.dart';
import 'package:mobile/features/accessibility/presentation/widgets/preference_toggle_tile.dart';

class AccessibilityScreen extends ConsumerStatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  ConsumerState<AccessibilityScreen> createState() =>
      _AccessibilityScreenState();
}

class _AccessibilityScreenState extends ConsumerState<AccessibilityScreen> {
  UserPreferences? _draft;

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
    });
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
            'Erro ao guardar as definições. Tenta novamente.',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Definições guardadas com sucesso.'),
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
      title: 'Definições de Acessibilidade',
      backIcon: Icons.chevron_left,
      onBack: () => Navigator.of(context).pop(),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Erro ao carregar as definições.',
            style: theme.textTheme.bodyLarge,
          ),
        ),
        data: (_) => _Body(
          current: current,
          isSaving: isSaving,
          onUpdate: _update,
          onSave: _save,
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
  });

  final UserPreferences current;
  final bool isSaving;
  final ValueChanged<UserPreferences> onUpdate;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card 1 — Tamanho da Letra
          FontSizeSliderCard(
            value: current.fontSize,
            onChanged: (v) => onUpdate(current.copyWith(fontSize: v)),
          ),

          const SizedBox(height: 12),

          // Card 2 — Modo de Interface
          InterfaceModeCard(
            value: current.interfaceMode,
            onChanged: (v) => onUpdate(current.copyWith(interfaceMode: v)),
          ),

          const SizedBox(height: 12),

          // Card 3 — Toggles
          Container(
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

          const SizedBox(height: AppSpacing.lg),

          SeniorButton(
            label: 'Guardar Definições',
            isLoading: isSaving,
            onPressed: onSave,
          ),

          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
