import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/guides/data/firebase_onboarding_repository.dart';
import 'package:mobile/features/guides/data/local_tutorial_state_repository.dart';
import 'package:mobile/features/guides/domain/repositories/onboarding_repository.dart';
import 'package:mobile/features/guides/domain/repositories/tutorial_state_repository.dart';
import 'package:mobile/features/guides/domain/usecases/complete_initial_tour_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/is_initial_tour_completed_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/mark_tutorial_offered_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/mark_tutorial_seen_use_case.dart';
import 'package:mobile/features/guides/domain/usecases/should_offer_tutorial_use_case.dart';

// --- Repositórios ---

final tutorialStateRepositoryProvider =
    Provider<TutorialStateRepository>((ref) => LocalTutorialStateRepository());

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => FirebaseOnboardingRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  ),
);

// --- Use cases ---

final shouldOfferTutorialUseCaseProvider =
    Provider<ShouldOfferTutorialUseCase>((ref) =>
        ShouldOfferTutorialUseCase(ref.watch(tutorialStateRepositoryProvider)));

final markTutorialOfferedUseCaseProvider =
    Provider<MarkTutorialOfferedUseCase>((ref) =>
        MarkTutorialOfferedUseCase(ref.watch(tutorialStateRepositoryProvider)));

final markTutorialSeenUseCaseProvider =
    Provider<MarkTutorialSeenUseCase>((ref) =>
        MarkTutorialSeenUseCase(ref.watch(tutorialStateRepositoryProvider)));

final isInitialTourCompletedUseCaseProvider =
    Provider<IsInitialTourCompletedUseCase>((ref) =>
        IsInitialTourCompletedUseCase(ref.watch(onboardingRepositoryProvider)));

final completeInitialTourUseCaseProvider =
    Provider<CompleteInitialTourUseCase>((ref) =>
        CompleteInitialTourUseCase(ref.watch(onboardingRepositoryProvider)));
