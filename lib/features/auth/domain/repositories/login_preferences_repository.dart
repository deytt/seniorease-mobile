import 'package:mobile/features/auth/domain/entities/login_preferences.dart';

/// Contrato para persistir localmente as preferências de login lembradas
/// (e-mail e método do último acesso). Não guarda credenciais sensíveis.
abstract interface class LoginPreferencesRepository {
  /// Lê as preferências guardadas. Devolve [LoginPreferences.initial] quando
  /// não há nada persistido.
  Future<LoginPreferences> get();

  /// Persiste as preferências. Quando `rememberMe` é `false`, a identidade
  /// lembrada (e-mail e método) é apagada.
  Future<void> save(LoginPreferences preferences);
}
