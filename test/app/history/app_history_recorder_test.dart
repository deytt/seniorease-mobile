import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/app/history/app_history_recorder.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/usecases/log_history_event_use_case.dart';
import 'package:mobile/features/history/presentation/providers/history_provider.dart';

class MockLogHistoryEventUseCase extends Mock
    implements LogHistoryEventUseCase {}

AppUser user() => AppUser(
      id: 'u1',
      email: 'a@b.com',
      name: 'Ana',
      createdAt: DateTime(2026, 1, 1),
    );

HistoryEvent fallbackEvent() => HistoryEvent(
      id: '',
      userId: 'u1',
      type: HistoryActionType.taskCreated,
      title: 'x',
      occurredAt: DateTime(2026, 1, 1),
    );

Future<ProviderContainer> buildContainer(
  MockLogHistoryEventUseCase useCase, {
  AppUser? currentUser,
}) async {
  final container = ProviderContainer(overrides: [
    authStateProvider.overrideWith((ref) => Stream.value(currentUser)),
    logHistoryEventUseCaseProvider.overrideWithValue(useCase),
    historyRecorderProvider.overrideWith((ref) => AppHistoryRecorder(ref)),
  ]);
  container.listen(authStateProvider, (_, _) {}, fireImmediately: true);
  await container.read(authStateProvider.future);
  return container;
}

void main() {
  setUpAll(() => registerFallbackValue(fallbackEvent()));

  test('record delega para o use case com o evento correto', () async {
    final useCase = MockLogHistoryEventUseCase();
    when(() => useCase.call(any())).thenAnswer((_) async {});

    final container = await buildContainer(useCase, currentUser: user());
    addTearDown(container.dispose);

    await container.read(historyRecorderProvider).record(
          type: HistoryActionType.taskCompleted,
          title: 'Concluiu: X',
          entityId: 't1',
          category: 'health',
        );

    final captured =
        verify(() => useCase.call(captureAny())).captured.single as HistoryEvent;
    expect(captured.userId, 'u1');
    expect(captured.type, HistoryActionType.taskCompleted);
    expect(captured.title, 'Concluiu: X');
    expect(captured.entityId, 't1');
    expect(captured.category, 'health');
  });

  test('record é best-effort: engole erros sem propagar', () async {
    final useCase = MockLogHistoryEventUseCase();
    when(() => useCase.call(any())).thenThrow(Exception('falha no Firestore'));

    final container = await buildContainer(useCase, currentUser: user());
    addTearDown(container.dispose);

    await expectLater(
      container.read(historyRecorderProvider).record(
            type: HistoryActionType.taskCompleted,
            title: 'Concluiu: X',
          ),
      completes,
    );
  });

  test('record não regista nada sem utilizador autenticado', () async {
    final useCase = MockLogHistoryEventUseCase();
    when(() => useCase.call(any())).thenAnswer((_) async {});

    final container = await buildContainer(useCase, currentUser: null);
    addTearDown(container.dispose);

    await container.read(historyRecorderProvider).record(
          type: HistoryActionType.taskCompleted,
          title: 'Concluiu: X',
        );

    verifyNever(() => useCase.call(any()));
  });
}
