import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';

/// Implementação Firebase de [FcmTokenRepository].
///
/// Grava cada token FCM como documento separado em
/// [users/{uid}/fcmTokens/{token}] usando o próprio token como ID.
/// O uso do token como ID evita duplicados e permite remover o documento
/// directamente sem precisar de query.
class FirebaseFcmTokenRepository implements FcmTokenRepository {
  FirebaseFcmTokenRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _tokens(String userId) =>
      _firestore.collection('users').doc(userId).collection('fcmTokens');

  @override
  Future<void> saveToken({
    required String userId,
    required String token,
    required String platform,
  }) =>
      _tokens(userId).doc(token).set({
        'token': token,
        'platform': platform,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  @override
  Future<void> removeToken({
    required String userId,
    required String token,
  }) async {
    await _tokens(userId).doc(token).delete();
  }
}
