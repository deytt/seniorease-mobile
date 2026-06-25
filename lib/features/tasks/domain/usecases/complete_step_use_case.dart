import 'package:mobile/features/tasks/domain/repositories/task_repository.dart';

class CompleteStepUseCase {
  const CompleteStepUseCase(this._repository);

  final TaskRepository _repository;

  Future<void> call(
    String taskId,
    String stepId, {
    required bool isCompleted,
  }) =>
      _repository.setStepCompleted(taskId, stepId, isCompleted: isCompleted);
}
