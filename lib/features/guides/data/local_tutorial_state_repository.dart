import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/domain/repositories/tutorial_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementação local (shared_preferences) do estado dos tutoriais.
///
/// As chaves são prefixadas por `userId` para suportar várias contas no mesmo
/// dispositivo sem misturar o progresso.
class LocalTutorialStateRepository implements TutorialStateRepository {
  String _key(String userId, TourId id, String suffix) =>
      'tour_${userId}_${id.storageKey}_$suffix';

  @override
  Future<bool> isOffered(String userId, TourId id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId, id, 'offered')) ?? false;
  }

  @override
  Future<void> markOffered(String userId, TourId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId, id, 'offered'), true);
  }

  @override
  Future<bool> isSeen(String userId, TourId id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId, id, 'seen')) ?? false;
  }

  @override
  Future<void> markSeen(String userId, TourId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId, id, 'seen'), true);
  }
}
