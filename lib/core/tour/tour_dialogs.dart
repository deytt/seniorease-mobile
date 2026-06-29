import 'package:flutter/material.dart';
import 'package:mobile/core/widgets/senior_modal.dart';

/// Convite genérico para iniciar um tutorial, com linguagem simples e dois
/// botões claros. Reutilizado pela boas-vindas inicial e pelos convites de
/// primeira utilização. Devolve `true` se o utilizador aceitar.
///
/// Reaproveita [showSeniorConfirmDialog] para manter total consistência visual
/// com o Design System (mesmos botões, raio, tipografia e acessibilidade).
Future<bool> showTourInviteDialog(
  BuildContext context, {
  required String title,
  required String message,
  String acceptLabel = 'Começar agora',
  String declineLabel = 'Agora não',
}) async {
  final result = await showSeniorConfirmDialog(
    context: context,
    title: title,
    message: message,
    confirmLabel: acceptLabel,
    cancelLabel: declineLabel,
  );
  return result ?? false;
}
