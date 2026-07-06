import 'package:flutter/material.dart';

/// Extensão de tema que expõe os espaçamentos já multiplicados pelo fator
/// do utilizador (compact 0.75 / comfortable 1.0 / spacious 1.5).
///
/// Consumida nas telas via:
/// ```dart
/// final spacing = Theme.of(context).extension<SeniorSpacingTheme>()!;
/// padding: EdgeInsets.all(spacing.cardPadding)
/// ```
class SeniorSpacingTheme extends ThemeExtension<SeniorSpacingTheme> {
  const SeniorSpacingTheme({
    required this.cardPadding,
    required this.sectionGap,
    required this.itemGap,
    required this.buttonGap,
    required this.screenPadding,
  });

  /// Padding interno de cards e containers (base: 16px).
  final double cardPadding;

  /// Espaço vertical entre secções distintas de uma página (base: 24px).
  final double sectionGap;

  /// Espaço entre itens de lista ou campos de formulário (base: 8px).
  final double itemGap;

  /// Espaço entre botões num grupo de ações (base: 8px).
  final double buttonGap;

  /// Padding horizontal/vertical das telas (base: 16px).
  final double screenPadding;

  /// Constrói a extensão a partir de um fator numérico (0.75 / 1.0 / 1.5).
  factory SeniorSpacingTheme.fromFactor(double factor) => SeniorSpacingTheme(
        cardPadding: 16 * factor,
        sectionGap: 24 * factor,
        itemGap: 8 * factor,
        buttonGap: 8 * factor,
        screenPadding: 16 * factor,
      );

  @override
  SeniorSpacingTheme copyWith({
    double? cardPadding,
    double? sectionGap,
    double? itemGap,
    double? buttonGap,
    double? screenPadding,
  }) =>
      SeniorSpacingTheme(
        cardPadding: cardPadding ?? this.cardPadding,
        sectionGap: sectionGap ?? this.sectionGap,
        itemGap: itemGap ?? this.itemGap,
        buttonGap: buttonGap ?? this.buttonGap,
        screenPadding: screenPadding ?? this.screenPadding,
      );

  @override
  SeniorSpacingTheme lerp(SeniorSpacingTheme? other, double t) {
    if (other == null) return this;
    return SeniorSpacingTheme(
      cardPadding: _lerp(cardPadding, other.cardPadding, t),
      sectionGap: _lerp(sectionGap, other.sectionGap, t),
      itemGap: _lerp(itemGap, other.itemGap, t),
      buttonGap: _lerp(buttonGap, other.buttonGap, t),
      screenPadding: _lerp(screenPadding, other.screenPadding, t),
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
