import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/notifications/presentation/providers/notifications_provider.dart';

/// Widget raiz que inicializa o FCM e gere os handlers de mensagens push.
///
/// Deve envolver o [MaterialApp.router] para ter acesso ao [BuildContext] do
/// navigator. Observa o [fcmInitProvider] (registo de token) e subscreve:
/// - [onMessage]: exibe [SeniorToast] quando o app está em primeiro plano.
/// - [onMessageOpenedApp]: navega para o item quando o utilizador toca na notificação.
/// - [getInitialMessage]: trata a mensagem que abriu o app a partir do estado terminado.
class AppNotificationsGate extends ConsumerStatefulWidget {
  const AppNotificationsGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppNotificationsGate> createState() =>
      _AppNotificationsGateState();
}

class _AppNotificationsGateState
    extends ConsumerState<AppNotificationsGate> {
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedSub;

  @override
  void initState() {
    super.initState();

    // Inicialização FCM: pedir permissão e registar token (side-effect)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fcmInitProvider);
    });

    final service = ref.read(pushNotificationServiceProvider);

    // Foreground: exibir toast informativo
    _onMessageSub = service.onMessage.listen(_handleForegroundMessage);

    // Tap na notificação (app em segundo plano / fechado mas não terminado)
    _onMessageOpenedSub =
        service.onMessageOpenedApp.listen(_handleNotificationTap);

    // App aberto a partir do estado terminado por tap na notificação
    service.getInitialMessage().then((message) {
      if (message != null) _handleNotificationTap(message);
    });
  }

  @override
  void dispose() {
    _onMessageSub?.cancel();
    _onMessageOpenedSub?.cancel();
    super.dispose();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!mounted) return;
    final title = message.notification?.title ?? message.data['title'] as String? ?? 'Notificação';
    final body = message.notification?.body ?? message.data['body'] as String? ?? '';
    showSeniorToast(
      context,
      title: title,
      message: body,
      variant: SeniorToastVariant.info,
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (!mounted) return;
    final entityType = message.data['entityType'] as String?;
    final entityId = message.data['entityId'] as String?;

    if (entityType == null || entityId == null) return;

    switch (entityType) {
      case 'task':
        context.push(AppRoutes.taskDetails(entityId));
      case 'reminder':
        context.go(AppRoutes.reminders);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
