import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/firebase/firebase_providers.dart';
import 'package:mobile/core/history/history_recorder.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/reminders/data/firebase_reminder_repository.dart';
import 'package:mobile/features/reminders/domain/entities/reminder.dart';
import 'package:mobile/features/reminders/domain/entities/reminder_filter.dart';
import 'package:mobile/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:mobile/features/reminders/domain/usecases/create_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/delete_reminder_use_case.dart';
import 'package:mobile/features/reminders/domain/usecases/update_reminder_use_case.dart';
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

final updateReminderUseCaseProvider = Provider<UpdateReminderUseCase>((ref) {
  return UpdateReminderUseCase(ref.watch(reminderRepositoryProvider));
});

final markReminderReadUseCaseProvider = Provider<MarkReminderReadUseCase>((ref) {
  return MarkReminderReadUseCase(ref.watch(reminderRepositoryProvider));
});

final deleteReminderUseCaseProvider = Provider<DeleteReminderUseCase>((ref) {
  return DeleteReminderUseCase(ref.watch(reminderRepositoryProvider));
});

// --- Filtro activo (combinável: categoria + hoje) ---

final reminderFilterProvider =
    NotifierProvider<ReminderFilterNotifier, ReminderFilter>(
  ReminderFilterNotifier.new,
);

class ReminderFilterNotifier extends Notifier<ReminderFilter> {
  @override
  ReminderFilter build() => ReminderFilter.empty;

  void update(ReminderFilter filter) => state = filter;
}

// --- Swipe do card (apenas um card aberto por vez, num único lado) ---

/// Lado revelado pelo swipe: editar (esquerda) ou excluir (direita).
enum ReminderSwipeSide { edit, delete }

/// Estado do swipe aberto: qual lembrete e qual lado.
typedef ReminderSwipe = ({String id, ReminderSwipeSide side});

final openReminderSwipeProvider =
    NotifierProvider<OpenReminderSwipeNotifier, ReminderSwipe?>(
  OpenReminderSwipeNotifier.new,
);

class OpenReminderSwipeNotifier extends Notifier<ReminderSwipe?> {
  @override
  ReminderSwipe? build() => null;

  void open(String reminderId, ReminderSwipeSide side) =>
      state = (id: reminderId, side: side);

  void close() => state = null;

  void closeIf(String reminderId) {
    if (state?.id == reminderId) state = null;
  }
}

// --- Card expandido (apenas um expandido por vez) ---

final expandedReminderIdProvider =
    NotifierProvider<ExpandedReminderNotifier, String?>(
  ExpandedReminderNotifier.new,
);

class ExpandedReminderNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void toggle(String reminderId) =>
      state = state == reminderId ? null : reminderId;

  void close() => state = null;
}

// --- Dica de swipe (peek) exibida uma vez por sessão ---

final reminderSwipeHintShownProvider =
    NotifierProvider<ReminderSwipeHintNotifier, bool>(
  ReminderSwipeHintNotifier.new,
);

class ReminderSwipeHintNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markShown() => state = true;
}

// --- Destaque de um lembrete (ao vir da Home) ---

final highlightReminderIdProvider =
    NotifierProvider<HighlightReminderNotifier, String?>(
  HighlightReminderNotifier.new,
);

class HighlightReminderNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void show(String reminderId) => state = reminderId;

  void clear() => state = null;
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
  final filter = ref.watch(reminderFilterProvider);
  return ref.read(getFilteredRemindersUseCaseProvider).call(userId, filter);
});

/// Próximos lembretes ativos para a secção na Home (máx. 3).
///
/// Usa a mesma ordenação da listagem (`scheduledAt` DESC) e exclui
/// lembretes já concluídos.
final todayRemindersProvider = Provider<List<Reminder>>((ref) {
  final all = ref.watch(remindersStreamProvider).asData?.value ?? const [];
  return all.where((r) => !r.isDone).take(3).toList();
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
    final id = result.asData?.value;
    if (id != null) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.reminderCreated,
            title: 'Criou o lembrete: ${reminder.title}',
            entityId: id,
            category: reminder.category.toFirestore(),
          );
    }
    return id;
  }

  Future<bool> update(Reminder reminder) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(updateReminderUseCaseProvider).call(reminder),
    );
    final ok = !state.hasError;
    if (ok) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.reminderEdited,
            title: 'Editou o lembrete: ${reminder.title}',
            entityId: reminder.id,
            category: reminder.category.toFirestore(),
          );
    }
    return ok;
  }

  Future<void> markRead(String reminderId, {required bool isRead}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(markReminderReadUseCaseProvider)
          .call(reminderId, isRead: isRead),
    );
    // Marcar como lido/concluído é uma "conclusão" — conta para streak/semana.
    if (!state.hasError && isRead) {
      final reminder = _findReminder(reminderId);
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.reminderCompleted,
            title: 'Concluiu o lembrete: ${reminder?.title ?? ''}'.trim(),
            entityId: reminderId,
            category: reminder?.category.toFirestore(),
          );
    }
  }

  Future<void> delete(String reminderId) async {
    // Captura os dados antes de apagar.
    final reminder = _findReminder(reminderId);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(deleteReminderUseCaseProvider).call(reminderId),
    );
    if (!state.hasError && reminder != null) {
      await ref.read(historyRecorderProvider).record(
            type: HistoryActionType.reminderDeleted,
            title: 'Removeu o lembrete: ${reminder.title}',
            entityId: reminderId,
            category: reminder.category.toFirestore(),
          );
    }
  }

  /// Procura um lembrete na cache do stream (para o registo de histórico).
  Reminder? _findReminder(String reminderId) {
    final reminders =
        ref.read(remindersStreamProvider).asData?.value ?? const [];
    for (final reminder in reminders) {
      if (reminder.id == reminderId) return reminder;
    }
    return null;
  }
}
