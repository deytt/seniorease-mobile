import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';

abstract interface class ReminderRepository {
  Stream<List<Reminder>> watchReminders(String userId);

  Stream<List<Reminder>> watchRemindersFiltered(
    String userId,
    ReminderFilter filter,
  );

  Future<String> createReminder(Reminder reminder);

  Future<void> markAsRead(String reminderId, {required bool isRead});

  Future<void> deleteReminder(String reminderId);
}
