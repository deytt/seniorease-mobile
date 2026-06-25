import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

/// Barra de progresso + bolinhas numeradas do Modo Guiado.
class GuidedProgressHeader extends StatelessWidget {
  const GuidedProgressHeader({
    required this.steps,
    required this.currentIndex,
    super.key,
  });

  final List<TaskStep> steps;

  /// Índice (0-based) do passo atualmente em foco.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = steps.length;
    final completed = steps.where((s) => s.isCompleted).length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.slate200,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < total; i++)
                _StepDot(
                  number: i + 1,
                  state: _dotState(i),
                ),
            ],
          ),
        ],
      ),
    );
  }

  _DotState _dotState(int index) {
    if (steps[index].isCompleted) return _DotState.completed;
    if (index == currentIndex) return _DotState.current;
    return _DotState.pending;
  }
}

enum _DotState { completed, current, pending }

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.state});

  final int number;
  final _DotState state;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (state) {
      _DotState.completed => (AppColors.success, Colors.white),
      _DotState.current => (AppColors.primary, Colors.white),
      _DotState.pending => (AppColors.slate200, AppColors.slate400),
    };

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: state == _DotState.completed
          ? const Icon(Icons.check, color: Colors.white, size: 16)
          : Text(
              '$number',
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }
}
