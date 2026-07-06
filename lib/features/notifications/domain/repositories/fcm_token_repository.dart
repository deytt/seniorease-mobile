/// Contrato para persistência de tokens FCM por dispositivo.
///
/// Os tokens ficam em [users/{uid}/fcmTokens/{tokenId}] no Firestore.
/// Cada documento guarda o token e metadados para que a Cloud Function
/// consiga enviar push a todos os dispositivos do utilizador.
abstract interface class FcmTokenRepository {
  Future<void> saveToken({
    required String userId,
    required String token,
    required String platform,
  });

  Future<void> removeToken({
    required String userId,
    required String token,
  });
}
