import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';

class RegisterFcmTokenUseCase {
  const RegisterFcmTokenUseCase(this._repository);

  final FcmTokenRepository _repository;

  Future<void> call({
    required String userId,
    required String token,
    required String platform,
  }) =>
      _repository.saveToken(
        userId: userId,
        token: token,
        platform: platform,
      );
}
