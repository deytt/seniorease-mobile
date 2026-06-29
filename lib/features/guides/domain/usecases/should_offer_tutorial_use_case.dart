import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/domain/repositories/tutorial_state_repository.dart';

/// Decide se um tutorial ainda deve ser oferecido automaticamente (i.e. nunca
/// foi oferecido antes neste dispositivo).
class ShouldOfferTutorialUseCase {
  const ShouldOfferTutorialUseCase(this._repository);

  final TutorialStateRepository _repository;

  Future<bool> call(String userId, TourId id) async =>
      !await _repository.isOffered(userId, id);
}
