import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';
import 'package:mobile/features/history/presentation/providers/history_provider.dart';

class _FakeHistoryRepository implements HistoryRepository {
  _FakeHistoryRepository(this.events);

  final List<HistoryEvent> events;

  @override
  Future<void> log(HistoryEvent event) async {}

  @override
  Stream<List<HistoryEvent>> watchRecent(String userId, {int limit = 50}) =>
      Stream.value(events);

  @override
  Future<List<HistoryEvent>> fetchCompletions(String userId, {int limit = 365}) async =>
      events;
}

AppUser user() => AppUser(
      id: 'u1',
      email: 'a@b.com',
      name: 'Ana',
      createdAt: DateTime(2026, 1, 1),
    );

HistoryEvent completionNow() => HistoryEvent(
      id: '',
      userId: 'u1',
      type: HistoryActionType.taskCompleted,
      title: 'x',
      occurredAt: DateTime.now(),
    );

void main() {
  test('historyStatsProvider calcula stats a partir das conclusões', () async {
    final container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(user())),
      historyRepositoryProvider.overrideWithValue(
        _FakeHistoryRepository([completionNow(), completionNow()]),
      ),
    ]);
    addTearDown(container.dispose);
    container.listen(authStateProvider, (_, _) {}, fireImmediately: true);
    await container.read(authStateProvider.future);

    final stats = await container.read(historyStatsProvider.future);

    // Duas conclusões hoje → 2 na semana, 1 dia de sequência.
    expect(stats.weeklyCount, 2);
    expect(stats.currentStreak, 1);
  });

  test('historyStatsProvider devolve vazio sem utilizador autenticado',
      () async {
    final container = ProviderContainer(overrides: [
      authStateProvider.overrideWith((ref) => Stream.value(null)),
      historyRepositoryProvider.overrideWithValue(
        _FakeHistoryRepository([completionNow()]),
      ),
    ]);
    addTearDown(container.dispose);
    container.listen(authStateProvider, (_, _) {}, fireImmediately: true);
    await container.read(authStateProvider.future);

    final stats = await container.read(historyStatsProvider.future);

    expect(stats.weeklyCount, 0);
    expect(stats.currentStreak, 0);
  });
}
