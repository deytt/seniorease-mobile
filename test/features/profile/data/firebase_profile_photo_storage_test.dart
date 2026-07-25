import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/profile/data/firebase_profile_photo_storage.dart';

// ---------------------------------------------------------------------------
// Fakes manuais (sem mocktail) — UploadTask é muito complexo para Mock
// ---------------------------------------------------------------------------

/// Regista as chamadas feitas à referência "filha" do Storage.
class _RecordingRef extends Fake implements Reference {
  final String expectedUrl;
  Uint8List? capturedBytes;
  SettableMetadata? capturedMetadata;

  _RecordingRef({required this.expectedUrl});

  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    capturedBytes = data;
    capturedMetadata = metadata;
    return _CompletedUploadTask();
  }

  @override
  Future<String> getDownloadURL() => Future.value(expectedUrl);
}

/// Delega `ref()` para a raiz, e `child()` para um [_RecordingRef].
class _FakeStorage extends Fake implements FirebaseStorage {
  final _RecordingRef child;
  _FakeStorage(this.child);

  @override
  Reference ref([String? path]) => _RootRef(child);
}

class _RootRef extends Fake implements Reference {
  final Reference _child;
  _RootRef(this._child);

  @override
  Reference child(String childPath) => _child;
}

/// Implementação mínima de UploadTask que completa imediatamente.
/// Evita ter que mockar toda a hierarquia Task/UploadTask do SDK.
class _CompletedUploadTask extends Fake implements UploadTask {
  static final _done = Completer<TaskSnapshot>()
    ..complete(_FakeTaskSnapshot());

  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) =>
      _done.future.then(onValue, onError: onError);

  @override
  Stream<TaskSnapshot> asStream() => _done.future.asStream();

  @override
  Future<TaskSnapshot> catchError(Function onError,
          {bool Function(Object)? test}) =>
      _done.future.catchError(onError, test: test);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      _done.future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(Duration timeLimit,
          {FutureOr<TaskSnapshot> Function()? onTimeout}) =>
      _done.future.timeout(timeLimit, onTimeout: onTimeout);
}

class _FakeTaskSnapshot extends Fake implements TaskSnapshot {}

/// Referência que lança FirebaseException no putData.
class _BrokenRef extends Fake implements Reference {
  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    throw FirebaseException(plugin: 'storage', code: 'unauthorized');
  }

  @override
  Future<String> getDownloadURL() => Future.value('');
}

class _BrokenStorage extends Fake implements FirebaseStorage {
  @override
  Reference ref([String? path]) => _BrokenRootRef();
}

class _BrokenRootRef extends Fake implements Reference {
  @override
  Reference child(String childPath) => _BrokenRef();
}

// ---------------------------------------------------------------------------
// Testes
// ---------------------------------------------------------------------------

void main() {
  group('FirebaseProfilePhotoStorage', () {
    test('faz upload e devolve URL de download', () async {
      final recordRef = _RecordingRef(expectedUrl: 'https://cdn.example.com/img.jpg');
      final storage = FirebaseProfilePhotoStorage(
        storage: _FakeStorage(recordRef),
      );
      final bytes = Uint8List.fromList([0xFF, 0xD8, 0xFF]);

      final url = await storage.upload('user123', bytes);

      expect(url, 'https://cdn.example.com/img.jpg');
      expect(recordRef.capturedBytes, bytes);
    });

    test('usa content-type jpeg por defeito', () async {
      final recordRef = _RecordingRef(expectedUrl: 'https://example.com/x.jpg');
      final storage = FirebaseProfilePhotoStorage(storage: _FakeStorage(recordRef));

      await storage.upload('u1', Uint8List.fromList([1, 2]));

      expect(recordRef.capturedMetadata?.contentType, 'image/jpeg');
    });

    test('usa content-type personalizado quando fornecido', () async {
      final recordRef = _RecordingRef(expectedUrl: 'https://example.com/x.png');
      final storage = FirebaseProfilePhotoStorage(storage: _FakeStorage(recordRef));

      await storage.upload('u1', Uint8List.fromList([1, 2]),
          contentType: 'image/png');

      expect(recordRef.capturedMetadata?.contentType, 'image/png');
    });

    test('propaga exceção do Storage ao fazer upload', () async {
      final storage = FirebaseProfilePhotoStorage(storage: _BrokenStorage());

      await expectLater(
        storage.upload('u1', Uint8List.fromList([1])),
        throwsA(isA<FirebaseException>()),
      );
    });
  });
}
