import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_alert.dart';

enum SeniorToastVariant { info, success, warning, danger }

void showSeniorToast(
  BuildContext context, {
  required String title,
  required String message,
  SeniorToastVariant variant = SeniorToastVariant.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();

  final alertVariant = switch (variant) {
    SeniorToastVariant.info => SeniorAlertVariant.info,
    SeniorToastVariant.success => SeniorAlertVariant.success,
    SeniorToastVariant.warning => SeniorAlertVariant.warning,
    SeniorToastVariant.danger => SeniorAlertVariant.danger,
  };

  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(AppSpacing.md),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(),
      duration: duration,
      content: SeniorAlert(
        title: title,
        message: message,
        variant: alertVariant,
        onDismiss: messenger.hideCurrentSnackBar,
      ),
    ),
  );
}
