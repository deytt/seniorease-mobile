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
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_history_provider.dart';
import 'package:mobile/features/notifications/presentation/widgets/notification_item_card.dart';

/// Tela de histórico de notificações push.
///
/// Exibe os avisos enviados pela Cloud Function `sendDueNotifications`
/// registados em `notifications/{id}`. Inclui tour guiado próprio.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with TourHost<NotificationsScreen> {
  static const String _scope = 'notifications';

  final _headerShowcaseKey = GlobalKey();
  final _listShowcaseKey = GlobalKey();
  final _cardShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.notifications;

  @override
  List<GlobalKey> get tourKeys =>
      [_headerShowcaseKey, _listShowcaseKey, _cardShowcaseKey];

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationHistoryProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _Header(
              headerShowcaseKey: _headerShowcaseKey,
              scope: _scope,
              onHelp: startTour,
              tourId: tourId,
            ),
            Expanded(
              child: notificationsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (_, _) => const _ErrorState(),
                data: (items) => items.isEmpty
                    ? _EmptyState(listShowcaseKey: _listShowcaseKey, scope: _scope)
                    : _NotificationList(
                        items: items,
                        scope: _scope,
                        listShowcaseKey: _listShowcaseKey,
                        cardShowcaseKey: _cardShowcaseKey,
                        onTap: (item) => _navigate(item),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(NotificationItem item) {
    switch (item.entityType) {
      case NotificationEntityType.task:
        context.push(AppRoutes.taskDetails(item.entityId));
      case NotificationEntityType.reminder:
        context.go(AppRoutes.reminders);
    }
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({
    required this.headerShowcaseKey,
    required this.scope,
    required this.onHelp,
    this.tourId,
  });

  final GlobalKey headerShowcaseKey;
  final String scope;
  final VoidCallback onHelp;
  final TourId? tourId;

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
                // Botão voltar
                Semantics(
                  button: true,
                  label: 'Voltar',
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: theme.colorScheme.outline),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SeniorShowcase(
                    showcaseKey: headerShowcaseKey,
                    scope: scope,
                    title: 'Histórico de avisos',
                    description:
                        'Aqui aparecem todos os avisos enviados para si — das suas tarefas e lembretes.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notificações',
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Avisos das suas tarefas e lembretes',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.slate500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                TourHelpButton(onPressed: onHelp, tourId: tourId),
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
// Lista
// ---------------------------------------------------------------------------

class _NotificationList extends StatelessWidget {
  const _NotificationList({
    required this.items,
    required this.scope,
    required this.listShowcaseKey,
    required this.cardShowcaseKey,
    required this.onTap,
  });

  final List<NotificationItem> items;
  final String scope;
  final GlobalKey listShowcaseKey;
  final GlobalKey cardShowcaseKey;
  final ValueChanged<NotificationItem> onTap;

  @override
  Widget build(BuildContext context) {
    return SeniorShowcase(
      showcaseKey: listShowcaseKey,
      scope: scope,
      title: 'Os seus avisos',
      description:
          'Cada cartão mostra a tarefa ou lembrete que gerou o aviso. Toque para abrir.',
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = items[index];
          final card = NotificationItemCard(
            key: ValueKey(item.id),
            item: item,
            onTap: () => onTap(item),
          );

          if (index != 0) return card;

          return SeniorShowcase(
            showcaseKey: cardShowcaseKey,
            scope: scope,
            title: 'Um aviso',
            description:
                'Toque no cartão para ir diretamente à tarefa ou lembrete que gerou este aviso.',
            child: card,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Estados
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.listShowcaseKey,
    required this.scope,
  });

  final GlobalKey listShowcaseKey;
  final String scope;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.50,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SeniorShowcase(
                showcaseKey: listShowcaseKey,
                scope: scope,
                title: 'Sempre atualizado',
                description:
                    'Quando uma nova notificação chegar, ela aparecerá aqui automaticamente.',
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Sem avisos por agora',
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Os avisos das suas tarefas e lembretes aparecerão aqui quando forem enviados.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
          height: MediaQuery.sizeOf(context).height * 0.50,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Não foi possível carregar as notificações. Tente novamente.',
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
