import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.reauthenticateAndChangePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
