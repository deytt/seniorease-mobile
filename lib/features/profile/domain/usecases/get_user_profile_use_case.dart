import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';

class GetUserProfileUseCase {
  const GetUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Stream<UserProfile> call(String userId) => _repository.watch(userId);
}
