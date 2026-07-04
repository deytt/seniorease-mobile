import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';

class GetHistoryUseCase {
  const GetHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Stream<List<HistoryEvent>> call(String userId, {int limit = 50}) =>
      _repository.watchRecent(userId, limit: limit);
}
