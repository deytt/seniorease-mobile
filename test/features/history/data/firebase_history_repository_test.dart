import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/history/data/firebase_history_repository.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseHistoryRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseHistoryRepository(firestore: db);
  });

  Future<void> seed(
    String id, {
    String userId = 'u1',
    String type = 'taskCompleted',
    DateTime? occurredAt,
  }) {
    return db.collection('history').doc(id).set({
      'userId': userId,
      'type': type,
      'title': 'Evento $id',
      'entityId': null,
      'category': null,
      'occurredAt': Timestamp.fromDate(occurredAt ?? DateTime(2026, 6, 30, 8)),
    });
  }

  test('log grava os campos corretos', () async {
    final event = HistoryEvent(
      id: '',
      userId: 'u1',
      type: HistoryActionType.taskCreated,
      title: 'Criou a tarefa: X',
      entityId: 't1',
      category: 'health',
      occurredAt: DateTime(2026, 6, 30, 8),
    );

    await repo.log(event);

    final snap = await db.collection('history').get();
    expect(snap.docs.length, 1);
    final data = snap.docs.first.data();
    expect(data['userId'], 'u1');
    expect(data['type'], 'taskCreated');
    expect(data['title'], 'Criou a tarefa: X');
    expect(data['entityId'], 't1');
    expect(data['category'], 'health');
  });

  test('watchRecent devolve eventos do utilizador ordenados desc', () async {
    await seed('a', occurredAt: DateTime(2026, 6, 30, 8));
    await seed('b', occurredAt: DateTime(2026, 6, 30, 12));
    await seed('c', occurredAt: DateTime(2026, 6, 29, 20));
    await seed('x', userId: 'outro', occurredAt: DateTime(2026, 6, 30, 23));

    final items = await repo.watchRecent('u1').first;

    expect(items.map((e) => e.id).toList(), ['b', 'a', 'c']);
  });

  test('watchRecent respeita o limite', () async {
    for (var i = 0; i < 5; i++) {
      await seed('e$i', occurredAt: DateTime(2026, 6, 30, i + 1));
    }

    final items = await repo.watchRecent('u1', limit: 2).first;

    expect(items.length, 2);
    // Mais recentes primeiro (hora 5 e 4).
    expect(items.map((e) => e.id).toList(), ['e4', 'e3']);
  });

  test('fetchCompletions devolve só conclusões, ordenadas desc', () async {
    await seed('c1', type: 'taskCompleted', occurredAt: DateTime(2026, 6, 30, 8));
    await seed(
      'c2',
      type: 'reminderCompleted',
      occurredAt: DateTime(2026, 6, 30, 12),
    );
    await seed('n1', type: 'taskCreated', occurredAt: DateTime(2026, 6, 30, 13));
    await seed(
      'n2',
      type: 'accessibilityChanged',
      occurredAt: DateTime(2026, 6, 30, 14),
    );

    final items = await repo.fetchCompletions('u1');

    expect(items.map((e) => e.id).toList(), ['c2', 'c1']);
    expect(items.every((e) => e.isCompletion), isTrue);
  });
}
