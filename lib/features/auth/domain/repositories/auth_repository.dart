import 'package:mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });

  /// Inicia o fluxo de login com Google (OAuth) e autentica no Firebase.
  /// O Firebase vincula automaticamente contas com o mesmo e-mail (definição
  /// ativada no console). No primeiro login, o perfil em `users/{uid}` é criado
  /// com nome/foto do Google.
  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail({required String email});

  /// Envia o e-mail de confirmação de conta para o utilizador autenticado.
  Future<void> sendEmailVerification();

  /// Recarrega o utilizador autenticado e devolve o estado atual de verificação
  /// do e-mail. Necessário porque o link de verificação não dispara o
  /// `authStateChanges`.
  Future<bool> reloadAndCheckEmailVerified();

  Future<void> signOut();
}
