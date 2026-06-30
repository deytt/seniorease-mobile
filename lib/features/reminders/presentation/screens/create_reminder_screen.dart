import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_input.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/presentation/providers/reminders_provider.dart';

class CreateReminderScreen extends ConsumerStatefulWidget {
  const CreateReminderScreen({super.key});

  @override
  ConsumerState<CreateReminderScreen> createState() =>
      _CreateReminderScreenState();
}

class _CreateReminderScreenState extends ConsumerState<CreateReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  ReminderCategory _category = ReminderCategory.general;
  DateTime _scheduledAt = DateTime.now().add(const Duration(hours: 1));

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Escolha a data',
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
      helpText: 'Escolha a hora',
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return;

    final reminder = Reminder(
      id: '',
      userId: user.id,
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      category: _category,
      scheduledAt: _scheduledAt,
      isRead: false,
      createdAt: DateTime.now(),
    );

    final id = await ref
        .read(remindersControllerProvider.notifier)
        .create(reminder);

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

  String _formatScheduled() {
    final d = _scheduledAt;
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} às $hour:$min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSaving = ref.watch(remindersControllerProvider).isLoading;

    return SeniorScreenScaffold(
      title: 'Novo Lembrete',
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            SeniorInput(
              label: 'Título',
              controller: _titleController,
              maxLength: 40,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indique um título' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            SeniorInput(
              label: 'Mensagem',
              controller: _messageController,
              maxLength: 100,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Categoria',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ReminderCategory.values.map((cat) {
                final selected = _category == cat;
                return FilterChip(
                  label: Text(cat.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = cat),
                  selectedColor: AppColors.primaryLight,
                  checkmarkColor: AppColors.primary,
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Data e hora',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SeniorButton(
              label: _formatScheduled(),
              variant: SeniorButtonVariant.outline,
              icon: Icons.calendar_today_outlined,
              onPressed: _pickDateTime,
            ),
            const SizedBox(height: AppSpacing.xl),
            SeniorButton(
              label: 'Salvar lembrete',
              isLoading: isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
