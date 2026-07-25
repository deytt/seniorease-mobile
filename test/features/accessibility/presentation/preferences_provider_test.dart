import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/usecases/save_preferences_use_case.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';

class MockSavePreferencesUseCase extends Mock implements SavePreferencesUseCase {}

class MockHistoryRecorder extends Mock implements HistoryRecorder {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserPreferences.defaults());
    registerFallbackValue(HistoryActionType.accessibilityChanged);
  });

  ProviderContainer buildContainer({
    required MockSavePreferencesUseCase saveUseCase,
    MockHistoryRecorder? historyRecorder,
  }) {
    final recorder = historyRecorder ?? MockHistoryRecorder();
    when(() => recorder.record(
          type: any(named: 'type'),
          title: any(named: 'title'),
          entityId: any(named: 'entityId'),
          category: any(named: 'category'),
        )).thenAnswer((_) async {});
    return ProviderContainer(overrides: [
      savePreferencesUseCaseProvider.overrideWithValue(saveUseCase),
      historyRecorderProvider.overrideWithValue(recorder),
    ]);
  }

  group('AccessibilityController', () {
    test('estado inicial é AsyncData(null)', () {
      final saveUC = MockSavePreferencesUseCase();
      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      expect(
        container.read(accessibilityControllerProvider),
        const AsyncData<void>(null),
      );
    });

    test('save bem-sucedido transita para AsyncData(null)', () async {
      final saveUC = MockSavePreferencesUseCase();
      when(() => saveUC.call(any())).thenAnswer((_) async {});

      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      await container
          .read(accessibilityControllerProvider.notifier)
          .save(UserPreferences.defaults());

      expect(
        container.read(accessibilityControllerProvider),
        const AsyncData<void>(null),
      );
      verify(() => saveUC.call(any())).called(1);
    });

    test('save com erro transita para AsyncError', () async {
      final saveUC = MockSavePreferencesUseCase();
      when(() => saveUC.call(any())).thenThrow(Exception('Firestore erro'));

      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      await container
          .read(accessibilityControllerProvider.notifier)
          .save(UserPreferences.defaults());

      expect(
        container.read(accessibilityControllerProvider),
        isA<AsyncError<void>>(),
      );
    });

    test('registo de histórico só ocorre uma vez por sessão (deduplica)', () async {
      final saveUC = MockSavePreferencesUseCase();
      final recorder = MockHistoryRecorder();
      when(() => saveUC.call(any())).thenAnswer((_) async {});
      when(() => recorder.record(
            type: any(named: 'type'),
            title: any(named: 'title'),
            entityId: any(named: 'entityId'),
            category: any(named: 'category'),
          )).thenAnswer((_) async {});

      final container = buildContainer(
        saveUseCase: saveUC,
        historyRecorder: recorder,
      );
      addTearDown(container.dispose);

      final notifier = container.read(accessibilityControllerProvider.notifier);
      await notifier.save(UserPreferences.defaults());
      await notifier.save(UserPreferences.defaults());

      verify(() => recorder.record(
            type: HistoryActionType.accessibilityChanged,
            title: any(named: 'title'),
          )).called(1);
    });
  });

  group('NotificationPreferencesController', () {
    test('estado inicial é AsyncData(null)', () {
      final saveUC = MockSavePreferencesUseCase();
      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      expect(
        container.read(notificationPreferencesControllerProvider),
        const AsyncData<void>(null),
      );
    });

    test('save bem-sucedido chama use case e permanece em AsyncData', () async {
      final saveUC = MockSavePreferencesUseCase();
      when(() => saveUC.call(any())).thenAnswer((_) async {});

      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      await container
          .read(notificationPreferencesControllerProvider.notifier)
          .save(UserPreferences.defaults());

      expect(
        container.read(notificationPreferencesControllerProvider),
        const AsyncData<void>(null),
      );
    });

    test('save com erro transita para AsyncError', () async {
      final saveUC = MockSavePreferencesUseCase();
      when(() => saveUC.call(any())).thenThrow(Exception('sem rede'));

      final container = buildContainer(saveUseCase: saveUC);
      addTearDown(container.dispose);

      await container
          .read(notificationPreferencesControllerProvider.notifier)
          .save(UserPreferences.defaults());

      expect(
        container.read(notificationPreferencesControllerProvider),
        isA<AsyncError<void>>(),
      );
    });
  });
}
