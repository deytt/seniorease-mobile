import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/data/local_tutorial_state_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocalTutorialStateRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = LocalTutorialStateRepository();
  });

  test('isOffered/isSeen são false por defeito', () async {
    expect(await repo.isOffered('u1', TourId.home), isFalse);
    expect(await repo.isSeen('u1', TourId.home), isFalse);
  });

  test('markOffered persiste e isOffered passa a true', () async {
    await repo.markOffered('u1', TourId.home);
    expect(await repo.isOffered('u1', TourId.home), isTrue);
    // markOffered não afeta o estado "seen".
    expect(await repo.isSeen('u1', TourId.home), isFalse);
  });

  test('markSeen persiste e isSeen passa a true', () async {
    await repo.markSeen('u1', TourId.createTask);
    expect(await repo.isSeen('u1', TourId.createTask), isTrue);
  });

  test('estado é isolado por utilizador', () async {
    await repo.markOffered('u1', TourId.taskList);
    expect(await repo.isOffered('u1', TourId.taskList), isTrue);
    expect(await repo.isOffered('u2', TourId.taskList), isFalse);
  });

  test('estado é isolado por tutorial', () async {
    await repo.markSeen('u1', TourId.home);
    expect(await repo.isSeen('u1', TourId.home), isTrue);
    expect(await repo.isSeen('u1', TourId.settings), isFalse);
  });
}
