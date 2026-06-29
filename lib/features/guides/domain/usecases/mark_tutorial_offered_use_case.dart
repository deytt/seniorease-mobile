import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/domain/repositories/tutorial_state_repository.dart';

/// Regista que um tutorial já foi oferecido automaticamente.
class MarkTutorialOfferedUseCase {
  const MarkTutorialOfferedUseCase(this._repository);

  final TutorialStateRepository _repository;

  Future<void> call(String userId, TourId id) =>
      _repository.markOffered(userId, id);
}
