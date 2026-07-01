import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/data/firebase_reminder_repository.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseReminderRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseReminderRepository(firestore: db);
  });

  Future<void> seedReminder(
    String id, {
    String userId = 'u1',
    String category = 'medication',
    DateTime? scheduledAt,
    bool isRead = false,
  }) {
    final at = scheduledAt ?? DateTime(2026, 6, 30, 8);
    return db.collection('reminders').doc(id).set({
      'userId': userId,
      'title': 'Lembrete $id',
      'message': 'Detalhe',
      'category': category,
      'scheduledAt': Timestamp.fromDate(at),
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(DateTime(2026, 6, 1)),
    });
  }

  test('watchRemindersFiltered hoje devolve apenas lembretes do dia', () async {
    // Data relativa ao dia atual — o repositório usa DateTime.now() no range.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    await seedReminder('r1', scheduledAt: today);
    await seedReminder('r2', scheduledAt: today.add(const Duration(days: 1)));
    await seedReminder(
      'r0',
      scheduledAt: today.subtract(const Duration(days: 1)),
    );

    final items = await repo
        .watchRemindersFiltered('u1', const ReminderFilter(isToday: true))
        .first;

    expect(items.length, 1);
    expect(items.first.id, 'r1');
  });

  test('watchRemindersFiltered devolve os lembretes ordenados por scheduledAt',
      () async {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, 6);
    await seedReminder('late', scheduledAt: base.add(const Duration(hours: 4)));
    await seedReminder('early', scheduledAt: base);
    await seedReminder('mid', scheduledAt: base.add(const Duration(hours: 2)));

    final items =
        await repo.watchRemindersFiltered('u1', ReminderFilter.empty).first;

    expect(items.map((r) => r.id).toList(), ['early', 'mid', 'late']);
  });

  test('watchRemindersFiltered medicação filtra por categoria', () async {
    final today = DateTime(2026, 6, 30, 10);
    await seedReminder('r1', category: 'medication', scheduledAt: today);
    await seedReminder(
      'r2',
      category: 'appointment',
      scheduledAt: today,
    );

    final items = await repo
        .watchRemindersFiltered(
          'u1',
          const ReminderFilter(category: ReminderCategory.medication),
        )
        .first;

    expect(items.length, 1);
    expect(items.first.id, 'r1');
  });

  test('watchRemindersFiltered combina categoria + hoje', () async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    // Medicação hoje → incluído.
    await seedReminder('r1', category: 'medication', scheduledAt: today);
    // Medicação amanhã → excluído (fora do range de hoje).
    await seedReminder(
      'r2',
      category: 'medication',
      scheduledAt: today.add(const Duration(days: 1)),
    );
    // Consulta hoje → excluído (categoria diferente).
    await seedReminder('r3', category: 'appointment', scheduledAt: today);

    final items = await repo
        .watchRemindersFiltered(
          'u1',
          const ReminderFilter(
            category: ReminderCategory.medication,
            isToday: true,
          ),
        )
        .first;

    expect(items.map((r) => r.id).toList(), ['r1']);
  });

  test('createReminder e markAsRead', () async {
    final reminder = Reminder(
      id: '',
      userId: 'u1',
      title: 'Medicação',
      message: 'Tomar com água',
      category: ReminderCategory.medication,
      scheduledAt: DateTime(2026, 6, 30, 12),
      isRead: false,
      createdAt: DateTime(2026, 6, 1),
    );

    final id = await repo.createReminder(reminder);
    await repo.markAsRead(id, isRead: true);

    final doc = await db.collection('reminders').doc(id).get();
    expect(doc.data()?['isRead'], isTrue);
    expect(doc.data()?['title'], 'Medicação');
  });
}
