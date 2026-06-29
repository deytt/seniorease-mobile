import 'package:mobile/features/guides/domain/repositories/onboarding_repository.dart';

/// Regista que a boas-vindas inicial foi concluída/recusada (Firestore), para
/// não voltar a aparecer automaticamente em nenhuma plataforma.
class CompleteInitialTourUseCase {
  const CompleteInitialTourUseCase(this._repository);

  final OnboardingRepository _repository;

  Future<void> call(String userId) => _repository.completeInitialTour(userId);
}
