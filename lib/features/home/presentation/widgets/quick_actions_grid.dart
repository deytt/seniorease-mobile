import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';

/// Grid 2×2 de ações rápidas.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm + 4,
      mainAxisSpacing: AppSpacing.sm + 4,
      childAspectRatio: 1.45,
      children: [
        _ActionCard(
          icon: Icons.add_task,
          label: 'Nova Tarefa',
          iconBg: AppColors.primary.withValues(alpha: 0.13),
          iconColor: AppColors.primary,
          onTap: () => context.go(AppRoutes.tasks),
        ),
        _ActionCard(
          icon: Icons.accessibility_new,
          label: 'Acessibilidade',
          iconBg: AppColors.secondary.withValues(alpha: 0.13),
          iconColor: AppColors.secondary,
          onTap: () => context.push(AppRoutes.accessibility),
        ),
        _ActionCard(
          icon: Icons.notifications_outlined,
          label: 'Lembretes',
          iconBg: AppColors.warning.withValues(alpha: 0.13),
          iconColor: AppColors.warning,
          onTap: () => context.go(AppRoutes.reminders),
        ),
        _ActionCard(
          icon: Icons.help_outline,
          label: 'Ajuda Rápida',
          iconBg: AppColors.danger.withValues(alpha: 0.13),
          iconColor: AppColors.danger,
          onTap: () => _showHelp(context),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.help_outline, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Precisa de Ajuda?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ligue para a nossa equipa de suporte — estamos aqui para si.'),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary, size: 20),
                SizedBox(width: 8),
                Text(
                  '1-800-SENIOR',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

// Note: FontSizeScale imported for potential future use when preferences affect card sizes
// ignore_for_file: unused_import
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Spacer(),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
