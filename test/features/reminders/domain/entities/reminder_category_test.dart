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
      expect(
        ReminderCategory.fromString('hydration'),
        ReminderCategory.hydration,
      );
      expect(ReminderCategory.fromString('meal'), ReminderCategory.meal);
      expect(ReminderCategory.fromString('bills'), ReminderCategory.bills);
    });

    test('usa medication como fallback para valores desconhecidos, vazios ou '
        'legados', () {
      expect(ReminderCategory.fromString(''), ReminderCategory.medication);
      expect(ReminderCategory.fromString('xpto'), ReminderCategory.medication);
      // Valor legado que já não existe no enum.
      expect(
        ReminderCategory.fromString('general'),
        ReminderCategory.medication,
      );
    });
  });

  group('ReminderCategory.toFirestore', () {
    test('devolve o name do enum', () {
      expect(ReminderCategory.medication.toFirestore(), 'medication');
      expect(ReminderCategory.appointment.toFirestore(), 'appointment');
      expect(ReminderCategory.hydration.toFirestore(), 'hydration');
      expect(ReminderCategory.meal.toFirestore(), 'meal');
      expect(ReminderCategory.bills.toFirestore(), 'bills');
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
      expect(ReminderCategory.hydration.label, 'Hidratação');
      expect(ReminderCategory.meal.label, 'Alimentação');
      expect(ReminderCategory.bills.label, 'Contas e Pagamentos');
    });
  });
}
