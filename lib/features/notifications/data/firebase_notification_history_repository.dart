import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';

/// Implementação Firebase de [NotificationHistoryRepository].
///
/// Lê a collection `notifications` onde `userId == uid`,
/// ordenada por `sentAt` descendente, com limite configurável.
/// A escrita é exclusiva da Cloud Function — o cliente só lê.
class FirebaseNotificationHistoryRepository
    implements NotificationHistoryRepository {
  FirebaseNotificationHistoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<NotificationItem>> watchByUser(
    String userId, {
    int limit = 50,
  }) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs.map(_fromDoc).toList(),
        );
  }

  NotificationItem _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final sentAtRaw = data['sentAt'];
    final sentAt = sentAtRaw is Timestamp
        ? sentAtRaw.toDate()
        : DateTime.now();

    return NotificationItem(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      entityId: data['entityId'] as String? ?? '',
      entityType: NotificationEntityType.fromString(
        data['entityType'] as String? ?? 'task',
      ),
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      sentAt: sentAt,
    );
  }
}
