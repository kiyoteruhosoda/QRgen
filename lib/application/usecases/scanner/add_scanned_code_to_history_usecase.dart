import 'package:flutterbase/domain/entities/scanned_code_history_item.dart';
import 'package:flutterbase/domain/repositories/scanned_code_history_repository.dart';

class AddScannedCodeToHistoryUseCase {
  const AddScannedCodeToHistoryUseCase(this._repository);

  final ScannedCodeHistoryRepository _repository;

  Future<void> execute(String code) {
    return _repository.add(
      ScannedCodeHistoryItem(
        value: code,
        scannedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
