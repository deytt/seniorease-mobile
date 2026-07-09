import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';
import 'package:mobile/features/auth/domain/usecases/authenticate_with_biometric_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/check_biometric_availability_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/disable_biometric_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/enable_biometric_use_case.dart';

class MockBiometricRepository extends Mock implements BiometricRepository {}

void main() {
  late MockBiometricRepository repo;

  setUp(() => repo = MockBiometricRepository());

  group('CheckBiometricAvailabilityUseCase', () {
    test('delega para isAvailable() e devolve o resultado', () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);

      final result = await CheckBiometricAvailabilityUseCase(repo).call();

      expect(result, isTrue);
      verify(() => repo.isAvailable()).called(1);
    });
  });

  group('AuthenticateWithBiometricUseCase', () {
    test('delega authenticate(reason:) e devolve o resultado', () async {
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);

      final result = await AuthenticateWithBiometricUseCase(repo).call(
        reason: 'Entre na sua conta SeniorEase com biometria.',
      );

      expect(result, isTrue);
      verify(() => repo.authenticate(
            reason: 'Entre na sua conta SeniorEase com biometria.',
          )).called(1);
    });
  });

  group('EnableBiometricUseCase', () {
    test(
        'quando isAvailable=true e auth bem-sucedida → chama setEnabled(true) e '
        'devolve true', () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);
      when(() => repo.setEnabled(value: any(named: 'value')))
          .thenAnswer((_) async {});

      final result = await EnableBiometricUseCase(repo).call();

      expect(result, isTrue);
      verify(() => repo.setEnabled(value: true)).called(1);
    });

    test('quando isAvailable=false → lança Exception e não chama setEnabled',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => false);

      expect(
        () => EnableBiometricUseCase(repo).call(),
        throwsException,
      );
      verifyNever(() => repo.setEnabled(value: any(named: 'value')));
    });

    test('quando auth cancelada → não chama setEnabled e devolve false',
        () async {
      when(() => repo.isAvailable()).thenAnswer((_) async => true);
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => false);

      final result = await EnableBiometricUseCase(repo).call();

      expect(result, isFalse);
      verifyNever(() => repo.setEnabled(value: any(named: 'value')));
    });
  });

  group('DisableBiometricUseCase', () {
    test(
        'quando auth bem-sucedida → chama setEnabled(false) e devolve true',
        () async {
      when(() => repo.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);
      when(() => repo.setEnabled(value: any(named: 'value')))
          .thenAnswer((_) async {});

      final result = await DisableBiometricUseCase(repo).call();

      expect(result, isTrue);
      verify(() => repo.setEnabled(value: false)).called(1);
    });
  });
}
