import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_dismissible_card.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_filter_sheet.dart';

/// Lista de lembretes (Figma `15:7912`).
class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with TourHost<RemindersScreen> {
  static const String _scope = 'remindersList';

  final _createShowcaseKey = GlobalKey();
  final _filterShowcaseKey = GlobalKey();
  final _firstCardShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.remindersList;

  @override
  List<GlobalKey> get tourKeys =>
      [_createShowcaseKey, _filterShowcaseKey, _firstCardShowcaseKey];

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(filteredRemindersStreamProvider);
    final filter = ref.watch(reminderFilterProvider);

    // Contagens baseadas na lista sem filtro para o subtítulo do header.
    final allReminders =
        ref.watch(remindersStreamProvider).asData?.value ?? const [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(
              doneCount: allReminders.where((r) => r.isDone).length,
              totalCount: allReminders.length,
              activeFilterCount: filter.activeCount,
              scope: _scope,
              createShowcaseKey: _createShowcaseKey,
              filterShowcaseKey: _filterShowcaseKey,
              onHelp: startTour,
              onCreate: () => context.push(AppRoutes.createReminder),
              onOpenFilter: () => _openFilterSheet(context, filter),
            ),
            if (!filter.isEmpty) _ActiveFilterBar(filter: filter, ref: ref),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.read(openReminderSwipeIdProvider.notifier).close();
                  ref.invalidate(filteredRemindersStreamProvider);
                  ref.invalidate(remindersStreamProvider);
                  await ref.read(filteredRemindersStreamProvider.future);
                },
                child: remindersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const _ErrorState(),
                  data: (reminders) => reminders.isEmpty
                      ? _EmptyState(hasFilter: !filter.isEmpty)
                      : _ReminderList(
                          reminders: reminders,
                          scope: _scope,
                          firstCardShowcaseKey: _firstCardShowcaseKey,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context, ReminderFilter current) {
    HapticFeedback.lightImpact();
    ref.read(openReminderSwipeIdProvider.notifier).close();
    ReminderFilterSheet.show(
      context,
      initialFilter: current,
      onApply: (newFilter) {
        ref.read(reminderFilterProvider.notifier).update(newFilter);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.doneCount,
    required this.totalCount,
    required this.activeFilterCount,
    required this.scope,
    required this.createShowcaseKey,
    required this.filterShowcaseKey,
    required this.onHelp,
    required this.onCreate,
    required this.onOpenFilter,
  });

  final int doneCount;
  final int totalCount;
  final int activeFilterCount;
  final String scope;
  final GlobalKey createShowcaseKey;
  final GlobalKey filterShowcaseKey;
  final VoidCallback onHelp;
  final VoidCallback onCreate;
  final VoidCallback onOpenFilter;

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lembretes',
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        totalCount == 0
                            ? 'Nenhum lembrete ainda'
                            : '$doneCount de $totalCount concluídos',
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
                const SizedBox(width: AppSpacing.sm),
                SeniorShowcase(
                  showcaseKey: filterShowcaseKey,
                  scope: scope,
                  title: 'Filtre os seus lembretes',
                  description:
                      'Toque aqui para ver só os lembretes de hoje, ou de uma categoria.',
                  child: Semantics(
                    button: true,
                    label: activeFilterCount > 0
                        ? 'Filtros ($activeFilterCount ativos)'
                        : 'Filtrar lembretes',
                    child: _FilterButton(
                      activeCount: activeFilterCount,
                      onTap: onOpenFilter,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SeniorShowcase(
                  showcaseKey: createShowcaseKey,
                  scope: scope,
                  title: 'Criar um novo lembrete',
                  description:
                      'Toque no "+" sempre que quiser adicionar um novo lembrete.',
                  child: Semantics(
                    button: true,
                    label: 'Novo lembrete',
                    child: Material(
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onCreate();
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child:
                              Icon(Icons.add, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }
}

/// Botão de filtro com badge numérico quando há filtros activos.
class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.activeCount,
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActive = activeCount > 0;

    return Material(
      color: hasActive
          ? AppColors.primary
          : theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            border: hasActive
                ? null
                : Border.all(color: AppColors.slate200, width: 1),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 20,
                color: hasActive ? Colors.white : AppColors.slate500,
              ),
              if (hasActive)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Barra de filtros activos
// ---------------------------------------------------------------------------

class _ActiveFilterBar extends StatelessWidget {
  const _ActiveFilterBar({required this.filter, required this.ref});

  final ReminderFilter filter;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              8,
              AppSpacing.md,
              8,
            ),
            child: Row(
              children: [
                if (filter.isToday)
                  _ActiveChip(
                    label: 'Hoje',
                    onRemove: () {
                      ref.read(reminderFilterProvider.notifier).update(
                            filter.removeToday(),
                          );
                    },
                  ),
                if (filter.isToday && filter.category != null)
                  const SizedBox(width: 6),
                if (filter.category != null)
                  _ActiveChip(
                    label: filter.category!.label,
                    onRemove: () {
                      ref.read(reminderFilterProvider.notifier).update(
                            filter.removeCategory(),
                          );
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Filtro ativo: $label. Toque para remover.',
      button: true,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onRemove();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.close_rounded,
                size: 14,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lista de lembretes
// ---------------------------------------------------------------------------

class _ReminderList extends ConsumerWidget {
  const _ReminderList({
    required this.reminders,
    required this.scope,
    required this.firstCardShowcaseKey,
  });

  final List<Reminder> reminders;
  final String scope;
  final GlobalKey firstCardShowcaseKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(filteredRemindersStreamProvider, (previous, next) {
      final prevList = previous?.asData?.value;
      final nextList = next.asData?.value;
      if (prevList == null || nextList == null) return;

      final prevIds = prevList.map((r) => r.id).toSet();
      final nextIds = nextList.map((r) => r.id).toSet();
      if (prevIds != nextIds) {
        ref.read(openReminderSwipeIdProvider.notifier).close();
      }
    });

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final card = ReminderDismissibleCard(
          key: ValueKey(reminder.id),
          reminder: reminder,
          onMarkDone: () => ref
              .read(remindersControllerProvider.notifier)
              .markRead(reminder.id, isRead: true),
          onDelete: () async {
            ref.read(openReminderSwipeIdProvider.notifier).close();
            await ref
                .read(remindersControllerProvider.notifier)
                .delete(reminder.id);
          },
        );

        if (index != 0) return card;

        return SeniorShowcase(
          showcaseKey: firstCardShowcaseKey,
          scope: scope,
          title: 'Os seus lembretes',
          description:
              'Cada cartão é um lembrete. Deslize para a esquerda para apagar, ou toque em "Concluir".',
          child: card,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter});

  final bool hasFilter;

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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasFilter
                        ? Icons.filter_list_off_rounded
                        : Icons.notifications_none_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    hasFilter
                        ? 'Nenhum lembrete com estes filtros'
                        : 'Sem lembretes por agora',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    hasFilter
                        ? 'Tente remover ou alterar os filtros ativos.'
                        : 'Toque no botão "+" para criar seu primeiro lembrete.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
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
                'Não foi possível carregar os lembretes. Tente novamente.',
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
