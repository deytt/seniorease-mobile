import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

abstract interface class TaskRepository {
  /// Stream de todas as tarefas do utilizador (sem os passos), ordenadas por
  /// data de criação descendente.
  Stream<List<Task>> watchTasks(String userId);

  /// Stream de uma tarefa individual, incluindo os seus passos.
  Stream<Task> watchTask(String taskId);

  /// Cria a tarefa e os seus passos de forma atómica. Devolve o ID gerado.
  Future<String> createTask(Task task, List<TaskStep> steps);

  /// Atualiza os campos editáveis de uma tarefa.
  Future<void> updateTask(Task task);

  /// Remove a tarefa e todos os seus passos.
  Future<void> deleteTask(String taskId);

  /// Marca/desmarca um passo como concluído.
  Future<void> setStepCompleted(
    String taskId,
    String stepId, {
    required bool isCompleted,
  });

  /// Marca a tarefa como concluída e todos os seus passos como concluídos.
  Future<void> completeTask(String taskId);
}
