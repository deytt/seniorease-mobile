import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_login_preferences_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/save_login_preferences_use_case.dart';

class MockLoginPreferencesRepository extends Mock
    implements LoginPreferencesRepository {}

void main() {
  late MockLoginPreferencesRepository repo;

  setUpAll(() {
    registerFallbackValue(const LoginPreferences(rememberMe: true));
  });

  setUp(() => repo = MockLoginPreferencesRepository());

  group('GetLoginPreferencesUseCase', () {
    test('delega para get() e devolve o resultado', () async {
      const expected = LoginPreferences(
        rememberMe: true,
        lastEmail: 'ana@email.com',
        lastMethod: LoginMethod.email,
      );
      when(() => repo.get()).thenAnswer((_) async => expected);

      final result = await GetLoginPreferencesUseCase(repo).call();

      expect(result, expected);
      verify(() => repo.get()).called(1);
    });
  });

  group('SaveLoginPreferencesUseCase', () {
    test('delega para save() com as preferências fornecidas', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});

      const prefs = LoginPreferences(
        rememberMe: true,
        lastEmail: 'ana@email.com',
        lastMethod: LoginMethod.google,
      );
      await SaveLoginPreferencesUseCase(repo).call(prefs);

      verify(() => repo.save(prefs)).called(1);
    });
  });

  group('LoginMethod', () {
    test('fromStorage mapeia google e faz fallback para email', () {
      expect(LoginMethod.fromStorage('google'), LoginMethod.google);
      expect(LoginMethod.fromStorage('email'), LoginMethod.email);
      expect(LoginMethod.fromStorage(null), LoginMethod.email);
      expect(LoginMethod.fromStorage('desconhecido'), LoginMethod.email);
    });

    test('storageValue devolve o name do enum', () {
      expect(LoginMethod.google.storageValue, 'google');
      expect(LoginMethod.email.storageValue, 'email');
    });
  });

  group('LoginPreferences', () {
    test('hasRememberedIdentity só é true com rememberMe e e-mail', () {
      expect(
        const LoginPreferences(rememberMe: true, lastEmail: 'a@b.com')
            .hasRememberedIdentity,
        isTrue,
      );
      expect(
        const LoginPreferences(rememberMe: false, lastEmail: 'a@b.com')
            .hasRememberedIdentity,
        isFalse,
      );
      expect(
        const LoginPreferences(rememberMe: true).hasRememberedIdentity,
        isFalse,
      );
    });

    test('igualdade de valor e hashCode', () {
      const a = LoginPreferences(
        rememberMe: true,
        lastEmail: 'a@b.com',
        lastMethod: LoginMethod.email,
      );
      const b = LoginPreferences(
        rememberMe: true,
        lastEmail: 'a@b.com',
        lastMethod: LoginMethod.email,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
