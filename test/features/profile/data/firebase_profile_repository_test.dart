import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/domain/entities/address.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/data/firebase_profile_repository.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebaseProfileRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebaseProfileRepository(firestore: db);
  });

  group('watch', () {
    test('emite perfil vazio quando o documento não existe', () async {
      final profile = await repo.watch('u1').first;
      expect(profile.id, 'u1');
      expect(profile.name, isEmpty);
    });

    test('mapeia o documento existente (incl. endereço)', () async {
      await db.collection('users').doc('u1').set({
        'name': 'Maria Silva',
        'email': 'm@x.pt',
        'phone': '(19) 9 9999-0034',
        'address': {'city': 'Campinas', 'state': 'SP'},
      });

      final profile = await repo.watch('u1').first;
      expect(profile.name, 'Maria Silva');
      expect(profile.phone, '(19) 9 9999-0034');
      expect(profile.address.city, 'Campinas');
    });
  });

  group('save', () {
    test('persiste os campos do perfil', () async {
      final profile = UserProfile(
        id: 'u1',
        name: 'Maria Silva',
        email: 'm@x.pt',
        phone: '(19) 9 9999-0034',
        address: const Address(city: 'Campinas'),
      );

      await repo.save(profile);

      final doc = await db.collection('users').doc('u1').get();
      expect(doc.data()!['name'], 'Maria Silva');
      expect(doc.data()!['phone'], '(19) 9 9999-0034');
      expect((doc.data()!['address'] as Map)['city'], 'Campinas');
    });

    test('faz merge — não apaga campos previamente guardados (ex.: createdAt)',
        () async {
      await db.collection('users').doc('u1').set({
        'createdAt': 'mantido',
        'name': 'Antigo',
      });

      await repo.save(UserProfile.empty('u1').copyWith(name: 'Maria'));

      final doc = await db.collection('users').doc('u1').get();
      expect(doc.data()!['createdAt'], 'mantido');
      expect(doc.data()!['name'], 'Maria');
    });
  });
}
