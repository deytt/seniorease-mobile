import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fontes únicas das dependências do Firebase, expostas como providers para
/// serem **injetadas** nos repositórios (composição em `presentation/providers`)
/// em vez de cada repositório criar `FirebaseXxx.instance` internamente.
///
/// Vivem em `core/` (sem regra de negócio) e podem ser substituídas por fakes
/// em testes via `ProviderScope`/`ProviderContainer` overrides.
final firebaseFirestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
