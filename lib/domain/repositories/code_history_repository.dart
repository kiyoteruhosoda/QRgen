import 'package:flutterbase/domain/entities/code_history_item.dart';

/// Most-recently-used list of codes, newest first.
abstract interface class CodeHistoryRepository {
  Future<List<CodeHistoryItem>> getAll();

  /// Puts [item] at the top, replacing any entry with the same value.
  Future<void> recordUse(CodeHistoryItem item);

  Future<void> remove(String value);

  Future<void> clear();
}
