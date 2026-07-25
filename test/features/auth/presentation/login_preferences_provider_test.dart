import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_login_preferences_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/save_login_preferences_use_case.dart';
import 'package:mobile/features/auth/presentation/providers/login_preferences_provider.dart';

class MockLoginPreferencesRepository extends Mock
    implements LoginPreferencesRepository {}

void main() {
  late MockLoginPreferencesRepository repo;

  setUpAll(() => registerFallbackValue(LoginPreferences.initial));

  setUp(() {
    repo = MockLoginPreferencesRepository();
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        loginPreferencesRepositoryProvider.overrideWith(
          (_) async => repo,
        ),
      ]);

  group('loginPreferencesRepositoryProvider', () {
    test('resolve com o repositório injetado', () async {
      final container = buildContainer();
      addTearDown(container.dispose);

      final resolvedRepo =
          await container.read(loginPreferencesRepositoryProvider.future);
      expect(resolvedRepo, isA<LoginPreferencesRepository>());
    });
  });

  group('getLoginPreferencesUseCaseProvider', () {
    test('resolve e delega para o repositório', () async {
      when(() => repo.get())
          .thenAnswer((_) async => const LoginPreferences(
                rememberMe: true,
                lastEmail: 'u@exemplo.com',
                lastMethod: LoginMethod.email,
              ));

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase =
          await container.read(getLoginPreferencesUseCaseProvider.future);
      expect(useCase, isA<GetLoginPreferencesUseCase>());

      final prefs = await useCase.call();
      expect(prefs.lastEmail, 'u@exemplo.com');
      expect(prefs.lastMethod, LoginMethod.email);
    });
  });

  group('saveLoginPreferencesUseCaseProvider', () {
    test('resolve e persiste preferências no repositório', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase =
          await container.read(saveLoginPreferencesUseCaseProvider.future);
      expect(useCase, isA<SaveLoginPreferencesUseCase>());

      const prefs = LoginPreferences(
        rememberMe: false,
        lastEmail: null,
        lastMethod: null,
      );
      await useCase.call(prefs);
      verify(() => repo.save(prefs)).called(1);
    });

    test('rememberMe false apaga a identidade lembrada', () async {
      LoginPreferences? saved;
      when(() => repo.save(any())).thenAnswer((inv) async {
        saved = inv.positionalArguments.first as LoginPreferences;
      });

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase =
          await container.read(saveLoginPreferencesUseCaseProvider.future);
      await useCase.call(LoginPreferences.initial.copyWith(rememberMe: false));

      expect(saved?.rememberMe, isFalse);
      expect(saved?.lastEmail, isNull);
    });
  });
}
