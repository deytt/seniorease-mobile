/// Categorias de lembrete disponíveis no combo de criação e nos filtros.
///
/// Os valores persistidos no Firestore são o [name] do enum (ver
/// [toFirestore]/[fromString]). Ao alterar/adicionar categorias, atualizar
/// também `memory-bank/firebaseSchema.md`.
enum ReminderCategory {
  medication,
  appointment,
  hydration,
  meal,
  bills;

  String get label => switch (this) {
        ReminderCategory.medication => 'Medicação',
        ReminderCategory.appointment => 'Consulta',
        ReminderCategory.hydration => 'Hidratação',
        ReminderCategory.meal => 'Alimentação',
        ReminderCategory.bills => 'Contas e Pagamentos',
      };

  static ReminderCategory fromString(String value) => switch (value) {
        'medication' => ReminderCategory.medication,
        'appointment' => ReminderCategory.appointment,
        'hydration' => ReminderCategory.hydration,
        'meal' => ReminderCategory.meal,
        'bills' => ReminderCategory.bills,
        // Fallback seguro para valores legados/desconhecidos (ex.: 'general').
        _ => ReminderCategory.medication,
      };

  String toFirestore() => name;
}
