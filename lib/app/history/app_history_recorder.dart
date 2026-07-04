import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/presentation/providers/history_provider.dart';

/// Implementação do port [HistoryRecorder] na camada `app/` (raiz de
/// composição). É o único ponto que liga as features consumidoras à feature
/// `history`, mantendo a inversão de dependência: os controllers dependem
/// apenas do port em `core/`, nunca da feature `history` (ADR-017).
///
/// [record] é **best-effort**: qualquer erro é engolido para nunca afetar a
/// ação principal do utilizador (ex.: criar uma tarefa não pode falhar porque
/// o registo de histórico falhou).
class AppHistoryRecorder implements HistoryRecorder {
  AppHistoryRecorder(this._ref);

  final Ref _ref;

  String? get _userId => _ref.read(authStateProvider).asData?.value?.id;

  @override
  Future<void> record({
    required HistoryActionType type,
    required String title,
    String? entityId,
    String? category,
  }) async {
    try {
      final userId = _userId;
      if (userId == null) return;

      final event = HistoryEvent(
        id: '',
        userId: userId,
        type: type,
        title: title,
        entityId: entityId,
        category: category,
        occurredAt: DateTime.now(),
      );
      await _ref.read(logHistoryEventUseCaseProvider).call(event);
    } catch (error, stackTrace) {
      // Best-effort: nunca propaga. Apenas regista em debug para diagnóstico.
      debugPrint('AppHistoryRecorder.record falhou: $error\n$stackTrace');
    }
  }
}
