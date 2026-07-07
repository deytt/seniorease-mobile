import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/firebase_notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseNotificationHistoryRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseNotificationHistoryRepository(firestore: db);
  });

  Future<void> seedNotification(
    String id, {
    String userId = 'u1',
    String entityType = 'task',
    DateTime? sentAt,
  }) {
    final at = sentAt ?? DateTime(2026, 7, 6, 14);
    return db.collection('notifications').doc(id).set({
      'userId': userId,
      'entityId': 'e1',
      'entityType': entityType,
      'title': 'Título $id',
      'body': 'Corpo $id',
      'sentAt': Timestamp.fromDate(at),
    });
  }

  group('watchByUser', () {
    test('devolve apenas notificações do userId dado', () async {
      await seedNotification('n1', userId: 'u1');
      await seedNotification('n2', userId: 'u2');

      final items = await repo.watchByUser('u1').first;

      expect(items.length, 1);
      expect(items.first.id, 'n1');
      expect(items.first.userId, 'u1');
    });

    test('mapeia entityType task correctamente', () async {
      await seedNotification('n1', entityType: 'task');

      final items = await repo.watchByUser('u1').first;

      expect(items.first.entityType, NotificationEntityType.task);
    });

    test('mapeia entityType reminder correctamente', () async {
      await seedNotification('n1', entityType: 'reminder');

      final items = await repo.watchByUser('u1').first;

      expect(items.first.entityType, NotificationEntityType.reminder);
    });

    test('usa task como fallback para entityType desconhecido', () async {
      await seedNotification('n1', entityType: 'outro');

      final items = await repo.watchByUser('u1').first;

      expect(items.first.entityType, NotificationEntityType.task);
    });

    test('devolve lista vazia quando não existem notificações', () async {
      final items = await repo.watchByUser('u1').first;

      expect(items, isEmpty);
    });

    test('respeita o limit', () async {
      for (var i = 1; i <= 5; i++) {
        await seedNotification('n$i',
            sentAt: DateTime(2026, 7, 6, i));
      }

      final items = await repo.watchByUser('u1', limit: 3).first;

      expect(items.length, 3);
    });

    test('fields são mapeados correctamente', () async {
      final at = DateTime(2026, 7, 6, 14, 30);
      await db.collection('notifications').doc('n1').set({
        'userId': 'u1',
        'entityId': 'task_99',
        'entityType': 'task',
        'title': 'Consulta em 30 min',
        'body': 'Não se esqueça da sua consulta.',
        'sentAt': Timestamp.fromDate(at),
      });

      final item = (await repo.watchByUser('u1').first).first;

      expect(item.id, 'n1');
      expect(item.userId, 'u1');
      expect(item.entityId, 'task_99');
      expect(item.title, 'Consulta em 30 min');
      expect(item.body, 'Não se esqueça da sua consulta.');
      expect(item.sentAt, at);
    });
  });
}
