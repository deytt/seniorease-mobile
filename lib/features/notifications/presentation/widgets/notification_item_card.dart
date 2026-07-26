import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';

/// Card de um aviso do histórico de notificações push.
///
/// Mostra ícone diferenciado por [entityType], título, corpo e data/hora
/// formatada. Área clicável ≥ 44×44px.
/// Quando [isUnread] é `true`, exibe indicador visual de não lido
/// (borda colorida + ponto azul), espelhando o `NotificationCard` do Web.
class NotificationItemCard extends StatelessWidget {
  const NotificationItemCard({
    required this.item,
    required this.onTap,
    this.isUnread = false,
    super.key,
  });

  final NotificationItem item;
  final VoidCallback onTap;

  /// Indica se esta notificação ainda não foi vista pelo utilizador.
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        isUnread ? AppColors.primary.withValues(alpha: 0.4) : theme.colorScheme.outline;
    final backgroundColor = isUnread
        ? AppColors.primary.withValues(alpha: 0.05)
        : theme.colorScheme.surface;

    return Semantics(
      button: true,
      label: '${isUnread ? 'Não lida. ' : ''}${item.title}. ${item.body}. ${_formattedDate(item.sentAt)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          child: Ink(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EntityIcon(entityType: item.entityType),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.body,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _formattedDate(item.sentAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (isUnread)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _formattedDate(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;

    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final time = '$hour:$min';

    if (isToday) return 'Hoje às $time';
    if (isYesterday) return 'Ontem às $time';

    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    return '$day/$month às $time';
  }
}

// ------------------------------------------------------------------

class _EntityIcon extends StatelessWidget {
  const _EntityIcon({required this.entityType});

  final NotificationEntityType entityType;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (entityType) {
      NotificationEntityType.task => (
          Icons.check_circle_outline,
          AppColors.primary,
        ),
      NotificationEntityType.reminder => (
          Icons.alarm_outlined,
          AppColors.secondary,
        ),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
