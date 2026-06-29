import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/guides/presentation/providers/tour_providers.dart';

/// Implementação do port [TourGate] na camada `app/` (raiz de composição).
///
/// É o único ponto que combina as features `guides` (persistência do tour) e
/// `accessibility` (Modo Básico), mantendo a inversão de dependência: as telas
/// dependem apenas do port em `core/`, nunca destas features (ADR-013).
class AppTourGate implements TourGate {
  AppTourGate(this._ref);

  final Ref _ref;

  String? get _userId => _ref.read(authStateProvider).asData?.value?.id;

  @override
  Future<bool> isInitialOnboardingPending() async {
    final userId = _userId;
    if (userId == null) return false;
    final completed =
        await _ref.read(isInitialTourCompletedUseCaseProvider).call(userId);
    return !completed;
  }

  @override
  Future<void> completeInitialOnboarding() async {
    final userId = _userId;
    if (userId == null) return;
    await _ref.read(completeInitialTourUseCaseProvider).call(userId);
  }

  @override
  Future<bool> shouldOfferFirstUse(TourId id) async {
    final userId = _userId;
    if (userId == null) return false;

    // Regra do Modo Básico — leitura legítima de uma preferência de
    // acessibilidade. Em Modo Avançado nunca interrompemos automaticamente.
    final prefs = _ref.read(preferencesProvider).asData?.value;
    if (prefs?.interfaceMode != InterfaceMode.basic) return false;

    return _ref.read(shouldOfferTutorialUseCaseProvider).call(userId, id);
  }

  @override
  Future<void> markOffered(TourId id) async {
    final userId = _userId;
    if (userId == null) return;
    await _ref.read(markTutorialOfferedUseCaseProvider).call(userId, id);
  }

  @override
  Future<void> markSeen(TourId id) async {
    final userId = _userId;
    if (userId == null) return;
    await _ref.read(markTutorialSeenUseCaseProvider).call(userId, id);
  }
}
