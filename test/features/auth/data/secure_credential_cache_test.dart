import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/auth/data/secure_credential_cache.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage mockStorage;
  late SecureCredentialCache cache;

  setUp(() {
    mockStorage = MockFlutterSecureStorage();
    cache = SecureCredentialCache(storage: mockStorage);
  });

  group('save', () {
    test('escreve e-mail e senha no storage seguro', () async {
      when(() => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          )).thenAnswer((_) async {});

      await cache.save(email: 'user@exemplo.com', password: 'senha123');

      verify(() => mockStorage.write(key: 'sc_email', value: 'user@exemplo.com'))
          .called(1);
      verify(() => mockStorage.write(key: 'sc_password', value: 'senha123'))
          .called(1);
    });
  });

  group('load', () {
    test('retorna credenciais quando ambas estão presentes', () async {
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => 'user@exemplo.com');
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => 'senha123');

      final result = await cache.load();

      expect(result, isNotNull);
      expect(result!.email, 'user@exemplo.com');
      expect(result.password, 'senha123');
    });

    test('retorna null quando e-mail está ausente', () async {
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => null);
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => 'senha123');

      expect(await cache.load(), isNull);
    });

    test('retorna null quando senha está ausente', () async {
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => 'user@exemplo.com');
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => null);

      expect(await cache.load(), isNull);
    });

    test('retorna null quando e-mail é string vazia', () async {
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => '');
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => 'senha123');

      expect(await cache.load(), isNull);
    });

    test('retorna null quando senha é string vazia', () async {
      when(() => mockStorage.read(key: 'sc_email'))
          .thenAnswer((_) async => 'user@exemplo.com');
      when(() => mockStorage.read(key: 'sc_password'))
          .thenAnswer((_) async => '');

      expect(await cache.load(), isNull);
    });
  });

  group('clear', () {
    test('apaga e-mail e senha do storage seguro', () async {
      when(() => mockStorage.delete(key: any(named: 'key')))
          .thenAnswer((_) async {});

      await cache.clear();

      verify(() => mockStorage.delete(key: 'sc_email')).called(1);
      verify(() => mockStorage.delete(key: 'sc_password')).called(1);
    });
  });
}
