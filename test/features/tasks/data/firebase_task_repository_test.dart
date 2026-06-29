import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tasks/data/firebase_task_repository.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseTaskRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseTaskRepository(firestore: db);
  });

  Future<void> seedTask(
    String id, {
    String userId = 'u1',
    TaskStatus status = TaskStatus.pending,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    String category = 'health',
    String priority = 'medium',
  }) {
    return db.collection('tasks').doc(id).set({
      'userId': userId,
      'title': 'T$id',
      'description': '',
      'priority': priority,
      'category': category,
      'status': status.toFirestore(),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt) : null,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
    });
  }

  Future<void> seedStep(
    String taskId,
    String stepId, {
    required int order,
    bool isCompleted = false,
  }) {
    return db
        .collection('tasks')
        .doc(taskId)
        .collection('steps')
        .doc(stepId)
        .set({
      'order': order,
      'title': 'passo $stepId',
      'instruction': '',
      'isCompleted': isCompleted,
    });
  }

  Task newTask() => Task(
        id: 'ignored',
        userId: 'u1',
        title: 'Nova',
        description: 'desc',
        priority: TaskPriority.high,
        category: TaskCategory.medication,
        status: TaskStatus.pending,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  group('createTask', () {
    test('cria a tarefa + passos atomicamente e devolve o id gerado', () async {
      final id = await repo.createTask(newTask(), [
        const TaskStep(id: 'x', order: 1, title: 'A'),
        const TaskStep(id: 'y', order: 2, title: 'B'),
      ]);

      final doc = await db.collection('tasks').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Nova');

      final steps =
          await db.collection('tasks').doc(id).collection('steps').get();
      expect(steps.docs, hasLength(2));
    });
  });

  group('watchTasksFiltered', () {
    test('ordena pendentes (dueDate asc) antes das concluídas', () async {
      await seedTask('a', dueDate: DateTime(2026, 6, 10));
      await seedTask('b', dueDate: DateTime(2026, 6, 5));
      await seedTask('c',
          status: TaskStatus.completed, completedAt: DateTime(2026, 6, 1));

      final tasks = await repo.watchTasksFiltered('u1', TaskFilter.empty).first;
      expect(tasks.map((t) => t.id).toList(), ['b', 'a', 'c']);
    });

    test('filtra por categoria', () async {
      await seedTask('a', category: 'health');
      await seedTask('b', category: 'exercise');

      final tasks = await repo
          .watchTasksFiltered(
            'u1',
            const TaskFilter(category: TaskCategory.exercise),
          )
          .first;
      expect(tasks.map((t) => t.id).toList(), ['b']);
    });

    test('só devolve tarefas do utilizador', () async {
      await seedTask('a', userId: 'u1');
      await seedTask('b', userId: 'u2');

      final tasks = await repo.watchTasksFiltered('u1', TaskFilter.empty).first;
      expect(tasks.map((t) => t.id).toList(), ['a']);
    });
  });

  group('deleteTask', () {
    test('remove a tarefa e os seus passos', () async {
      await seedTask('t');
      await seedStep('t', 's1', order: 1);
      await seedStep('t', 's2', order: 2);

      await repo.deleteTask('t');

      expect((await db.collection('tasks').doc('t').get()).exists, isFalse);
      final steps =
          await db.collection('tasks').doc('t').collection('steps').get();
      expect(steps.docs, isEmpty);
    });
  });

  group('setStepCompleted — sincroniza o status', () {
    test('parcial → in_progress; todos → completed; nenhum → pending', () async {
      await seedTask('t');
      await seedStep('t', 's1', order: 1);
      await seedStep('t', 's2', order: 2);

      Future<String> status() async =>
          (await db.collection('tasks').doc('t').get()).data()!['status']
              as String;

      await repo.setStepCompleted('t', 's1', isCompleted: true);
      expect(await status(), 'in_progress');

      await repo.setStepCompleted('t', 's2', isCompleted: true);
      expect(await status(), 'completed');

      await repo.setStepCompleted('t', 's1', isCompleted: false);
      expect(await status(), 'in_progress');
    });
  });

  group('completeTask', () {
    test('marca todos os passos e o status como completed', () async {
      await seedTask('t');
      await seedStep('t', 's1', order: 1);
      await seedStep('t', 's2', order: 2);

      await repo.completeTask('t');

      final task = await db.collection('tasks').doc('t').get();
      expect(task.data()!['status'], 'completed');

      final steps =
          await db.collection('tasks').doc('t').collection('steps').get();
      expect(steps.docs.every((d) => d.data()['isCompleted'] == true), isTrue);
    });
  });

  group('watchTask', () {
    test('emite a tarefa com os passos ordenados por order', () async {
      await seedTask('t');
      await seedStep('t', 's2', order: 2);
      await seedStep('t', 's1', order: 1);

      // watchTask combina os snapshots da tarefa e dos passos; a 1ª emissão
      // pode chegar antes dos passos, por isso esperamos a que já os contém.
      final task =
          await repo.watchTask('t').firstWhere((t) => t.steps.length == 2);
      expect(task.id, 't');
      expect(task.steps.map((s) => s.order).toList(), [1, 2]);
    });
  });
}
