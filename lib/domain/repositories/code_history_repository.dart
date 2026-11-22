import 'package:flutterbase/domain/entities/code_history_item.dart';

/// Most-recently-used list of codes, newest first.
abstract interface class CodeHistoryRepository {
  Future<List<CodeHistoryItem>> getAll();

  /// Puts [item] at the top, replacing any entry with the same value but
  /// keeping that entry's note. Entries with a note never age out.
  Future<void> recordUse(CodeHistoryItem item);

  /// Sets or, with null, removes the note of the entry holding [value],
  /// without moving it.
  Future<void> setNote(String value, String? note);

  Future<void> remove(String value);

  Future<void> clear();
}
