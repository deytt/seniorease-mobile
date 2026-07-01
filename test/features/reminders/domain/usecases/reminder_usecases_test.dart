import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:mobile/features/reminders/domain/usecases/create_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/delete_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/get_filtered_reminders_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/get_reminders_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/mark_reminder_read_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/update_reminder_use_case.dart';

class MockReminderRepository extends Mock implements ReminderRepository {}

void main() {
  late MockReminderRepository repo;

  final reminder = Reminder(
    id: 'r1',
    userId: 'u1',
    title: 'Tomar remédio',
    message: 'Com água',
    category: ReminderCategory.medication,
    scheduledAt: DateTime(2026, 6, 30, 8),
    isRead: false,
    createdAt: DateTime(2026, 6, 1),
  );

  setUp(() {
    repo = MockReminderRepository();
    registerFallbackValue(reminder);
  });

  group('GetRemindersUseCase', () {
    test('delega para watchReminders', () {
      when(() => repo.watchReminders('u1'))
          .thenAnswer((_) => Stream.value([reminder]));

      final stream = GetRemindersUseCase(repo).call('u1');

      expect(stream, emits([reminder]));
      verify(() => repo.watchReminders('u1')).called(1);
    });
  });

  group('GetFilteredRemindersUseCase', () {
    test('delega para watchRemindersFiltered com o filtro', () {
      const filter = ReminderFilter(category: ReminderCategory.medication);
      when(() => repo.watchRemindersFiltered('u1', filter))
          .thenAnswer((_) => Stream.value([reminder]));

      final stream = GetFilteredRemindersUseCase(repo).call('u1', filter);

      expect(stream, emits([reminder]));
      verify(() => repo.watchRemindersFiltered('u1', filter)).called(1);
    });
  });

  group('CreateReminderUseCase', () {
    test('delega para createReminder e devolve o id gerado', () async {
      when(() => repo.createReminder(any())).thenAnswer((_) async => 'new-id');

      final id = await CreateReminderUseCase(repo).call(reminder);

      expect(id, 'new-id');
      verify(() => repo.createReminder(reminder)).called(1);
    });
  });

  group('UpdateReminderUseCase', () {
    test('delega para updateReminder', () async {
      when(() => repo.updateReminder(any())).thenAnswer((_) async {});

      await UpdateReminderUseCase(repo).call(reminder);

      verify(() => repo.updateReminder(reminder)).called(1);
    });
  });

  group('MarkReminderReadUseCase', () {
    test('delega para markAsRead com o valor de isRead', () async {
      when(() => repo.markAsRead(any(), isRead: any(named: 'isRead')))
          .thenAnswer((_) async {});

      await MarkReminderReadUseCase(repo).call('r1', isRead: true);

      verify(() => repo.markAsRead('r1', isRead: true)).called(1);
    });
  });

  group('DeleteReminderUseCase', () {
    test('delega para deleteReminder', () async {
      when(() => repo.deleteReminder(any())).thenAnswer((_) async {});

      await DeleteReminderUseCase(repo).call('r1');

      verify(() => repo.deleteReminder('r1')).called(1);
    });
  });
}
