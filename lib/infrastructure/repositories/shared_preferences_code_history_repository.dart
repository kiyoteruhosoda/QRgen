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

  /// Limit for entries without a note. A note is typed by the user, so it
  /// must not disappear just because other codes were used later.
  static const _maxItemsWithoutNote = 50;

  final SharedPreferences _prefs;
  final String storageKey;
  Future<void> _pendingWrite = Future.value();

  @override
  Future<void> recordUse(CodeHistoryItem item) {
    return _update((current) {
      final previous = current.where((e) => e.value == item.value).firstOrNull;
      final used = item.withNote(item.note ?? previous?.note);
      var withoutNote = 0;
      return [used, ...current.where((e) => e.value != item.value)]
          .where((e) => e.note != null || ++withoutNote <= _maxItemsWithoutNote)
          .toList(growable: false);
    });
  }

  @override
  Future<void> setNote(String value, String? note) {
    return _update(
      (current) => current
          .map((e) => e.value == value ? e.withNote(note) : e)
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
              note: data['note'] as String?,
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
              if (e.note != null) 'note': e.note,
            }),
          )
          .toList(growable: false);
      await _prefs.setStringList(storageKey, payload);
    });
    return _pendingWrite;
  }
}
