import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';

void main() {
  group('TaskFilter', () {
    test('empty está vazio e tem activeCount 0', () {
      expect(TaskFilter.empty.isEmpty, isTrue);
      expect(TaskFilter.empty.activeCount, 0);
    });

    test('activeCount conta cada filtro ativo', () {
      const f = TaskFilter(
        category: TaskCategory.health,
        priority: TaskPriority.high,
        isToday: true,
      );
      expect(f.activeCount, 3);
      expect(f.isEmpty, isFalse);
    });

    test('copyWith mantém valores não fornecidos', () {
      const f = TaskFilter(category: TaskCategory.social, isToday: true);
      final updated = f.copyWith(priority: TaskPriority.low);
      expect(updated.category, TaskCategory.social);
      expect(updated.priority, TaskPriority.low);
      expect(updated.isToday, isTrue);
    });

    test('copyWith distingue null explícito de não fornecido (sentinela)', () {
      const f = TaskFilter(
        category: TaskCategory.social,
        priority: TaskPriority.low,
      );
      // Não fornecer priority → mantém-se.
      final keep = f.copyWith(category: TaskCategory.health);
      expect(keep.priority, TaskPriority.low);
      // Fornecer null explícito → remove.
      final cleared = f.copyWith(category: null);
      expect(cleared.category, isNull);
      expect(cleared.priority, TaskPriority.low);
    });

    test('removeCategory/removePriority/removeToday limpam o respetivo campo',
        () {
      const f = TaskFilter(
        category: TaskCategory.health,
        priority: TaskPriority.high,
        isToday: true,
      );
      expect(f.removeCategory().category, isNull);
      expect(f.removePriority().priority, isNull);
      expect(f.removeToday().isToday, isFalse);
    });

    test('igualdade de valor e hashCode', () {
      const a = TaskFilter(category: TaskCategory.health, isToday: true);
      const b = TaskFilter(category: TaskCategory.health, isToday: true);
      const c = TaskFilter(category: TaskCategory.exercise);
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });
  });
}
