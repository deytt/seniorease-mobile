import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/preferences/user_preferences.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_dialogs.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/accessibility/presentation/widgets/notification_offset_card.dart';
import 'package:mobile/features/accessibility/presentation/widgets/preference_toggle_tile.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends ConsumerState<NotificationPreferencesScreen>
    with TourHost<NotificationPreferencesScreen> {
  static const String _scope = 'notificationPreferences';

  final _tasksShowcaseKey = GlobalKey();
  final _remindersShowcaseKey = GlobalKey();
  final _saveShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.notificationPreferences;

  @override
  List<GlobalKey> get tourKeys =>
      [_tasksShowcaseKey, _remindersShowcaseKey, _saveShowcaseKey];

  UserPreferences? _draft;

  UserPreferences get _current =>
      _draft ??
      ref.read(preferencesProvider).value ??
      UserPreferences.defaults();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider).value;
      if (prefs != null && mounted) {
        setState(() => _draft = prefs);
      }
      _maybeOfferFirstUse();
    });
  }

  /// Na primeira visita (apenas em Modo Básico), pergunta se pode mostrar
  /// como funciona esta tela. A decisão de "quando" é toda do [TourGate].
  Future<void> _maybeOfferFirstUse() async {
    if (!mounted) return;
    final gate = ref.read(tourGateProvider);
    if (!await gate.shouldOfferFirstUse(tourId)) return;
    if (!mounted) return;

    await gate.markOffered(tourId);
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Quer conhecer esta tela?',
      message: 'Posso mostrar como tudo funciona aqui em poucos passos.',
    );
    if (accepted && mounted) startTour();
  }

  void _update(UserPreferences updated) => setState(() => _draft = updated);

  Future<void> _save() async {
    if (_draft == null) return;
    final prefs = ref.read(preferencesProvider).value;
    if (prefs == null) return;
    final toSave = _draft!.copyWith(userId: prefs.userId);
    await ref
        .read(notificationPreferencesControllerProvider.notifier)
        .save(toSave);

    if (!mounted) return;
    final saveState = ref.read(notificationPreferencesControllerProvider);
    if (saveState.hasError) {
      showSeniorToast(
        context,
        title: 'Erro ao guardar',
        message: 'Não foi possível guardar as preferências. Tente novamente.',
        variant: SeniorToastVariant.danger,
      );
    } else {
      showSeniorToast(
        context,
        title: 'Preferências guardadas',
        message: 'As suas configurações de notificação foram atualizadas.',
        variant: SeniorToastVariant.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(preferencesProvider);
    final saveState = ref.watch(notificationPreferencesControllerProvider);
    final isSaving = saveState is AsyncLoading;

    prefsAsync.whenData((prefs) {
      if (_draft == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => setState(() => _draft = prefs),
        );
      }
    });

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: SeniorScreenScaffold(
        title: 'Notificações',
        backIcon: Icons.chevron_left,
        onBack: () => Navigator.of(context).pop(),
        trailing: TourHelpButton(onPressed: startTour),
        body: prefsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (_) => _Body(
            current: _current,
            isSaving: isSaving,
            onUpdate: _update,
            onSave: _save,
            tourScope: _scope,
            tasksShowcaseKey: _tasksShowcaseKey,
            remindersShowcaseKey: _remindersShowcaseKey,
            saveShowcaseKey: _saveShowcaseKey,
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------

class _Body extends StatelessWidget {
  const _Body({
    required this.current,
    required this.isSaving,
    required this.onUpdate,
    required this.onSave,
    required this.tourScope,
    required this.tasksShowcaseKey,
    required this.remindersShowcaseKey,
    required this.saveShowcaseKey,
  });

  final UserPreferences current;
  final bool isSaving;
  final ValueChanged<UserPreferences> onUpdate;
  final VoidCallback onSave;
  final String tourScope;
  final GlobalKey tasksShowcaseKey;
  final GlobalKey remindersShowcaseKey;
  final GlobalKey saveShowcaseKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- Secção: Tarefas ----
          SeniorShowcase(
            showcaseKey: tasksShowcaseKey,
            scope: tourScope,
            title: 'Notificações de tarefas',
            description:
                'Ative para receber avisos antes das suas tarefas e escolha com quanto tempo de antecedência quer ser avisado.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tarefas',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      PreferenceToggleTile(
                        emoji: '📋',
                        label: 'Avisar antes de tarefas',
                        value: current.tasksNotificationsEnabled,
                        onChanged: (v) => onUpdate(
                          current.copyWith(tasksNotificationsEnabled: v),
                        ),
                        showDivider: false,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                NotificationOffsetCard(
                  title: 'Antecedência do aviso',
                  subtitle: 'Quanto tempo antes da tarefa quero ser avisado',
                  value: current.taskNotificationOffset,
                  enabled: current.tasksNotificationsEnabled,
                  onChanged: (v) =>
                      onUpdate(current.copyWith(taskNotificationOffset: v)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ---- Secção: Lembretes ----
          SeniorShowcase(
            showcaseKey: remindersShowcaseKey,
            scope: tourScope,
            title: 'Notificações de lembretes',
            description:
                'Ative para receber avisos antes dos seus lembretes e escolha com quanto tempo de antecedência quer ser avisado.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Lembretes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      PreferenceToggleTile(
                        emoji: '🔔',
                        label: 'Avisar antes de lembretes',
                        value: current.remindersNotificationsEnabled,
                        onChanged: (v) => onUpdate(
                          current.copyWith(remindersNotificationsEnabled: v),
                        ),
                        showDivider: false,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                NotificationOffsetCard(
                  title: 'Antecedência do aviso',
                  subtitle: 'Quanto tempo antes do lembrete quero ser avisado',
                  value: current.reminderNotificationOffset,
                  enabled: current.remindersNotificationsEnabled,
                  onChanged: (v) =>
                      onUpdate(current.copyWith(reminderNotificationOffset: v)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ---- Botão Salvar ----
          SeniorShowcase(
            showcaseKey: saveShowcaseKey,
            scope: tourScope,
            title: 'Guardar as preferências',
            description:
                'Toque aqui para guardar as suas escolhas. As notificações serão ajustadas de imediato.',
            child: SeniorButton(
              label: 'Guardar configurações',
              icon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: onSave,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
