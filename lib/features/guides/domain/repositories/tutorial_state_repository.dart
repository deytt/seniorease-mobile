import 'package:mobile/core/tour/tour_id.dart';

/// Contrato para o estado **local** de cada tutorial (por dispositivo).
///
/// Guarda apenas se um tutorial já foi "oferecido" automaticamente e se já foi
/// "visto". É informação efémera/por-dispositivo — não precisa de sincronização
/// no Firestore (ADR-013).
abstract interface class TutorialStateRepository {
  Future<bool> isOffered(String userId, TourId id);
  Future<void> markOffered(String userId, TourId id);
  Future<bool> isSeen(String userId, TourId id);
  Future<void> markSeen(String userId, TourId id);
}
