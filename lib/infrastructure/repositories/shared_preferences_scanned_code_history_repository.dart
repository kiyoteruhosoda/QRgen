import 'dart:convert';

import 'package:flutterbase/domain/entities/scanned_code_history_item.dart';
import 'package:flutterbase/domain/repositories/scanned_code_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesScannedCodeHistoryRepository
    implements ScannedCodeHistoryRepository {
  SharedPreferencesScannedCodeHistoryRepository(this._prefs);

  static const _historyKey = 'scanned_code_history';
  static const _maxItems = 50;

  final SharedPreferences _prefs;

  @override
  Future<void> add(ScannedCodeHistoryItem item) async {
    final current = await getAll();
    final next = [item, ...current.where((e) => e.value != item.value)]
        .take(_maxItems)
        .toList(growable: false);
    final payload = next
        .map(
          (e) => jsonEncode({
            'value': e.value,
            'scannedAt': e.scannedAt.toIso8601String(),
          }),
        )
        .toList(growable: false);
    await _prefs.setStringList(_historyKey, payload);
  }

  @override
  Future<List<ScannedCodeHistoryItem>> getAll() async {
    final raw = _prefs.getStringList(_historyKey) ?? const [];
    return raw
        .map((e) {
          try {
            final data = jsonDecode(e) as Map<String, dynamic>;
            final value = data['value'] as String?;
            final scannedAt = data['scannedAt'] as String?;
            if (value == null || scannedAt == null) return null;
            return ScannedCodeHistoryItem(
              value: value,
              scannedAt: DateTime.parse(scannedAt).toUtc(),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ScannedCodeHistoryItem>()
        .toList(growable: false);
  }
}
