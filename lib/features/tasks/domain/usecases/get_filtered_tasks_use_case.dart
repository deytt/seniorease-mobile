import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_filter.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class GetFilteredTasksUseCase {
  const GetFilteredTasksUseCase(this._repository);

  final TaskRepository _repository;

  Stream<List<Task>> call(String userId, TaskFilter filter) =>
      _repository.watchTasksFiltered(userId, filter);
}
