import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class FirebaseTaskRepository implements TaskRepository {
  FirebaseTaskRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _firestore.collection('tasks');

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
    return _tasks.doc(taskId).snapshots().map((snap) {
      return Task.fromMap(snap.id, snap.data() ?? {});
    });
  }

  @override
  Future<String> createTask(Task task, List<TaskStep> steps) async {
    final taskRef = _tasks.doc();
    final taskId = taskRef.id;

    final normalizedSteps = [
      for (var i = 0; i < steps.length; i++)
        steps[i].copyWith(
          id: steps[i].id.isEmpty ? 'step_$i' : steps[i].id,
          taskId: taskId,
          order: steps[i].order,
          isCompleted: false,
        ),
    ];

    await taskRef.set({
      ...task.toMap(),
      'steps': normalizedSteps.map((s) => s.toMap()).toList(),
    });
    return taskId;
  }

  @override
  Future<void> updateTask(Task task) =>
      _tasks.doc(task.id).set(task.toMap(), SetOptions(merge: true));

  @override
  Future<void> deleteTask(String taskId) => _tasks.doc(taskId).delete();

  @override
  Future<void> setStepCompleted(
    String taskId,
    String stepId, {
    required bool isCompleted,
  }) async {
    final ref = _tasks.doc(taskId);
    final snap = await ref.get();
    final task = Task.fromMap(taskId, snap.data() ?? {});

    final updatedSteps = [
      for (final step in task.steps)
        step.id == stepId ? step.copyWith(isCompleted: isCompleted) : step,
    ];

    await ref.update({
      'steps': updatedSteps.map((s) => s.toMap()).toList(),
      ..._statusFieldsFromSteps(updatedSteps),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeTask(String taskId) async {
    final ref = _tasks.doc(taskId);
    final snap = await ref.get();
    final task = Task.fromMap(taskId, snap.data() ?? {});

    final updatedSteps = [
      for (final step in task.steps) step.copyWith(isCompleted: true),
    ];

    await ref.update({
      'steps': updatedSteps.map((s) => s.toMap()).toList(),
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Campos de status derivados do estado dos passos (sem `updatedAt`).
  Map<String, dynamic> _statusFieldsFromSteps(List<TaskStep> steps) {
    if (steps.isEmpty) {
      return const {};
    }

    final done = steps.where((s) => s.isCompleted).length;
    final String status;
    if (done == 0) {
      status = 'pending';
    } else if (done >= steps.length) {
      status = 'completed';
    } else {
      status = 'in_progress';
    }

    return {
      'status': status,
      'completedAt':
          status == 'completed' ? FieldValue.serverTimestamp() : null,
    };
  }
}
