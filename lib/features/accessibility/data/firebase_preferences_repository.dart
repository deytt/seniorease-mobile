import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/repositories/preferences_repository.dart';

class FirebasePreferencesRepository implements PreferencesRepository {
  FirebasePreferencesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('preferences');

  @override
  Stream<UserPreferences> watch(String userId) => _collection
      .doc(userId)
      .snapshots()
      .map((snap) => snap.exists && snap.data() != null
          ? UserPreferences.fromMap(userId, snap.data()!)
          : UserPreferences.defaults(userId: userId));

  @override
  Future<void> save(UserPreferences preferences) =>
      _collection.doc(preferences.userId).set(
            preferences.toMap(),
            SetOptions(merge: true),
          );
}
