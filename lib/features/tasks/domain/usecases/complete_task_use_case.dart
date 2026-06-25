import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class CompleteTaskUseCase {
  const CompleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  /// Marca a tarefa como concluída e todos os seus passos como concluídos.
  Future<void> call(String taskId) => _repository.completeTask(taskId);
}
