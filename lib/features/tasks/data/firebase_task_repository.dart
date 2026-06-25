import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

  CollectionReference<Map<String, dynamic>> _steps(String taskId) =>
      _tasks.doc(taskId).collection('steps');

  @override
  Stream<List<Task>> watchTasks(String userId) =>
      watchTasksFiltered(userId, TaskFilter.empty);

  @override
  Stream<List<Task>> watchTasksFiltered(String userId, TaskFilter filter) {
    // Ponto de partida: filtro por utilizador.
    Query<Map<String, dynamic>> query =
        _tasks.where('userId', isEqualTo: userId);

    // Filtro por categoria (equality — não precisa de composite index sozinho).
    if (filter.category != null) {
      query = query.where('category',
          isEqualTo: filter.category!.toFirestore());
    }

    // Filtro por prioridade (equality — não precisa de composite index sozinho).
    if (filter.priority != null) {
      query = query.where('priority',
          isEqualTo: filter.priority!.toFirestore());
    }

    // Filtro "hoje": range query em dueDate — requer composite index com userId
    // (e category/priority se combinados). Ver firebaseSchema.md § Indexes.
    if (filter.isToday) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      query = query
          .where('dueDate',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('dueDate', isLessThan: Timestamp.fromDate(endOfDay));
    }

    return query.snapshots().map((snap) {
      final tasks =
          snap.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList();

      // Ordena em memória (mantém o mesmo critério do watchTasks):
      // 1. Pendentes/em progresso antes de concluídas.
      // 2. Dentro de pendentes: dueDate ascendente; null vai para o fim.
      // 3. Dentro de concluídas: completedAt descendente.
      tasks.sort((a, b) {
        final aDone = a.isCompleted;
        final bDone = b.isCompleted;
        if (aDone != bDone) return aDone ? 1 : -1;

        if (aDone) {
          final aAt = a.completedAt ?? a.updatedAt;
          final bAt = b.completedAt ?? b.updatedAt;
          return bAt.compareTo(aAt);
        }

        final aDue = a.dueDate;
        final bDue = b.dueDate;
        if (aDue == null && bDue == null) {
          return b.createdAt.compareTo(a.createdAt);
        }
        if (aDue == null) return 1;
        if (bDue == null) return -1;
        return aDue.compareTo(bDue);
      });
      return tasks;
    });
  }

  @override
  Stream<Task> watchTask(String taskId) {
    // Combina os snapshots da tarefa e dos passos, reemitindo sempre que
    // qualquer um dos dois muda.
    final controller = StreamController<Task>();

    DocumentSnapshot<Map<String, dynamic>>? lastTask;
    List<TaskStep> lastSteps = const [];

    void emit() {
      if (lastTask == null) return;
      controller.add(
        Task.fromMap(lastTask!.id, lastTask!.data() ?? {}, steps: lastSteps),
      );
    }

    final taskSub = _tasks.doc(taskId).snapshots().listen((snap) {
      lastTask = snap;
      emit();
    }, onError: controller.addError);

    final stepsSub =
        _steps(taskId).orderBy('order').snapshots().listen((snap) {
      lastSteps =
          snap.docs.map((doc) => TaskStep.fromMap(doc.id, doc.data())).toList();
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await taskSub.cancel();
      await stepsSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<String> createTask(Task task, List<TaskStep> steps) async {
    final batch = _firestore.batch();
    final taskRef = _tasks.doc();

    batch.set(taskRef, task.toMap());

    for (final step in steps) {
      final stepRef = taskRef.collection('steps').doc();
      batch.set(stepRef, step.toMap());
    }

    await batch.commit();
    return taskRef.id;
  }

  @override
  Future<void> updateTask(Task task) =>
      _tasks.doc(task.id).set(task.toMap(), SetOptions(merge: true));

  @override
  Future<void> deleteTask(String taskId) async {
    final stepsSnap = await _steps(taskId).get();
    final batch = _firestore.batch();
    for (final doc in stepsSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_tasks.doc(taskId));
    await batch.commit();
  }

  @override
  Future<void> setStepCompleted(
    String taskId,
    String stepId, {
    required bool isCompleted,
  }) async {
    await _steps(taskId).doc(stepId).update({'isCompleted': isCompleted});
    await _syncStatusFromSteps(taskId);
  }

  @override
  Future<void> completeTask(String taskId) async {
    final stepsSnap = await _steps(taskId).get();
    final batch = _firestore.batch();
    for (final doc in stepsSnap.docs) {
      batch.update(doc.reference, {'isCompleted': true});
    }
    batch.update(_tasks.doc(taskId), {
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Recalcula o status da tarefa a partir do estado dos passos.
  Future<void> _syncStatusFromSteps(String taskId) async {
    final stepsSnap = await _steps(taskId).get();
    if (stepsSnap.docs.isEmpty) return;

    final total = stepsSnap.docs.length;
    final done = stepsSnap.docs
        .where((d) => d.data()['isCompleted'] == true)
        .length;

    final String status;
    if (done == 0) {
      status = 'pending';
    } else if (done >= total) {
      status = 'completed';
    } else {
      status = 'in_progress';
    }

    await _tasks.doc(taskId).update({
      'status': status,
      'completedAt': status == 'completed'
          ? FieldValue.serverTimestamp()
          : null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
