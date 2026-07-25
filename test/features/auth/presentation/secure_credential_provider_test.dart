import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/data/secure_credential_cache.dart';
import 'package:mobile/features/auth/presentation/providers/secure_credential_provider.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('secureCredentialCacheProvider', () {
    test('fornece uma instância de SecureCredentialCache', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cache = container.read(secureCredentialCacheProvider);
      expect(cache, isA<SecureCredentialCache>());
    });

    test('pode ser substituído por instância customizada em testes', () {
      final mockStorage = MockFlutterSecureStorage();
      final customCache = SecureCredentialCache(storage: mockStorage);

      final container = ProviderContainer(overrides: [
        secureCredentialCacheProvider.overrideWithValue(customCache),
      ]);
      addTearDown(container.dispose);

      final cache = container.read(secureCredentialCacheProvider);
      expect(cache, same(customCache));
    });
  });

  group('SecureCredentialCache — integração com provider', () {
    test('save e load fazem roundtrip quando storage está disponível', () async {
      final mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => 'test@exemplo.com');
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => 'senha-segura');

      final cache = SecureCredentialCache(storage: mockStorage);
      await cache.save(email: 'test@exemplo.com', password: 'senha-segura');
      final result = await cache.load();

      expect(result, isNotNull);
      expect(result!.email, 'test@exemplo.com');
      expect(result.password, 'senha-segura');
    });

    test('load retorna null quando storage está vazio', () async {
      final mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.read(key: any(named: 'key')))
          .thenAnswer((_) async => null);

      final cache = SecureCredentialCache(storage: mockStorage);
      expect(await cache.load(), isNull);
    });

    test('clear apaga as credenciais', () async {
      final mockStorage = MockFlutterSecureStorage();
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      final cache = SecureCredentialCache(storage: mockStorage);
      await cache.clear();

      verify(() => mockStorage.delete(key: 'sc_email')).called(1);
      verify(() => mockStorage.delete(key: 'sc_password')).called(1);
    });
  });
}
