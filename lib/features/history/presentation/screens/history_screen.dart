import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/entities/history_stats.dart';
import 'package:mobile/features/history/presentation/providers/history_provider.dart';
import 'package:mobile/features/history/presentation/widgets/history_activity_card.dart';
import 'package:mobile/features/history/presentation/widgets/history_date_format.dart';
import 'package:mobile/features/history/presentation/widgets/history_day_section.dart';
import 'package:mobile/features/history/presentation/widgets/history_empty_state.dart';
import 'package:mobile/features/history/presentation/widgets/history_stat_card.dart';
import 'package:mobile/features/history/presentation/widgets/streak_banner.dart';

/// Tela de Histórico de Atividades (Figma `15:8316`).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with TourHost<HistoryScreen> {
  static const String _scope = 'history';

  /// Tipos ocultados no Modo Básico (baixa relevância para o utilizador).
  static const Set<HistoryActionType> _hiddenInBasic = {
    HistoryActionType.reminderEdited,
    HistoryActionType.taskDeleted,
    HistoryActionType.reminderDeleted,
    HistoryActionType.accessibilityChanged,
    HistoryActionType.profileUpdated,
  };

  final _statsShowcaseKey = GlobalKey();
  final _streakShowcaseKey = GlobalKey();
  final _activityShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.history;

  @override
  List<GlobalKey> get tourKeys =>
      [_statsShowcaseKey, _streakShowcaseKey, _activityShowcaseKey];

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(historyStreamProvider);
    final stats = ref.watch(historyStatsProvider).asData?.value ??
        HistoryStats.empty;
    final isBasic = ref.watch(preferencesProvider).asData?.value.interfaceMode ==
        InterfaceMode.basic;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(onHelp: startTour),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _onRefresh,
                child: eventsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const _ErrorState(),
                  data: (allEvents) => allEvents.isEmpty
                      ? _EmptyScroll(
                          onCreateTask: () => context.go(AppRoutes.tasks),
                        )
                      : _Content(
                          events: _applyBasicFilter(allEvents, isBasic),
                          stats: stats,
                          statsShowcaseKey: _statsShowcaseKey,
                          streakShowcaseKey: _streakShowcaseKey,
                          activityShowcaseKey: _activityShowcaseKey,
                          scope: _scope,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HistoryEvent> _applyBasicFilter(
    List<HistoryEvent> events,
    bool isBasic,
  ) {
    if (!isBasic) return events;
    return events.where((e) => !_hiddenInBasic.contains(e.type)).toList();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(historyStreamProvider);
    ref.invalidate(historyStatsProvider);
    await ref
        .read(historyStreamProvider.future)
        .catchError((_) => <HistoryEvent>[]);
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onHelp});

  final VoidCallback onHelp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              MediaQuery.paddingOf(context).top + 12,
              AppSpacing.md,
              13,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Histórico de Atividades',
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Está a ir muito bem!',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TourHelpButton(onPressed: onHelp),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Conteúdo (stats + banner + atividade)
// ---------------------------------------------------------------------------

class _Content extends StatelessWidget {
  const _Content({
    required this.events,
    required this.stats,
    required this.statsShowcaseKey,
    required this.streakShowcaseKey,
    required this.activityShowcaseKey,
    required this.scope,
  });

  final List<HistoryEvent> events;
  final HistoryStats stats;
  final GlobalKey statsShowcaseKey;
  final GlobalKey streakShowcaseKey;
  final GlobalKey activityShowcaseKey;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showStreak = stats.currentStreak >= StreakBanner.minStreakToShow;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        SeniorShowcase(
          showcaseKey: statsShowcaseKey,
          scope: scope,
          title: 'As suas conquistas',
          description:
              'Aqui vê quantas atividades concluiu esta semana e há quantos dias seguidos está ativo.',
          child: Row(
            children: [
              Expanded(
                child: HistoryStatCard(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.primary,
                  value: _plural(stats.weeklyCount, 'tarefa', 'tarefas'),
                  label: 'Esta semana',
                  semanticLabel:
                      '${stats.weeklyCount} atividades concluídas esta semana.',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: HistoryStatCard(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: AppColors.warning,
                  value: _plural(stats.currentStreak, 'dia', 'dias'),
                  label: 'Sequência',
                  semanticLabel:
                      'Sequência atual de ${stats.currentStreak} dias.',
                ),
              ),
            ],
          ),
        ),
        if (showStreak) ...[
          const SizedBox(height: AppSpacing.md),
          SeniorShowcase(
            showcaseKey: streakShowcaseKey,
            scope: scope,
            title: 'A sua sequência',
            description:
                'Complete pelo menos uma atividade por dia para manter a sua sequência a crescer.',
            child: StreakBanner(streak: stats.currentStreak),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        SeniorShowcase(
          showcaseKey: activityShowcaseKey,
          scope: scope,
          title: 'Atividade recente',
          description:
              'Esta é a lista das coisas que fez, das mais recentes para as mais antigas.',
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Atividade Recente',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (events.isEmpty)
          _BasicEmptyNote()
        else
          ..._buildGroupedActivity(context, events),
      ],
    );
  }

  List<Widget> _buildGroupedActivity(
    BuildContext context,
    List<HistoryEvent> events,
  ) {
    final now = DateTime.now();
    final widgets = <Widget>[];
    String? currentLabel;

    for (final event in events) {
      final label = historyDayLabel(event.occurredAt, now);
      if (label != currentLabel) {
        currentLabel = label;
        widgets.add(HistoryDaySection(label: label));
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: HistoryActivityCard(event: event),
        ),
      );
    }
    return widgets;
  }

  /// "1 dia" vs "3 dias".
  static String _plural(int count, String singular, String plural) =>
      '$count ${count == 1 ? singular : plural}';
}

/// Nota exibida quando o Modo Básico esconde todos os eventos disponíveis.
class _BasicEmptyNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        'As suas atividades mais importantes aparecerão aqui.',
        style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.slate500),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados
// ---------------------------------------------------------------------------

class _EmptyScroll extends StatelessWidget {
  const _EmptyScroll({required this.onCreateTask});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.6,
          child: HistoryEmptyState(onCreateTask: onCreateTask),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.45,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Não foi possível carregar o histórico. Tente novamente.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
