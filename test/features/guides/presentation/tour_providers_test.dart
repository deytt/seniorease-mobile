import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:mobile/features/guides/presentation/providers/tour_providers.dart';

class MockTutorialStateRepository extends Mock
    implements TutorialStateRepository {}

class MockOnboardingRepository extends Mock implements OnboardingRepository {}

void main() {
  late MockTutorialStateRepository stateRepo;
  late MockOnboardingRepository onboardingRepo;

  setUpAll(() {
    registerFallbackValue(TourId.home);
  });

  setUp(() {
    stateRepo = MockTutorialStateRepository();
    onboardingRepo = MockOnboardingRepository();
  });

  ProviderContainer buildContainer() => ProviderContainer(overrides: [
        tutorialStateRepositoryProvider.overrideWithValue(stateRepo),
        onboardingRepositoryProvider.overrideWithValue(onboardingRepo),
      ]);

  group('shouldOfferTutorialUseCaseProvider', () {
    test('instancia ShouldOfferTutorialUseCase com repositório correto',
        () async {
      when(() => stateRepo.isOffered(any(), any()))
          .thenAnswer((_) async => false);

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(shouldOfferTutorialUseCaseProvider);
      expect(useCase, isA<ShouldOfferTutorialUseCase>());

      final shouldOffer = await useCase.call('u1', TourId.home);
      expect(shouldOffer, isTrue);
    });

    test('retorna false quando o tutorial já foi oferecido', () async {
      when(() => stateRepo.isOffered(any(), any()))
          .thenAnswer((_) async => true);

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(shouldOfferTutorialUseCaseProvider);
      final shouldOffer = await useCase.call('u1', TourId.home);
      expect(shouldOffer, isFalse);
    });
  });

  group('markTutorialOfferedUseCaseProvider', () {
    test('instancia MarkTutorialOfferedUseCase e delega para repositório', () async {
      when(() => stateRepo.markOffered(any(), any()))
          .thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(markTutorialOfferedUseCaseProvider);
      expect(useCase, isA<MarkTutorialOfferedUseCase>());

      await useCase.call('u1', TourId.taskList);
      verify(() => stateRepo.markOffered('u1', TourId.taskList)).called(1);
    });
  });

  group('markTutorialSeenUseCaseProvider', () {
    test('instancia MarkTutorialSeenUseCase e delega para repositório', () async {
      when(() => stateRepo.markSeen(any(), any())).thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(markTutorialSeenUseCaseProvider);
      expect(useCase, isA<MarkTutorialSeenUseCase>());

      await useCase.call('u1', TourId.createTask);
      verify(() => stateRepo.markSeen('u1', TourId.createTask)).called(1);
    });
  });

  group('isInitialTourCompletedUseCaseProvider', () {
    test('retorna true quando onboarding foi concluído', () async {
      when(() => onboardingRepo.isInitialTourCompleted(any()))
          .thenAnswer((_) async => true);

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(isInitialTourCompletedUseCaseProvider);
      expect(useCase, isA<IsInitialTourCompletedUseCase>());

      expect(await useCase.call('u1'), isTrue);
    });

    test('retorna false quando onboarding não foi concluído', () async {
      when(() => onboardingRepo.isInitialTourCompleted(any()))
          .thenAnswer((_) async => false);

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(isInitialTourCompletedUseCaseProvider);
      expect(await useCase.call('u1'), isFalse);
    });
  });

  group('completeInitialTourUseCaseProvider', () {
    test('instancia CompleteInitialTourUseCase e delega para repositório',
        () async {
      when(() => onboardingRepo.completeInitialTour(any()))
          .thenAnswer((_) async {});

      final container = buildContainer();
      addTearDown(container.dispose);

      final useCase = container.read(completeInitialTourUseCaseProvider);
      expect(useCase, isA<CompleteInitialTourUseCase>());

      await useCase.call('u1');
      verify(() => onboardingRepo.completeInitialTour('u1')).called(1);
    });
  });
}
