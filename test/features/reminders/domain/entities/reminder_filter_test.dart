import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';

void main() {
  group('ReminderListFilter.category', () {
    test('mapeia os filtros de categoria', () {
      expect(
        ReminderListFilter.medication.category,
        ReminderCategory.medication,
      );
      expect(
        ReminderListFilter.appointments.category,
        ReminderCategory.appointment,
      );
    });

    test('hoje não tem categoria associada', () {
      expect(ReminderListFilter.today.category, isNull);
    });
  });

  group('ReminderListFilter.isToday', () {
    test('só é verdadeiro para o filtro today', () {
      expect(ReminderListFilter.today.isToday, isTrue);
      expect(ReminderListFilter.medication.isToday, isFalse);
      expect(ReminderListFilter.appointments.isToday, isFalse);
    });
  });

  group('ReminderListFilter.label', () {
    test('tem rótulo em português para cada filtro', () {
      expect(ReminderListFilter.today.label, 'Hoje');
      expect(ReminderListFilter.medication.label, 'Medicação');
      expect(ReminderListFilter.appointments.label, 'Consultas');
    });
  });
}
