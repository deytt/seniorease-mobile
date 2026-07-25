import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/change_password_use_case.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;
  late ChangePasswordUseCase useCase;

  setUp(() {
    repo = MockAuthRepository();
    useCase = ChangePasswordUseCase(repo);
  });

  group('ChangePasswordUseCase', () {
    test('delega para reauthenticateAndChangePassword com os parâmetros corretos',
        () async {
      when(() => repo.reauthenticateAndChangePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async {});

      await useCase.call(
        currentPassword: 'senha-atual',
        newPassword: 'nova-senha',
      );

      verify(() => repo.reauthenticateAndChangePassword(
            currentPassword: 'senha-atual',
            newPassword: 'nova-senha',
          )).called(1);
    });

    test('propaga exceção do repositório', () async {
      when(() => repo.reauthenticateAndChangePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer(
        (_) => Future.error(Exception('wrong-password')),
      );

      await expectLater(
        useCase.call(currentPassword: 'errada', newPassword: 'nova'),
        throwsException,
      );
    });

    test('propaga erro de conta Google (sem provedor de senha)', () async {
      when(() => repo.reauthenticateAndChangePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer(
        (_) => Future.error(Exception('operation-not-allowed')),
      );

      await expectLater(
        useCase.call(currentPassword: '', newPassword: 'nova'),
        throwsException,
      );
    });
  });
}
