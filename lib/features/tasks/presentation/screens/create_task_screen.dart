import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_input.dart';
import 'package:mobile/core/widgets/senior_feedback_overlay.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/tasks/domain/entities/task.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';
import 'package:mobile/features/tasks/presentation/providers/tasks_provider.dart';
import 'package:mobile/features/tasks/presentation/widgets/category_dropdown.dart';
import 'package:mobile/features/tasks/presentation/widgets/priority_dropdown.dart';
import 'package:mobile/features/tasks/presentation/widgets/step_editor_field.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen>
    with TourHost<CreateTaskScreen> {
  static const String _scope = 'createTask';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Alvos do tutorial guiado.
  final _titleShowcaseKey = GlobalKey();
  final _stepsShowcaseKey = GlobalKey();
  final _createShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.createTask;

  @override
  List<GlobalKey> get tourKeys =>
      [_titleShowcaseKey, _stepsShowcaseKey, _createShowcaseKey];

  // 1 passo pré-aberto por defeito
  final List<TextEditingController> _stepControllers = [
    TextEditingController(),
  ];

  TaskPriority _priority = TaskPriority.medium;
  TaskCategory _category = TaskCategory.health;
  DateTime? _scheduledAt;

  // Erros inline não cobertos pelo Form
  String? _dateTimeError;
  String? _stepsError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final c in _stepControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addStep() {
    setState(() => _stepControllers.add(TextEditingController()));
  }

  void _removeStep(int index) {
    if (_stepControllers.length == 1) return;
    setState(() {
      _stepControllers.removeAt(index).dispose();
    });
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now,
      firstDate: today,
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledAt != null
          ? TimeOfDay(hour: _scheduledAt!.hour, minute: _scheduledAt!.minute)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      _scheduledAt = picked;
      _dateTimeError = null;
    });
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$min';
  }

  bool _validateExtra() {
    bool valid = true;

    if (_scheduledAt == null) {
      setState(() => _dateTimeError = 'Defina a data e hora da tarefa');
      valid = false;
    } else if (_scheduledAt!.isBefore(DateTime.now())) {
      setState(() => _dateTimeError = 'A data e hora não pode ser no passado');
      valid = false;
    } else {
      setState(() => _dateTimeError = null);
    }

    final hasStep = _stepControllers.any((c) => c.text.trim().isNotEmpty);
    if (!hasStep) {
      setState(() => _stepsError = 'Adicione pelo menos 1 passo à tarefa');
      valid = false;
    } else {
      setState(() => _stepsError = null);
    }

    return valid;
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState!.validate();
    final extraOk = _validateExtra();
    if (!formOk || !extraOk) return;

    final userId = ref.read(authStateProvider).asData?.value?.id;
    if (userId == null) return;

    final now = DateTime.now();
    final steps = <TaskStep>[
      for (var i = 0; i < _stepControllers.length; i++)
        if (_stepControllers[i].text.trim().isNotEmpty)
          TaskStep(
            id: 'step_$i',
            order: i,
            title: _stepControllers[i].text.trim(),
          ),
    ];

    final task = Task(
      id: '',
      userId: userId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
      category: _category,
      status: TaskStatus.pending,
      dueDate: _scheduledAt,
      createdAt: now,
      updatedAt: now,
    );

    final id = await ref.read(tasksControllerProvider.notifier).create(task, steps);

    if (!mounted) return;

    if (id != null) {
      await SeniorFeedback.success(ref);
      if (!mounted) return;
      await SeniorFeedbackOverlay.show(
        context,
        title: 'Tarefa criada!',
        message: 'A sua tarefa foi guardada com sucesso.',
      );
      if (!mounted) return;
      context.pop();
    } else {
      showSeniorToast(
        context,
        title: 'Algo deu errado',
        message: 'Não foi possível criar a tarefa. Tente novamente.',
        variant: SeniorToastVariant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(tasksControllerProvider).isLoading;

    return SeniorScreenScaffold(
      title: 'Nova Tarefa',
      backIcon: Icons.close,
      trailing: TourHelpButton(onPressed: startTour, tourId: tourId),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SeniorShowcase(
              showcaseKey: _titleShowcaseKey,
              scope: _scope,
              title: 'Dê um nome à tarefa',
              description:
                  'Escreva aqui o que precisa de fazer. Por exemplo: "Tomar o remédio".',
              child: SeniorInput(
                controller: _titleController,
                label: 'Nome da Tarefa *',
                hint: 'O que precisa de fazer?',
                textInputAction: TextInputAction.next,
                maxLength: 30,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Por favor, escreva um nome para a tarefa'
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _DescriptionField(controller: _descriptionController),
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Prioridade',
                    child: PriorityDropdown(
                      value: _priority,
                      onChanged: (p) => setState(() => _priority = p),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _LabeledField(
                    label: 'Categoria',
                    child: CategoryDropdown(
                      value: _category,
                      onChanged: (c) => setState(() => _category = c),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _LabeledField(
              label: 'Data e Hora',
              child: _DateTimePickerField(
                scheduledAt: _scheduledAt,
                label: _scheduledAt != null
                    ? _formatDateTime(_scheduledAt!)
                    : 'Definir data e hora',
                errorText: _dateTimeError,
                onTap: _pickDateTime,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SeniorShowcase(
              showcaseKey: _stepsShowcaseKey,
              scope: _scope,
              title: 'Divida em passos simples',
              description:
                  'Escreva cada passo da tarefa. Assim fica mais fácil de seguir, um de cada vez.',
              child: _StepsSection(
                controllers: _stepControllers,
                errorText: _stepsError,
                onAdd: _addStep,
                onRemove: _removeStep,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SeniorShowcase(
              showcaseKey: _createShowcaseKey,
              scope: _scope,
              title: 'Salve sua tarefa',
              description:
                  'Quando terminar, toque aqui para salvar. Pronto, é só isso!',
              child: SeniorButton(
                label: 'Criar Tarefa',
                icon: Icons.add,
                isLoading: isSaving,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Widgets internos

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _LabeledField(
      label: 'Descrição',
      child: TextField(
        controller: controller,
        minLines: 3,
        maxLines: 5,
        maxLength: 100,
        textInputAction: TextInputAction.newline,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
        decoration: const InputDecoration(
          hintText: 'Adicione mais detalhes...',
        ),
      ),
    );
  }
}

class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.scheduledAt,
    required this.label,
    required this.onTap,
    this.errorText,
  });

  final DateTime? scheduledAt;
  final String label;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              height: 54,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(
                  color: hasError ? AppColors.danger : theme.colorScheme.outline,
                  width: hasError ? 1.5 : 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: hasError ? AppColors.danger : AppColors.slate400,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheduledAt != null
                            ? theme.colorScheme.onSurface
                            : AppColors.slate400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}

class _StepsSection extends StatelessWidget {
  const _StepsSection({
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
    this.errorText,
  });

  final List<TextEditingController> controllers;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Passos da Tarefa *',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Divida a tarefa em passos simples para o modo guiado.',
          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate500),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        for (var i = 0; i < controllers.length; i++) ...[
          StepEditorField(
            index: i + 1,
            controller: controllers[i],
            canRemove: controllers.length > 1,
            onRemove: () => onRemove(i),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: SeniorButton(
            label: 'Adicionar outro passo',
            icon: Icons.add,
            variant: SeniorButtonVariant.outline,
            size: SeniorButtonSize.medium,
            isExpanded: false,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}
