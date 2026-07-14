import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/local_login_preferences_repository.dart';
import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalLoginPreferencesRepository repo;

  Future<LocalLoginPreferencesRepository> makeRepo() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalLoginPreferencesRepository(prefs: prefs);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = await makeRepo();
  });

  test('get devolve rememberMe=true por defeito e sem identidade', () async {
    final prefs = await repo.get();
    expect(prefs.rememberMe, isTrue);
    expect(prefs.lastEmail, isNull);
    expect(prefs.lastMethod, isNull);
    expect(prefs.hasRememberedIdentity, isFalse);
  });

  test('save persiste e-mail e método quando rememberMe=true', () async {
    await repo.save(
      const LoginPreferences(
        rememberMe: true,
        lastEmail: 'ana@email.com',
        lastMethod: LoginMethod.google,
      ),
    );

    final prefs = await repo.get();
    expect(prefs.rememberMe, isTrue);
    expect(prefs.lastEmail, 'ana@email.com');
    expect(prefs.lastMethod, LoginMethod.google);
    expect(prefs.hasRememberedIdentity, isTrue);
  });

  test('save com método email por defeito quando não especificado', () async {
    await repo.save(
      const LoginPreferences(rememberMe: true, lastEmail: 'ana@email.com'),
    );

    final prefs = await repo.get();
    expect(prefs.lastMethod, LoginMethod.email);
  });

  test('save com rememberMe=false apaga a identidade guardada', () async {
    await repo.save(
      const LoginPreferences(
        rememberMe: true,
        lastEmail: 'ana@email.com',
        lastMethod: LoginMethod.email,
      ),
    );

    await repo.save(const LoginPreferences(rememberMe: false));

    final prefs = await repo.get();
    expect(prefs.rememberMe, isFalse);
    expect(prefs.lastEmail, isNull);
    expect(prefs.lastMethod, isNull);
  });

  test('get não devolve identidade quando rememberMe está desligado', () async {
    SharedPreferences.setMockInitialValues({
      'login_remember_me': false,
      'login_last_email': 'ana@email.com',
      'login_last_method': 'google',
    });
    repo = await makeRepo();

    final prefs = await repo.get();
    expect(prefs.rememberMe, isFalse);
    expect(prefs.lastEmail, isNull);
    expect(prefs.lastMethod, isNull);
  });

  test('save ignora e-mail vazio (não marca identidade lembrada)', () async {
    await repo.save(const LoginPreferences(rememberMe: true, lastEmail: ''));

    final prefs = await repo.get();
    expect(prefs.hasRememberedIdentity, isFalse);
    expect(prefs.lastEmail, isNull);
  });
}
