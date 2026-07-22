import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class CreateTaskUseCase {
  const CreateTaskUseCase(this._repository);

  final TaskRepository _repository;

  /// Normaliza a ordem dos passos (0-indexed) e persiste a tarefa.
  Future<String> call(Task task, List<TaskStep> steps) {
    final ordered = [
      for (var i = 0; i < steps.length; i++)
        steps[i].copyWith(
          id: 'step_$i',
          order: i,
          isCompleted: false,
        ),
    ];
    return _repository.createTask(task, ordered);
  }
}
