import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/preferences/preferences_state.dart';

/// Wrapper centralizado para todo o feedback tátil (haptic) e sonoro do app.
///
/// Todos os métodos respeitam a preferência `audioFeedbackEnabled` — se
/// estiver desligada, nenhum haptic nem som é disparado.
///
/// Uso:
/// ```dart
/// // Navegação / botão genérico
/// await SeniorFeedback.light(ref);
///
/// // Toggle, chip, seleção
/// await SeniorFeedback.selection(ref);
///
/// // Guardar, confirmar, eliminar
/// await SeniorFeedback.medium(ref);
///
/// // Conclusão / celebração (haptic + som)
/// await SeniorFeedback.success(ref);
/// ```
class SeniorFeedback {
  SeniorFeedback._();

  /// Player singleton com lazy-init para minimizar latência na primeira
  /// reprodução.
  static AudioPlayer? _player;

  static AudioPlayer get _audioPlayer {
    _player ??= AudioPlayer();
    return _player!;
  }

  static bool _isEnabled(WidgetRef ref) =>
      ref.read(audioFeedbackEnabledProvider);

  /// Feedback leve — navegação, abrir telas, botões gerais.
  static Future<void> light(WidgetRef ref) async {
    if (!_isEnabled(ref)) return;
    await HapticFeedback.lightImpact();
  }

  /// Feedback de seleção — chips, toggles, filtros.
  static Future<void> selection(WidgetRef ref) async {
    if (!_isEnabled(ref)) return;
    await HapticFeedback.selectionClick();
  }

  /// Feedback médio — guardar dados, confirmar ações importantes, eliminar.
  static Future<void> medium(WidgetRef ref) async {
    if (!_isEnabled(ref)) return;
    await HapticFeedback.mediumImpact();
  }

  /// Feedback de conclusão/celebração — haptic médio + som positivo.
  /// Usar em: tarefa concluída, lembrete marcado, perfil guardado com sucesso.
  static Future<void> success(WidgetRef ref) async {
    if (!_isEnabled(ref)) return;
    await HapticFeedback.mediumImpact();
    try {
      await _audioPlayer.play(AssetSource('sounds/success.mp3'));
    } catch (_) {
      // Falhas de áudio são silenciosas — não bloqueiam o fluxo principal.
    }
  }
}
