import 'package:flutter/material.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/core/theme/app_colors.dart';

/// Aparência (ícone, cor e rótulo semântico) de um evento no histórico,
/// derivada do tipo de ação e, quando útil, da categoria do item.
class HistoryVisual {
  const HistoryVisual({
    required this.icon,
    required this.color,
    required this.semanticLabel,
  });

  final IconData icon;
  final Color color;
  final String semanticLabel;

  Color get background => color.withValues(alpha: 0.13);
}

/// Mapeia um evento para a sua aparência. Para conclusões, refina o ícone com
/// base na [category] do item (ex.: medicação → comprimido).
HistoryVisual historyVisual(HistoryActionType type, {String? category}) {
  switch (type) {
    case HistoryActionType.taskCompleted:
    case HistoryActionType.reminderCompleted:
      return HistoryVisual(
        icon: _completionIcon(category),
        color: AppColors.success,
        semanticLabel: 'Concluído',
      );
    case HistoryActionType.taskStepCompleted:
      return const HistoryVisual(
        icon: Icons.done_all_rounded,
        color: AppColors.secondary,
        semanticLabel: 'Passo concluído',
      );
    case HistoryActionType.taskCreated:
      return const HistoryVisual(
        icon: Icons.add_task_rounded,
        color: AppColors.primary,
        semanticLabel: 'Tarefa criada',
      );
    case HistoryActionType.reminderCreated:
      return const HistoryVisual(
        icon: Icons.add_alert_outlined,
        color: AppColors.primary,
        semanticLabel: 'Lembrete criado',
      );
    case HistoryActionType.reminderEdited:
      return const HistoryVisual(
        icon: Icons.edit_outlined,
        color: AppColors.warning,
        semanticLabel: 'Lembrete editado',
      );
    case HistoryActionType.taskDeleted:
    case HistoryActionType.reminderDeleted:
      return const HistoryVisual(
        icon: Icons.delete_outline_rounded,
        color: AppColors.danger,
        semanticLabel: 'Item removido',
      );
    case HistoryActionType.accessibilityChanged:
      return const HistoryVisual(
        icon: Icons.settings_accessibility_rounded,
        color: AppColors.secondary,
        semanticLabel: 'Acessibilidade ajustada',
      );
    case HistoryActionType.profileUpdated:
      return const HistoryVisual(
        icon: Icons.person_outline_rounded,
        color: AppColors.primary,
        semanticLabel: 'Perfil atualizado',
      );
    case HistoryActionType.accountVerified:
      return const HistoryVisual(
        icon: Icons.verified_user_outlined,
        color: AppColors.success,
        semanticLabel: 'Conta verificada',
      );
  }
}

/// Ícone da conclusão consoante a categoria (task/reminder partilham valores).
IconData _completionIcon(String? category) => switch (category) {
      'medication' => Icons.medication_outlined,
      'health' || 'appointment' => Icons.favorite_outline_rounded,
      'exercise' => Icons.directions_walk_rounded,
      'social' => Icons.groups_outlined,
      'hydration' => Icons.water_drop_outlined,
      'meal' => Icons.restaurant_outlined,
      'bills' => Icons.receipt_long_outlined,
      _ => Icons.check_circle_outline_rounded,
    };
