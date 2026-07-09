import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';

/// Autentica com biometria e, em caso de sucesso, grava a preferência como
/// desativada.
class DisableBiometricUseCase {
  const DisableBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  Future<bool> call() async {
    final confirmed = await _repository.authenticate(
      reason:
          'Confirme a sua identidade para desativar o desbloqueio biométrico.',
    );
    if (!confirmed) return false;

    await _repository.setEnabled(value: false);
    return true;
  }
}
