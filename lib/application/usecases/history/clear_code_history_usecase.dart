import 'package:flutterbase/domain/repositories/code_history_repository.dart';

class ClearCodeHistoryUseCase {
  const ClearCodeHistoryUseCase(this._repository);

  final CodeHistoryRepository _repository;

  Future<void> execute() => _repository.clear();
}
