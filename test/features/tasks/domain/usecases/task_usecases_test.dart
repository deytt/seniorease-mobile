import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:mobile/features/tasks/domain/usecases/complete_step_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/get_filtered_tasks_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/get_tasks_use_case.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

Task _task() => Task(
      id: 't1',
      userId: 'u1',
      title: 'Tarefa',
      description: '',
      priority: TaskPriority.medium,
      category: TaskCategory.health,
      status: TaskStatus.pending,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  late MockTaskRepository repo;

  setUpAll(() {
    registerFallbackValue(_task());
    registerFallbackValue(const <TaskStep>[]);
    registerFallbackValue(TaskFilter.empty);
  });

  setUp(() => repo = MockTaskRepository());

  group('GetTasksUseCase', () {
    test('delega para watchTasks', () {
      when(() => repo.watchTasks(any())).thenAnswer((_) => Stream.value(const []));
      GetTasksUseCase(repo).call('u1');
      verify(() => repo.watchTasks('u1')).called(1);
    });
  });

  group('GetFilteredTasksUseCase', () {
    test('delega para watchTasksFiltered com o filtro', () {
      const filter = TaskFilter(category: TaskCategory.health);
      when(() => repo.watchTasksFiltered(any(), any()))
          .thenAnswer((_) => Stream.value(const []));
      GetFilteredTasksUseCase(repo).call('u1', filter);
      verify(() => repo.watchTasksFiltered('u1', filter)).called(1);
    });
  });

  group('GetTaskUseCase', () {
    test('delega para watchTask', () {
      when(() => repo.watchTask(any())).thenAnswer((_) => Stream.value(_task()));
      GetTaskUseCase(repo).call('t1');
      verify(() => repo.watchTask('t1')).called(1);
    });
  });

  group('CreateTaskUseCase', () {
    test('normaliza a ordem dos passos (1-indexed) e zera isCompleted', () async {
      when(() => repo.createTask(any(), any())).thenAnswer((_) async => 'new-id');

      final steps = [
        const TaskStep(id: 'a', order: 99, title: 'A', isCompleted: true),
        const TaskStep(id: 'b', order: 5, title: 'B', isCompleted: true),
      ];

      final id = await CreateTaskUseCase(repo).call(_task(), steps);
      expect(id, 'new-id');

      final captured = verify(() => repo.createTask(any(), captureAny()))
          .captured
          .single as List<TaskStep>;
      expect(captured.map((s) => s.order), [1, 2]);
      expect(captured.every((s) => !s.isCompleted), isTrue);
    });
  });

  group('DeleteTaskUseCase', () {
    test('delega para deleteTask', () async {
      when(() => repo.deleteTask(any())).thenAnswer((_) async {});
      await DeleteTaskUseCase(repo).call('t1');
      verify(() => repo.deleteTask('t1')).called(1);
    });
  });

  group('CompleteStepUseCase', () {
    test('delega para setStepCompleted com o flag', () async {
      when(() => repo.setStepCompleted(any(), any(),
          isCompleted: any(named: 'isCompleted'))).thenAnswer((_) async {});
      await CompleteStepUseCase(repo).call('t1', 's1', isCompleted: true);
      verify(() => repo.setStepCompleted('t1', 's1', isCompleted: true))
          .called(1);
    });
  });

  group('CompleteTaskUseCase', () {
    test('delega para completeTask', () async {
      when(() => repo.completeTask(any())).thenAnswer((_) async {});
      await CompleteTaskUseCase(repo).call('t1');
      verify(() => repo.completeTask('t1')).called(1);
    });
  });
}
