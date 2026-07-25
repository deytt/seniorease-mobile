import 'package:flutter_test/flutter_test.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/auth/data/local_biometric_repository.dart';

class MockLocalAuthentication extends Mock implements LocalAuthentication {}

void main() {
  late MockLocalAuthentication mockAuth;
  late SharedPreferences prefs;
  late LocalBiometricRepository repo;

  setUpAll(() {
    registerFallbackValue(const AuthenticationOptions());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockAuth = MockLocalAuthentication();
    repo = LocalBiometricRepository(prefs: prefs, auth: mockAuth);
  });

  group('isAvailable', () {
    test('retorna false quando canCheckBiometrics é false', () async {
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => false);

      expect(await repo.isAvailable(), isFalse);
      verifyNever(() => mockAuth.getAvailableBiometrics());
    });

    test('retorna false quando lista de biometrias está vazia', () async {
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => []);

      expect(await repo.isAvailable(), isFalse);
    });

    test('retorna true quando biometria está disponível e registada', () async {
      when(() => mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
      when(() => mockAuth.getAvailableBiometrics())
          .thenAnswer((_) async => [BiometricType.fingerprint]);

      expect(await repo.isAvailable(), isTrue);
    });

    test('captura exceção e retorna false', () async {
      when(() => mockAuth.canCheckBiometrics).thenThrow(Exception('erro'));

      expect(await repo.isAvailable(), isFalse);
    });
  });

  group('isEnabled / setEnabled', () {
    test('isEnabled retorna false por defeito', () {
      expect(repo.isEnabled(), isFalse);
    });

    test('setEnabled persiste a preferência', () async {
      await repo.setEnabled(value: true);
      expect(repo.isEnabled(), isTrue);
    });

    test('setEnabled pode desativar a preferência', () async {
      await repo.setEnabled(value: true);
      await repo.setEnabled(value: false);
      expect(repo.isEnabled(), isFalse);
    });
  });

  group('authenticate', () {
    test('retorna true quando autenticação bem-sucedida', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => true);

      expect(
        await repo.authenticate(reason: 'Por favor, autentique-se'),
        isTrue,
      );
    });

    test('retorna false quando utilizador cancela', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => false);

      expect(
        await repo.authenticate(reason: 'Por favor, autentique-se'),
        isFalse,
      );
    });

    test('captura exceção e retorna false', () async {
      when(() => mockAuth.authenticate(
            localizedReason: any(named: 'localizedReason'),
            options: any(named: 'options'),
          )).thenThrow(Exception('erro de biometria'));

      expect(
        await repo.authenticate(reason: 'Por favor, autentique-se'),
        isFalse,
      );
    });
  });
}
