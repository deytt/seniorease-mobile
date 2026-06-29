import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';

class MockCreateTaskUseCase extends Mock implements CreateTaskUseCase {}

class MockDeleteTaskUseCase extends Mock implements DeleteTaskUseCase {}

Task task(String id, {bool completed = false, DateTime? dueDate}) => Task(
      id: id,
      userId: 'u1',
      title: 'T$id',
      description: '',
      priority: TaskPriority.medium,
      category: TaskCategory.health,
      status: completed ? TaskStatus.completed : TaskStatus.pending,
      dueDate: dueDate,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  setUpAll(() {
    registerFallbackValue(task('fallback'));
    registerFallbackValue(const <TaskStep>[]);
  });

  group('TaskFilterNotifier', () {
    test('estado inicial é vazio e update altera o filtro', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(taskFilterProvider), TaskFilter.empty);

      container
          .read(taskFilterProvider.notifier)
          .update(const TaskFilter(isToday: true));

      expect(container.read(taskFilterProvider).isToday, isTrue);
    });
  });

  group('nextPendingTaskProvider', () {
    Future<Task?> resolveWith(List<Task> tasks) async {
      final container = ProviderContainer(overrides: [
        tasksStreamProvider.overrideWith((ref) => Stream.value(tasks)),
      ]);
      addTearDown(container.dispose);
      // Mantém uma subscrição ativa e deixa o event loop correr para o
      // Stream.value emitir antes de ler o provider derivado.
      container.listen(tasksStreamProvider, (_, _) {}, fireImmediately: true);
      await Future<void>.delayed(Duration.zero);
      return container.read(nextPendingTaskProvider);
    }

    test('devolve null quando não há tarefas pendentes', () async {
      final result = await resolveWith([task('a', completed: true)]);
      expect(result, isNull);
    });

    test('prefere a próxima tarefa futura mais próxima', () async {
      final now = DateTime.now();
      final result = await resolveWith([
        task('done', completed: true),
        task('far', dueDate: now.add(const Duration(days: 2))),
        task('near', dueDate: now.add(const Duration(days: 1))),
      ]);
      expect(result?.id, 'near');
    });

    test('fallback: sem futuras, devolve a primeira pendente', () async {
      final now = DateTime.now();
      final result = await resolveWith([
        task('noDate'),
        task('past', dueDate: now.subtract(const Duration(days: 1))),
      ]);
      expect(result?.id, 'noDate');
    });
  });

  group('TasksController', () {
    test('create: sucesso → AsyncData e devolve o id', () async {
      final useCase = MockCreateTaskUseCase();
      when(() => useCase.call(any(), any())).thenAnswer((_) async => 'new-id');

      final container = ProviderContainer(overrides: [
        createTaskUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(tasksControllerProvider.notifier);
      final id = await controller.create(task('a'), const []);

      expect(id, 'new-id');
      expect(container.read(tasksControllerProvider), isA<AsyncData<void>>());
    });

    test('create: erro → AsyncError e devolve null', () async {
      final useCase = MockCreateTaskUseCase();
      when(() => useCase.call(any(), any())).thenThrow(Exception('falha'));

      final container = ProviderContainer(overrides: [
        createTaskUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(tasksControllerProvider.notifier);
      final id = await controller.create(task('a'), const []);

      expect(id, isNull);
      expect(container.read(tasksControllerProvider), isA<AsyncError<void>>());
    });

    test('delete: sucesso → AsyncData e chama o use case', () async {
      final useCase = MockDeleteTaskUseCase();
      when(() => useCase.call(any())).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        deleteTaskUseCaseProvider.overrideWithValue(useCase),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(tasksControllerProvider.notifier);
      await controller.delete('t1');

      verify(() => useCase.call('t1')).called(1);
      expect(container.read(tasksControllerProvider), isA<AsyncData<void>>());
    });
  });
}
