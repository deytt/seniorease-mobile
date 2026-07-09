import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/data/firebase_auth_repository.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/change_password_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/refresh_email_verification_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/send_email_verification_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';

// --- Repositório ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firebaseFirestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// --- Use cases ---

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return SignInWithGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((ref) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

final sendEmailVerificationUseCaseProvider =
    Provider<SendEmailVerificationUseCase>((ref) {
  return SendEmailVerificationUseCase(ref.watch(authRepositoryProvider));
});

final refreshEmailVerificationUseCaseProvider =
    Provider<RefreshEmailVerificationUseCase>((ref) {
  return RefreshEmailVerificationUseCase(ref.watch(authRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

// --- Estado de autenticação ---

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// --- Controller ---

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
  /// Evita registar o evento de verificação de conta mais do que uma vez.
  bool _verificationLogged = false;

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(signInUseCaseProvider)
          .call(email: email, password: password)
          .then((_) {}),
    );
    // Login explícito com senha → desbloqueia o app lock biométrico para esta
    // sessão. O lock screen só deve aparecer em arranque frio com sessão já
    // persistida, não imediatamente a seguir a um login manual.
    if (state is AsyncData) {
      ref.read(biometricLockedProvider.notifier).unlock();
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(signUpUseCaseProvider)
          .call(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          )
          .then((_) {}),
    );
    if (state is AsyncData) {
      ref.read(biometricLockedProvider.notifier).unlock();
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sendPasswordResetUseCaseProvider).call(email: email),
    );
  }

  /// Envia o e-mail de verificação para a conta atual. Lança em caso de erro
  /// para que a UI possa exibir o toast adequado.
  Future<void> sendEmailVerification() {
    return ref.read(sendEmailVerificationUseCaseProvider).call();
  }

  /// Recarrega o utilizador e devolve se o e-mail já foi verificado. Quando
  /// confirmado, invalida o `authStateProvider` para que o selo e o alerta nas
  /// Definições se atualizem em toda a app.
  Future<bool> refreshEmailVerification() async {
    final verified =
        await ref.read(refreshEmailVerificationUseCaseProvider).call();
    if (verified) {
      // Regista antes de invalidar (a seguir o userId fica momentaneamente
      // indisponível enquanto o authState recarrega).
      if (!_verificationLogged) {
        _verificationLogged = true;
        await ref.read(historyRecorderProvider).record(
              type: HistoryActionType.accountVerified,
              title: 'Verificou a sua conta',
            );
      }
      ref.invalidate(authStateProvider);
    }
    return verified;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signInWithGoogleUseCaseProvider).call().then((_) {}),
    );
    if (state is AsyncData) {
      ref.read(biometricLockedProvider.notifier).unlock();
    }
  }

  /// Reautentica com [currentPassword] e define [newPassword]. Regista a ação
  /// no Histórico em caso de sucesso (best-effort, não propaga falhas de log).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(changePasswordUseCaseProvider).call(
            currentPassword: currentPassword,
            newPassword: newPassword,
          ),
    );
    if (state is AsyncData) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.passwordChanged,
            title: 'Alterou a senha',
          );
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signOutUseCaseProvider).call(),
    );
  }
}
