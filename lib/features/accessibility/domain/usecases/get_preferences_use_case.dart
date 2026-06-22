import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/repositories/preferences_repository.dart';

class GetPreferencesUseCase {
  const GetPreferencesUseCase(this._repository);

  final PreferencesRepository _repository;

  Stream<UserPreferences> call(String userId) =>
      _repository.watch(userId);
}
