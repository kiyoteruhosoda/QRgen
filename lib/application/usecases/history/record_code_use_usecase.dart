import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/domain/repositories/code_history_repository.dart';

/// Records that a code was scanned, generated or picked again from the
/// history, moving it to the top.
class RecordCodeUseUseCase {
  const RecordCodeUseUseCase(this._repository);

  final CodeHistoryRepository _repository;

  Future<void> execute(String code) {
    return _repository.recordUse(
      CodeHistoryItem(
        value: code,
        usedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
