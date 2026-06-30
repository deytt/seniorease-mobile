import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/widgets/senior_button.dart';

Future<bool?> showSeniorConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  String cancelLabel = 'Cancelar',
  bool isDestructive = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        title: Text(
          title,
          style: Theme.of(dialogContext).textTheme.headlineSmall,
        ),
        content: Text(
          message,
          style: Theme.of(dialogContext).textTheme.bodyLarge,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SeniorButton(
                label: cancelLabel,
                variant: SeniorButtonVariant.secondary,
                isExpanded: false,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              const SizedBox(height: AppSpacing.sm),
              SeniorButton(
                label: confirmLabel,
                variant: isDestructive
                    ? SeniorButtonVariant.destructive
                    : SeniorButtonVariant.primary,
                isExpanded: false,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          ),
        ],
      );
    },
  );
}
