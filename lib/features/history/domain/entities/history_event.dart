import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/core/history/history_recorder.dart';

/// Um evento registado no Histórico de Atividades do utilizador.
///
/// O [title] é um *snapshot* do texto no momento do evento (ex.: "Concluiu:
/// Tomar remédio"), preservando o histórico mesmo que a tarefa/lembrete de
/// origem seja apagada. [entityId] guarda o id do item de origem para permitir
/// navegação futura; [category] alimenta o ícone/cor do card.
class HistoryEvent {
  const HistoryEvent({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.occurredAt,
    this.entityId,
    this.category,
  });

  final String id;
  final String userId;
  final HistoryActionType type;
  final String title;
  final String? entityId;
  final String? category;
  final DateTime occurredAt;

  /// `true` se o evento conta para o streak e o contador semanal.
  bool get isCompletion => type.isCompletion;

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type.storageKey,
        'title': title,
        'entityId': entityId,
        'category': category,
        'occurredAt': Timestamp.fromDate(occurredAt),
      };

  factory HistoryEvent.fromMap(String id, Map<String, dynamic> map) =>
      HistoryEvent(
        id: id,
        userId: map['userId'] as String? ?? '',
        type: HistoryActionType.fromString(map['type'] as String? ?? ''),
        title: map['title'] as String? ?? '',
        entityId: map['entityId'] as String?,
        category: map['category'] as String?,
        occurredAt:
            (map['occurredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
