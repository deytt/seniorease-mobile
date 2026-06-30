import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/data/firebase_auth_repository.dart';

void main() {
  late FakeFirebaseFirestore db;

  MockUser user({bool isEmailVerified = true}) => MockUser(
        uid: 'u1',
        email: 'a@b.com',
        displayName: 'Ana',
        isEmailVerified: isEmailVerified,
      );

  FirebaseAuthRepository buildRepo(MockFirebaseAuth auth) =>
      FirebaseAuthRepository(
        firebaseAuth: auth,
        firestore: db,
        googleSignIn: GoogleSignIn(),
      );

  setUp(() => db = FakeFirebaseFirestore());

  group('signUp', () {
    test('cria o utilizador, grava o perfil no Firestore e devolve o AppUser',
        () async {
      final repo = buildRepo(MockFirebaseAuth(mockUser: user()));

      final result = await repo.signUp(
        firstName: 'Ana',
        lastName: 'Silva',
        email: 'a@b.com',
        password: '123456',
      );

      // O uid é gerado pelo Firebase Auth; o nome é composto pelos parâmetros.
      expect(result.id, isNotEmpty);
      expect(result.name, 'Ana Silva');
      expect(result.email, 'a@b.com');

      final doc = await db.collection('users').doc(result.id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['name'], 'Ana Silva');
      expect(doc.data()!['email'], 'a@b.com');
    });
  });

  group('signIn', () {
    test('autentica e mapeia o perfil guardado no Firestore', () async {
      await db.collection('users').doc('u1').set({
        'id': 'u1',
        'name': 'Ana Maria',
        'email': 'a@b.com',
      });

      final repo =
          buildRepo(MockFirebaseAuth(mockUser: user(), signedIn: true));

      final result = await repo.signIn(email: 'a@b.com', password: '123456');

      expect(result.id, 'u1');
      expect(result.name, 'Ana Maria');
      expect(result.email, 'a@b.com');
    });
  });

  group('authStateChanges', () {
    test('emite o AppUser mapeado quando autenticado', () async {
      await db.collection('users').doc('u1').set({'name': 'Ana'});

      final repo =
          buildRepo(MockFirebaseAuth(mockUser: user(), signedIn: true));

      final mapped = await repo.authStateChanges().first;
      expect(mapped, isNotNull);
      expect(mapped!.id, 'u1');
      expect(mapped.name, 'Ana');
    });

    test('emite null quando não autenticado', () async {
      final repo = buildRepo(MockFirebaseAuth());
      expect(await repo.authStateChanges().first, isNull);
    });
  });

  group('signOut', () {
    test('termina a sessão (authStateChanges passa a emitir null)', () async {
      final auth = MockFirebaseAuth(mockUser: user(), signedIn: true);
      final repo = buildRepo(auth);

      await repo.signOut();

      expect(auth.currentUser, isNull);
    });
  });

  group('email verification', () {
    test('mapeia emailVerified do utilizador autenticado', () async {
      await db.collection('users').doc('u1').set({'name': 'Ana'});
      final repo = buildRepo(
        MockFirebaseAuth(
          mockUser: user(isEmailVerified: false),
          signedIn: true,
        ),
      );

      final mapped = await repo.authStateChanges().first;
      expect(mapped!.emailVerified, isFalse);
    });

    test('sendEmailVerification não lança quando autenticado', () async {
      final repo =
          buildRepo(MockFirebaseAuth(mockUser: user(), signedIn: true));
      await expectLater(repo.sendEmailVerification(), completes);
    });

    test('reloadAndCheckEmailVerified devolve o estado atual', () async {
      final repo = buildRepo(
        MockFirebaseAuth(mockUser: user(isEmailVerified: true), signedIn: true),
      );
      expect(await repo.reloadAndCheckEmailVerified(), isTrue);
    });
  });
}
