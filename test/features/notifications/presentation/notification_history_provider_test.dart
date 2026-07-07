import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:mobile/features/notifications/presentation/providers/notification_history_provider.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeNotificationHistoryRepository
    implements NotificationHistoryRepository {
  _FakeNotificationHistoryRepository(this.items);
  final List<NotificationItem> items;

  // Stream.fromFuture garante emissão assíncrona (evita race com o listener).
  @override
  Stream<List<NotificationItem>> watchByUser(String userId,
          {int limit = 50}) =>
      Stream.fromFuture(Future.value(items));
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

AppUser _user() => AppUser(
      id: 'u1',
      email: 'user@test.com',
      name: 'Utilizador',
      createdAt: DateTime(2026, 1, 1),
    );

NotificationItem _item(String id, {DateTime? sentAt}) => NotificationItem(
      id: id,
      userId: 'u1',
      entityId: 'e1',
      entityType: NotificationEntityType.task,
      title: 'Título',
      body: 'Corpo',
      sentAt: sentAt ?? DateTime.now(),
    );

/// Aguarda o [StreamProvider] emitir o primeiro valor usando um [Completer].
/// Evita o padrão [provider.future] que pode ficar preso quando o stream
/// inicial do provider é [Stream.empty()].
Future<List<NotificationItem>> _firstEmission(
  ProviderContainer container,
) async {
  final completer = Completer<List<NotificationItem>>();

  final sub = container.listen<AsyncValue<List<NotificationItem>>>(
    notificationHistoryProvider,
    (_, next) {
      if (!completer.isCompleted) {
        next.when(
          data: (v) => completer.complete(v),
          error: (e, _) => completer.completeError(e),
          loading: () {},
        );
      }
    },
    fireImmediately: true,
  );

  final result = await completer.future;
  sub.close();
  return result;
}

// ---------------------------------------------------------------------------
// Tests — notificationHistoryProvider
// ---------------------------------------------------------------------------

void main() {
  group('notificationHistoryProvider', () {
    test('devolve lista de itens quando há utilizador autenticado', () async {
      final items = [_item('n1'), _item('n2')];

      final container = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(_user())),
        notificationHistoryRepositoryProvider.overrideWithValue(
          _FakeNotificationHistoryRepository(items),
        ),
      ]);
      addTearDown(container.dispose);

      container.listen(authStateProvider, (_, __) {}, fireImmediately: true);
      await container.read(authStateProvider.future);

      final result = await _firstEmission(container);

      expect(result, items);
    });

    test('devolve lista vazia quando o repositório não tem itens', () async {
      final container = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(_user())),
        notificationHistoryRepositoryProvider.overrideWithValue(
          _FakeNotificationHistoryRepository([]),
        ),
      ]);
      addTearDown(container.dispose);

      container.listen(authStateProvider, (_, __) {}, fireImmediately: true);
      await container.read(authStateProvider.future);

      final result = await _firstEmission(container);

      expect(result, isEmpty);
    });

    test('não emite quando não há utilizador (stream permanece loading)',
        () async {
      final container = ProviderContainer(overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(null)),
        notificationHistoryRepositoryProvider.overrideWithValue(
          _FakeNotificationHistoryRepository([]),
        ),
      ]);
      addTearDown(container.dispose);

      container.listen(authStateProvider, (_, __) {}, fireImmediately: true);
      await container.read(authStateProvider.future);

      final state = container.read(notificationHistoryProvider);
      // userId é null → Stream.empty() → provider fica em loading
      expect(state.hasValue, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Tests — todayNotificationCountProvider
  // Testa a lógica de filtragem sobrepondo directamente o StreamProvider,
  // sem passar pela cadeia auth → repositório.
  // -------------------------------------------------------------------------

  group('todayNotificationCountProvider', () {
    ProviderContainer _makeContainer(List<NotificationItem> items) {
      final container = ProviderContainer(overrides: [
        notificationHistoryProvider.overrideWith(
          (ref) => Stream.fromFuture(Future.value(items)),
        ),
      ]);
      addTearDown(container.dispose);
      return container;
    }

    Future<int> _readCount(List<NotificationItem> items) async {
      final c = _makeContainer(items);
      // Usa _firstEmission para aguardar a emissão via Completer (mais robusto
      // que .future quando o stream usa Future.value internamente).
      await _firstEmission(c);
      return c.read(todayNotificationCountProvider);
    }

    test('conta apenas notificações enviadas hoje', () async {
      final now = DateTime.now();
      final today1 =
          _item('n1', sentAt: DateTime(now.year, now.month, now.day, 9));
      final today2 =
          _item('n2', sentAt: DateTime(now.year, now.month, now.day, 15));
      final yesterday =
          _item('n3', sentAt: DateTime(now.year, now.month, now.day - 1, 10));

      expect(await _readCount([today1, today2, yesterday]), 2);
    });

    test('devolve 0 quando não há notificações', () async {
      expect(await _readCount([]), 0);
    });

    test('devolve 0 quando todas as notificações são de dias anteriores',
        () async {
      final past = _item('n1', sentAt: DateTime(2024, 1, 1, 10));
      expect(await _readCount([past]), 0);
    });

    test('conta todas as notificações de hoje se não houver anteriores',
        () async {
      final now = DateTime.now();
      final items = List.generate(
        5,
        (i) => _item('n$i',
            sentAt: DateTime(now.year, now.month, now.day, i + 8)),
      );
      expect(await _readCount(items), 5);
    });
  });
}
