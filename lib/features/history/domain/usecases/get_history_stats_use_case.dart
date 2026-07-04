import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/entities/history_stats.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';

/// Calcula as estatísticas do Histórico (contador semanal + streak) a partir
/// dos eventos de conclusão do utilizador.
///
/// A lógica de agregação é uma **função pura** ([computeStats]) para ser
/// facilmente testada e portada 1:1 para a Web (ver ADR-017).
class GetHistoryStatsUseCase {
  const GetHistoryStatsUseCase(this._repository);

  final HistoryRepository _repository;

  Future<HistoryStats> call(String userId, {int limit = 365}) async {
    final completions = await _repository.fetchCompletions(userId, limit: limit);
    return computeStats(completions);
  }

  /// Função pura: dado o conjunto de eventos de conclusão, devolve o contador
  /// semanal e os streaks. [now] é injetável para testes determinísticos.
  static HistoryStats computeStats(
    List<HistoryEvent> completions, {
    DateTime? now,
  }) {
    if (completions.isEmpty) return HistoryStats.empty;

    final reference = now ?? DateTime.now();
    final today = _dateOnly(reference);

    // Início da semana (segunda-feira 00:00). weekday: Monday=1..Sunday=7.
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    var weeklyCount = 0;
    final days = <DateTime>{};
    for (final event in completions) {
      final day = _dateOnly(event.occurredAt);
      days.add(day);
      if (!day.isBefore(weekStart)) weeklyCount++;
    }

    final sortedDesc = days.toList()..sort((a, b) => b.compareTo(a));

    return HistoryStats(
      weeklyCount: weeklyCount,
      currentStreak: _currentStreak(days, today),
      longestStreak: _longestStreak(sortedDesc),
    );
  }

  /// Dias consecutivos terminando hoje (ou ontem, se hoje ainda sem conclusão).
  static int _currentStreak(Set<DateTime> days, DateTime today) {
    final yesterday = today.subtract(const Duration(days: 1));
    DateTime anchor;
    if (days.contains(today)) {
      anchor = today;
    } else if (days.contains(yesterday)) {
      anchor = yesterday;
    } else {
      return 0;
    }

    var streak = 0;
    var cursor = anchor;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Maior sequência de dias consecutivos (lista ordenada descendente e única).
  static int _longestStreak(List<DateTime> sortedDesc) {
    if (sortedDesc.isEmpty) return 0;
    var longest = 1;
    var run = 1;
    for (var i = 1; i < sortedDesc.length; i++) {
      final expectedPrev = sortedDesc[i - 1].subtract(const Duration(days: 1));
      if (sortedDesc[i] == expectedPrev) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }
    return longest;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
