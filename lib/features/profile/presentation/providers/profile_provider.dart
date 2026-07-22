import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/profile/data/firebase_profile_photo_storage.dart';
import 'package:mobile/features/profile/data/firebase_profile_repository.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/domain/repositories/profile_photo_storage.dart';
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:mobile/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:mobile/features/profile/domain/usecases/save_user_profile_use_case.dart';
import 'package:mobile/features/profile/domain/usecases/upload_profile_photo_use_case.dart';

// --- Repositórios ---

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FirebaseProfileRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final profilePhotoStorageProvider = Provider<ProfilePhotoStorage>((ref) {
  return FirebaseProfilePhotoStorage(
    storage: ref.watch(firebaseStorageProvider),
  );
});

// --- Use cases ---

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  return GetUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final saveUserProfileUseCaseProvider = Provider<SaveUserProfileUseCase>((ref) {
  return SaveUserProfileUseCase(ref.watch(profileRepositoryProvider));
});

final uploadProfilePhotoUseCaseProvider =
    Provider<UploadProfilePhotoUseCase>((ref) {
  return UploadProfilePhotoUseCase(ref.watch(profilePhotoStorageProvider));
});

// --- Perfil do utilizador autenticado ---

/// Stream do perfil. Emite um perfil vazio enquanto não houver utilizador
/// autenticado ou enquanto o Firestore não responder.
final profileProvider = StreamProvider<UserProfile>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) {
    return Stream.value(UserProfile.empty(''));
  }
  return ref.read(getUserProfileUseCaseProvider).call(userId);
});

// --- Controller ---

final profileControllerProvider =
    NotifierProvider<ProfileController, AsyncValue<void>>(
  ProfileController.new,
);

class ProfileController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> save(UserProfile profile) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(saveUserProfileUseCaseProvider).call(profile),
    );
    if (!state.hasError) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.profileUpdated,
            title: 'Atualizou perfil',
          );
    }
  }

  /// Faz upload da foto e devolve o URL público (ou `null` em caso de erro).
  Future<String?> uploadPhoto(String userId, Uint8List bytes) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(uploadProfilePhotoUseCaseProvider).call(userId, bytes),
    );
    state = result.whenData((_) {});
    return result.asData?.value;
  }
}
