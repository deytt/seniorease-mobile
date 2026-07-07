import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/notifications/domain/entities/notification_item.dart';
import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:mobile/features/notifications/domain/repositories/notification_history_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/register_fcm_token_use_case.dart';
import 'package:mobile/features/notifications/domain/usecases/remove_fcm_token_use_case.dart';
import 'package:mobile/features/notifications/domain/usecases/watch_notification_history_use_case.dart';

class MockFcmTokenRepository extends Mock implements FcmTokenRepository {}
class MockNotificationHistoryRepository extends Mock
    implements NotificationHistoryRepository {}

NotificationItem _item(String id) => NotificationItem(
      id: id,
      userId: 'u1',
      entityId: 'e1',
      entityType: NotificationEntityType.task,
      title: 'Título',
      body: 'Corpo',
      sentAt: DateTime(2026, 7, 6, 14),
    );

void main() {
  group('RegisterFcmTokenUseCase', () {
    late MockFcmTokenRepository repo;

    setUp(() => repo = MockFcmTokenRepository());

    setUpAll(() {
      registerFallbackValue('');
    });

    test('delega saveToken para o repositório', () async {
      when(
        () => repo.saveToken(
          userId: any(named: 'userId'),
          token: any(named: 'token'),
          platform: any(named: 'platform'),
        ),
      ).thenAnswer((_) async {});

      await RegisterFcmTokenUseCase(repo).call(
        userId: 'u1',
        token: 'tok123',
        platform: 'android',
      );

      verify(
        () => repo.saveToken(
          userId: 'u1',
          token: 'tok123',
          platform: 'android',
        ),
      ).called(1);
    });
  });

  group('RemoveFcmTokenUseCase', () {
    late MockFcmTokenRepository repo;

    setUp(() => repo = MockFcmTokenRepository());

    test('delega removeToken para o repositório', () async {
      when(
        () => repo.removeToken(
          userId: any(named: 'userId'),
          token: any(named: 'token'),
        ),
      ).thenAnswer((_) async {});

      await RemoveFcmTokenUseCase(repo).call(userId: 'u1', token: 'tok123');

      verify(
        () => repo.removeToken(userId: 'u1', token: 'tok123'),
      ).called(1);
    });
  });

  group('WatchNotificationHistoryUseCase', () {
    late MockNotificationHistoryRepository repo;

    setUp(() => repo = MockNotificationHistoryRepository());

    test('delega watchByUser com o userId e limit padrão 50', () {
      when(() => repo.watchByUser(any(), limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value([_item('n1')]));

      WatchNotificationHistoryUseCase(repo).call('u1');

      verify(() => repo.watchByUser('u1', limit: 50)).called(1);
    });

    test('aceita limit personalizado', () {
      when(() => repo.watchByUser(any(), limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value([]));

      WatchNotificationHistoryUseCase(repo).call('u1', limit: 20);

      verify(() => repo.watchByUser('u1', limit: 20)).called(1);
    });

    test('propaga os itens do stream', () async {
      final items = [_item('n1'), _item('n2')];
      when(() => repo.watchByUser(any(), limit: any(named: 'limit')))
          .thenAnswer((_) => Stream.value(items));

      final result = await WatchNotificationHistoryUseCase(repo)
          .call('u1')
          .first;

      expect(result, items);
    });
  });
}
