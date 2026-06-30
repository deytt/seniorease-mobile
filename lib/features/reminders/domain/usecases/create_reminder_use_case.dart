import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class CreateReminderUseCase {
  const CreateReminderUseCase(this._repository);

  final ReminderRepository _repository;

  Future<String> call(Reminder reminder) => _repository.createReminder(reminder);
}
