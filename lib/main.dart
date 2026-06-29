import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/app/tour/app_tour_gate.dart';
import 'package:mobile/core/firebase/firebase_options.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/tour/tour_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeniorSystemUi.configureEdgeToEdge();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ProviderScope(
      overrides: [
        // Injeta a implementação real do port do tour (camada de composição).
        tourGateProvider.overrideWith((ref) => AppTourGate(ref)),
      ],
      child: const SeniorEaseApp(),
    ),
  );
}
