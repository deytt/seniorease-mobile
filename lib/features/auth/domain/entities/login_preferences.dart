/// Método de autenticação usado no último login bem-sucedido.
enum LoginMethod {
  email,
  google;

  /// Converte o valor persistido (string) para o enum, com fallback para email.
  static LoginMethod fromStorage(String? value) => switch (value) {
        'google' => LoginMethod.google,
        _ => LoginMethod.email,
      };

  /// Valor persistido no armazenamento local.
  String get storageValue => name;
}

/// Preferências de login lembradas localmente entre sessões.
///
/// Guarda apenas dados não sensíveis: se o utilizador marcou "Lembrar de mim",
/// o último e-mail usado e o método de autenticação preferido. **Nunca** guarda
/// a senha.
class LoginPreferences {
  const LoginPreferences({
    required this.rememberMe,
    this.lastEmail,
    this.lastMethod,
  });

  /// Estado inicial para um dispositivo sem preferências guardadas.
  /// `rememberMe` começa `true` para manter o comportamento por defeito do app.
  static const initial = LoginPreferences(rememberMe: true);

  /// O utilizador optou por ser lembrado neste dispositivo.
  final bool rememberMe;

  /// Último e-mail usado (só preenchido quando [rememberMe] é `true`).
  final String? lastEmail;

  /// Método do último login (só preenchido quando [rememberMe] é `true`).
  final LoginMethod? lastMethod;

  /// Há uma identidade lembrada para pré-preencher a tela de login.
  bool get hasRememberedIdentity =>
      rememberMe && lastEmail != null && lastEmail!.isNotEmpty;

  LoginPreferences copyWith({
    bool? rememberMe,
    String? lastEmail,
    LoginMethod? lastMethod,
  }) =>
      LoginPreferences(
        rememberMe: rememberMe ?? this.rememberMe,
        lastEmail: lastEmail ?? this.lastEmail,
        lastMethod: lastMethod ?? this.lastMethod,
      );

  @override
  bool operator ==(Object other) =>
      other is LoginPreferences &&
      other.rememberMe == rememberMe &&
      other.lastEmail == lastEmail &&
      other.lastMethod == lastMethod;

  @override
  int get hashCode => Object.hash(rememberMe, lastEmail, lastMethod);
}
