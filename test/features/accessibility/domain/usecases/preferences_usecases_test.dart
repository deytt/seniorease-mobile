import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/domain/repositories/preferences_repository.dart';
import 'package:mobile/features/accessibility/domain/usecases/get_preferences_use_case.dart';
import 'package:mobile/features/accessibility/domain/usecases/save_preferences_use_case.dart';

class MockPreferencesRepository extends Mock implements PreferencesRepository {}

void main() {
  late MockPreferencesRepository repo;

  setUpAll(() => registerFallbackValue(UserPreferences.defaults()));
  setUp(() => repo = MockPreferencesRepository());

  group('GetPreferencesUseCase', () {
    test('delega para watch', () {
      when(() => repo.watch(any()))
          .thenAnswer((_) => Stream.value(UserPreferences.defaults()));
      GetPreferencesUseCase(repo).call('u1');
      verify(() => repo.watch('u1')).called(1);
    });
  });

  group('SavePreferencesUseCase — resolução de contraste', () {
    UserPreferences prefs({
      required bool darkMode,
      required ContrastMode contrast,
    }) =>
        UserPreferences.defaults(userId: 'u1')
            .copyWith(darkMode: darkMode, contrast: contrast);

    test('darkMode + high → maximum', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});
      await SavePreferencesUseCase(repo)
          .call(prefs(darkMode: true, contrast: ContrastMode.high));

      final saved =
          verify(() => repo.save(captureAny())).captured.single
              as UserPreferences;
      expect(saved.contrast, ContrastMode.maximum);
    });

    test('sem darkMode mas maximum → baixa para high', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});
      await SavePreferencesUseCase(repo)
          .call(prefs(darkMode: false, contrast: ContrastMode.maximum));

      final saved =
          verify(() => repo.save(captureAny())).captured.single
              as UserPreferences;
      expect(saved.contrast, ContrastMode.high);
    });

    test('caso neutro mantém o contraste', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});
      await SavePreferencesUseCase(repo)
          .call(prefs(darkMode: false, contrast: ContrastMode.defaultMode));

      final saved =
          verify(() => repo.save(captureAny())).captured.single
              as UserPreferences;
      expect(saved.contrast, ContrastMode.defaultMode);
    });
  });
}
