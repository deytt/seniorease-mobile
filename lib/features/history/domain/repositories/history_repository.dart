import 'package:mobile/features/history/domain/entities/history_event.dart';

abstract interface class HistoryRepository {
  /// Regista um novo evento de histórico.
  Future<void> log(HistoryEvent event);

  /// Stream dos eventos mais recentes do utilizador (para a lista de atividade).
  Stream<List<HistoryEvent>> watchRecent(String userId, {int limit});

  /// Busca (one-shot) os eventos de conclusão mais recentes, usados para
  /// calcular o streak e o contador semanal.
  Future<List<HistoryEvent>> fetchCompletions(String userId, {int limit});
}
