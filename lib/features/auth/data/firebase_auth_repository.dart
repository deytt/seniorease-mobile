import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _auth = firebaseAuth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _mapFirebaseUser(user);
    });
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<AppUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
      await user.updateDisplayName(fullName);

      final appUser = AppUser(
        id: user.uid,
        email: user.email ?? email.trim(),
        name: fullName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set({
        'id': appUser.id,
        'name': appUser.name,
        'email': appUser.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return appUser;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<AppUser> _mapFirebaseUser(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    return AppUser(
      id: user.uid,
      email: user.email ?? data?['email'] as String? ?? '',
      name: data?['name'] as String? ?? user.displayName ?? 'Usuário',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Exception _mapAuthException(FirebaseAuthException error) {
    final message = switch (error.code) {
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Esta conta foi desativada.',
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'email-already-in-use' => 'Este e-mail já está em uso.',
      'weak-password' => 'A senha é muito fraca. Use pelo menos 6 caracteres.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      _ => 'Não foi possível concluir a operação. Tente novamente.',
    };
    return Exception(message);
  }
}
