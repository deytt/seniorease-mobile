import 'package:flutter/material.dart';

/// Tokens de cor do Design System SeniorEase (techContext.md).
abstract final class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);

  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFFF0FDFA);

  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color successDark = Color(0xFF166534);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEF2F2);
  static const Color dangerDark = Color(0xFF991B1B);

  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate900 = Color(0xFF0F172A);

  // Dark mode — fundos e superfícies
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF475569);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);

  // High contrast — WCAG AAA reforçado
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBg = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFF000000);

  // Maximum contrast (dark mode + high contrast) — preto/branco/amarelo
  static const Color maximumBackground = Color(0xFF000000);
  static const Color maximumSurface = Color(0xFF111111);
  static const Color maximumText = Color(0xFFFFFFFF);
  static const Color maximumTextSecondary = Color(0xFFDDDDDD);
  static const Color maximumButton = Color(0xFFFFFF00);
  static const Color maximumButtonText = Color(0xFF000000);
}
