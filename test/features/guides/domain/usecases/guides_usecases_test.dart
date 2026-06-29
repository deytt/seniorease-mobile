import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/features/guides/domain/repositories/onboarding_repository.dart';
import 'package:mobile/features/guides/domain/repositories/tutorial_state_repository.dart';
import 'package:mobile/features/guides/domain/usecases/complete_initial_tour_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/is_initial_tour_completed_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/mark_tutorial_offered_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/mark_tutorial_seen_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/should_offer_tutorial_use_case.dart';

class MockTutorialStateRepository extends Mock
    implements TutorialStateRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  setUpAll(() => registerFallbackValue(TourId.home));

  group('ShouldOfferTutorialUseCase', () {
    late MockTutorialStateRepository repo;
    setUp(() => repo = MockTutorialStateRepository());

    test('oferece quando ainda não foi oferecido', () async {
      when(() => repo.isOffered(any(), any())).thenAnswer((_) async => false);
      final result =
          await ShouldOfferTutorialUseCase(repo).call('u1', TourId.home);
      expect(result, isTrue);
    });

    test('não oferece quando já foi oferecido', () async {
      when(() => repo.isOffered(any(), any())).thenAnswer((_) async => true);
      final result =
          await ShouldOfferTutorialUseCase(repo).call('u1', TourId.createTask);
      expect(result, isFalse);
      verify(() => repo.isOffered('u1', TourId.createTask)).called(1);
    });
  });

  group('MarkTutorialOfferedUseCase / MarkTutorialSeenUseCase', () {
    late MockTutorialStateRepository repo;
    setUp(() => repo = MockTutorialStateRepository());

    test('markOffered delega', () async {
      when(() => repo.markOffered(any(), any())).thenAnswer((_) async {});
      await MarkTutorialOfferedUseCase(repo).call('u1', TourId.home);
      verify(() => repo.markOffered('u1', TourId.home)).called(1);
    });

    test('markSeen delega', () async {
      when(() => repo.markSeen(any(), any())).thenAnswer((_) async {});
      await MarkTutorialSeenUseCase(repo).call('u1', TourId.taskList);
      verify(() => repo.markSeen('u1', TourId.taskList)).called(1);
    });
  });

  group('Onboarding inicial', () {
    late MockOnboardingRepository repo;
    setUp(() => repo = MockOnboardingRepository());

    test('IsInitialTourCompletedUseCase delega e devolve o valor', () async {
      when(() => repo.isInitialTourCompleted(any()))
          .thenAnswer((_) async => true);
      final result = await IsInitialTourCompletedUseCase(repo).call('u1');
      expect(result, isTrue);
      verify(() => repo.isInitialTourCompleted('u1')).called(1);
    });

    test('CompleteInitialTourUseCase delega', () async {
      when(() => repo.completeInitialTour(any())).thenAnswer((_) async {});
      await CompleteInitialTourUseCase(repo).call('u1');
      verify(() => repo.completeInitialTour('u1')).called(1);
    });
  });
}
