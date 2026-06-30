import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';

/// Implementação Firestore do [ProfileRepository] sobre a collection `users`.
///
/// Usa `SetOptions(merge: true)` para preservar campos não geridos pelo perfil
/// (ex.: `id`, `createdAt` escritos no registo).
class FirebaseProfileRepository implements ProfileRepository {
  FirebaseProfileRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  @override
  Stream<UserProfile> watch(String userId) => _collection
      .doc(userId)
      .snapshots()
      .map((snap) => snap.exists && snap.data() != null
          ? UserProfile.fromMap(userId, snap.data()!)
          : UserProfile.empty(userId));

  @override
  Future<void> save(UserProfile profile) => _collection.doc(profile.id).set(
        {
          ...profile.toMap(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
}
