import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider de feature-flag para feedback de áudio/tátil.
///
/// Valor default = false — sem side-effects antes de qualquer override.
/// Em produção é substituído em [app.dart] com o valor real lido de
/// `preferencesProvider`, mantendo `core/` livre de qualquer import de
/// `features/`.
final audioFeedbackEnabledProvider = Provider<bool>((ref) => false);
