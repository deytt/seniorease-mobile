import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_dialogs.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_input.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';
import 'package:mobile/features/reminders/presentation/widgets/reminder_category_dropdown.dart';

class CreateReminderScreen extends ConsumerStatefulWidget {
  const CreateReminderScreen({super.key, this.initial});

  /// Quando presente, a tela funciona em modo de edição do lembrete indicado.
  final Reminder? initial;

  @override
  ConsumerState<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen>
    with TourHost<CreateReminderScreen> {
  static const String _scope = 'createReminder';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  // Alvos do tutorial guiado.
  final _titleShowcaseKey = GlobalKey();
  final _categoryShowcaseKey = GlobalKey();
  final _dateShowcaseKey = GlobalKey();
  final _saveShowcaseKey = GlobalKey();

  ReminderCategory _category = ReminderCategory.medication;
  DateTime? _scheduledAt;
  String? _dateTimeError;

  bool get _isEditing => widget.initial != null;

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.createReminder;

  @override
  List<GlobalKey> get tourKeys => [
        _titleShowcaseKey,
        _categoryShowcaseKey,
        _dateShowcaseKey,
        _saveShowcaseKey,
      ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _titleController.text = initial.title;
      _messageController.text = initial.message;
      _category = initial.category;
      _scheduledAt = initial.scheduledAt;
    }
    // A oferta de tour na 1ª utilização só faz sentido na criação.
    if (!_isEditing) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _maybeOfferFirstUse());
    }
  }

  /// Na primeira utilização (apenas em Modo Básico), pergunta se pode mostrar
  /// como criar um lembrete. A decisão de "quando" é toda do [TourGate].
  Future<void> _maybeOfferFirstUse() async {
    if (!mounted) return;
    if (ref.read(tourSessionProvider)) return;

    final gate = ref.read(tourGateProvider);
    if (!await gate.shouldOfferFirstUse(TourId.createReminder)) return;
    if (!mounted) return;

    ref.read(tourSessionProvider.notifier).markAutoOffered();
    await gate.markOffered(TourId.createReminder);
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Vamos fazer juntos?',
      message: 'Posso mostrar rapidamente como criar um lembrete?',
      acceptLabel: 'Sim',
      declineLabel: 'Agora não',
    );
    if (accepted && mounted) startTour();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? now,
      firstDate: today,
      lastDate: DateTime(now.year + 5),
      helpText: 'Escolha a data',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _scheduledAt != null
          ? TimeOfDay(hour: _scheduledAt!.hour, minute: _scheduledAt!.minute)
          : TimeOfDay.now(),
      helpText: 'Escolha a hora',
    );
    if (time == null) return;

    setState(() {
      _scheduledAt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _dateTimeError = null;
    });
  }

  bool _validateDateTime() {
    if (_scheduledAt == null) {
      setState(() => _dateTimeError = 'Defina a data e hora do lembrete');
      return false;
    }
    if (_scheduledAt!.isBefore(DateTime.now())) {
      setState(
        () => _dateTimeError = 'A data e hora não pode ser no passado',
      );
      return false;
    }
    setState(() => _dateTimeError = null);
    return true;
  }

  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final dateOk = _validateDateTime();
    if (!formOk || !dateOk) return;

    HapticFeedback.lightImpact();

    final controller = ref.read(remindersControllerProvider.notifier);

    if (_isEditing) {
      final updated = widget.initial!.copyWith(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        category: _category,
        scheduledAt: _scheduledAt!,
      );

      final ok = await controller.update(updated);
      if (!mounted) return;

      if (!ok) {
        showSeniorToast(
          context,
          title: 'Erro',
          message: 'Não foi possível salvar as alterações.',
          variant: SeniorToastVariant.danger,
        );
        return;
      }

      showSeniorToast(
        context,
        title: 'Lembrete atualizado',
        message: 'As alterações foram salvas com sucesso.',
        variant: SeniorToastVariant.success,
      );
      context.pop();
      return;
    }

    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;

    final reminder = Reminder(
      id: '',
      userId: user.id,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      category: _category,
      scheduledAt: _scheduledAt!,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final id = await controller.create(reminder);

    if (!mounted) return;

    if (id == null) {
      showSeniorToast(
        context,
        title: 'Erro',
        message: 'Não foi possível salvar o lembrete.',
        variant: SeniorToastVariant.danger,
      );
      return;
    }

    showSeniorToast(
      context,
      title: 'Lembrete criado',
      message: 'Seu lembrete foi salvo com sucesso.',
      variant: SeniorToastVariant.success,
    );
    context.pop();
  }

  String _formatScheduled(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year}  $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(remindersControllerProvider).isLoading;

    return SeniorScreenScaffold(
      title: _isEditing ? 'Editar Lembrete' : 'Novo Lembrete',
      backIcon: Icons.close,
      trailing: TourHelpButton(onPressed: startTour),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SeniorShowcase(
              showcaseKey: _titleShowcaseKey,
              scope: _scope,
              title: 'Dê um nome ao lembrete',
              description:
                  'Escreva aqui o que quer lembrar. Por exemplo: "Tomar o remédio".',
              child: SeniorInput(
                controller: _titleController,
                label: 'Título *',
                hint: 'O que quer lembrar?',
                textInputAction: TextInputAction.next,
                maxLength: 30,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Por favor, escreva um título para o lembrete'
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SeniorInput(
              controller: _messageController,
              label: 'Mensagem',
              hint: 'Adicione mais detalhes (opcional)',
              maxLength: 100,
            ),
            const SizedBox(height: AppSpacing.md),
            SeniorShowcase(
              showcaseKey: _categoryShowcaseKey,
              scope: _scope,
              title: 'Escolha a categoria',
              description:
                  'A categoria ajuda a organizar e a encontrar os seus lembretes depois.',
              child: _LabeledField(
                label: 'Categoria',
                child: ReminderCategoryDropdown(
                  value: _category,
                  onChanged: (c) => setState(() => _category = c),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SeniorShowcase(
              showcaseKey: _dateShowcaseKey,
              scope: _scope,
              title: 'Quando quer ser lembrado?',
              description:
                  'Toque para escolher o dia e a hora do seu lembrete.',
              child: _LabeledField(
                label: 'Data e Hora',
                child: _DateTimePickerField(
                  scheduledAt: _scheduledAt,
                  label: _scheduledAt != null
                      ? _formatScheduled(_scheduledAt!)
                      : 'Definir data e hora',
                  errorText: _dateTimeError,
                  onTap: _pickDateTime,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SeniorShowcase(
              showcaseKey: _saveShowcaseKey,
              scope: _scope,
              title: 'Salve o lembrete',
              description:
                  'Quando terminar, toque aqui para salvar. Pronto, é só isso!',
              child: SeniorButton(
                label: _isEditing ? 'Salvar alterações' : 'Salvar lembrete',
                icon: _isEditing ? Icons.check : Icons.add,
                isLoading: isSaving,
                onPressed: _save,
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
                color: AppColors.slate900,
              ),
        ),
        const SizedBox(height: 6),
        child,
      ],
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
                  color:
                      hasError ? AppColors.danger : theme.colorScheme.outline,
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
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ],
    );
  }
}
