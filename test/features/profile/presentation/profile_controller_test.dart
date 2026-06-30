import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_photo_storage.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile/features/profile/presentation/providers/profile_provider.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfilePhotoStorage extends Mock implements ProfilePhotoStorage {}

void main() {
  late MockProfileRepository repo;
  late MockProfilePhotoStorage storage;

  setUpAll(() {
    registerFallbackValue(UserProfile.empty('u1'));
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    repo = MockProfileRepository();
    storage = MockProfilePhotoStorage();
  });

  ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(repo),
          profilePhotoStorageProvider.overrideWithValue(storage),
          // Não usado diretamente aqui, mas evita tocar no Firebase real.
          firebaseStorageProvider.overrideWith(
            (ref) => throw UnimplementedError(),
          ),
        ],
      );

  group('save', () {
    test('sucesso → estado AsyncData', () async {
      when(() => repo.save(any())).thenAnswer((_) async {});
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(profileControllerProvider.notifier)
          .save(UserProfile.empty('u1').copyWith(name: 'Maria'));

      expect(container.read(profileControllerProvider), isA<AsyncData<void>>());
      verify(() => repo.save(any())).called(1);
    });

    test('falha → estado AsyncError', () async {
      when(() => repo.save(any())).thenThrow(Exception('boom'));
      final container = makeContainer();
      addTearDown(container.dispose);

      await container
          .read(profileControllerProvider.notifier)
          .save(UserProfile.empty('u1'));

      expect(container.read(profileControllerProvider), isA<AsyncError<void>>());
    });
  });

  group('uploadPhoto', () {
    test('sucesso → devolve o URL e estado AsyncData', () async {
      when(() => storage.upload(any(), any(),
              contentType: any(named: 'contentType')))
          .thenAnswer((_) async => 'http://x/p.jpg');
      final container = makeContainer();
      addTearDown(container.dispose);

      final url = await container
          .read(profileControllerProvider.notifier)
          .uploadPhoto('u1', Uint8List.fromList([1, 2, 3]));

      expect(url, 'http://x/p.jpg');
      expect(container.read(profileControllerProvider), isA<AsyncData<void>>());
    });

    test('falha → devolve null e estado AsyncError', () async {
      when(() => storage.upload(any(), any(),
              contentType: any(named: 'contentType')))
          .thenThrow(Exception('boom'));
      final container = makeContainer();
      addTearDown(container.dispose);

      final url = await container
          .read(profileControllerProvider.notifier)
          .uploadPhoto('u1', Uint8List.fromList([1, 2, 3]));

      expect(url, isNull);
      expect(container.read(profileControllerProvider), isA<AsyncError<void>>());
    });
  });
}
