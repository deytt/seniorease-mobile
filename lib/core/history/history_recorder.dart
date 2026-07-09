import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tipos de ação registáveis no Histórico de Atividades.
///
/// Vive em `core/` (sem regra de negócio), tal como [TourId], para que qualquer
/// feature (tasks, reminders, accessibility, profile, auth) possa registar um
/// evento sem importar a feature `history` — a implementação real é injetada na
/// raiz de composição (`app/`) via [historyRecorderProvider] (ver ADR-017).
enum HistoryActionType {
  taskCreated,
  taskCompleted,
  taskStepCompleted,
  taskDeleted,
  reminderCreated,
  reminderCompleted,
  reminderEdited,
  reminderDeleted,
  accessibilityChanged,
  profileUpdated,
  accountVerified,
  passwordChanged;

  /// Chave estável persistida no Firestore (`history.type`).
  String get storageKey => name;

  static HistoryActionType fromString(String value) =>
      HistoryActionType.values.firstWhere(
        (t) => t.name == value,
        orElse: () => HistoryActionType.taskCreated,
      );

  /// `true` para ações que contam para o streak e o contador semanal.
  bool get isCompletion =>
      this == HistoryActionType.taskCompleted ||
      this == HistoryActionType.reminderCompleted;
}

/// Port (abstração) para registar ações do utilizador no histórico.
///
/// As features dependem **apenas deste port** (via [historyRecorderProvider]),
/// nunca da feature `history`. A implementação real ([AppHistoryRecorder]) vive
/// na camada `app/` e delega para a use case da feature — é a inversão de
/// dependência descrita no ADR-013/ADR-017.
///
/// Contrato: [record] é **best-effort** — nunca deve propagar erros. Falhar a
/// gravar o histórico jamais pode fazer falhar a ação principal do utilizador.
abstract interface class HistoryRecorder {
  Future<void> record({
    required HistoryActionType type,
    required String title,
    String? entityId,
    String? category,
  });
}

/// Implementação default no-op — mantém `core/` compilável e testável de forma
/// isolada. É substituída na `main.dart` por [AppHistoryRecorder] via
/// `overrideWith`.
class NoopHistoryRecorder implements HistoryRecorder {
  const NoopHistoryRecorder();

  @override
  Future<void> record({
    required HistoryActionType type,
    required String title,
    String? entityId,
    String? category,
  }) async {}
}

final historyRecorderProvider =
    Provider<HistoryRecorder>((ref) => const NoopHistoryRecorder());
