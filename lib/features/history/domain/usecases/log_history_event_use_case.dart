import 'package:mobile/features/history/domain/entities/history_event.dart';
import 'package:mobile/features/history/domain/repositories/history_repository.dart';

class LogHistoryEventUseCase {
  const LogHistoryEventUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call(HistoryEvent event) => _repository.log(event);
}
