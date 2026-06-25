import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';

/// Grid 2×2 de ações rápidas.
/// Usa IntrinsicHeight + Row em vez de GridView para que os cards
/// cresçam com o tamanho da fonte sem overflow.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  static const double _gap = AppSpacing.sm + 4; // 12px

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.add_task,
                  label: 'Nova Tarefa',
                  iconBg: AppColors.primary.withValues(alpha: 0.13),
                  iconColor: AppColors.primary,
                  onTap: () => context.push(AppRoutes.createTask),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _ActionCard(
                  icon: Icons.accessibility_new,
                  label: 'Acessibilidade',
                  iconBg: AppColors.secondary.withValues(alpha: 0.13),
                  iconColor: AppColors.secondary,
                  onTap: () => context.push(AppRoutes.accessibility),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.notifications_outlined,
                  label: 'Lembretes',
                  iconBg: AppColors.warning.withValues(alpha: 0.13),
                  iconColor: AppColors.warning,
                  onTap: () => context.go(AppRoutes.reminders),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _ActionCard(
                  icon: Icons.help_outline,
                  label: 'Ajuda Rápida',
                  iconBg: AppColors.danger.withValues(alpha: 0.13),
                  iconColor: AppColors.danger,
                  onTap: () => _showHelp(context),
                ),
              ),
            ],
          ),
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
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
