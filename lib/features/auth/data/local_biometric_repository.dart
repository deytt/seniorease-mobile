import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/auth/domain/repositories/biometric_repository.dart';

/// Chave usada no [SharedPreferences] para persistir a preferência de biometria.
const _kBiometricEnabled = 'biometric_enabled';

/// Implementação de [BiometricRepository] que delega para o plugin `local_auth`
/// (diálogo biométrico nativo iOS/Android) e usa [SharedPreferences] para
/// persistir a preferência do utilizador.
///
/// A instância de [SharedPreferences] é injetada para facilitar testes
/// unitários — ver [biometricRepositoryProvider].
class LocalBiometricRepository implements BiometricRepository {
  LocalBiometricRepository({
    required SharedPreferences prefs,
    LocalAuthentication? auth,
  })  : _prefs = prefs,
        _auth = auth ?? LocalAuthentication();

  final SharedPreferences _prefs;
  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final biometrics = await _auth.getAvailableBiometrics();
      return biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  bool isEnabled() => _prefs.getBool(_kBiometricEnabled) ?? false;

  @override
  Future<void> setEnabled({required bool value}) =>
      _prefs.setBool(_kBiometricEnabled, value);

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
