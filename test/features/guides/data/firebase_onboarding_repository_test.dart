import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/guides/data/firebase_onboarding_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseOnboardingRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseOnboardingRepository(firestore: db);
  });

  test('isInitialTourCompleted é false quando não há documento', () async {
    expect(await repo.isInitialTourCompleted('u1'), isFalse);
  });

  test('completeInitialTour persiste e isInitialTourCompleted passa a true',
      () async {
    await repo.completeInitialTour('u1');

    expect(await repo.isInitialTourCompleted('u1'), isTrue);

    final doc = await db.collection('onboarding').doc('u1').get();
    expect(doc.data()!['userId'], 'u1');
    expect(doc.data()!['initialTourCompleted'], isTrue);
  });

  test('isInitialTourCompleted é false se o campo estiver explicitamente false',
      () async {
    await db
        .collection('onboarding')
        .doc('u1')
        .set({'initialTourCompleted': false});
    expect(await repo.isInitialTourCompleted('u1'), isFalse);
  });

  test('estado é isolado por utilizador', () async {
    await repo.completeInitialTour('u1');
    expect(await repo.isInitialTourCompleted('u1'), isTrue);
    expect(await repo.isInitialTourCompleted('u2'), isFalse);
  });
}
