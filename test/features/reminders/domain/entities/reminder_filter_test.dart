import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';

void main() {
  group('ReminderFilter.empty', () {
    test('não tem filtros ativos', () {
      expect(ReminderFilter.empty.isEmpty, isTrue);
      expect(ReminderFilter.empty.category, isNull);
      expect(ReminderFilter.empty.isToday, isFalse);
      expect(ReminderFilter.empty.activeCount, 0);
    });
  });

  group('ReminderFilter.activeCount', () {
    test('conta cada campo activo', () {
      expect(const ReminderFilter(isToday: true).activeCount, 1);
      expect(
        const ReminderFilter(category: ReminderCategory.medication).activeCount,
        1,
      );
      expect(
        const ReminderFilter(
          category: ReminderCategory.meal,
          isToday: true,
        ).activeCount,
        2,
      );
    });
  });

  group('ReminderFilter.copyWith', () {
    test('mantém a categoria quando não é fornecida', () {
      const filter = ReminderFilter(category: ReminderCategory.bills);
      final updated = filter.copyWith(isToday: true);

      expect(updated.category, ReminderCategory.bills);
      expect(updated.isToday, isTrue);
    });

    test('permite limpar a categoria explicitamente com null', () {
      const filter = ReminderFilter(category: ReminderCategory.hydration);
      final updated = filter.copyWith(category: null);

      expect(updated.category, isNull);
    });
  });

  group('ReminderFilter.remove*', () {
    test('removeCategory e removeToday limpam apenas o respetivo campo', () {
      const filter = ReminderFilter(
        category: ReminderCategory.appointment,
        isToday: true,
      );

      expect(filter.removeCategory().category, isNull);
      expect(filter.removeCategory().isToday, isTrue);

      expect(filter.removeToday().isToday, isFalse);
      expect(filter.removeToday().category, ReminderCategory.appointment);
    });
  });

  group('ReminderFilter igualdade', () {
    test('filtros com os mesmos campos são iguais', () {
      expect(
        const ReminderFilter(
          category: ReminderCategory.medication,
          isToday: true,
        ),
        const ReminderFilter(
          category: ReminderCategory.medication,
          isToday: true,
        ),
      );
    });
  });
}
