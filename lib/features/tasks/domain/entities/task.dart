import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/tasks/domain/entities/task_step.dart';

enum TaskPriority {
  low,
  medium,
  high;

  /// Rótulo curto exibido na lista (ex: "alta").
  String get label => switch (this) {
        TaskPriority.low => 'baixa',
        TaskPriority.medium => 'média',
        TaskPriority.high => 'alta',
      };

  /// Rótulo completo exibido nos detalhes (ex: "Prioridade Alta").
  String get fullLabel => switch (this) {
        TaskPriority.low => 'Prioridade Baixa',
        TaskPriority.medium => 'Prioridade Média',
        TaskPriority.high => 'Prioridade Alta',
      };

  static TaskPriority fromString(String value) => switch (value) {
        'low' => TaskPriority.low,
        'high' => TaskPriority.high,
        _ => TaskPriority.medium,
      };

  String toFirestore() => name;
}

enum TaskCategory {
  medication,
  health,
  exercise,
  social,
  personal;

  /// Rótulo exibido em português nos chips e badges.
  String get label => switch (this) {
        TaskCategory.medication => 'Medicação',
        TaskCategory.health => 'Saúde',
        TaskCategory.exercise => 'Exercício',
        TaskCategory.social => 'Social',
        TaskCategory.personal => 'Pessoal',
      };

  static TaskCategory fromString(String value) => switch (value) {
        'medication' => TaskCategory.medication,
        'exercise' => TaskCategory.exercise,
        'social' => TaskCategory.social,
        'personal' => TaskCategory.personal,
        _ => TaskCategory.health,
      };

  String toFirestore() => name;
}

enum TaskStatus {
  pending,
  inProgress,
  completed;

  bool get isCompleted => this == TaskStatus.completed;

  static TaskStatus fromString(String value) => switch (value) {
        'in_progress' => TaskStatus.inProgress,
        'completed' => TaskStatus.completed,
        _ => TaskStatus.pending,
      };

  String toFirestore() => switch (this) {
        TaskStatus.pending => 'pending',
        TaskStatus.inProgress => 'in_progress',
        TaskStatus.completed => 'completed',
      };
}

class Task {
  const Task({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.steps = const [],
    this.dueDate,
    this.completedAt,
    this.notified = false,
  });

  final String id;
  final String userId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskCategory category;
  final TaskStatus status;

  /// Passos ordenados por `order`. Vazio quando não carregados.
  final List<TaskStep> steps;

  final DateTime? dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// true após a Cloud Function ter enviado o push de aviso desta tarefa.
  /// Reposto a false se dueDate for alterada.
  final bool notified;

  bool get isCompleted => status.isCompleted;

  int get completedSteps => steps.where((s) => s.isCompleted).length;

  int get totalSteps => steps.length;

  /// Progresso de 0.0 a 1.0 com base nos passos concluídos.
  double get progress {
    if (steps.isEmpty) return isCompleted ? 1.0 : 0.0;
    return completedSteps / totalSteps;
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskCategory? category,
    TaskStatus? status,
    List<TaskStep>? steps,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? notified,
  }) =>
      Task(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        category: category ?? this.category,
        status: status ?? this.status,
        steps: steps ?? this.steps,
        dueDate: dueDate ?? this.dueDate,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        notified: notified ?? this.notified,
      );

  /// Mapa para gravação no Firestore. Não inclui `steps` (subcollection).
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'description': description,
        'priority': priority.toFirestore(),
        'category': category.toFirestore(),
        'status': status.toFirestore(),
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'notified': notified,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory Task.fromMap(
    String id,
    Map<String, dynamic> map, {
    List<TaskStep> steps = const [],
  }) =>
      Task(
        id: id,
        userId: map['userId'] as String? ?? '',
        title: map['title'] as String? ?? '',
        description: map['description'] as String? ?? '',
        priority: TaskPriority.fromString(map['priority'] as String? ?? ''),
        category: TaskCategory.fromString(map['category'] as String? ?? ''),
        status: TaskStatus.fromString(map['status'] as String? ?? ''),
        steps: steps,
        dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
        completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
        notified: map['notified'] as bool? ?? false,
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
