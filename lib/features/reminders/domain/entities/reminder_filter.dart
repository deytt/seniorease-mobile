import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

/// Modelo imutável de filtros para a lista de lembretes.
///
/// Os campos são combináveis — `null`/`false` significa "sem filtro neste
/// campo". Use [ReminderFilter.empty] como valor padrão (sem filtros ativos).
class ReminderFilter {
  const ReminderFilter({
    this.category,
    this.isDone,
    this.isToday = false,
  });

  /// Sem filtros aplicados.
  static const empty = ReminderFilter();

  final ReminderCategory? category;

  /// `false` → pendentes (`isRead == false`).
  /// `true` → concluídos (`isRead == true`).
  /// `null` → sem filtro de status.
  final bool? isDone;

  /// Quando `true`, exibe apenas lembretes cuja `scheduledAt` é hoje.
  final bool isToday;

  bool get isEmpty => category == null && isDone == null && !isToday;

  /// Número de filtros activos (para badge no botão de filtro).
  int get activeCount =>
      (category != null ? 1 : 0) +
      (isDone != null ? 1 : 0) +
      (isToday ? 1 : 0);

  ReminderFilter copyWith({
    Object? category = _sentinel,
    Object? isDone = _sentinel,
    bool? isToday,
  }) =>
      ReminderFilter(
        category: category == _sentinel
            ? this.category
            : category as ReminderCategory?,
        isDone: isDone == _sentinel ? this.isDone : isDone as bool?,
        isToday: isToday ?? this.isToday,
      );

  ReminderFilter removeCategory() => copyWith(category: null);
  ReminderFilter removeStatus() => copyWith(isDone: null);
  ReminderFilter removeToday() => copyWith(isToday: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderFilter &&
          other.category == category &&
          other.isDone == isDone &&
          other.isToday == isToday;

  @override
  int get hashCode => Object.hash(category, isDone, isToday);
}

// Sentinela para distinguir `null` explícito de "não fornecido" no copyWith.
const _sentinel = Object();
