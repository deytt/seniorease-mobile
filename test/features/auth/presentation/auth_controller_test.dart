import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}

class MockSignOutUseCase extends Mock implements SignOutUseCase {}

AppUser _user() => AppUser(
      id: 'u1',
      email: 'a@b.com',
      name: 'Ana',
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  group('AuthController', () {
    test('signIn: sucesso → AsyncData e chama o use case', () async {
      final signIn = MockSignInUseCase();
      // Devolve um AppUser válido (o controller ignora o valor).
      when(() => signIn.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => _user());

      final container = ProviderContainer(overrides: [
        signInUseCaseProvider.overrideWithValue(signIn),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn(email: 'a@b.com', password: '123');

      verify(() => signIn.call(email: 'a@b.com', password: '123')).called(1);
      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });

    test('signIn: erro → AsyncError', () async {
      final signIn = MockSignInUseCase();
      when(() => signIn.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(Exception('credenciais inválidas'));

      final container = ProviderContainer(overrides: [
        signInUseCaseProvider.overrideWithValue(signIn),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn(email: 'a@b.com', password: 'errada');

      expect(container.read(authControllerProvider), isA<AsyncError<void>>());
    });

    test('signOut: sucesso → AsyncData e chama o use case', () async {
      final signOut = MockSignOutUseCase();
      when(() => signOut.call()).thenAnswer((_) async {});

      final container = ProviderContainer(overrides: [
        signOutUseCaseProvider.overrideWithValue(signOut),
      ]);
      addTearDown(container.dispose);

      final controller = container.read(authControllerProvider.notifier);
      await controller.signOut();

      verify(() => signOut.call()).called(1);
      expect(container.read(authControllerProvider), isA<AsyncData<void>>());
    });
  });
}
