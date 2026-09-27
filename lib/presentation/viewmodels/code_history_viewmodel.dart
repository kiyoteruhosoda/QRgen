import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/usecases/history/clear_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/delete_code_history_item_usecase.dart';
import 'package:flutterbase/application/usecases/history/get_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/record_code_use_usecase.dart';
import 'package:flutterbase/domain/entities/code_history_item.dart';

/// History list of one tab (scanner or generator).
class CodeHistoryViewModel extends ChangeNotifier {
  CodeHistoryViewModel({
    required GetCodeHistoryUseCase getHistory,
    required RecordCodeUseUseCase recordUse,
    required DeleteCodeHistoryItemUseCase deleteItem,
    required ClearCodeHistoryUseCase clearHistory,
  })  : _getHistory = getHistory,
        _recordUse = recordUse,
        _deleteItem = deleteItem,
        _clearHistory = clearHistory;

  final GetCodeHistoryUseCase _getHistory;
  final RecordCodeUseUseCase _recordUse;
  final DeleteCodeHistoryItemUseCase _deleteItem;
  final ClearCodeHistoryUseCase _clearHistory;

  List<CodeHistoryItem> _items = const [];
  List<CodeHistoryItem> get items => _items;

  Future<void> load() async {
    _items = await _getHistory.execute();
    notifyListeners();
  }

  /// Records [code] as just used, moving it to the top of the list.
  Future<void> recordUse(String code) async {
    await _recordUse.execute(code);
    await load();
  }

  Future<void> delete(String code) async {
    // Drop the entry before awaiting storage: a swiped-away Dismissible must
    // leave the tree in the same frame.
    _items = _items.where((e) => e.value != code).toList(growable: false);
    notifyListeners();
    await _deleteItem.execute(code);
    await load();
  }

  Future<void> clear() async {
    await _clearHistory.execute();
    await load();
  }
}
