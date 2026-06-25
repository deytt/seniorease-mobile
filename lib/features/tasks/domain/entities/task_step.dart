/// Um passo de uma tarefa (subcollection `steps` no Firestore).
class TaskStep {
  const TaskStep({
    required this.id,
    required this.order,
    required this.title,
    this.instruction = '',
    this.isCompleted = false,
  });

  final String id;

  /// Ordem do passo no modo guiado (1-indexed).
  final int order;

  /// Texto principal do passo (capturado no formulário de criação).
  final String title;

  /// Instrução adicional opcional (enriquece o Modo Guiado).
  final String instruction;

  final bool isCompleted;

  TaskStep copyWith({
    String? id,
    int? order,
    String? title,
    String? instruction,
    bool? isCompleted,
  }) =>
      TaskStep(
        id: id ?? this.id,
        order: order ?? this.order,
        title: title ?? this.title,
        instruction: instruction ?? this.instruction,
        isCompleted: isCompleted ?? this.isCompleted,
      );

  Map<String, dynamic> toMap() => {
        'order': order,
        'title': title,
        'instruction': instruction,
        'isCompleted': isCompleted,
      };

  factory TaskStep.fromMap(String id, Map<String, dynamic> map) => TaskStep(
        id: id,
        order: (map['order'] as num?)?.toInt() ?? 0,
        title: map['title'] as String? ?? '',
        instruction: map['instruction'] as String? ?? '',
        isCompleted: map['isCompleted'] as bool? ?? false,
      );
}
