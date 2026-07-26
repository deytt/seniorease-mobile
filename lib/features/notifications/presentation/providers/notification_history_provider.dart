import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/notifications/data/firebase_notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/watch_notification_history_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ------------------------------------------------------------------ Infra

final notificationHistoryRepositoryProvider =
    Provider<NotificationHistoryRepository>((ref) {
  return FirebaseNotificationHistoryRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final watchNotificationHistoryUseCaseProvider =
    Provider<WatchNotificationHistoryUseCase>((ref) {
  return WatchNotificationHistoryUseCase(
    ref.watch(notificationHistoryRepositoryProvider),
  );
});

// ------------------------------------------------------------------ Stream principal

/// Stream dos últimos 50 avisos do utilizador autenticado.
/// Devolve lista vazia se não há utilizador.
final notificationHistoryProvider =
    StreamProvider<List<NotificationItem>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return const Stream.empty();

  return ref
      .watch(watchNotificationHistoryUseCaseProvider)
      .call(userId, limit: 50);
});

// ------------------------------------------------------------------ Lido / não lido

/// Contador interno que força re-derivação do [notifLastSeenAtProvider]
/// quando [markNotificationsSeen] é chamado.
final _notifReadVersionProvider =
    NotifierProvider<_ReadVersionNotifier, int>(_ReadVersionNotifier.new);

class _ReadVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

/// Chave SharedPreferences para o timestamp de "última visualização".
/// Formato: `seniorease_notif_last_seen_{userId}`.
String _notifSeenKey(String userId) => 'seniorease_notif_last_seen_$userId';

/// Data/hora da última vez que o utilizador abriu a tela de notificações.
/// Lido do SharedPreferences; devolve `null` se ainda não foi vista nenhuma.
final notifLastSeenAtProvider = FutureProvider<DateTime?>((ref) async {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  ref.watch(_notifReadVersionProvider); // re-executa ao marcar como lido

  if (userId == null) return null;

  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_notifSeenKey(userId));
  return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
});

/// Marca todas as notificações como lidas, gravando o timestamp actual no
/// SharedPreferences. O badge vai imediatamente a zero porque
/// [notifLastSeenAtProvider] é re-derivado via [_notifReadVersionProvider].
Future<void> markNotificationsSeen(WidgetRef ref) async {
  final userId = ref.read(authStateProvider).asData?.value?.id;
  if (userId == null) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
    _notifSeenKey(userId),
    DateTime.now().millisecondsSinceEpoch,
  );
  ref.read(_notifReadVersionProvider.notifier).increment();
}

// ------------------------------------------------------------------ Badge (não lidos)

/// Número de notificações ainda não vistas (recebidas após [notifLastSeenAtProvider]).
/// Substitui o antigo `todayNotificationCountProvider`.
/// Usado pelo sininho da Home para mostrar o badge.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationHistoryProvider).asData?.value ?? [];
  final lastSeen = ref.watch(notifLastSeenAtProvider).asData?.value;

  if (lastSeen == null) return items.length;
  return items.where((n) => n.sentAt.isAfter(lastSeen)).length;
});

/// @deprecated Use [unreadNotificationCountProvider].
final todayNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(unreadNotificationCountProvider);
});
