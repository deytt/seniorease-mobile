import 'package:mobile/features/profile/domain/entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// Stream do perfil do utilizador (documento `users/{userId}`). Emite um
  /// perfil vazio enquanto o documento não existir.
  Stream<UserProfile> watch(String userId);

  /// Persiste os campos editáveis do perfil (merge — preserva `id`/`createdAt`).
  Future<void> save(UserProfile profile);
}
