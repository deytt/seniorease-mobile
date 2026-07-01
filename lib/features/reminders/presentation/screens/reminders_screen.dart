import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_dismissible_card.dart';

/// Lista de lembretes (Figma `15:7912`).
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(filteredRemindersStreamProvider);
    final activeFilter = ref.watch(reminderListFilterProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(
              activeFilter: activeFilter,
              onCreate: () => context.push(AppRoutes.createReminder),
              onFilterSelected: (filter) {
                HapticFeedback.selectionClick();
                ref.read(openReminderSwipeIdProvider.notifier).close();
                ref.read(reminderListFilterProvider.notifier).select(filter);
              },
            ),
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
                      ? const _EmptyState()
                      : _ReminderList(reminders: reminders),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.activeFilter,
    required this.onCreate,
    required this.onFilterSelected,
  });

  final ReminderListFilter activeFilter;
  final VoidCallback onCreate;
  final ValueChanged<ReminderListFilter> onFilterSelected;

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
              AppSpacing.md + 4,
              MediaQuery.paddingOf(context).top + 16,
              AppSpacing.md + 4,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Lembretes',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Novo lembrete',
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onCreate();
                      },
                      borderRadius:
                          BorderRadius.circular(AppTheme.borderRadius),
                      child: const SizedBox(
                        width: AppTheme.minTouchTarget,
                        height: AppTheme.minTouchTarget,
                        child: Icon(Icons.add, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md + 4,
              0,
              AppSpacing.md + 4,
              13,
            ),
            child: Row(
              children: [
                for (final filter in ReminderListFilter.values) ...[
                  _FilterChip(
                    label: filter.label,
                    selected: activeFilter == filter,
                    onTap: () => onFilterSelected(filter),
                  ),
                  if (filter != ReminderListFilter.values.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.slate200),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? AppColors.primary : AppColors.slate50,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          // Área de toque mínima de 48px (WCAG / persona idosa).
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: AppTheme.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.slate500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReminderList extends ConsumerWidget {
  const _ReminderList({required this.reminders});

  final List<Reminder> reminders;

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
        return ReminderDismissibleCard(
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
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
                    Icons.notifications_none_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Sem lembretes por agora',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Toque no botão "+" para criar seu primeiro lembrete.',
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
