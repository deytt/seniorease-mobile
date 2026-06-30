import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/refresh_email_verification_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/send_email_verification_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/send_password_reset_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_with_google_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_up_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  final user = AppUser(
    id: 'u1',
    email: 'a@b.com',
    name: 'Ana',
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() => repo = MockAuthRepository());

  group('SignInUseCase', () {
    test('delega para signIn e devolve o utilizador', () async {
      when(() => repo.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => user);

      final result =
          await SignInUseCase(repo).call(email: 'a@b.com', password: '123');

      expect(result, user);
      verify(() => repo.signIn(email: 'a@b.com', password: '123')).called(1);
    });
  });

  group('SignUpUseCase', () {
    test('delega para signUp com todos os campos', () async {
      when(() => repo.signUp(
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => user);

      final result = await SignUpUseCase(repo).call(
        firstName: 'Ana',
        lastName: 'Silva',
        email: 'a@b.com',
        password: '123',
      );

      expect(result, user);
      verify(() => repo.signUp(
            firstName: 'Ana',
            lastName: 'Silva',
            email: 'a@b.com',
            password: '123',
          )).called(1);
    });
  });

  group('SignOutUseCase', () {
    test('delega para signOut', () async {
      when(() => repo.signOut()).thenAnswer((_) async {});
      await SignOutUseCase(repo).call();
      verify(() => repo.signOut()).called(1);
    });
  });

  group('SendPasswordResetUseCase', () {
    test('delega para sendPasswordResetEmail', () async {
      when(() => repo.sendPasswordResetEmail(email: any(named: 'email')))
          .thenAnswer((_) async {});
      await SendPasswordResetUseCase(repo).call(email: 'a@b.com');
      verify(() => repo.sendPasswordResetEmail(email: 'a@b.com')).called(1);
    });
  });

  group('SendEmailVerificationUseCase', () {
    test('delega para sendEmailVerification', () async {
      when(() => repo.sendEmailVerification()).thenAnswer((_) async {});
      await SendEmailVerificationUseCase(repo).call();
      verify(() => repo.sendEmailVerification()).called(1);
    });
  });

  group('RefreshEmailVerificationUseCase', () {
    test('delega para reloadAndCheckEmailVerified e devolve o resultado',
        () async {
      when(() => repo.reloadAndCheckEmailVerified())
          .thenAnswer((_) async => true);
      final result = await RefreshEmailVerificationUseCase(repo).call();
      expect(result, isTrue);
      verify(() => repo.reloadAndCheckEmailVerified()).called(1);
    });
  });

  group('SignInWithGoogleUseCase', () {
    test('delega para signInWithGoogle e devolve o utilizador', () async {
      when(() => repo.signInWithGoogle()).thenAnswer((_) async => user);
      final result = await SignInWithGoogleUseCase(repo).call();
      expect(result, user);
      verify(() => repo.signInWithGoogle()).called(1);
    });
  });
}
