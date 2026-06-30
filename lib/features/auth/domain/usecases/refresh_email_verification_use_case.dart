import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class RefreshEmailVerificationUseCase {
  const RefreshEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.reloadAndCheckEmailVerified();
  }
}
