import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/presentation/theme/app_colors.dart';

/// Estilos de system UI reutilizáveis (status bar + nav bar).
abstract final class SeniorSystemUi {
  static const SystemUiOverlayStyle transparentNavBar = SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle headerOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.white,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static const SystemUiOverlayStyle loginOverlay = SystemUiOverlayStyle(
    statusBarColor: AppColors.slate50,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  static Future<void> configureEdgeToEdge() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(transparentNavBar);
  }
}
