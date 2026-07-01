import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class GetFilteredRemindersUseCase {
  const GetFilteredRemindersUseCase(this._repository);

  final ReminderRepository _repository;

  Stream<List<Reminder>> call(String userId, ReminderFilter filter) =>
      _repository.watchRemindersFiltered(userId, filter);
}
