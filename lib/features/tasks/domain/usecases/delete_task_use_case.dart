import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class DeleteTaskUseCase {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(String taskId) => _repository.deleteTask(taskId);
}
