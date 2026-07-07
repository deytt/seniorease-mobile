import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';

void main() {
  final sentAt = DateTime(2026, 7, 6, 14, 30);

  NotificationItem _item({
    String id = 'n1',
    NotificationEntityType type = NotificationEntityType.task,
  }) =>
      NotificationItem(
        id: id,
        userId: 'u1',
        entityId: 'e1',
        entityType: type,
        title: 'Tarefa em 30 minutos',
        body: 'Lavar o carro',
        sentAt: sentAt,
      );

  group('NotificationEntityType.fromString', () {
    test('devolve task para "task"', () {
      expect(
        NotificationEntityType.fromString('task'),
        NotificationEntityType.task,
      );
    });

    test('devolve reminder para "reminder"', () {
      expect(
        NotificationEntityType.fromString('reminder'),
        NotificationEntityType.reminder,
      );
    });

    test('devolve task como fallback para valor desconhecido', () {
      expect(
        NotificationEntityType.fromString('unknown'),
        NotificationEntityType.task,
      );
    });

    test('storageValue devolve o name do enum', () {
      expect(NotificationEntityType.task.storageValue, 'task');
      expect(NotificationEntityType.reminder.storageValue, 'reminder');
    });
  });

  group('NotificationItem', () {
    test('igualdade baseia-se apenas no id', () {
      final a = _item(id: 'n1');
      final b = NotificationItem(
        id: 'n1',
        userId: 'outro',
        entityId: 'outro',
        entityType: NotificationEntityType.reminder,
        title: 'Outro',
        body: 'Outro',
        sentAt: DateTime(2025),
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('itens com ids diferentes não são iguais', () {
      expect(_item(id: 'n1'), isNot(equals(_item(id: 'n2'))));
    });

    test('campos são preservados correctamente', () {
      final item = _item();
      expect(item.id, 'n1');
      expect(item.userId, 'u1');
      expect(item.entityId, 'e1');
      expect(item.entityType, NotificationEntityType.task);
      expect(item.title, 'Tarefa em 30 minutos');
      expect(item.body, 'Lavar o carro');
      expect(item.sentAt, sentAt);
    });
  });
}
