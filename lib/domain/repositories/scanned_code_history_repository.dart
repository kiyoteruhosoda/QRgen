import 'package:flutterbase/domain/entities/scanned_code_history_item.dart';

abstract interface class ScannedCodeHistoryRepository {
  Future<List<ScannedCodeHistoryItem>> getAll();

  Future<void> add(ScannedCodeHistoryItem item);
}
