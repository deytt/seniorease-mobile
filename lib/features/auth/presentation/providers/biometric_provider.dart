import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile/features/auth/data/local_biometric_repository.dart';
import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';
import 'package:mobile/features/auth/domain/usecases/authenticate_with_biometric_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/check_biometric_availability_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/disable_biometric_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/enable_biometric_use_case.dart';

// --- Repositório ---

/// Cria o repositório de biometria de forma assíncrona; SharedPreferences é
/// obtido diretamente (mesmo padrão usado em LocalTutorialStateRepository).
final biometricRepositoryProvider =
    FutureProvider<BiometricRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocalBiometricRepository(
    prefs: prefs,
    auth: LocalAuthentication(),
  );
});

// --- Use cases ---

final checkBiometricAvailabilityUseCaseProvider =
    FutureProvider<CheckBiometricAvailabilityUseCase>((ref) async {
  final repo = await ref.watch(biometricRepositoryProvider.future);
  return CheckBiometricAvailabilityUseCase(repo);
});

final authenticateWithBiometricUseCaseProvider =
    FutureProvider<AuthenticateWithBiometricUseCase>((ref) async {
  final repo = await ref.watch(biometricRepositoryProvider.future);
  return AuthenticateWithBiometricUseCase(repo);
});

final enableBiometricUseCaseProvider =
    FutureProvider<EnableBiometricUseCase>((ref) async {
  final repo = await ref.watch(biometricRepositoryProvider.future);
  return EnableBiometricUseCase(repo);
});

final disableBiometricUseCaseProvider =
    FutureProvider<DisableBiometricUseCase>((ref) async {
  final repo = await ref.watch(biometricRepositoryProvider.future);
  return DisableBiometricUseCase(repo);
});

// --- Estado ---

/// `true` enquanto a sessão ainda não foi desbloqueada por biometria neste
/// arranque da app. O [BiometricLockScreen] define `false` após auth com sucesso.
/// É sessão-scoped (reset ao reiniciar a app).
final biometricLockedProvider =
    NotifierProvider<BiometricLockNotifier, bool>(BiometricLockNotifier.new);

class BiometricLockNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void unlock() => state = false;
  void reset() => state = true;
}

/// Leitura síncrona de se a biometria está ativada — derivada do controller
/// assíncrono com null-safety (devolve false enquanto carrega).
final biometricEnabledProvider = Provider<bool>((ref) {
  return ref.watch(biometricControllerProvider).asData?.value.isEnabled ?? false;
});

/// Estado imutável com as duas propriedades que a UI precisa.
class BiometricState {
  const BiometricState({
    required this.isAvailable,
    required this.isEnabled,
  });

  /// O dispositivo tem biometria configurada e disponível.
  final bool isAvailable;

  /// O utilizador ativou o desbloqueio biométrico neste dispositivo.
  final bool isEnabled;

  BiometricState copyWith({bool? isAvailable, bool? isEnabled}) =>
      BiometricState(
        isAvailable: isAvailable ?? this.isAvailable,
        isEnabled: isEnabled ?? this.isEnabled,
      );
}

// --- Controller ---

final biometricControllerProvider =
    AsyncNotifierProvider<BiometricController, BiometricState>(
  BiometricController.new,
);

class BiometricController extends AsyncNotifier<BiometricState> {
  @override
  Future<BiometricState> build() async {
    final repo = await ref.watch(biometricRepositoryProvider.future);
    final available = await repo.isAvailable();
    final enabled = repo.isEnabled();
    return BiometricState(isAvailable: available, isEnabled: enabled);
  }

  /// Tenta ativar a biometria. Devolve `true` se bem-sucedido ou `false` se o
  /// utilizador cancelou. Lança exceção se o dispositivo não tiver biometria.
  Future<bool> enable() async {
    final previous =
        state.asData?.value ??
        const BiometricState(isAvailable: false, isEnabled: false);
    state = const AsyncLoading();
    try {
      final useCase = await ref.read(enableBiometricUseCaseProvider.future);
      final confirmed = await useCase.call();
      if (confirmed) {
        state = AsyncData(previous.copyWith(isEnabled: true));
      } else {
        state = AsyncData(previous);
      }
      return confirmed;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Tenta desativar a biometria. Devolve `true` se bem-sucedido.
  Future<bool> disable() async {
    final previous =
        state.asData?.value ??
        const BiometricState(isAvailable: false, isEnabled: false);
    state = const AsyncLoading();
    try {
      final useCase = await ref.read(disableBiometricUseCaseProvider.future);
      final confirmed = await useCase.call();
      if (confirmed) {
        state = AsyncData(previous.copyWith(isEnabled: false));
      } else {
        state = AsyncData(previous);
      }
      return confirmed;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Autentica para aceder à app (usado na LoginScreen).
  Future<bool> authenticateForLogin() async {
    final useCase =
        await ref.read(authenticateWithBiometricUseCaseProvider.future);
    return useCase.call(
      reason: 'Entre na sua conta SeniorEase com biometria.',
    );
  }
}
