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

  /// Mapa para gravação no Firestore. Datas são [DateTime] — o repositório
  /// Firebase converte para Timestamp antes de gravar.
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type.storageKey,
        'title': title,
        'entityId': entityId,
        'category': category,
        'occurredAt': occurredAt,
      };

  /// Converte um valor dinâmico (Timestamp do Firestore ou DateTime) em [DateTime?].
  static DateTime? _dateFrom(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  factory HistoryEvent.fromMap(String id, Map<String, dynamic> map) =>
      HistoryEvent(
        id: id,
        userId: map['userId'] as String? ?? '',
        type: HistoryActionType.fromString(map['type'] as String? ?? ''),
        title: map['title'] as String? ?? '',
        entityId: map['entityId'] as String?,
        category: map['category'] as String?,
        occurredAt: _dateFrom(map['occurredAt']) ?? DateTime.now(),
      );
}
