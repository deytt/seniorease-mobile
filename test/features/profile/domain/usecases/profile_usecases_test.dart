import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_photo_storage.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/profile/domain/usecases/save_user_profile_use_case.dart';
import 'package:mobile/features/profile/domain/usecases/upload_profile_photo_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockProfilePhotoStorage extends Mock implements ProfilePhotoStorage {}

void main() {
  setUpAll(() {
    registerFallbackValue(UserProfile.empty('u1'));
    registerFallbackValue(Uint8List(0));
  });

  group('GetUserProfileUseCase', () {
    test('delega para watch', () {
      final repo = MockProfileRepository();
      when(() => repo.watch(any()))
          .thenAnswer((_) => Stream.value(UserProfile.empty('u1')));

      GetUserProfileUseCase(repo).call('u1');

      verify(() => repo.watch('u1')).called(1);
    });
  });

  group('SaveUserProfileUseCase', () {
    test('delega para save', () async {
      final repo = MockProfileRepository();
      when(() => repo.save(any())).thenAnswer((_) async {});
      final profile = UserProfile.empty('u1').copyWith(name: 'Maria');

      await SaveUserProfileUseCase(repo).call(profile);

      verify(() => repo.save(profile)).called(1);
    });
  });

  group('UploadProfilePhotoUseCase', () {
    test('delega para storage.upload e devolve o URL', () async {
      final storage = MockProfilePhotoStorage();
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(() => storage.upload(any(), any(),
              contentType: any(named: 'contentType')))
          .thenAnswer((_) async => 'http://x/p.jpg');

      final url = await UploadProfilePhotoUseCase(storage).call('u1', bytes);

      expect(url, 'http://x/p.jpg');
      verify(() => storage.upload('u1', bytes,
          contentType: 'image/jpeg')).called(1);
    });
  });
}
