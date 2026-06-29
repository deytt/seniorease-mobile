import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/guides/domain/repositories/onboarding_repository.dart';

/// Implementação Firestore do onboarding inicial — collection própria da feature
/// `guides` (`onboarding/{userId}`), partilhada com o projeto Web (ADR-013).
class FirebaseOnboardingRepository implements OnboardingRepository {
  FirebaseOnboardingRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('onboarding');

  @override
  Future<bool> isInitialTourCompleted(String userId) async {
    final snap = await _collection.doc(userId).get();
    return (snap.data()?['initialTourCompleted'] as bool?) ?? false;
  }

  @override
  Future<void> completeInitialTour(String userId) {
    return _collection.doc(userId).set(
      {
        'userId': userId,
        'initialTourCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
