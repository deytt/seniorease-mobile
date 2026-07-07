import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/notifications/app_notifications_gate.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/preferences/preferences_state.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';

class SeniorEaseApp extends ConsumerWidget {
  const SeniorEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final prefsAsync = ref.watch(preferencesProvider);
    final prefs = prefsAsync.value ?? UserPreferences.defaults();

    return ProviderScope(
      overrides: [
        // Liga o provider de core/ ao valor real lido de features/accessibility.
        // Desta forma core/ nunca importa features/, mas o comportamento
        // em runtime é correctamente controlado pela preferência do utilizador.
        audioFeedbackEnabledProvider
            .overrideWithValue(prefs.audioFeedbackEnabled),
      ],
      child: AppNotificationsGate(
        child: MaterialApp.router(
          title: 'Senior Ease',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildDynamic(prefs),
          darkTheme: AppTheme.buildDynamic(prefs.copyWith(darkMode: true)),
          themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: router,
        ),
      ),
    );
  }
}
