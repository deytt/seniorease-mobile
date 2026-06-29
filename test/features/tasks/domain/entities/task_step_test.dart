import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

void main() {
  group('TaskStep', () {
    test('valores por defeito (instruction vazia, não concluído)', () {
      const s = TaskStep(id: 's1', order: 1, title: 'Abrir a caixa');
      expect(s.instruction, '');
      expect(s.isCompleted, isFalse);
    });

    test('copyWith altera apenas o fornecido', () {
      const s = TaskStep(id: 's1', order: 1, title: 'a');
      final updated = s.copyWith(order: 3, isCompleted: true);
      expect(updated.order, 3);
      expect(updated.isCompleted, isTrue);
      expect(updated.id, 's1');
      expect(updated.title, 'a');
    });

    test('toMap serializa os campos', () {
      const s = TaskStep(
        id: 's1',
        order: 2,
        title: 'Tomar água',
        instruction: 'um copo',
        isCompleted: true,
      );
      expect(s.toMap(), {
        'order': 2,
        'title': 'Tomar água',
        'instruction': 'um copo',
        'isCompleted': true,
      });
    });

    test('fromMap reconstrói e aplica defaults', () {
      final s = TaskStep.fromMap('id1', {'title': 'x'});
      expect(s.id, 'id1');
      expect(s.order, 0);
      expect(s.title, 'x');
      expect(s.instruction, '');
      expect(s.isCompleted, isFalse);
    });

    test('fromMap converte order numérico (num → int)', () {
      final s = TaskStep.fromMap('id1', {'order': 3.0, 'title': 'x'});
      expect(s.order, 3);
    });
  });
}
