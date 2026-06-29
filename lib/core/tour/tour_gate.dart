import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/tour/tour_id.dart';

/// Port (abstração) que decide *quando* oferecer tutoriais automáticos e
/// persiste essa decisão.
///
/// Vive em `core/` como contrato puro. A implementação real ([AppTourGate])
/// está na camada `app/` (raiz de composição), que pode compor as features
/// `guides` (persistência) e `accessibility` (Modo Básico) sem que nenhuma
/// feature importe outra — é a inversão de dependência descrita no ADR-013.
///
/// As telas dependem **apenas deste port** (via [tourGateProvider]); nunca
/// conhecem `guides` nem `accessibility`.
abstract interface class TourGate {
  /// `true` se a boas-vindas inicial ainda não foi concluída/recusada.
  Future<bool> isInitialOnboardingPending();

  /// Regista que a boas-vindas inicial foi concluída ou recusada (não volta a
  /// aparecer automaticamente). Sincronizado no Firestore.
  Future<void> completeInitialOnboarding();

  /// `true` se devemos oferecer automaticamente o tutorial de [id] na primeira
  /// utilização do recurso (apenas em Modo Básico e se ainda não foi oferecido).
  Future<bool> shouldOfferFirstUse(TourId id);

  /// Regista que o tutorial de [id] já foi oferecido automaticamente (local).
  Future<void> markOffered(TourId id);

  /// Regista que o tutorial de [id] já foi visto (local).
  Future<void> markSeen(TourId id);
}

/// Implementação default no-op — mantém `core/` compilável e testável de forma
/// isolada. É substituída na `main.dart` por [AppTourGate] via `overrideWith`.
class NoopTourGate implements TourGate {
  const NoopTourGate();

  @override
  Future<bool> isInitialOnboardingPending() async => false;

  @override
  Future<void> completeInitialOnboarding() async {}

  @override
  Future<bool> shouldOfferFirstUse(TourId id) async => false;

  @override
  Future<void> markOffered(TourId id) async {}

  @override
  Future<void> markSeen(TourId id) async {}
}

final tourGateProvider = Provider<TourGate>((ref) => const NoopTourGate());
