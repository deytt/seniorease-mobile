import 'package:mobile/features/guides/domain/repositories/onboarding_repository.dart';

/// Indica se a boas-vindas inicial já foi concluída/recusada (Firestore).
class IsInitialTourCompletedUseCase {
  const IsInitialTourCompletedUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<bool> call(String userId) =>
      _repository.isInitialTourCompleted(userId);
}
