import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';

/// Estado vazio motivador do Histórico, com atalho para criar uma tarefa.
class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({required this.onCreateTask, super.key});

  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ainda não há atividades',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Comece criando uma tarefa ou um lembrete. As suas conquistas vão aparecer aqui!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SeniorButton(
              label: 'Criar uma tarefa',
              icon: Icons.add_task_rounded,
              onPressed: onCreateTask,
            ),
          ],
        ),
      ),
    );
  }
}
