import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/senior_spacing_theme.dart';
import 'package:mobile/core/preferences/user_preferences.dart';

/// Tema global do SeniorEase alinhado ao Design System (Figma).
abstract final class AppTheme {
  // ------------------------------------------------------------------ Sizing
  static const double minTouchTarget = 48;
  static const double minTouchTargetLarge = 64;
  static const double backButtonVisualSize = 36;
  static const double backButtonIconSize = 18;
  static const double buttonHeight = 56;
  static const double inputHeight = 58;
  static const double borderRadius = 14;
  static const double borderRadiusSm = 10;
  static const double inputBorderRadius = 16;
  static const double buttonBorderRadius = 16;

  // ------------------------------------------------------------------ Temas base

  static ThemeData get light => _buildBase(
        colorScheme: _lightColorScheme,
        textTheme: _baseTextTheme,
        minTouchTarget: minTouchTarget,
      );

  static ThemeData get dark => _buildBase(
        colorScheme: _darkColorScheme,
        textTheme: _baseTextTheme.apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary,
        ),
        minTouchTarget: minTouchTarget,
        scaffoldBg: AppColors.darkBackground,
        appBarBg: AppColors.darkSurface,
        appBarFg: AppColors.darkTextPrimary,
        inputFill: AppColors.darkSurface,
        dividerColor: AppColors.darkBorder,
      );

  // ------------------------------------------------------------------ Dynamic

  /// Constrói um [ThemeData] com base nas preferências do utilizador.
  /// Aplicado globalmente via [MaterialApp.theme].
  static ThemeData buildDynamic(UserPreferences prefs) {
    final isMaximum = prefs.contrast == ContrastMode.maximum;
    final isDark = prefs.darkMode || isMaximum;
    final isHighContrast =
        prefs.contrast == ContrastMode.high || isMaximum;
    final touchTarget =
        prefs.largeTouchTargets ? minTouchTargetLarge : minTouchTarget;

    ColorScheme colorScheme;
    Color scaffoldBg;
    Color appBarBg;
    Color appBarFg;
    Color inputFill;
    Color dividerColor;
    TextTheme scaledText;

    if (isMaximum) {
      // Preto/branco/amarelo — máximo contraste
      colorScheme = const ColorScheme.dark(
        primary: AppColors.maximumButton,
        onPrimary: AppColors.maximumButtonText,
        secondary: AppColors.maximumButton,
        onSecondary: AppColors.maximumButtonText,
        error: Color(0xFFFF4444),
        onError: AppColors.maximumButtonText,
        surface: AppColors.maximumSurface,
        onSurface: AppColors.maximumText,
        outline: Color(0xFF666666),
      );
      scaffoldBg = AppColors.maximumBackground;
      appBarBg = AppColors.maximumSurface;
      appBarFg = AppColors.maximumText;
      inputFill = AppColors.maximumSurface;
      dividerColor = const Color(0xFF444444);
      scaledText = _scale(
        _baseTextTheme.apply(
          bodyColor: AppColors.maximumText,
          displayColor: AppColors.maximumText,
        ),
        prefs.fontSize.scale,
      );
    } else if (isDark) {
      colorScheme = isHighContrast
          ? _darkColorScheme.copyWith(
              primary: const Color(0xFF93C5FD),
              onPrimary: AppColors.darkBackground,
              outline: AppColors.darkTextSecondary,
            )
          : _darkColorScheme;
      scaffoldBg = AppColors.darkBackground;
      appBarBg = AppColors.darkSurface;
      appBarFg = AppColors.darkTextPrimary;
      inputFill = AppColors.darkSurface;
      dividerColor = AppColors.darkBorder;
      scaledText = _scale(
        _baseTextTheme.apply(
          bodyColor: AppColors.darkTextPrimary,
          displayColor: AppColors.darkTextPrimary,
        ),
        prefs.fontSize.scale,
      );
    } else if (isHighContrast) {
      // Contraste elevado no tema claro
      colorScheme = _lightColorScheme.copyWith(
        primary: const Color(0xFF1D4ED8),
        outline: AppColors.highContrastBorder,
        onSurface: AppColors.highContrastText,
      );
      scaffoldBg = AppColors.highContrastBg;
      appBarBg = AppColors.highContrastBg;
      appBarFg = AppColors.highContrastText;
      inputFill = AppColors.highContrastBg;
      dividerColor = AppColors.highContrastBorder;
      scaledText = _scale(_baseTextTheme, prefs.fontSize.scale);
    } else {
      // Padrão — light
      colorScheme = _lightColorScheme;
      scaffoldBg = AppColors.slate50;
      appBarBg = Colors.white;
      appBarFg = AppColors.slate900;
      inputFill = Colors.white;
      dividerColor = AppColors.slate200;
      scaledText = _scale(_baseTextTheme, prefs.fontSize.scale);
    }

    final spacingTheme =
        SeniorSpacingTheme.fromFactor(AppSpacing.factor(prefs.spacing));

    return _buildBase(
      colorScheme: colorScheme,
      textTheme: scaledText,
      minTouchTarget: touchTarget,
      scaffoldBg: scaffoldBg,
      appBarBg: appBarBg,
      appBarFg: appBarFg,
      inputFill: inputFill,
      dividerColor: dividerColor,
      spacingTheme: spacingTheme,
    );
  }

  // ------------------------------------------------------------------ Helpers

  static ThemeData _buildBase({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required double minTouchTarget,
    Color scaffoldBg = AppColors.slate50,
    Color appBarBg = Colors.white,
    Color appBarFg = AppColors.slate900,
    Color inputFill = Colors.white,
    Color dividerColor = AppColors.slate200,
    SeniorSpacingTheme? spacingTheme,
  }) {
    final spacing = spacingTheme ?? SeniorSpacingTheme.fromFactor(1.0);
    final inputRadius = BorderRadius.circular(inputBorderRadius);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme,
      extensions: <ThemeExtension<dynamic>>[spacing],
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        centerTitle: false,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return inputFill;
        }),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: inputRadius,
          borderSide: BorderSide(color: colorScheme.outline, width: 1),
        ),
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        hintStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        errorStyle: TextStyle(fontSize: 14, color: colorScheme.error),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(minTouchTarget, minTouchTarget),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: Size(minTouchTarget, minTouchTarget),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      dividerTheme: DividerThemeData(color: dividerColor, thickness: 1),
    );
  }

  /// Multiplica todos os tamanhos de fonte de um [TextTheme] pelo factor dado.
  static TextTheme _scale(TextTheme base, double factor) {
    if (factor == 1.0) return base;

    TextStyle? scaleStyle(TextStyle? style) =>
        style?.copyWith(fontSize: (style.fontSize ?? 14) * factor);

    return base.copyWith(
      displayLarge: scaleStyle(base.displayLarge),
      displayMedium: scaleStyle(base.displayMedium),
      displaySmall: scaleStyle(base.displaySmall),
      headlineLarge: scaleStyle(base.headlineLarge),
      headlineMedium: scaleStyle(base.headlineMedium),
      headlineSmall: scaleStyle(base.headlineSmall),
      titleLarge: scaleStyle(base.titleLarge),
      titleMedium: scaleStyle(base.titleMedium),
      titleSmall: scaleStyle(base.titleSmall),
      bodyLarge: scaleStyle(base.bodyLarge),
      bodyMedium: scaleStyle(base.bodyMedium),
      bodySmall: scaleStyle(base.bodySmall),
      labelLarge: scaleStyle(base.labelLarge),
      labelMedium: scaleStyle(base.labelMedium),
      labelSmall: scaleStyle(base.labelSmall),
    );
  }

  // ------------------------------------------------------------------ ColorSchemes

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.slate900,
    outline: AppColors.slate200,
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    outline: AppColors.darkBorder,
  );

  // ------------------------------------------------------------------ TextTheme
  // Escala tipográfica alinhada ao Figma Design System (Inter)
  // Display 48 / H1 36 / H2 30 / H3 24 / H4 20 / Body-L 18 / Body 16 / Small 14 / Caption 12

  static const TextTheme _baseTextTheme = TextTheme(
    // Display — 48px Bold — hero headlines, ecrãs de celebração
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      height: 1.17,
      color: AppColors.slate900,
    ),
    // H1 — 36px Bold — títulos de página, saudação no dashboard
    displayMedium: TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: AppColors.slate900,
    ),
    // H2 — 30px Bold — headers de secção, nomes de ecrã
    displaySmall: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      height: 1.2,
      color: AppColors.slate900,
    ),
    // H3 — 24px Semibold — títulos de card, títulos de modal
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.25,
      color: AppColors.slate900,
    ),
    // H4 — 20px Semibold — sub-títulos, labels de grupo
    headlineMedium: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: AppColors.slate900,
    ),
    // Body Large — 18px Regular — texto principal, instruções
    headlineSmall: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: AppColors.slate600,
    ),
    // Body — 16px Regular — texto secundário, labels
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      height: 1.5,
      color: AppColors.slate600,
    ),
    // Small — 14px Medium — timestamps, helper text, captions
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: AppColors.slate500,
    ),
    // Caption — 12px Semibold — badge labels, status tags (uppercase only)
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.5,
      letterSpacing: 0.5,
      color: AppColors.slate400,
    ),
    // Title Large — 18px Semibold — títulos de appbar, botões grandes
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: AppColors.slate900,
    ),
    // Body Small — 13px Regular — texto de apoio muito pequeno
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      height: 1.4,
      color: AppColors.slate500,
    ),
  );
}
