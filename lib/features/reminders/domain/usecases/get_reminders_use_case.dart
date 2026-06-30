import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class GetRemindersUseCase {
  const GetRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  Stream<List<Reminder>> call(String userId) =>
      _repository.watchReminders(userId);
}
