import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

abstract interface class TaskRepository {
  /// Stream de todas as tarefas do utilizador, ordenadas por `dueDate` DESC.
  Stream<List<Task>> watchTasks(String userId);

  /// Stream filtrada de tarefas aplicando os critérios de [filter] na query Firestore.
  /// Quando [filter] está vazio, comporta-se como [watchTasks].
  /// Ordenação: `dueDate` descendente (server-side).
  Stream<List<Task>> watchTasksFiltered(String userId, TaskFilter filter);

  /// Stream de uma tarefa individual (passos no campo `steps` do documento).
  Stream<Task> watchTask(String taskId);

  /// Cria a tarefa com o array `steps` no mesmo documento. Devolve o ID gerado.
  Future<String> createTask(Task task, List<TaskStep> steps);

  /// Atualiza os campos editáveis de uma tarefa (inclui `steps` se presentes).
  Future<void> updateTask(Task task);

  /// Remove a tarefa (o array `steps` é removido com o documento).
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
