import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/tasks/data/firebase_task_repository.dart';
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

// --- Repositório ---

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return FirebaseTaskRepository(firestore: ref.watch(firebaseFirestoreProvider));
});

// --- Use cases ---

final getTasksUseCaseProvider = Provider<GetTasksUseCase>((ref) {
  return GetTasksUseCase(ref.watch(taskRepositoryProvider));
});

final getFilteredTasksUseCaseProvider = Provider<GetFilteredTasksUseCase>((ref) {
  return GetFilteredTasksUseCase(ref.watch(taskRepositoryProvider));
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

// --- Estado do filtro ---

/// Filtro activo na lista de tarefas. Alterado pelo bottom sheet de filtros.
final taskFilterProvider =
    NotifierProvider<TaskFilterNotifier, TaskFilter>(TaskFilterNotifier.new);

class TaskFilterNotifier extends Notifier<TaskFilter> {
  @override
  TaskFilter build() => TaskFilter.empty;

  void update(TaskFilter filter) => state = filter;
}

// --- Streams ---

/// Lista de tarefas do utilizador autenticado (sem filtro — usada internamente
/// pelo [nextPendingTaskProvider] e pelo pull-to-refresh).
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  return ref.read(getTasksUseCaseProvider).call(userId);
});

/// Lista filtrada de tarefas, derivada do [taskFilterProvider].
/// É o stream principal exibido pela [TaskListScreen].
final filteredTasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  final filter = ref.watch(taskFilterProvider);
  return ref.read(getFilteredTasksUseCaseProvider).call(userId, filter);
});

/// Próxima tarefa pendente para exibir no card "Próxima Atividade" da Home.
///
/// Critérios (por prioridade):
/// 1. Tarefa não concluída com dueDate >= agora, ordenada pela mais próxima.
/// 2. Se não houver, qualquer tarefa não concluída (sem dueDate ou dueDate passado).
/// Devolve `null` se não existirem tarefas pendentes.
final nextPendingTaskProvider = Provider<Task?>((ref) {
  final tasks = ref.watch(tasksStreamProvider).asData?.value ?? const [];
  final pending = tasks.where((t) => !t.isCompleted).toList();
  if (pending.isEmpty) return null;

  final now = DateTime.now();

  // Prefere a próxima tarefa com dueDate no futuro (ou agora)
  final upcoming = pending
      .where((t) => t.dueDate != null && !t.dueDate!.isBefore(now))
      .toList()
    ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));

  if (upcoming.isNotEmpty) return upcoming.first;

  // Fallback: tarefa mais recente sem data (ou com data já passada)
  return pending.first;
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
    final id = result.asData?.value;
    if (id != null) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.taskCreated,
            title: 'Criou a tarefa: ${task.title}',
            entityId: id,
            category: task.category.toFirestore(),
          );
    }
    return id;
  }

  Future<void> delete(String taskId) async {
    // Captura os dados antes de apagar (depois já não existem).
    final task = _findTask(taskId);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteTaskUseCaseProvider).call(taskId),
    );
    if (!state.hasError && task != null) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.taskDeleted,
            title: 'Removeu a tarefa: ${task.title}',
            entityId: taskId,
            category: task.category.toFirestore(),
          );
    }
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
    if (!state.hasError && isCompleted) {
      final task = _findTask(taskId);
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.taskStepCompleted,
            title: 'Concluiu um passo de: ${task?.title ?? 'uma tarefa'}',
            entityId: taskId,
            category: task?.category.toFirestore(),
          );
    }
  }

  Future<void> completeTask(String taskId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(completeTaskUseCaseProvider).call(taskId),
    );
    if (!state.hasError) {
      final task = _findTask(taskId);
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.taskCompleted,
            title: 'Concluiu: ${task?.title ?? 'uma tarefa'}',
            entityId: taskId,
            category: task?.category.toFirestore(),
          );
    }
  }

  /// Procura uma tarefa na cache do stream (sem passos, mas com título e
  /// categoria — suficiente para o registo de histórico).
  Task? _findTask(String taskId) {
    final tasks = ref.read(tasksStreamProvider).asData?.value ?? const [];
    for (final task in tasks) {
      if (task.id == taskId) return task;
    }
    return null;
  }
}
