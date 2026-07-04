import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/accessibility/data/firebase_preferences_repository.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/repositories/preferences_repository.dart';
import 'package:mobile/features/accessibility/domain/usecases/get_preferences_use_case.dart';
import 'package:mobile/features/accessibility/domain/usecases/save_preferences_use_case.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

// --- Repositório ---

final preferencesRepositoryProvider = Provider<PreferencesRepository>((ref) {
  return FirebasePreferencesRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// --- Use cases ---

final getPreferencesUseCaseProvider = Provider<GetPreferencesUseCase>((ref) {
  return GetPreferencesUseCase(ref.watch(preferencesRepositoryProvider));
});

final savePreferencesUseCaseProvider = Provider<SavePreferencesUseCase>((ref) {
  return SavePreferencesUseCase(ref.watch(preferencesRepositoryProvider));
});

// --- Preferências do utilizador autenticado ---

/// Stream das preferências. Emite [UserPreferences.defaults()] quando não há
/// utilizador autenticado ou enquanto o Firestore não responde.
final preferencesProvider = StreamProvider<UserPreferences>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.asData?.value?.id;

  if (userId == null) {
    return Stream.value(UserPreferences.defaults());
  }

  return ref.read(getPreferencesUseCaseProvider).call(userId);
});

// --- Controller ---

final accessibilityControllerProvider =
    NotifierProvider<AccessibilityController, AsyncValue<void>>(
  AccessibilityController.new,
);

class AccessibilityController extends Notifier<AsyncValue<void>> {
  /// Evita registar múltiplos eventos de histórico quando o utilizador ajusta
  /// vários controlos seguidos: regista apenas 1 vez por sessão.
  bool _accessibilityLogged = false;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save(UserPreferences preferences) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(savePreferencesUseCaseProvider).call(preferences),
    );
    if (!state.hasError && !_accessibilityLogged) {
      _accessibilityLogged = true;
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.accessibilityChanged,
            title: 'Ajustou as opções de acessibilidade',
          );
    }
  }
}
