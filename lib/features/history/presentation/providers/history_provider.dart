import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/history/data/firebase_history_repository.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/entities/history_stats.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';
import 'package:mobile/features/history/domain/usecases/get_history_stats_use_case.dart';
import 'package:mobile/features/history/domain/usecases/get_history_use_case.dart';
import 'package:mobile/features/history/domain/usecases/log_history_event_use_case.dart';

// --- Repositório ---

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return FirebaseHistoryRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// --- Use cases ---

final logHistoryEventUseCaseProvider = Provider<LogHistoryEventUseCase>((ref) {
  return LogHistoryEventUseCase(ref.watch(historyRepositoryProvider));
});

final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(ref.watch(historyRepositoryProvider));
});

final getHistoryStatsUseCaseProvider = Provider<GetHistoryStatsUseCase>((ref) {
  return GetHistoryStatsUseCase(ref.watch(historyRepositoryProvider));
});

// --- Streams / derivados ---

/// Eventos de atividade recente do utilizador (mais recentes primeiro).
final historyStreamProvider = StreamProvider<List<HistoryEvent>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  return ref.read(getHistoryUseCaseProvider).call(userId);
});

/// Estatísticas do topo (contador semanal + streak). Recalcula sempre que a
/// atividade recente muda (novo evento registado).
final historyStatsProvider = FutureProvider<HistoryStats>((ref) async {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return HistoryStats.empty;
  // Dispara recomputação quando um novo evento é adicionado.
  ref.watch(historyStreamProvider);
  return ref.read(getHistoryStatsUseCaseProvider).call(userId);
});
