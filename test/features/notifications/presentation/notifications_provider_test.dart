import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/register_fcm_token_use_case.dart';
import 'package:mobile/features/notifications/domain/usecases/remove_fcm_token_use_case.dart';
import 'package:mobile/features/notifications/presentation/providers/notifications_provider.dart';

class MockFcmTokenRepository extends Mock implements FcmTokenRepository {}

void main() {
  late MockFcmTokenRepository repo;

  setUp(() {
    repo = MockFcmTokenRepository();
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        fcmTokenRepositoryProvider.overrideWithValue(repo),
      ]);

  group('registerFcmTokenUseCaseProvider', () {
    test('instancia RegisterFcmTokenUseCase e delega para repositório', () async {
      when(() => repo.saveToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
            platform: any(named: 'platform'),
          )).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(registerFcmTokenUseCaseProvider);
      expect(useCase, isA<RegisterFcmTokenUseCase>());

      await useCase.call(
        userId: 'u1',
        token: 'token-abc',
        platform: 'android',
      );

      verify(() => repo.saveToken(
            userId: 'u1',
            token: 'token-abc',
            platform: 'android',
          )).called(1);
    });
  });

  group('removeFcmTokenUseCaseProvider', () {
    test('instancia RemoveFcmTokenUseCase e delega para repositório', () async {
      when(() => repo.removeToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
          )).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(removeFcmTokenUseCaseProvider);
      expect(useCase, isA<RemoveFcmTokenUseCase>());

      await useCase.call(userId: 'u1', token: 'token-abc');

      verify(() => repo.removeToken(userId: 'u1', token: 'token-abc')).called(1);
    });

    test('propaga erro do repositório', () async {
      when(() => repo.removeToken(
            userId: any(named: 'userId'),
            token: any(named: 'token'),
          )).thenAnswer((_) => Future.error(Exception('sem rede')));

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(removeFcmTokenUseCaseProvider);
      await expectLater(
        useCase.call(userId: 'u1', token: 'token-xyz'),
        throwsException,
      );
    });
  });
}
