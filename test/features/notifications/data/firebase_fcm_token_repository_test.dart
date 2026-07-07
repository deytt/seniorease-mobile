import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/notifications/data/firebase_fcm_token_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseFcmTokenRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseFcmTokenRepository(firestore: db);
  });

  group('saveToken', () {
    test('cria documento em users/{uid}/fcmTokens/{token}', () async {
      await repo.saveToken(
        userId: 'u1',
        token: 'tok_abc',
        platform: 'android',
      );

      final doc = await db
          .collection('users')
          .doc('u1')
          .collection('fcmTokens')
          .doc('tok_abc')
          .get();

      expect(doc.exists, isTrue);
      expect(doc.data()!['token'], 'tok_abc');
      expect(doc.data()!['platform'], 'android');
    });

    test('sobrescreve (merge) sem duplicar se token já existir', () async {
      await repo.saveToken(userId: 'u1', token: 'tok_x', platform: 'android');
      await repo.saveToken(userId: 'u1', token: 'tok_x', platform: 'ios');

      final snap = await db
          .collection('users')
          .doc('u1')
          .collection('fcmTokens')
          .get();

      expect(snap.docs.length, 1);
      expect(snap.docs.first.data()['platform'], 'ios');
    });

    test('tokens diferentes ficam em documentos separados', () async {
      await repo.saveToken(userId: 'u1', token: 'tok_1', platform: 'android');
      await repo.saveToken(userId: 'u1', token: 'tok_2', platform: 'ios');

      final snap = await db
          .collection('users')
          .doc('u1')
          .collection('fcmTokens')
          .get();

      expect(snap.docs.length, 2);
    });
  });

  group('removeToken', () {
    test('apaga o documento do token', () async {
      await repo.saveToken(userId: 'u1', token: 'tok_del', platform: 'android');

      await repo.removeToken(userId: 'u1', token: 'tok_del');

      final doc = await db
          .collection('users')
          .doc('u1')
          .collection('fcmTokens')
          .doc('tok_del')
          .get();

      expect(doc.exists, isFalse);
    });

    test('não lança erro ao tentar remover token inexistente', () async {
      await expectLater(
        repo.removeToken(userId: 'u1', token: 'nao_existe'),
        completes,
      );
    });
  });
}
