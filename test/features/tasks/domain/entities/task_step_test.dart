import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

void main() {
  group('TaskStep', () {
    test('valores por defeito (instruction vazia, não concluído)', () {
      const s = TaskStep(id: 's1', order: 0, title: 'Abrir a caixa');
      expect(s.instruction, '');
      expect(s.isCompleted, isFalse);
      expect(s.taskId, '');
    });

    test('copyWith altera apenas o fornecido', () {
      const s = TaskStep(id: 's1', order: 0, title: 'a');
      final updated = s.copyWith(order: 3, isCompleted: true, taskId: 't1');
      expect(updated.order, 3);
      expect(updated.isCompleted, isTrue);
      expect(updated.id, 's1');
      expect(updated.title, 'a');
      expect(updated.taskId, 't1');
    });

    test('toMap serializa os campos do contrato web/mobile', () {
      const s = TaskStep(
        id: 'step_0',
        taskId: 't1',
        order: 0,
        title: 'Tomar água',
        instruction: 'um copo',
        isCompleted: true,
      );
      expect(s.toMap(), {
        'id': 'step_0',
        'taskId': 't1',
        'order': 0,
        'title': 'Tomar água',
        'instruction': 'um copo',
        'isCompleted': true,
      });
    });

    test('fromMap reconstrói e aplica defaults', () {
      final s = TaskStep.fromMap('id1', {'title': 'x'});
      expect(s.id, 'id1');
      expect(s.taskId, '');
      expect(s.order, 0);
      expect(s.title, 'x');
      expect(s.instruction, '');
      expect(s.isCompleted, isFalse);
    });

    test('fromMap prefere id e taskId do mapa', () {
      final s = TaskStep.fromMap('fallback', {
        'id': 'step_0',
        'taskId': 't9',
        'order': 3.0,
        'title': 'x',
      });
      expect(s.id, 'step_0');
      expect(s.taskId, 't9');
      expect(s.order, 3);
    });
  });
}
