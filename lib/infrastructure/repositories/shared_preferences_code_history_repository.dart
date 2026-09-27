import 'dart:convert';

import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/domain/repositories/code_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCodeHistoryRepository implements CodeHistoryRepository {
  SharedPreferencesCodeHistoryRepository(
    this._prefs, {
    required this.storageKey,
  });

  /// Key of the scan history. Kept as-is so existing history survives.
  static const scannedStorageKey = 'scanned_code_history';
  static const generatedStorageKey = 'generated_code_history';
  static const _maxItems = 50;

  final SharedPreferences _prefs;
  final String storageKey;
  Future<void> _pendingWrite = Future.value();

  @override
  Future<void> recordUse(CodeHistoryItem item) {
    return _update(
      (current) => [item, ...current.where((e) => e.value != item.value)]
          .take(_maxItems)
          .toList(growable: false),
    );
  }

  @override
  Future<void> remove(String value) {
    return _update(
      (current) =>
          current.where((e) => e.value != value).toList(growable: false),
    );
  }

  @override
  Future<void> clear() {
    return _update((_) => const []);
  }

  @override
  Future<List<CodeHistoryItem>> getAll() async {
    final raw = _prefs.getStringList(storageKey) ?? const [];
    return raw
        .map((e) {
          try {
            final data = jsonDecode(e) as Map<String, dynamic>;
            final value = data['value'] as String?;
            // 'scannedAt' is the field name written before generator history
            // existed.
            final usedAt = (data['usedAt'] ?? data['scannedAt']) as String?;
            if (value == null || usedAt == null) return null;
            return CodeHistoryItem(
              value: value,
              usedAt: DateTime.parse(usedAt).toUtc(),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<CodeHistoryItem>()
        .toList(growable: false);
  }

  /// Serialises read-modify-write cycles so concurrent calls never drop an
  /// update.
  Future<void> _update(
    List<CodeHistoryItem> Function(List<CodeHistoryItem> current) change,
  ) {
    _pendingWrite = _pendingWrite.then((_) async {
      final next = change(await getAll());
      final payload = next
          .map(
            (e) => jsonEncode({
              'value': e.value,
              'usedAt': e.usedAt.toIso8601String(),
            }),
          )
          .toList(growable: false);
      await _prefs.setStringList(storageKey, payload);
    });
    return _pendingWrite;
  }
}
