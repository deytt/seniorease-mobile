import 'package:mobile/core/preferences/user_preferences.dart';

/// Tokens de espaçamento do Design System SeniorEase.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Multiplicador de espaçamento para cada modo escolhido pelo utilizador.
  /// Usado por [SeniorSpacingTheme.fromFactor] para escalar os tokens acima.
  static double factor(SpacingMode mode) => switch (mode) {
        SpacingMode.compact => 0.75,
        SpacingMode.comfortable => 1.0,
        SpacingMode.spacious => 1.5,
      };
}
