import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/firebase_auth_repository.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_up_use_case.dart';

// --- Repositório ---

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// --- Use cases ---

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

final sendPasswordResetUseCaseProvider = Provider<SendPasswordResetUseCase>((ref) {
  return SendPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

// --- Estado de autenticação ---

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// --- Controller ---

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class AuthController extends Notifier<AsyncValue<void>> {
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
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sendPasswordResetUseCaseProvider).call(email: email),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(signOutUseCaseProvider).call(),
    );
  }
}
