import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

void main() {
  Reminder buildReminder() => Reminder(
        id: 'r1',
        userId: 'u1',
        taskId: 't1',
        title: 'Tomar remédio',
        message: 'Com água',
        category: ReminderCategory.medication,
        scheduledAt: DateTime(2026, 6, 30, 8, 30),
        isRead: false,
        createdAt: DateTime(2026, 6, 1),
      );

  group('Reminder.isDone', () {
    test('reflete o valor de isRead', () {
      expect(buildReminder().copyWith(isRead: true).isDone, isTrue);
      expect(buildReminder().copyWith(isRead: false).isDone, isFalse);
    });
  });

  group('Reminder.copyWith', () {
    test('substitui apenas os campos indicados', () {
      final original = buildReminder();
      final updated = original.copyWith(
        title: 'Novo título',
        isRead: true,
        category: ReminderCategory.appointment,
      );

      expect(updated.title, 'Novo título');
      expect(updated.isRead, isTrue);
      expect(updated.category, ReminderCategory.appointment);
      // Campos não indicados permanecem.
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
      expect(updated.taskId, original.taskId);
      expect(updated.message, original.message);
      expect(updated.scheduledAt, original.scheduledAt);
      expect(updated.createdAt, original.createdAt);
    });
  });

  group('Reminder.toMap', () {
    test('serializa datas como Timestamp e categoria como string', () {
      final map = buildReminder().toMap();

      expect(map['userId'], 'u1');
      expect(map['taskId'], 't1');
      expect(map['title'], 'Tomar remédio');
      expect(map['message'], 'Com água');
      expect(map['category'], 'medication');
      expect(map['isRead'], isFalse);
      expect(map['scheduledAt'], isA<Timestamp>());
      expect(
        (map['scheduledAt'] as Timestamp).toDate(),
        DateTime(2026, 6, 30, 8, 30),
      );
      expect(map['createdAt'], isA<Timestamp>());
      // O id não é persistido no mapa (vem do docId).
      expect(map.containsKey('id'), isFalse);
    });
  });

  group('Reminder.fromMap', () {
    test('desserializa um documento completo', () {
      final reminder = Reminder.fromMap('r9', {
        'userId': 'u2',
        'taskId': 't2',
        'title': 'Consulta',
        'message': 'Dr. Silva',
        'category': 'appointment',
        'scheduledAt': Timestamp.fromDate(DateTime(2026, 7, 1, 14)),
        'isRead': true,
        'createdAt': Timestamp.fromDate(DateTime(2026, 6, 20)),
      });

      expect(reminder.id, 'r9');
      expect(reminder.userId, 'u2');
      expect(reminder.taskId, 't2');
      expect(reminder.title, 'Consulta');
      expect(reminder.message, 'Dr. Silva');
      expect(reminder.category, ReminderCategory.appointment);
      expect(reminder.scheduledAt, DateTime(2026, 7, 1, 14));
      expect(reminder.isRead, isTrue);
      expect(reminder.createdAt, DateTime(2026, 6, 20));
    });

    test('aplica defaults defensivos quando campos faltam ou são nulos', () {
      final reminder = Reminder.fromMap('r0', <String, dynamic>{});

      expect(reminder.id, 'r0');
      expect(reminder.userId, '');
      expect(reminder.taskId, isNull);
      expect(reminder.title, '');
      expect(reminder.message, '');
      // Categoria desconhecida cai no fallback general.
      expect(reminder.category, ReminderCategory.general);
      expect(reminder.isRead, isFalse);
      expect(reminder.scheduledAt, isA<DateTime>());
      expect(reminder.createdAt, isA<DateTime>());
    });
  });
}
