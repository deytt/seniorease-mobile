import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/notifications/data/firebase_notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/watch_notification_history_use_case.dart';

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

// ------------------------------------------------------------------ Badge (hoje)

/// Número de notificações recebidas hoje.
/// Usado pelo sininho da Home para mostrar badge de não lidos.
final todayNotificationCountProvider = Provider<int>((ref) {
  final items = ref.watch(notificationHistoryProvider).asData?.value ?? [];
  final today = DateTime.now();
  return items.where((n) {
    final s = n.sentAt;
    return s.year == today.year &&
        s.month == today.month &&
        s.day == today.day;
  }).length;
});
