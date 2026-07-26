import 'package:mobile/features/tasks/domain/entities/task.dart';

/// Modelo imutável de filtros para a lista de tarefas.
///
/// Todos os campos são opcionais — `null` significa "sem filtro neste campo".
/// Use [TaskFilter.empty] como valor padrão (sem filtros ativos).
class TaskFilter {
  const TaskFilter({
    this.category,
    this.priority,
    this.status,
    this.isToday = false,
  });

  /// Sem filtros aplicados.
  static const empty = TaskFilter();

  final TaskCategory? category;
  final TaskPriority? priority;

  /// `TaskStatus.pending` → mostra pendentes + em progresso.
  /// `TaskStatus.completed` → mostra apenas concluídas.
  /// `null` → sem filtro de status.
  final TaskStatus? status;

  /// Quando `true`, exibe apenas tarefas cuja `dueDate` é hoje.
  final bool isToday;

  bool get isEmpty =>
      category == null && priority == null && status == null && !isToday;

  /// Número de filtros activos (para badge no botão de filtro).
  int get activeCount =>
      (category != null ? 1 : 0) +
      (priority != null ? 1 : 0) +
      (status != null ? 1 : 0) +
      (isToday ? 1 : 0);

  TaskFilter copyWith({
    Object? category = _sentinel,
    Object? priority = _sentinel,
    Object? status = _sentinel,
    bool? isToday,
  }) =>
      TaskFilter(
        category: category == _sentinel
            ? this.category
            : category as TaskCategory?,
        priority: priority == _sentinel
            ? this.priority
            : priority as TaskPriority?,
        status: status == _sentinel ? this.status : status as TaskStatus?,
        isToday: isToday ?? this.isToday,
      );

  TaskFilter removeCategory() => copyWith(category: null);
  TaskFilter removePriority() => copyWith(priority: null);
  TaskFilter removeStatus() => copyWith(status: null);
  TaskFilter removeToday() => copyWith(isToday: false);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskFilter &&
          other.category == category &&
          other.priority == priority &&
          other.status == status &&
          other.isToday == isToday;

  @override
  int get hashCode => Object.hash(category, priority, status, isToday);
}

// Sentinela para distinguir `null` explícito de "não fornecido" no copyWith.
const _sentinel = Object();
