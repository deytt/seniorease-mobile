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
  ///
  /// Quando [preferSilent] é `true`, tenta primeiro `signInSilently` (sem UI)
  /// e só abre o seletor/consentimento Google se a sessão em cache não existir.
  /// Usado no re-login com conta lembrada (ex.: após biometria) para evitar a
  /// race de UI entre Face ID/Touch ID e o sheet OAuth no iOS.
  Future<AppUser> signInWithGoogle({bool preferSilent = false});

  /// Limpa a sessão Google no dispositivo (não afecta o Firebase Auth).
  /// Usado ao escolher "Usar outra conta" para o próximo login forçar o seletor.
  Future<void> clearGoogleSession();

  Future<void> sendPasswordResetEmail({required String email});

  /// Reautentica o utilizador com a senha atual e define uma nova senha.
  /// Obrigatório pelo Firebase para operações sensíveis quando a sessão é antiga.
  Future<void> reauthenticateAndChangePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Envia o e-mail de confirmação de conta para o utilizador autenticado.
  Future<void> sendEmailVerification();

  /// Recarrega o utilizador autenticado e devolve o estado atual de verificação
  /// do e-mail. Necessário porque o link de verificação não dispara o
  /// `authStateChanges`.
  Future<bool> reloadAndCheckEmailVerified();

  /// Termina apenas a sessão Firebase. A sessão Google no dispositivo é
  /// preservada de propósito para permitir reauth silenciosa após biometria
  /// (ver [signInWithGoogle] com `preferSilent: true`).
  Future<void> signOut();
}
