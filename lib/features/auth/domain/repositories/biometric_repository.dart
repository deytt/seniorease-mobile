/// Abstração para operações de autenticação biométrica.
///
/// A Domain layer nunca importa de Infrastructure — esta interface é o ponto
/// de contacto; a implementação real ([LocalBiometricRepository]) vive na
/// camada Data e usa `local_auth` + `shared_preferences`.
abstract interface class BiometricRepository {
  /// Verifica se o dispositivo suporta biometria e tem pelo menos um método
  /// de biometria registado (impressão digital, rosto, íris).
  Future<bool> isAvailable();

  /// Lê a preferência persistida localmente (síncrono após inicialização).
  /// Devolve `false` se a chave ainda não foi gravada.
  bool isEnabled();

  /// Persiste a preferência de biometria.
  Future<void> setEnabled({required bool value});

  /// Aciona o diálogo de biometria nativo.
  ///
  /// [reason] é a mensagem mostrada ao utilizador no diálogo do sistema.
  /// Devolve `true` se o utilizador se autenticou com sucesso; `false` se
  /// cancelou ou falhou (sem lançar exceção).
  Future<bool> authenticate({required String reason});
}
