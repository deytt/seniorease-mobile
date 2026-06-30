import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mobile/features/profile/domain/repositories/profile_photo_storage.dart';

/// Implementação do [ProfilePhotoStorage] sobre o Firebase Storage.
///
/// Guarda a foto em `profile_photos/{userId}` (um ficheiro por utilizador — o
/// upload seguinte substitui o anterior) e devolve o URL público de download.
class FirebaseProfilePhotoStorage implements ProfilePhotoStorage {
  FirebaseProfilePhotoStorage({required FirebaseStorage storage})
      : _storage = storage;

  final FirebaseStorage _storage;

  @override
  Future<String> upload(
    String userId,
    Uint8List bytes, {
    String contentType = 'image/jpeg',
  }) async {
    final ref = _storage.ref().child('profile_photos/$userId');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }
}
