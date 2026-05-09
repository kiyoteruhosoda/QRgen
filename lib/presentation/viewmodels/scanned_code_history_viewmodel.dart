import 'package:flutter/foundation.dart';
import 'package:flutterbase/application/usecases/scanner/add_scanned_code_to_history_usecase.dart';
import 'package:flutterbase/application/usecases/scanner/get_scanned_code_history_usecase.dart';
import 'package:flutterbase/domain/entities/scanned_code_history_item.dart';

class ScannedCodeHistoryViewModel extends ChangeNotifier {
  ScannedCodeHistoryViewModel(
    this._getHistoryUseCase,
    this._addUseCase,
  );

  final GetScannedCodeHistoryUseCase _getHistoryUseCase;
  final AddScannedCodeToHistoryUseCase _addUseCase;

  List<ScannedCodeHistoryItem> _items = const [];
  List<ScannedCodeHistoryItem> get items => _items;

  Future<void> load() async {
    _items = await _getHistoryUseCase.execute();
    notifyListeners();
  }

  Future<void> add(String code) async {
    await _addUseCase.execute(code);
    await load();
  }
}
