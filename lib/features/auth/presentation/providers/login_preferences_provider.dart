import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/local_login_preferences_repository.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';
import 'package:mobile/features/auth/domain/usecases/get_login_preferences_use_case.dart';
import 'package:mobile/features/auth/domain/usecases/save_login_preferences_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Repositório ---

/// Cria o repositório de preferências de login de forma assíncrona
/// (SharedPreferences é obtido diretamente, como nos outros repositórios locais).
final loginPreferencesRepositoryProvider =
    FutureProvider<LoginPreferencesRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LocalLoginPreferencesRepository(prefs: prefs);
});

// --- Use cases ---

final getLoginPreferencesUseCaseProvider =
    FutureProvider<GetLoginPreferencesUseCase>((ref) async {
  final repo = await ref.watch(loginPreferencesRepositoryProvider.future);
  return GetLoginPreferencesUseCase(repo);
});

final saveLoginPreferencesUseCaseProvider =
    FutureProvider<SaveLoginPreferencesUseCase>((ref) async {
  final repo = await ref.watch(loginPreferencesRepositoryProvider.future);
  return SaveLoginPreferencesUseCase(repo);
});
