import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class SendEmailVerificationUseCase {
  const SendEmailVerificationUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call() {
    return _repository.sendEmailVerification();
  }
}
