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

      container.listen(authStateProvider, (prev, next) {}, fireImmediately: true);
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

      container.listen(authStateProvider, (prev, next) {}, fireImmediately: true);
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

      container.listen(authStateProvider, (prev, next) {}, fireImmediately: true);
      await container.read(authStateProvider.future);

      final state = container.read(notificationHistoryProvider);
      // userId é null → Stream.empty() → provider fica em loading
      expect(state.hasValue, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // Tests — unreadNotificationCountProvider
  // Badge "não lido" baseado em lastSeenAt (SharedPreferences).
  // -------------------------------------------------------------------------

  group('unreadNotificationCountProvider', () {
    ProviderContainer makeContainer(
      List<NotificationItem> items, {
      DateTime? lastSeenAt,
    }) {
      final container = ProviderContainer(overrides: [
        notificationHistoryProvider.overrideWith(
          (ref) => Stream.fromFuture(Future.value(items)),
        ),
        // Simula o lastSeenAt sem aceder ao SharedPreferences real.
        notifLastSeenAtProvider.overrideWith(
          (ref) => Future.value(lastSeenAt),
        ),
      ]);
      addTearDown(container.dispose);
      return container;
    }

    Future<int> readCount(
      List<NotificationItem> items, {
      DateTime? lastSeenAt,
    }) async {
      final c = makeContainer(items, lastSeenAt: lastSeenAt);
      await _firstEmission(c);
      // Aguarda o FutureProvider do lastSeenAt completar.
      await c.read(notifLastSeenAtProvider.future);
      return c.read(unreadNotificationCountProvider);
    }

    test('conta todas como não lidas quando não há lastSeenAt', () async {
      final now = DateTime.now();
      final items = [
        _item('n1', sentAt: now.subtract(const Duration(hours: 1))),
        _item('n2', sentAt: now.subtract(const Duration(days: 1))),
        _item('n3', sentAt: now.subtract(const Duration(days: 5))),
      ];
      // Sem lastSeenAt → todas as notificações são consideradas não lidas.
      expect(await readCount(items), 3);
    });

    test('devolve 0 quando não há notificações', () async {
      expect(await readCount([]), 0);
    });

    test('devolve 0 quando lastSeenAt é posterior a todas as notificações',
        () async {
      final past = _item('n1', sentAt: DateTime(2024, 1, 1, 10));
      final lastSeen = DateTime(2025, 1, 1); // mais recente que a notificação
      expect(await readCount([past], lastSeenAt: lastSeen), 0);
    });

    test('conta apenas notificações enviadas após lastSeenAt', () async {
      final lastSeen = DateTime(2026, 1, 15, 12);
      final before = _item('n1', sentAt: DateTime(2026, 1, 15, 10)); // antes
      final after1 = _item('n2', sentAt: DateTime(2026, 1, 15, 14)); // depois
      final after2 = _item('n3', sentAt: DateTime(2026, 1, 16)); // depois

      expect(
        await readCount([before, after1, after2], lastSeenAt: lastSeen),
        2,
      );
    });

    test('devolve 0 imediatamente após marcar como lido', () async {
      final now = DateTime.now();
      final items = [
        _item('n1', sentAt: now.subtract(const Duration(minutes: 5))),
      ];
      // Simula lastSeenAt = agora (equivalente a markNotificationsSeen).
      expect(await readCount(items, lastSeenAt: DateTime.now()), 0);
    });
  });

  // -------------------------------------------------------------------------
  // Tests — todayNotificationCountProvider (alias de unreadNotificationCountProvider)
  // -------------------------------------------------------------------------

  group('todayNotificationCountProvider', () {
    test('delega para unreadNotificationCountProvider', () async {
      final now = DateTime.now();
      final items = [
        _item('n1', sentAt: now),
        _item('n2', sentAt: now),
      ];

      final container = ProviderContainer(overrides: [
        notificationHistoryProvider.overrideWith(
          (ref) => Stream.fromFuture(Future.value(items)),
        ),
        notifLastSeenAtProvider.overrideWith((ref) => Future.value(null)),
      ]);
      addTearDown(container.dispose);

      await _firstEmission(container);
      await container.read(notifLastSeenAtProvider.future);

      // todayNotificationCountProvider é alias de unreadNotificationCountProvider.
      expect(
        container.read(todayNotificationCountProvider),
        container.read(unreadNotificationCountProvider),
      );
    });
  });
}
