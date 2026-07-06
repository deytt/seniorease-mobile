import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/notifications/push_notification_service.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/notifications/data/firebase_fcm_token_repository.dart';
import 'package:mobile/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:mobile/features/notifications/domain/usecases/register_fcm_token_use_case.dart';
import 'package:mobile/features/notifications/domain/usecases/remove_fcm_token_use_case.dart';

// ------------------------------------------------------------------ Infra

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(FirebaseMessaging.instance);
});

final fcmTokenRepositoryProvider = Provider<FcmTokenRepository>((ref) {
  return FirebaseFcmTokenRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

final registerFcmTokenUseCaseProvider = Provider<RegisterFcmTokenUseCase>((ref) {
  return RegisterFcmTokenUseCase(ref.watch(fcmTokenRepositoryProvider));
});

final removeFcmTokenUseCaseProvider = Provider<RemoveFcmTokenUseCase>((ref) {
  return RemoveFcmTokenUseCase(ref.watch(fcmTokenRepositoryProvider));
});

// ------------------------------------------------------------------ Token atual em memória

/// Guarda o último token FCM activo para que o sign-out o possa remover
/// sem precisar de voltar a pedir ao FirebaseMessaging.
final _currentFcmTokenProvider =
    NotifierProvider<_TokenHolder, String?>(_TokenHolder.new);

class _TokenHolder extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? token) => state = token;
}

// ------------------------------------------------------------------ Inicialização

/// Provider que inicializa FCM, pede permissão e regista o token quando
/// o utilizador está autenticado. Deve ser observado num widget raiz.
///
/// Retorna [AsyncValue<void>] — loading enquanto inicializa, error se falhar.
final fcmInitProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);
  final authState = ref.watch(authStateProvider);
  final userId = authState.asData?.value?.id;

  if (userId == null) return;

  final granted = await service.requestPermission();
  if (!granted) return;

  final token = await service.getToken();
  if (token == null) return;

  ref.read(_currentFcmTokenProvider.notifier).set(token);

  await ref.read(registerFcmTokenUseCaseProvider).call(
        userId: userId,
        token: token,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

  // Renovação automática do token — registar o novo token no Firestore
  final subscription = service.onTokenRefresh.listen((newToken) async {
    ref.read(_currentFcmTokenProvider.notifier).set(newToken);
    await ref.read(registerFcmTokenUseCaseProvider).call(
          userId: userId,
          token: newToken,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
  });

  ref.onDispose(subscription.cancel);
});

// ------------------------------------------------------------------ Remoção no sign-out

/// Remove o token FCM do Firestore antes de fazer sign-out.
/// Deve ser chamado pelo controller de sign-out ANTES de chamar signOut().
Future<void> removeFcmTokenOnSignOut(WidgetRef ref) async {
  final authState = ref.read(authStateProvider);
  final userId = authState.asData?.value?.id;
  final token = ref.read(_currentFcmTokenProvider);

  if (userId == null || token == null) return;

  await ref
      .read(removeFcmTokenUseCaseProvider)
      .call(userId: userId, token: token);

  ref.read(_currentFcmTokenProvider.notifier).set(null);
}
