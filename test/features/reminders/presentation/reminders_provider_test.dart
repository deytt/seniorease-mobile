import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/usecases/create_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/delete_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/mark_reminder_read_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/update_reminder_use_case.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';

class MockCreateReminderUseCase extends Mock implements CreateReminderUseCase {}

class MockMarkReminderReadUseCase extends Mock
    implements MarkReminderReadUseCase {}

class MockDeleteReminderUseCase extends Mock implements DeleteReminderUseCase {}

class MockUpdateReminderUseCase extends Mock implements UpdateReminderUseCase {}

Reminder reminder(String id) => Reminder(
      id: id,
      userId: 'u1',
      title: 'T$id',
      message: '',
      category: ReminderCategory.medication,
      scheduledAt: DateTime(2026, 6, 30, 8),
      isRead: false,
      createdAt: DateTime(2026, 6, 1),
    );

void main() {
  setUpAll(() => registerFallbackValue(reminder('fallback')));

  group('ReminderFilterNotifier', () {
    test('estado inicial é vazio e update altera o filtro', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(reminderFilterProvider), ReminderFilter.empty);

      const newFilter = ReminderFilter(
        category: ReminderCategory.medication,
        isToday: true,
      );
      container.read(reminderFilterProvider.notifier).update(newFilter);

      expect(container.read(reminderFilterProvider), newFilter);
    });
  });

  group('OpenReminderSwipeNotifier', () {
    test('estado inicial é null e open/close guardam id + lado', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(openReminderSwipeProvider.notifier);

      expect(container.read(openReminderSwipeProvider), isNull);

      notifier.open('r1', ReminderSwipeSide.delete);
      expect(
        container.read(openReminderSwipeProvider),
        (id: 'r1', side: ReminderSwipeSide.delete),
      );

      notifier.open('r1', ReminderSwipeSide.edit);
      expect(
        container.read(openReminderSwipeProvider),
        (id: 'r1', side: ReminderSwipeSide.edit),
      );

      notifier.close();
      expect(container.read(openReminderSwipeProvider), isNull);
    });

    test('closeIf só fecha quando o id corresponde ao aberto', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(openReminderSwipeProvider.notifier);

      notifier.open('r1', ReminderSwipeSide.delete);
      notifier.closeIf('r2');
      expect(
        container.read(openReminderSwipeProvider),
        (id: 'r1', side: ReminderSwipeSide.delete),
      );

      notifier.closeIf('r1');
      expect(container.read(openReminderSwipeProvider), isNull);
    });
  });

  group('ExpandedReminderNotifier', () {
    test('toggle expande/recolhe e alterna entre ids', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(expandedReminderIdProvider.notifier);

      expect(container.read(expandedReminderIdProvider), isNull);

      notifier.toggle('r1');
      expect(container.read(expandedReminderIdProvider), 'r1');

      notifier.toggle('r1');
      expect(container.read(expandedReminderIdProvider), isNull);

      notifier.toggle('r1');
      notifier.toggle('r2');
      expect(container.read(expandedReminderIdProvider), 'r2');

      notifier.close();
      expect(container.read(expandedReminderIdProvider), isNull);
    });
  });

  group('HighlightReminderNotifier', () {
    test('show define e clear limpa o destaque', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(highlightReminderIdProvider.notifier);

      expect(container.read(highlightReminderIdProvider), isNull);

      notifier.show('r1');
      expect(container.read(highlightReminderIdProvider), 'r1');

      notifier.clear();
      expect(container.read(highlightReminderIdProvider), isNull);
    });
  });

  group('ReminderSwipeHintNotifier', () {
    test('markShown passa de false para true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(reminderSwipeHintShownProvider), isFalse);

      container.read(reminderSwipeHintShownProvider.notifier).markShown();
      expect(container.read(reminderSwipeHintShownProvider), isTrue);
    });
  });

  group('RemindersController', () {
    test('create: sucesso → AsyncData e devolve o id', () async {
      final useCase = MockCreateReminderUseCase();
      when(() => useCase.call(any())).thenAnswer((_) async => 'new-id');

      final container = ProviderContainer(overrides: [
        createReminderUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      final id = await controller.create(reminder('a'));

      expect(id, 'new-id');
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncData<void>>(),
      );
    });

    test('create: erro → AsyncError e devolve null', () async {
      final useCase = MockCreateReminderUseCase();
      when(() => useCase.call(any())).thenThrow(Exception('falha'));

      final container = ProviderContainer(overrides: [
        createReminderUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      final id = await controller.create(reminder('a'));

      expect(id, isNull);
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncError<void>>(),
      );
    });

    test('update: sucesso → AsyncData e devolve true', () async {
      final useCase = MockUpdateReminderUseCase();
      when(() => useCase.call(any())).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        updateReminderUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      final ok = await controller.update(reminder('a'));

      expect(ok, isTrue);
      verify(() => useCase.call(any())).called(1);
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncData<void>>(),
      );
    });

    test('update: erro → AsyncError e devolve false', () async {
      final useCase = MockUpdateReminderUseCase();
      when(() => useCase.call(any())).thenThrow(Exception('falha'));

      final container = ProviderContainer(overrides: [
        updateReminderUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      final ok = await controller.update(reminder('a'));

      expect(ok, isFalse);
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncError<void>>(),
      );
    });

    test('markRead: chama o use case com isRead e resulta em AsyncData',
        () async {
      final useCase = MockMarkReminderReadUseCase();
      when(() => useCase.call(any(), isRead: any(named: 'isRead')))
          .thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        markReminderReadUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      await controller.markRead('r1', isRead: true);

      verify(() => useCase.call('r1', isRead: true)).called(1);
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncData<void>>(),
      );
    });

    test('delete: sucesso → AsyncData e chama o use case', () async {
      final useCase = MockDeleteReminderUseCase();
      when(() => useCase.call(any())).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        deleteReminderUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(remindersControllerProvider.notifier);
      await controller.delete('r1');

      verify(() => useCase.call('r1')).called(1);
      expect(
        container.read(remindersControllerProvider),
        isA<AsyncData<void>>(),
      );
    });
  });
}
