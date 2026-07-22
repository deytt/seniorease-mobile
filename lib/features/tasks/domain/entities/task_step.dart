/// Um passo de uma tarefa (campo `steps` no documento Firestore da tarefa).
class TaskStep {
  const TaskStep({
    required this.id,
    required this.order,
    required this.title,
    this.taskId = '',
    this.instruction = '',
    this.isCompleted = false,
  });

  final String id;

  /// ID da tarefa pai (espelhado no documento para paridade com a web).
  final String taskId;

  /// Ordem do passo no modo guiado (0-indexed).
  final int order;

  /// Texto principal do passo (capturado no formulário de criação).
  final String title;

  /// Instrução adicional opcional (enriquece o Modo Guiado).
  final String instruction;

  final bool isCompleted;

  TaskStep copyWith({
    String? id,
    String? taskId,
    int? order,
    String? title,
    String? instruction,
    bool? isCompleted,
  }) =>
      TaskStep(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        order: order ?? this.order,
        title: title ?? this.title,
        instruction: instruction ?? this.instruction,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'taskId': taskId,
        'order': order,
        'title': title,
        'instruction': instruction,
        'isCompleted': isCompleted,
      };

  /// [fallbackId] é usado quando o mapa não traz `id` (dados legados).
  factory TaskStep.fromMap(String fallbackId, Map<String, dynamic> map) =>
      TaskStep(
        id: map['id'] as String? ?? fallbackId,
        taskId: map['taskId'] as String? ?? '',
        order: (map['order'] as num?)?.toInt() ?? 0,
        title: map['title'] as String? ?? '',
        instruction: map['instruction'] as String? ?? '',
        isCompleted: map['isCompleted'] as bool? ?? false,
      );
}
