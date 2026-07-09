import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';

/// Verifica se o dispositivo tem suporte e biometria registada.
class CheckBiometricAvailabilityUseCase {
  const CheckBiometricAvailabilityUseCase(this._repository);
  final BiometricRepository _repository;

  Future<bool> call() => _repository.isAvailable();
}
