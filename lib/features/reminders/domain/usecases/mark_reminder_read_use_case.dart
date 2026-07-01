import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';

class MarkReminderReadUseCase {
  const MarkReminderReadUseCase(this._repository);

  final ReminderRepository _repository;

  Future<void> call(String reminderId, {required bool isRead}) =>
      _repository.markAsRead(reminderId, isRead: isRead);
}
