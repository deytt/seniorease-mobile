import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  /// [preferSilent] — ver [AuthRepository.signInWithGoogle].
  Future<AppUser> call({bool preferSilent = false}) {
    return _repository.signInWithGoogle(preferSilent: preferSilent);
  }
}
