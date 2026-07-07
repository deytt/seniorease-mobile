import 'package:mobile/features/notifications/domain/entities/notification_item.dart';

/// Contrato para leitura do histórico de notificações push do utilizador.
///
/// Os documentos vivem em `notifications/{id}` no Firestore e são escritos
/// exclusivamente pela Cloud Function `sendDueNotifications`.
abstract interface class NotificationHistoryRepository {
  /// Devolve um stream dos últimos [limit] avisos enviados ao [userId],
  /// ordenados por `sentAt` descendente.
  Stream<List<NotificationItem>> watchByUser(
    String userId, {
    int limit = 50,
  });
}
