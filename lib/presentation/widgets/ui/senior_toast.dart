import 'package:flutter/material.dart';
import 'package:mobile/presentation/theme/app_spacing.dart';
import 'package:mobile/presentation/widgets/ui/senior_alert.dart';

enum SeniorToastVariant { info, success, warning, danger }

class SeniorToast extends StatelessWidget {
  const SeniorToast({
    required this.title,
    required this.message,
    super.key,
    this.variant = SeniorToastVariant.info,
    this.onDismiss,
  });

  final String title;
  final String message;
  final SeniorToastVariant variant;
  final VoidCallback? onDismiss;

  SeniorAlertVariant get _alertVariant => switch (variant) {
        SeniorToastVariant.info => SeniorAlertVariant.info,
        SeniorToastVariant.success => SeniorAlertVariant.success,
        SeniorToastVariant.warning => SeniorAlertVariant.warning,
        SeniorToastVariant.danger => SeniorAlertVariant.danger,
      };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SeniorAlert(
        title: title,
        message: message,
        variant: _alertVariant,
        onDismiss: onDismiss,
      ),
    );
  }
}

void showSeniorToast(
  BuildContext context, {
  required String title,
  required String message,
  SeniorToastVariant variant = SeniorToastVariant.info,
  Duration duration = const Duration(seconds: 4),
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.md),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      content: SeniorToast(
        title: title,
        message: message,
        variant: variant,
        onDismiss: messenger.hideCurrentSnackBar,
      ),
    ),
  );
}
