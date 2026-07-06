import 'package:mobile/core/preferences/user_preferences.dart';

/// Tokens de espaçamento do Design System SeniorEase (techContext.md).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Multiplicador de espaçamento para cada modo escolhido pelo utilizador.
  /// Usado por [SeniorSpacingTheme.fromFactor] para escalar os tokens acima.
  // ignore: todo
  // TODO(GAP-005): mover SpacingMode para core/ e eliminar este import de features.
  static double factor(SpacingMode mode) => switch (mode) {
        SpacingMode.compact => 0.75,
        SpacingMode.comfortable => 1.0,
        SpacingMode.spacious => 1.5,
      };
}
