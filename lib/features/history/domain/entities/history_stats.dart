/// Estatísticas agregadas exibidas no topo da tela de Histórico.
///
/// Calculadas *on-read* a partir dos eventos de conclusão (ver
/// [GetHistoryStatsUseCase]) — não são denormalizadas no Firestore.
class HistoryStats {
  const HistoryStats({
    required this.weeklyCount,
    required this.currentStreak,
    required this.longestStreak,
  });

  /// Conclusões (tarefas + lembretes) desde a segunda-feira da semana atual.
  final int weeklyCount;

  /// Dias consecutivos (terminando hoje ou ontem) com ≥ 1 conclusão.
  final int currentStreak;

  /// Maior sequência de dias consecutivos com conclusões no período analisado.
  final int longestStreak;

  static const empty =
      HistoryStats(weeklyCount: 0, currentStreak: 0, longestStreak: 0);
}
