import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

abstract interface class PreferencesRepository {
  /// Stream das preferências do utilizador. Emite [UserPreferences.defaults()]
  /// enquanto o documento não existir no Firestore.
  Stream<UserPreferences> watch(String userId);

  /// Persiste as preferências no Firestore.
  Future<void> save(UserPreferences preferences);
}
