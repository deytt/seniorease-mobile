import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/celebration_overlay.dart';
import 'package:mobile/features/tasks/presentation/widgets/guided_progress_header.dart';

class GuidedTaskScreen extends ConsumerStatefulWidget {
  const GuidedTaskScreen({required this.taskId, super.key});

  final String taskId;

  @override
  ConsumerState<GuidedTaskScreen> createState() => _GuidedTaskScreenState();
}

class _GuidedTaskScreenState extends ConsumerState<GuidedTaskScreen>
    with TourHost<GuidedTaskScreen> {
  static const String _scope = 'guidedTask';

  int _currentIndex = 0;
  bool _initialized = false;
  bool _finishing = false;

  final _progressShowcaseKey = GlobalKey();
  final _stepCardShowcaseKey = GlobalKey();
  final _footerShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.guidedTask;

  @override
  List<GlobalKey> get tourKeys =>
      [_progressShowcaseKey, _stepCardShowcaseKey, _footerShowcaseKey];

  /// Início inteligente: começa no primeiro passo ainda não concluído.
  void _ensureInit(Task task) {
    if (_initialized || task.steps.isEmpty) return;
    _initialized = true;
    final firstIncomplete = task.steps.indexWhere((s) => !s.isCompleted);
    _currentIndex =
        firstIncomplete == -1 ? task.steps.length - 1 : firstIncomplete;
  }

  Future<void> _onNext(Task task) async {
    if (_finishing) return;
    final controller = ref.read(tasksControllerProvider.notifier);
    final step = task.steps[_currentIndex];
    final isLast = _currentIndex >= task.steps.length - 1;

    // Avançar conclui o passo atual (idempotente).
    if (!step.isCompleted) {
      await controller.setStepCompleted(
        task.id,
        step.id,
        isCompleted: true,
      );
    }
    if (!mounted) return;

    if (isLast) {
      await SeniorFeedback.success(ref);
      setState(() => _finishing = true);
      await controller.completeTask(task.id);
      if (!mounted) return;
      await CelebrationOverlay.show(
        context,
        message: 'Concluiu "${task.title}"!',
      );
      if (!mounted) return;
      context.pop();
    } else {
      await SeniorFeedback.light(ref);
      setState(() => _currentIndex++);
    }
  }

  void _onBack() {
    if (_currentIndex == 0) return;
    SeniorFeedback.selection(ref);
    setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskStreamProvider(widget.taskId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.headerOverlay,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: taskAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('Não foi possível carregar a tarefa.'),
              ),
            ),
            data: (task) {
              if (task.steps.isEmpty) return _NoSteps(onClose: context.pop);
              _ensureInit(task);
              final index = _currentIndex.clamp(0, task.steps.length - 1);
              return _GuidedBody(
                task: task,
                currentIndex: index,
                scope: _scope,
                progressShowcaseKey: _progressShowcaseKey,
                stepCardShowcaseKey: _stepCardShowcaseKey,
                footerShowcaseKey: _footerShowcaseKey,
                onNext: () => _onNext(task),
                onBack: _onBack,
                onHelp: startTour,
                tourId: tourId,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuidedBody extends StatelessWidget {
  const _GuidedBody({
    required this.task,
    required this.currentIndex,
    required this.scope,
    required this.progressShowcaseKey,
    required this.stepCardShowcaseKey,
    required this.footerShowcaseKey,
    required this.onNext,
    required this.onBack,
    required this.onHelp,
    this.tourId,
  });

  final Task task;
  final int currentIndex;
  final String scope;
  final GlobalKey progressShowcaseKey;
  final GlobalKey stepCardShowcaseKey;
  final GlobalKey footerShowcaseKey;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final TourId? tourId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final step = task.steps[currentIndex];
    final total = task.steps.length;
    final isLast = currentIndex >= total - 1;
    final isFirst = currentIndex == 0;

    return Column(
      children: [
        _Header(
          scope: scope,
          progressShowcaseKey: progressShowcaseKey,
          onHelp: onHelp,
          tourId: tourId,
        ),
        GuidedProgressHeader(steps: task.steps, currentIndex: currentIndex),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
            child: SeniorShowcase(
              showcaseKey: stepCardShowcaseKey,
              scope: scope,
              title: 'Passo atual',
              description:
                  'Leia com calma o que precisa de fazer neste passo. Quando terminar, toque em "Próximo".',
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: 'Passo ${currentIndex + 1} de $total',
                    child: Text(
                      'Passo ${currentIndex + 1} de $total',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate400,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: 80,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${step.order}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    step.title,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    step.instruction.isNotEmpty
                        ? step.instruction
                        : 'Quando terminar este passo, toque em «Próximo».',
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
        SeniorShowcase(
          showcaseKey: footerShowcaseKey,
          scope: scope,
          title: 'Navegar entre passos',
          description:
              '"Anterior" volta ao passo anterior. "Próximo" avança e conclui o passo atual. No último passo aparece "Concluir".',
          child: _Footer(
            isFirst: isFirst,
            isLast: isLast,
            onBack: onBack,
            onNext: onNext,
          ),
        ),
      ],
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.scope,
    required this.progressShowcaseKey,
    required this.onHelp,
    this.tourId,
  });

  final String scope;
  final GlobalKey progressShowcaseKey;
  final VoidCallback onHelp;
  final TourId? tourId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        12,
        AppSpacing.md,
        17,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Semantics(
            button: true,
            label: 'Sair do modo guiado',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  SeniorFeedback.light(ref);
                  Navigator.of(context).maybePop();
                },
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                child: SizedBox(
                  width: AppTheme.minTouchTarget,
                  height: AppTheme.minTouchTarget,
                  child: Center(
                    child: Ink(
                      width: AppTheme.backButtonVisualSize,
                      height: AppTheme.backButtonVisualSize,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadius),
                        border: Border.all(color: theme.colorScheme.outline),
                      ),
                      child: const Icon(Icons.close,
                          color: AppColors.slate900, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SeniorShowcase(
            showcaseKey: progressShowcaseKey,
            scope: scope,
            title: 'Progresso do modo guiado',
            description:
                'Este número mostra em que passo está e quantos passos tem esta tarefa no total.',
            child: Text(
              'Modo Guiado',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          TourHelpButton(onPressed: onHelp, tourId: tourId),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isFirst,
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });

  final bool isFirst;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        17,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Opacity(
              opacity: isFirst ? 0.4 : 1,
              child: _FooterButton(
                label: 'Anterior',
                icon: Icons.arrow_back,
                filled: false,
                onTap: isFirst ? null : onBack,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _FooterButton(
              label: isLast ? 'Concluir' : 'Próximo',
              icon: isLast ? Icons.check : Icons.arrow_forward,
              iconAtEnd: true,
              filled: true,
              onTap: onNext,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterButton extends StatelessWidget {
  const _FooterButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.iconAtEnd = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool iconAtEnd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = filled ? Colors.white : theme.colorScheme.onSurface;

    final children = <Widget>[
      Icon(icon, size: 20, color: fg),
      const SizedBox(width: AppSpacing.sm),
      Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ];

    return Material(
      color: filled ? AppColors.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
        child: Ink(
          height: AppTheme.buttonHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.inputBorderRadius),
            border: filled
                ? null
                : Border.all(color: theme.colorScheme.outline),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: iconAtEnd ? children.reversed.toList() : children,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoSteps extends StatelessWidget {
  const _NoSteps({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Esta tarefa não tem passos',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione passos à tarefa para usar o modo guiado.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton(onPressed: onClose, child: const Text('Voltar')),
          ],
        ),
      ),
    );
  }
}
