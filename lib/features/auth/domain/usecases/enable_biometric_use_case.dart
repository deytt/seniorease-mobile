import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';

/// Autentica com biometria e, em caso de sucesso, grava a preferência como
/// ativada. Lança [Exception] se o dispositivo não suportar biometria.
class EnableBiometricUseCase {
  const EnableBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  Future<bool> call() async {
    final available = await _repository.isAvailable();
    if (!available) {
      throw Exception(
        'O seu dispositivo não tem biometria disponível ou configurada.',
      );
    }

    final confirmed = await _repository.authenticate(
      reason:
          'Confirme a sua identidade para ativar o desbloqueio biométrico.',
    );
    if (!confirmed) return false;

    await _repository.setEnabled(value: true);
    return true;
  }
}
