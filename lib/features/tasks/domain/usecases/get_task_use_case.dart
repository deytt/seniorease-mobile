import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class GetTaskUseCase {
  const GetTaskUseCase(this._repository);

  final TaskRepository _repository;

  Stream<Task> call(String taskId) => _repository.watchTask(taskId);
}
