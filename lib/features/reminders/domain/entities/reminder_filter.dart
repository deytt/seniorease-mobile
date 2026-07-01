import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

/// Modelo imutável de filtros para a lista de lembretes.
///
/// Os campos são combináveis — `null`/`false` significa "sem filtro neste
/// campo". Use [ReminderFilter.empty] como valor padrão (sem filtros ativos).
class ReminderFilter {
  const ReminderFilter({
    this.category,
    this.isToday = false,
  });

  /// Sem filtros aplicados.
  static const empty = ReminderFilter();

  final ReminderCategory? category;

  /// Quando `true`, exibe apenas lembretes cuja `scheduledAt` é hoje.
  final bool isToday;

  bool get isEmpty => category == null && !isToday;

  /// Número de filtros activos (para badge no botão de filtro).
  int get activeCount => (category != null ? 1 : 0) + (isToday ? 1 : 0);

  ReminderFilter copyWith({
    Object? category = _sentinel,
    bool? isToday,
  }) =>
      ReminderFilter(
        category: category == _sentinel
            ? this.category
            : category as ReminderCategory?,
        isToday: isToday ?? this.isToday,
      );

  ReminderFilter removeCategory() => copyWith(category: null);
  ReminderFilter removeToday() => copyWith(isToday: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderFilter &&
          other.category == category &&
          other.isToday == isToday;

  @override
  int get hashCode => Object.hash(category, isToday);
}

// Sentinela para distinguir `null` explícito de "não fornecido" no copyWith.
const _sentinel = Object();
