import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/login_preferences_repository.dart';

/// Lê as preferências de login lembradas neste dispositivo.
class GetLoginPreferencesUseCase {
  const GetLoginPreferencesUseCase(this._repository);
  final LoginPreferencesRepository _repository;

  Future<LoginPreferences> call() => _repository.get();
}
