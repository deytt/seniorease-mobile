import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chaves usadas no [SharedPreferences] para as preferências de login.
const _kRememberMe = 'login_remember_me';
const _kLastEmail = 'login_last_email';
const _kLastMethod = 'login_last_method';

/// Implementação de [LoginPreferencesRepository] baseada em [SharedPreferences].
///
/// A instância é injetada para facilitar testes unitários — ver
/// `loginPreferencesRepositoryProvider`.
class LocalLoginPreferencesRepository implements LoginPreferencesRepository {
  LocalLoginPreferencesRepository({required SharedPreferences prefs})
      : _prefs = prefs;

  final SharedPreferences _prefs;

  @override
  Future<LoginPreferences> get() async {
    // Default `true` mantém o comportamento por defeito do checkbox no app.
    final rememberMe = _prefs.getBool(_kRememberMe) ?? true;
    if (!rememberMe) {
      return const LoginPreferences(rememberMe: false);
    }

    final email = _prefs.getString(_kLastEmail);
    final method = _prefs.getString(_kLastMethod);
    return LoginPreferences(
      rememberMe: true,
      lastEmail: email,
      lastMethod: (email != null && email.isNotEmpty)
          ? LoginMethod.fromStorage(method)
          : null,
    );
  }

  @override
  Future<void> save(LoginPreferences preferences) async {
    await _prefs.setBool(_kRememberMe, preferences.rememberMe);

    final email = preferences.lastEmail;
    final shouldRememberIdentity =
        preferences.rememberMe && email != null && email.isNotEmpty;

    if (shouldRememberIdentity) {
      await _prefs.setString(_kLastEmail, email);
      await _prefs.setString(
        _kLastMethod,
        (preferences.lastMethod ?? LoginMethod.email).storageValue,
      );
    } else {
      // Sem "lembrar de mim" → apaga a identidade guardada.
      await _prefs.remove(_kLastEmail);
      await _prefs.remove(_kLastMethod);
    }
  }
}
