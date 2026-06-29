import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

void main() {
  TaskStep step(String id, {bool done = false}) =>
      TaskStep(id: id, order: 1, title: 'passo $id', isCompleted: done);

  Task baseTask({
    TaskStatus status = TaskStatus.pending,
    List<TaskStep> steps = const [],
  }) =>
      Task(
        id: 't1',
        userId: 'u1',
        title: 'Tomar remédio',
        description: 'descrição',
        priority: TaskPriority.high,
        category: TaskCategory.medication,
        status: status,
        steps: steps,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );

  group('TaskPriority', () {
    test('fromString mapeia valores conhecidos e faz fallback para medium', () {
      expect(TaskPriority.fromString('low'), TaskPriority.low);
      expect(TaskPriority.fromString('high'), TaskPriority.high);
      expect(TaskPriority.fromString('desconhecido'), TaskPriority.medium);
    });

    test('labels e toFirestore', () {
      expect(TaskPriority.high.label, 'alta');
      expect(TaskPriority.high.fullLabel, 'Prioridade Alta');
      expect(TaskPriority.low.toFirestore(), 'low');
    });
  });

  group('TaskCategory', () {
    test('fromString com fallback para health', () {
      expect(TaskCategory.fromString('exercise'), TaskCategory.exercise);
      expect(TaskCategory.fromString('xpto'), TaskCategory.health);
    });

    test('label em português', () {
      expect(TaskCategory.medication.label, 'Medicação');
      expect(TaskCategory.social.label, 'Social');
    });
  });

  group('TaskStatus', () {
    test('fromString e toFirestore (in_progress)', () {
      expect(TaskStatus.fromString('in_progress'), TaskStatus.inProgress);
      expect(TaskStatus.fromString('completed'), TaskStatus.completed);
      expect(TaskStatus.fromString('x'), TaskStatus.pending);
      expect(TaskStatus.inProgress.toFirestore(), 'in_progress');
    });

    test('isCompleted', () {
      expect(TaskStatus.completed.isCompleted, isTrue);
      expect(TaskStatus.pending.isCompleted, isFalse);
    });
  });

  group('Task — getters derivados', () {
    test('progress 0 quando sem passos e pendente', () {
      expect(baseTask().progress, 0.0);
    });

    test('progress 1 quando sem passos mas concluída', () {
      expect(baseTask(status: TaskStatus.completed).progress, 1.0);
    });

    test('completedSteps/totalSteps/progress com passos', () {
      final t = baseTask(
        steps: [step('a', done: true), step('b'), step('c', done: true)],
      );
      expect(t.totalSteps, 3);
      expect(t.completedSteps, 2);
      expect(t.progress, closeTo(2 / 3, 0.0001));
    });

    test('isCompleted reflete o status', () {
      expect(baseTask(status: TaskStatus.completed).isCompleted, isTrue);
      expect(baseTask().isCompleted, isFalse);
    });
  });

  group('Task.copyWith', () {
    test('mantém valores não fornecidos e altera os fornecidos', () {
      final t = baseTask();
      final updated = t.copyWith(title: 'Novo', status: TaskStatus.completed);
      expect(updated.title, 'Novo');
      expect(updated.status, TaskStatus.completed);
      expect(updated.id, t.id);
      expect(updated.priority, t.priority);
    });
  });

  group('Task mapeamento Firestore', () {
    test('toMap serializa enums e datas', () {
      final map = baseTask(status: TaskStatus.inProgress).toMap();
      expect(map['userId'], 'u1');
      expect(map['priority'], 'high');
      expect(map['category'], 'medication');
      expect(map['status'], 'in_progress');
      expect(map['createdAt'], isA<Timestamp>());
      // updatedAt é sempre serverTimestamp na escrita.
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('fromMap reconstrói a entidade e usa defaults para campos ausentes',
        () {
      final task = Task.fromMap('id1', {
        'userId': 'u9',
        'title': 'Caminhada',
        'priority': 'low',
        'category': 'exercise',
        'status': 'completed',
        'createdAt': Timestamp.fromDate(DateTime(2026, 5, 1)),
        'updatedAt': Timestamp.fromDate(DateTime(2026, 5, 2)),
      });
      expect(task.id, 'id1');
      expect(task.userId, 'u9');
      expect(task.description, ''); // ausente → default
      expect(task.priority, TaskPriority.low);
      expect(task.category, TaskCategory.exercise);
      expect(task.status, TaskStatus.completed);
      expect(task.createdAt, DateTime(2026, 5, 1));
    });

    test('fromMap aceita passos injetados', () {
      final task = Task.fromMap(
        'id1',
        {'userId': 'u', 'title': 't'},
        steps: [step('s1')],
      );
      expect(task.steps, hasLength(1));
      expect(task.steps.first.id, 's1');
    });
  });
}
