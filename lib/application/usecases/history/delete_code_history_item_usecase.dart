import 'package:flutterbase/domain/repositories/code_history_repository.dart';

class DeleteCodeHistoryItemUseCase {
  const DeleteCodeHistoryItemUseCase(this._repository);

  final CodeHistoryRepository _repository;

  Future<void> execute(String code) => _repository.remove(code);
}
