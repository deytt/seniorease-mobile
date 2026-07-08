import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile/features/auth/domain/auth_exceptions.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _auth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  /// Nome completo capturado durante o `signUp()`. Serve de fallback imediato
  /// para o `authStateChanges()`, que pode emitir antes de o Firestore e o
  /// `updateDisplayName` terminarem, evitando o "Usuário" transitório na Home.
  String? _pendingSignUpName;

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
    final fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
    // Guarda o nome antes de criar a conta: o `authStateChanges()` pode emitir
    // imediatamente após `createUserWithEmailAndPassword`, antes de o Firestore
    // e o `updateDisplayName` terminarem. O `_pendingSignUpName` garante que
    // `_mapFirebaseUser` devolva o nome correto nessa janela de race condition.
    _pendingSignUpName = fullName;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

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

      _pendingSignUpName = null;
      return appUser;
    } on FirebaseAuthException catch (error) {
      _pendingSignUpName = null;
      throw _mapAuthException(error);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Utilizador fechou/cancelou o seletor de contas.
        throw const AuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final result = await _auth.signInWithCredential(credential);
      final user = result.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      await _ensureUserDocument(
        user,
        fallbackName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );

      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  /// Cria o documento `users/{uid}` no primeiro login com Google (auto-preenche
  /// nome e foto). Em logins seguintes, não sobrescreve o perfil existente —
  /// apenas preenche a `photoUrl` se ainda estiver vazia.
  Future<void> _ensureUserDocument(
    User user, {
    String? fallbackName,
    String? photoUrl,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      await ref.set({
        'id': user.uid,
        'name': user.displayName ?? fallbackName ?? 'Usuário',
        'email': user.email ?? '',
        if (photoUrl != null && photoUrl.isNotEmpty) 'photoUrl': photoUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final data = snapshot.data();
    final hasPhoto = (data?['photoUrl'] as String?)?.isNotEmpty ?? false;
    if (!hasPhoto && photoUrl != null && photoUrl.isNotEmpty) {
      await ref.set({'photoUrl': photoUrl}, SetOptions(merge: true));
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
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<bool> reloadAndCheckEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<AppUser> _mapFirebaseUser(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data();

    return AppUser(
      id: user.uid,
      email: user.email ?? data?['email'] as String? ?? '',
      name: data?['name'] as String? ?? user.displayName ?? _pendingSignUpName ?? 'Usuário',
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      emailVerified: user.emailVerified,
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
