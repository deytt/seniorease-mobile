import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';

/// Grid 2×2 de ações rápidas.
/// Usa IntrinsicHeight + Row em vez de GridView para que os cards
/// cresçam com o tamanho da fonte sem overflow.
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    this.tourScope,
    this.newTaskShowcaseKey,
    this.accessibilityShowcaseKey,
  });

  /// Quando fornecidos, os cards "Nova Tarefa" e "Acessibilidade" são alvos do
  /// tutorial guiado da Tela Inicial.
  final String? tourScope;
  final GlobalKey? newTaskShowcaseKey;
  final GlobalKey? accessibilityShowcaseKey;

  static const double _gap = AppSpacing.sm + 4; // 12px

  Widget _maybeShowcase({
    required GlobalKey? key,
    required String title,
    required String description,
    required Widget child,
  }) {
    if (tourScope == null || key == null) return child;
    return SeniorShowcase(
      showcaseKey: key,
      scope: tourScope!,
      title: title,
      description: description,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _maybeShowcase(
                  key: newTaskShowcaseKey,
                  title: 'Criar uma nova tarefa',
                  description:
                      'Toque aqui para criar uma tarefa, como tomar um remédio ou ir ao médico.',
                  child: _ActionCard(
                    icon: Icons.add_task,
                    label: 'Nova Tarefa',
                    iconBg: AppColors.primary.withValues(alpha: 0.13),
                    iconColor: AppColors.primary,
                    onTap: () => context.push(AppRoutes.createTask),
                  ),
                ),
              ),
              const SizedBox(width: _gap),
              Expanded(
                child: _maybeShowcase(
                  key: accessibilityShowcaseKey,
                  title: 'Ajustar para si',
                  description:
                      'Aqui você pode aumentar as letras e melhorar as cores para ver melhor.',
                  child: _ActionCard(
                    icon: Icons.accessibility_new,
                    label: 'Acessibilidade',
                    iconBg: AppColors.secondary.withValues(alpha: 0.13),
                    iconColor: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.accessibility),
                  ),
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
                  onTap: () => context.push(AppRoutes.guides),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _ActionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            SeniorFeedback.light(ref);
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
