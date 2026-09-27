import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/domain/repositories/code_history_repository.dart';

class GetCodeHistoryUseCase {
  const GetCodeHistoryUseCase(this._repository);

  final CodeHistoryRepository _repository;

  Future<List<CodeHistoryItem>> execute() => _repository.getAll();
}
