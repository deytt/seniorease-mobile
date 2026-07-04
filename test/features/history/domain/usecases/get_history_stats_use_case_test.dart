import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/usecases/get_history_stats_use_case.dart';

void main() {
  // Referência determinística (não usar DateTime.now nos testes).
  final now = DateTime(2026, 7, 1, 15); // meio da semana
  DateTime dayAt(int daysAgo) =>
      DateTime(now.year, now.month, now.day, 9).subtract(Duration(days: daysAgo));

  HistoryEvent completion(DateTime at) => HistoryEvent(
        id: '',
        userId: 'u1',
        type: HistoryActionType.taskCompleted,
        title: 'x',
        occurredAt: at,
      );

  group('GetHistoryStatsUseCase.computeStats', () {
    test('lista vazia → tudo zero', () {
      final stats = GetHistoryStatsUseCase.computeStats(const [], now: now);
      expect(stats.weeklyCount, 0);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
    });

    test('streak atual conta dias consecutivos terminando hoje', () {
      final stats = GetHistoryStatsUseCase.computeStats(
        [completion(dayAt(0)), completion(dayAt(1)), completion(dayAt(2))],
        now: now,
      );
      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
    });

    test('sem conclusão hoje mas com ontem → streak ancora em ontem', () {
      final stats = GetHistoryStatsUseCase.computeStats(
        [completion(dayAt(1)), completion(dayAt(2))],
        now: now,
      );
      expect(stats.currentStreak, 2);
    });

    test('lacuna quebra o streak atual (só hoje conta)', () {
      final stats = GetHistoryStatsUseCase.computeStats(
        // hoje presente, ontem ausente, anteontem presente
        [completion(dayAt(0)), completion(dayAt(2))],
        now: now,
      );
      expect(stats.currentStreak, 1);
      expect(stats.longestStreak, 1);
    });

    test('sem conclusão hoje nem ontem → streak atual zero', () {
      final stats = GetHistoryStatsUseCase.computeStats(
        [completion(dayAt(3)), completion(dayAt(4))],
        now: now,
      );
      expect(stats.currentStreak, 0);
      // Mas o maior streak histórico é 2 (dias 3 e 4 são consecutivos).
      expect(stats.longestStreak, 2);
    });

    test('várias conclusões no mesmo dia contam 1 dia para o streak', () {
      final today = dayAt(0);
      final stats = GetHistoryStatsUseCase.computeStats(
        [
          completion(today),
          completion(today.add(const Duration(hours: 2))),
          completion(today.add(const Duration(hours: 5))),
        ],
        now: now,
      );
      expect(stats.currentStreak, 1);
      // Mas o contador semanal conta cada conclusão.
      expect(stats.weeklyCount, 3);
    });

    test('contador semanal ignora conclusões de semanas anteriores', () {
      final stats = GetHistoryStatsUseCase.computeStats(
        [
          completion(dayAt(0)),
          completion(dayAt(0)),
          // 8 dias atrás está sempre fora da semana atual.
          completion(dayAt(8)),
        ],
        now: now,
      );
      expect(stats.weeklyCount, 2);
    });
  });
}
