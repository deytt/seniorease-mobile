import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class UpdateReminderUseCase {
  const UpdateReminderUseCase(this._repository);

  final ReminderRepository _repository;

  Future<void> call(Reminder reminder) => _repository.updateReminder(reminder);
}
