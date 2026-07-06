import 'package:firebase_messaging/firebase_messaging.dart';

/// Thin wrapper sobre [FirebaseMessaging] sem dependência de features.
///
/// Responsável por: pedido de permissão, obtenção de token FCM, stream de
/// token refresh e exposição dos streams de mensagens recebidas.
/// A lógica de negócio (gravar token, exibir toast, navegar) fica na camada
/// de features/app, que usa este serviço via injecção de dependência.
class PushNotificationService {
  PushNotificationService(this._messaging);

  final FirebaseMessaging _messaging;

  /// Pede permissão ao sistema operativo para enviar notificações.
  /// Em Android ≥13 apresenta o diálogo; em versões anteriores é automático.
  /// Retorna true se a permissão foi concedida (authorized ou provisional).
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Devolve o token FCM actual do dispositivo, ou null se não disponível.
  Future<String?> getToken() => _messaging.getToken();

  /// Stream que emite um novo token sempre que o FCM o renovar.
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  /// Stream de mensagens recebidas enquanto o app está em primeiro plano.
  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  /// Stream de mensagens em que o utilizador tocou na notificação (app em
  /// segundo plano ou fechado mas não terminado pelo OS).
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  /// Mensagem que causou a abertura do app a partir do estado terminado.
  /// Retorna null se o app foi aberto de outra forma.
  Future<RemoteMessage?> getInitialMessage() =>
      _messaging.getInitialMessage();
}
