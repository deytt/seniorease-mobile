import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_category.dart';

class Reminder {
  const Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.category,
    required this.scheduledAt,
    required this.isRead,
    required this.createdAt,
    this.taskId,
    this.notified = false,
  });

  final String id;
  final String userId;
  final String? taskId;
  final String title;
  final String message;
  final ReminderCategory category;
  final DateTime scheduledAt;
  final bool isRead;
  final DateTime createdAt;

  /// true após a Cloud Function ter enviado o push de aviso deste lembrete.
  /// Reposto a false se scheduledAt for alterado.
  final bool notified;

  bool get isDone => isRead;

  Reminder copyWith({
    String? id,
    String? userId,
    String? taskId,
    String? title,
    String? message,
    ReminderCategory? category,
    DateTime? scheduledAt,
    bool? isRead,
    DateTime? createdAt,
    bool? notified,
  }) =>
      Reminder(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        message: message ?? this.message,
        category: category ?? this.category,
        scheduledAt: scheduledAt ?? this.scheduledAt,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
        notified: notified ?? this.notified,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'taskId': taskId,
        'title': title,
        'message': message,
        'category': category.toFirestore(),
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'isRead': isRead,
        'notified': notified,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory Reminder.fromMap(String id, Map<String, dynamic> map) => Reminder(
        id: id,
        userId: map['userId'] as String? ?? '',
        taskId: map['taskId'] as String?,
        title: map['title'] as String? ?? '',
        message: map['message'] as String? ?? '',
        category:
            ReminderCategory.fromString(map['category'] as String? ?? ''),
        scheduledAt:
            (map['scheduledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: map['isRead'] as bool? ?? false,
        notified: map['notified'] as bool? ?? false,
        createdAt:
            (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
