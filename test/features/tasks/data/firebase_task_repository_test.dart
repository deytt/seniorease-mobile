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
    List<Map<String, dynamic>> steps = const [],
  }) {
    return db.collection('tasks').doc(id).set({
      'userId': userId,
      'title': 'T$id',
      'description': '',
      'priority': priority,
      'category': category,
      'status': status.toFirestore(),
      // dueDate é obrigatório para aparecer em orderBy('dueDate') no Firestore.
      'dueDate': Timestamp.fromDate(dueDate ?? DateTime(2026, 6, 1)),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt) : null,
      'createdAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
      'updatedAt': Timestamp.fromDate(createdAt ?? DateTime(2026, 1, 1)),
      'steps': steps,
    });
  }

  List<Map<String, dynamic>> stepsMaps(String taskId, int count,
      {Set<int> completed = const {}}) {
    return [
      for (var i = 0; i < count; i++)
        {
          'id': 'step_$i',
          'taskId': taskId,
          'order': i,
          'title': 'passo step_$i',
          'instruction': '',
          'isCompleted': completed.contains(i),
        },
    ];
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
    test('cria a tarefa com steps no documento e devolve o id gerado', () async {
      final id = await repo.createTask(newTask(), [
        const TaskStep(id: 'step_0', order: 0, title: 'A'),
        const TaskStep(id: 'step_1', order: 1, title: 'B'),
      ]);

      final doc = await db.collection('tasks').doc(id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['title'], 'Nova');

      final steps = doc.data()!['steps'] as List<dynamic>;
      expect(steps, hasLength(2));
      expect(steps[0]['id'], 'step_0');
      expect(steps[0]['taskId'], id);
      expect(steps[0]['title'], 'A');
      expect(steps[1]['order'], 1);
      expect(steps[1]['taskId'], id);
    });
  });

  group('watchTasksFiltered', () {
    test('ordena por dueDate descendente (maior data primeiro)', () async {
      await seedTask('a', dueDate: DateTime(2026, 6, 10));
      await seedTask('b', dueDate: DateTime(2026, 6, 5));
      await seedTask('c',
          status: TaskStatus.completed,
          dueDate: DateTime(2026, 6, 15),
          completedAt: DateTime(2026, 6, 1));

      final tasks = await repo.watchTasksFiltered('u1', TaskFilter.empty).first;
      expect(tasks.map((t) => t.id).toList(), ['c', 'a', 'b']);
    });

    test('filtra por categoria', () async {
      await seedTask('a',
          category: 'health', dueDate: DateTime(2026, 6, 10));
      await seedTask('b',
          category: 'exercise', dueDate: DateTime(2026, 6, 11));

      final tasks = await repo
          .watchTasksFiltered(
            'u1',
            const TaskFilter(category: TaskCategory.exercise),
          )
          .first;
      expect(tasks.map((t) => t.id).toList(), ['b']);
    });

    test('só devolve tarefas do utilizador', () async {
      await seedTask('a', userId: 'u1', dueDate: DateTime(2026, 6, 10));
      await seedTask('b', userId: 'u2', dueDate: DateTime(2026, 6, 11));

      final tasks = await repo.watchTasksFiltered('u1', TaskFilter.empty).first;
      expect(tasks.map((t) => t.id).toList(), ['a']);
    });

    test('inclui steps do documento na lista', () async {
      await seedTask('t',
          dueDate: DateTime(2026, 6, 10), steps: stepsMaps('t', 2));

      final tasks = await repo.watchTasksFiltered('u1', TaskFilter.empty).first;
      expect(tasks.single.steps, hasLength(2));
      expect(tasks.single.steps.first.id, 'step_0');
    });
  });

  group('deleteTask', () {
    test('remove a tarefa (steps vão com o documento)', () async {
      await seedTask('t', steps: stepsMaps('t', 2));

      await repo.deleteTask('t');

      expect((await db.collection('tasks').doc('t').get()).exists, isFalse);
    });
  });

  group('setStepCompleted — sincroniza o status', () {
    test('parcial → in_progress; todos → completed; nenhum → pending',
        () async {
      await seedTask('t', steps: stepsMaps('t', 2));

      Future<String> status() async =>
          (await db.collection('tasks').doc('t').get()).data()!['status']
              as String;

      await repo.setStepCompleted('t', 'step_0', isCompleted: true);
      expect(await status(), 'in_progress');

      await repo.setStepCompleted('t', 'step_1', isCompleted: true);
      expect(await status(), 'completed');

      await repo.setStepCompleted('t', 'step_0', isCompleted: false);
      expect(await status(), 'in_progress');
    });
  });

  group('completeTask', () {
    test('marca todos os passos e o status como completed', () async {
      await seedTask('t', steps: stepsMaps('t', 2));

      await repo.completeTask('t');

      final task = await db.collection('tasks').doc('t').get();
      expect(task.data()!['status'], 'completed');

      final steps = task.data()!['steps'] as List<dynamic>;
      expect(steps.every((s) => s['isCompleted'] == true), isTrue);
    });
  });

  group('watchTask', () {
    test('emite a tarefa com os passos ordenados por order', () async {
      await seedTask('t', steps: [
        {
          'id': 'step_1',
          'taskId': 't',
          'order': 1,
          'title': 'segundo',
          'instruction': '',
          'isCompleted': false,
        },
        {
          'id': 'step_0',
          'taskId': 't',
          'order': 0,
          'title': 'primeiro',
          'instruction': '',
          'isCompleted': false,
        },
      ]);

      final task = await repo.watchTask('t').first;
      expect(task.id, 't');
      expect(task.steps.map((s) => s.order).toList(), [0, 1]);
      expect(task.steps.map((s) => s.title).toList(), ['primeiro', 'segundo']);
    });
  });
}
