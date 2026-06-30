import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';

class SaveUserProfileUseCase {
  const SaveUserProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> call(UserProfile profile) => _repository.save(profile);
}
