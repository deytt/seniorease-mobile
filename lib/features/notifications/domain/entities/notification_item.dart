/// Tipos de entidade que podem originar uma notificação push.
enum NotificationEntityType {
  task,
  reminder;

  static NotificationEntityType fromString(String value) =>
      switch (value) {
        'task' => task,
        'reminder' => reminder,
        _ => task,
      };

  String get storageValue => name;
}

/// Registo de uma notificação push enviada ao utilizador.
///
/// Espelha o documento `notifications/{id}` no Firestore.
/// Criado exclusivamente pela Cloud Function `sendDueNotifications`.
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.userId,
    required this.entityId,
    required this.entityType,
    required this.title,
    required this.body,
    required this.sentAt,
  });

  final String id;
  final String userId;
  final String entityId;
  final NotificationEntityType entityType;
  final String title;
  final String body;
  final DateTime sentAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NotificationItem && id == other.id);

  @override
  int get hashCode => id.hashCode;
}
