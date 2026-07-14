import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';

/// Persiste as preferências de login (lembrar e-mail e método preferido).
class SaveLoginPreferencesUseCase {
  const SaveLoginPreferencesUseCase(this._repository);
  final LoginPreferencesRepository _repository;

  Future<void> call(LoginPreferences preferences) =>
      _repository.save(preferences);
}
