import 'package:flutterbase/domain/entities/scanned_code_history_item.dart';
import 'package:flutterbase/domain/repositories/scanned_code_history_repository.dart';

class GetScannedCodeHistoryUseCase {
  const GetScannedCodeHistoryUseCase(this._repository);

  final ScannedCodeHistoryRepository _repository;

  Future<List<ScannedCodeHistoryItem>> execute() => _repository.getAll();
}
