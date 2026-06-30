import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

/// Filtro exclusivo da lista de lembretes (chips do Figma `15:7912`).
enum ReminderListFilter {
  today,
  medication,
  appointments;

  String get label => switch (this) {
        ReminderListFilter.today => 'Hoje',
        ReminderListFilter.medication => 'Medicação',
        ReminderListFilter.appointments => 'Consultas',
      };

  ReminderCategory? get category => switch (this) {
        ReminderListFilter.medication => ReminderCategory.medication,
        ReminderListFilter.appointments => ReminderCategory.appointment,
        ReminderListFilter.today => null,
      };

  bool get isToday => this == ReminderListFilter.today;
}
