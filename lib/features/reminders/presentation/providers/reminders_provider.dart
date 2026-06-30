import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/reminders/data/firebase_reminder_repository.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:mobile/features/reminders/domain/usecases/create_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/delete_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/get_filtered_reminders_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/get_reminders_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/mark_reminder_read_use_case.dart';

// --- Repositório ---

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return FirebaseReminderRepository(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
});

// --- Use cases ---

final getRemindersUseCaseProvider = Provider<GetRemindersUseCase>((ref) {
  return GetRemindersUseCase(ref.watch(reminderRepositoryProvider));
});

final getFilteredRemindersUseCaseProvider =
    Provider<GetFilteredRemindersUseCase>((ref) {
  return GetFilteredRemindersUseCase(ref.watch(reminderRepositoryProvider));
});

final createReminderUseCaseProvider = Provider<CreateReminderUseCase>((ref) {
  return CreateReminderUseCase(ref.watch(reminderRepositoryProvider));
});

final markReminderReadUseCaseProvider = Provider<MarkReminderReadUseCase>((ref) {
  return MarkReminderReadUseCase(ref.watch(reminderRepositoryProvider));
});

final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  return DeleteReminderUseCase(ref.watch(reminderRepositoryProvider));
});

// --- Filtro activo (chips exclusivos) ---

final reminderListFilterProvider =
    NotifierProvider<ReminderListFilterNotifier, ReminderListFilter>(
  ReminderListFilterNotifier.new,
);

class ReminderListFilterNotifier extends Notifier<ReminderListFilter> {
  @override
  ReminderListFilter build() => ReminderListFilter.today;

  void select(ReminderListFilter filter) => state = filter;
}

// --- Swipe de exclusão (apenas um card aberto por vez) ---

final openReminderSwipeIdProvider =
    NotifierProvider<OpenReminderSwipeNotifier, String?>(
  OpenReminderSwipeNotifier.new,
);

class OpenReminderSwipeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void open(String reminderId) => state = reminderId;

  void close() => state = null;

  void closeIf(String reminderId) {
    if (state == reminderId) state = null;
  }
}

// --- Streams ---

final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  return ref.read(getRemindersUseCaseProvider).call(userId);
});

final filteredRemindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  final userId = ref.watch(authStateProvider).asData?.value?.id;
  if (userId == null) return Stream.value(const []);
  final filter = ref.watch(reminderListFilterProvider);
  return ref.read(getFilteredRemindersUseCaseProvider).call(userId, filter);
});

/// Lembretes de hoje para a secção na Home (máx. 3, por hora).
final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  final all = ref.watch(remindersStreamProvider).asData?.value ?? const [];
  return all.take(3).toList();
});

// --- Controller ---

final remindersControllerProvider =
    NotifierProvider<RemindersController, AsyncValue<void>>(
  RemindersController.new,
);

class RemindersController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String?> create(Reminder reminder) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(createReminderUseCaseProvider).call(reminder),
    );
    state = result.whenData((_) {});
    return result.asData?.value;
  }

  Future<void> markRead(String reminderId, {required bool isRead}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(markReminderReadUseCaseProvider)
          .call(reminderId, isRead: isRead),
    );
  }

  Future<void> delete(String reminderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteReminderUseCaseProvider).call(reminderId),
    );
  }
}
