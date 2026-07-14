import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Armazena credenciais de e-mail+senha no keystore/keychain do dispositivo,
/// cifradas pelo SO. O conteúdo só é acessível após o utilizador autenticar-se
/// (PIN, padrão, biometria) — nunca é transmitido ou exportado.
///
/// Usada exclusivamente para permitir o login silencioso com biometria após a
/// sessão Firebase expirar, replicando o comportamento de apps bancários.
class SecureCredentialCache {
  SecureCredentialCache({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _keyEmail = 'sc_email';
  static const _keyPassword = 'sc_password';

  /// Persiste as credenciais de forma segura após um login bem-sucedido.
  Future<void> save({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Recupera as credenciais guardadas, ou `null` se não existirem.
  Future<({String email, String password})?> load() async {
    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);
    if (email == null || password == null || email.isEmpty || password.isEmpty) {
      return null;
    }
    return (email: email, password: password);
  }

  /// Remove as credenciais guardadas (e.g. ao trocar de conta ou fazer logout).
  Future<void> clear() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
  }
}
