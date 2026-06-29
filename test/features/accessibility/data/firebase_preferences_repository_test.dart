import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/accessibility/data/firebase_preferences_repository.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FirebasePreferencesRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    repo = FirebasePreferencesRepository(firestore: db);
  });

  group('watch', () {
    test('emite defaults quando o documento não existe', () async {
      final prefs = await repo.watch('u1').first;
      expect(prefs.userId, 'u1');
      expect(prefs.fontSize, FontSizeScale.medium);
      expect(prefs.interfaceMode, InterfaceMode.advanced);
    });

    test('emite as preferências guardadas quando o documento existe', () async {
      await db.collection('preferences').doc('u1').set({
        'fontSize': 'large',
        'darkMode': true,
        'contrast': 'maximum',
        'interfaceMode': 'basic',
        'updatedAt': Timestamp.fromDate(DateTime(2026, 2, 2)),
      });

      final prefs = await repo.watch('u1').first;
      expect(prefs.fontSize, FontSizeScale.large);
      expect(prefs.darkMode, isTrue);
      expect(prefs.contrast, ContrastMode.maximum);
      expect(prefs.interfaceMode, InterfaceMode.basic);
    });
  });

  group('save', () {
    test('persiste as preferências no documento do utilizador', () async {
      final prefs = UserPreferences.defaults(userId: 'u1').copyWith(
        fontSize: FontSizeScale.large,
        interfaceMode: InterfaceMode.basic,
      );

      await repo.save(prefs);

      final doc = await db.collection('preferences').doc('u1').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['fontSize'], 'large');
      expect(doc.data()!['interfaceMode'], 'basic');
    });

    test('faz merge — não apaga campos previamente guardados', () async {
      await db.collection('preferences').doc('u1').set({'extra': 'mantido'});

      await repo.save(UserPreferences.defaults(userId: 'u1'));

      final doc = await db.collection('preferences').doc('u1').get();
      expect(doc.data()!['extra'], 'mantido');
      expect(doc.data()!['fontSize'], 'medium');
    });
  });
}
