import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';

/// Expõe o stream de histórico de notificações para a camada de apresentação.
class WatchNotificationHistoryUseCase {
  const WatchNotificationHistoryUseCase(this._repository);

  final NotificationHistoryRepository _repository;

  Stream<List<NotificationItem>> call(String userId, {int limit = 50}) =>
      _repository.watchByUser(userId, limit: limit);
}
