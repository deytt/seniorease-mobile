import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

void main() {
  group('ReminderCategory.fromString', () {
    test('mapeia os valores conhecidos', () {
      expect(
        ReminderCategory.fromString('medication'),
        ReminderCategory.medication,
      );
      expect(
        ReminderCategory.fromString('appointment'),
        ReminderCategory.appointment,
      );
      expect(ReminderCategory.fromString('general'), ReminderCategory.general);
    });

    test('usa general como fallback para valores desconhecidos ou vazios', () {
      expect(ReminderCategory.fromString(''), ReminderCategory.general);
      expect(ReminderCategory.fromString('xpto'), ReminderCategory.general);
    });
  });

  group('ReminderCategory.toFirestore', () {
    test('devolve o name do enum', () {
      expect(ReminderCategory.medication.toFirestore(), 'medication');
      expect(ReminderCategory.appointment.toFirestore(), 'appointment');
      expect(ReminderCategory.general.toFirestore(), 'general');
    });

    test('é o inverso de fromString', () {
      for (final category in ReminderCategory.values) {
        expect(
          ReminderCategory.fromString(category.toFirestore()),
          category,
        );
      }
    });
  });

  group('ReminderCategory.label', () {
    test('tem rótulo em português para cada categoria', () {
      expect(ReminderCategory.medication.label, 'Medicação');
      expect(ReminderCategory.appointment.label, 'Consulta');
      expect(ReminderCategory.general.label, 'Geral');
    });
  });
}
