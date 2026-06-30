import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

final firebaseStorageProvider =
    Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

/// Web Client ID (OAuth) do projeto `seniorease-backend`. O `google_sign_in`
/// usa-o como `serverClientId` para devolver um `idToken` que o Firebase Auth
/// consome em `signInWithCredential`.
const _googleServerClientId =
    '98401811269-69e4nd2f8s3da66d6tjb86ast6kjuddp.apps.googleusercontent.com';

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    scopes: const ['email'],
    serverClientId: _googleServerClientId,
  ),
);
