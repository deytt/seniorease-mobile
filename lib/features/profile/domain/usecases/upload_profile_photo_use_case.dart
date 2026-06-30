import 'dart:typed_data';

import 'package:mobile/features/profile/domain/repositories/profile_photo_storage.dart';

class UploadProfilePhotoUseCase {
  const UploadProfilePhotoUseCase(this._storage);

  final ProfilePhotoStorage _storage;

  /// Faz upload da foto e devolve o URL público a guardar em `photoUrl`.
  Future<String> call(
    String userId,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) =>
      _storage.upload(userId, bytes, contentType: contentType);
}
