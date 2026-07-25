import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider de feature-flag para feedback de áudio/tátil.
///
/// Valor default = false — sem side-effects antes de qualquer override.
/// Em produção é substituído em [app.dart] com o valor real lido de
/// `preferencesProvider`, mantendo `core/` livre de qualquer import de
/// `features/`.
final audioFeedbackEnabledProvider = Provider<bool>((ref) => false);

/// Provider de feature-flag para alvos de toque maiores (64 × 64 px).
///
/// Segue o mesmo padrão de [audioFeedbackEnabledProvider]: valor default = false,
/// substituído em [app.dart] com `prefs.largeTouchTargets`. Desta forma
/// `core/widgets/senior_button.dart` nunca importa `features/`.
final largeTouchTargetsProvider = Provider<bool>((ref) => false);
