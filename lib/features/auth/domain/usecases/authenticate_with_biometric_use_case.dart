import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';

/// Aciona o diálogo biométrico nativo e devolve o resultado.
class AuthenticateWithBiometricUseCase {
  const AuthenticateWithBiometricUseCase(this._repository);
  final BiometricRepository _repository;

  Future<bool> call({required String reason}) =>
      _repository.authenticate(reason: reason);
}
