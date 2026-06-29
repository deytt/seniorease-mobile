/// Contrato para o estado **remoto** do onboarding inicial (partilhado entre
/// Web e Mobile via Firestore — collection `onboarding/{userId}`).
///
/// Guarda apenas o que é necessário sincronizar: se a boas-vindas inicial já
/// foi concluída ou recusada, para não voltar a aparecer automaticamente em
/// nenhuma plataforma ou dispositivo (ADR-013).
abstract interface class OnboardingRepository {
  Future<bool> isInitialTourCompleted(String userId);
  Future<void> completeInitialTour(String userId);
}
