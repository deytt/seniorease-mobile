enum ReminderCategory {
  medication,
  appointment,
  general;

  String get label => switch (this) {
        ReminderCategory.medication => 'Medicação',
        ReminderCategory.appointment => 'Consulta',
        ReminderCategory.general => 'Geral',
      };

  static ReminderCategory fromString(String value) => switch (value) {
        'medication' => ReminderCategory.medication,
        'appointment' => ReminderCategory.appointment,
        _ => ReminderCategory.general,
      };

  String toFirestore() => name;
}
