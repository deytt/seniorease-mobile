import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class FirebaseReminderRepository implements ReminderRepository {
  FirebaseReminderRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reminders =>
      _firestore.collection('reminders');

  @override
  Stream<List<Reminder>> watchReminders(String userId) =>
      watchRemindersFiltered(userId, ReminderListFilter.today);

  @override
  Stream<List<Reminder>> watchRemindersFiltered(
    String userId,
    ReminderListFilter filter,
  ) {
    Query<Map<String, dynamic>> query =
        _reminders.where('userId', isEqualTo: userId);

    final category = filter.category;
    if (category != null) {
      query = query.where('category', isEqualTo: category.toFirestore());
    }

    // Filtro "Hoje" server-side (range em scheduledAt). Requer os composite
    // indexes de firestore.indexes.json publicados (ver firebaseSchema.md).
    if (filter.isToday) {
      final (start, end) = _todayRange();
      query = query
          .where('scheduledAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('scheduledAt', isLessThan: Timestamp.fromDate(end));
    }

    // Ordenação server-side por horário agendado.
    query = query.orderBy('scheduledAt');

    return query.snapshots().map(
          (snap) => snap.docs
              .map((doc) => Reminder.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  (DateTime start, DateTime end) _todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return (start, start.add(const Duration(days: 1)));
  }

  @override
  Future<String> createReminder(Reminder reminder) async {
    final ref = _reminders.doc();
    await ref.set(reminder.toMap());
    return ref.id;
  }

  @override
  Future<void> markAsRead(String reminderId, {required bool isRead}) async {
    await _reminders.doc(reminderId).update({'isRead': isRead});
  }

  @override
  Future<void> deleteReminder(String reminderId) async {
    await _reminders.doc(reminderId).delete();
  }
}
