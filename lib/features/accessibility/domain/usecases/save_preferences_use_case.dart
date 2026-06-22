import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/repositories/preferences_repository.dart';

class SavePreferencesUseCase {
  const SavePreferencesUseCase(this._repository);

  final PreferencesRepository _repository;

  /// Calcula [ContrastMode.maximum] automaticamente quando darkMode e high
  /// contrast estão ambos activos, depois persiste no repositório.
  Future<void> call(UserPreferences preferences) {
    final resolved = _resolveContrast(preferences);
    return _repository.save(resolved);
  }

  UserPreferences _resolveContrast(UserPreferences prefs) {
    if (prefs.darkMode && prefs.contrast == ContrastMode.high) {
      return prefs.copyWith(contrast: ContrastMode.maximum);
    }
    // Se o utilizador desligou darkMode mas mantinha maximum, baixa para high
    if (!prefs.darkMode && prefs.contrast == ContrastMode.maximum) {
      return prefs.copyWith(contrast: ContrastMode.high);
    }
    return prefs;
  }
}
