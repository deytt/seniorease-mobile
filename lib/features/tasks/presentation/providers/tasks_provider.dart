import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/tasks/data/firebase_task_repository.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';
import 'package:mobile/features/tasks/domain/usecases/complete_step_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/complete_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/create_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/delete_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/get_task_use_case.dart';
import 'package:mobile/features/tasks/domain/usecases/get_tasks_use_case.dart';

// --- Repositório ---

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository();
});

// --- Use cases ---

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final getTaskUseCaseProvider = Provider<GetTaskUseCase>((ref) {
  return GetTaskUseCase(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTaskUseCase>((ref) {
  return CreateTaskUseCase(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTaskUseCase>((ref) {
  return DeleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

final completeStepUseCaseProvider = Provider<CompleteStepUseCase>((ref) {
  return CompleteStepUseCase(ref.watch(taskRepositoryProvider));
});

final completeTaskUseCaseProvider = Provider<CompleteTaskUseCase>((ref) {
  return CompleteTaskUseCase(ref.watch(taskRepositoryProvider));
});

// --- Streams ---

/// Lista de tarefas do utilizador autenticado.
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  return ref.read(getTasksUseCaseProvider).call(userId);
});

/// Stream de uma tarefa individual (com passos).
final taskStreamProvider = StreamProvider.family<Task, String>((ref, taskId) {
  return ref.read(getTaskUseCaseProvider).call(taskId);
});

// --- Controller ---

final tasksControllerProvider =
    NotifierProvider<TasksController, AsyncValue<void>>(TasksController.new);

class TasksController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Cria uma nova tarefa. Devolve o ID gerado ou `null` em caso de erro.
  Future<String?> create(Task task, List<TaskStep> steps) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(createTaskUseCaseProvider).call(task, steps),
    );
    state = result.whenData((_) {});
    return result.asData?.value;
  }

  Future<void> delete(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteTaskUseCaseProvider).call(taskId),
    );
  }

  Future<void> setStepCompleted(
    String taskId,
    String stepId, {
    required bool isCompleted,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(completeStepUseCaseProvider)
          .call(taskId, stepId, isCompleted: isCompleted),
    );
  }

  Future<void> completeTask(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(completeTaskUseCaseProvider).call(taskId),
    );
  }
}
