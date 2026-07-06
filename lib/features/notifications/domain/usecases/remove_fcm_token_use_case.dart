import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';

class RemoveFcmTokenUseCase {
  const RemoveFcmTokenUseCase(this._repository);

  final FcmTokenRepository _repository;

  Future<void> call({required String userId, required String token}) =>
      _repository.removeToken(userId: userId, token: token);
}
