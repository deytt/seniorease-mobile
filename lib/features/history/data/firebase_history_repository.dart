import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';

class FirebaseHistoryRepository implements HistoryRepository {
  FirebaseHistoryRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _history =>
      _firestore.collection('history');

  @override
  Future<void> log(HistoryEvent event) async {
    await _history.add(event.toMap());
  }

  @override
  Stream<List<HistoryEvent>> watchRecent(String userId, {int limit = 50}) {
    // Requer o composite index (userId ASC, occurredAt DESC) — ver
    // firestore.indexes.json / firebaseSchema.md.
    return _history
        .where('userId', isEqualTo: userId)
        .orderBy('occurredAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => HistoryEvent.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<List<HistoryEvent>> fetchCompletions(
    String userId, {
    int limit = 365,
  }) async {
    final completionTypes = HistoryActionType.values
        .where((t) => t.isCompletion)
        .map((t) => t.storageKey)
        .toList();

    // Requer o composite index (userId ASC, type ASC, occurredAt DESC).
    final snap = await _history
        .where('userId', isEqualTo: userId)
        .where('type', whereIn: completionTypes)
        .orderBy('occurredAt', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((doc) => HistoryEvent.fromMap(doc.id, doc.data()))
        .toList();
  }
}
