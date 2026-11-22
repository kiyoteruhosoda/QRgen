import 'package:flutterbase/domain/repositories/code_history_repository.dart';

/// Attaches a note to a code in the history. A blank note removes it.
class SetCodeNoteUseCase {
  const SetCodeNoteUseCase(this._repository);

  final CodeHistoryRepository _repository;

  Future<void> execute(String code, String note) {
    final trimmed = note.trim();
    return _repository.setNote(code, trimmed.isEmpty ? null : trimmed);
  }
}
