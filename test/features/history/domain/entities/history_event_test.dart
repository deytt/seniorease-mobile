import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';

void main() {
  HistoryEvent buildEvent() => HistoryEvent(
        id: 'h1',
        userId: 'u1',
        type: HistoryActionType.taskCompleted,
        title: 'Concluiu: Tomar remédio',
        entityId: 't1',
        category: 'medication',
        occurredAt: DateTime(2026, 6, 30, 8, 5),
      );

  group('HistoryEvent.isCompletion', () {
    test('true para conclusões, false para o resto', () {
      expect(buildEvent().isCompletion, isTrue);
      expect(
        buildEvent()
            .toMap()
            .containsKey('type'),
        isTrue,
      );
      final created = HistoryEvent(
        id: 'h2',
        userId: 'u1',
        type: HistoryActionType.taskCreated,
        title: 'Criou',
        occurredAt: DateTime(2026, 6, 30),
      );
      expect(created.isCompletion, isFalse);
    });
  });

  group('HistoryEvent.toMap', () {
    test('serializa tipo como string e data como Timestamp; sem id', () {
      final map = buildEvent().toMap();

      expect(map['userId'], 'u1');
      expect(map['type'], 'taskCompleted');
      expect(map['title'], 'Concluiu: Tomar remédio');
      expect(map['entityId'], 't1');
      expect(map['category'], 'medication');
      expect(map['occurredAt'], isA<Timestamp>());
      expect(
        (map['occurredAt'] as Timestamp).toDate(),
        DateTime(2026, 6, 30, 8, 5),
      );
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('HistoryEvent.fromMap', () {
    test('desserializa um documento completo', () {
      final event = HistoryEvent.fromMap('h9', {
        'userId': 'u2',
        'type': 'reminderCompleted',
        'title': 'Concluiu o lembrete: Água',
        'entityId': 'r2',
        'category': 'hydration',
        'occurredAt': Timestamp.fromDate(DateTime(2026, 7, 1, 14)),
      });

      expect(event.id, 'h9');
      expect(event.userId, 'u2');
      expect(event.type, HistoryActionType.reminderCompleted);
      expect(event.title, 'Concluiu o lembrete: Água');
      expect(event.entityId, 'r2');
      expect(event.category, 'hydration');
      expect(event.occurredAt, DateTime(2026, 7, 1, 14));
    });

    test('aplica defaults defensivos quando faltam campos', () {
      final event = HistoryEvent.fromMap('h0', <String, dynamic>{});

      expect(event.id, 'h0');
      expect(event.userId, '');
      // Tipo desconhecido cai no fallback (taskCreated).
      expect(event.type, HistoryActionType.taskCreated);
      expect(event.title, '');
      expect(event.entityId, isNull);
      expect(event.category, isNull);
      expect(event.occurredAt, isA<DateTime>());
    });
  });

  group('HistoryActionType.fromString', () {
    test('mapeia valores conhecidos e faz fallback seguro', () {
      expect(
        HistoryActionType.fromString('accountVerified'),
        HistoryActionType.accountVerified,
      );
      expect(
        HistoryActionType.fromString('valor_invalido'),
        HistoryActionType.taskCreated,
      );
    });
  });
}
