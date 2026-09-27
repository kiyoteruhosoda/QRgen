import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/domain/entities/code_history_item.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_code_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  SharedPreferencesCodeHistoryRepository repoFor(String key) =>
      SharedPreferencesCodeHistoryRepository(prefs, storageKey: key);

  CodeHistoryItem item(String value, int minute) => CodeHistoryItem(
        value: value,
        usedAt: DateTime.utc(2026, 9, 27, 0, minute),
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('SharedPreferencesCodeHistoryRepository', () {
    test('returns newest use first', () async {
      final repo = repoFor('h');
      await repo.recordUse(item('a', 1));
      await repo.recordUse(item('b', 2));

      final values = (await repo.getAll()).map((e) => e.value);
      expect(values, ['b', 'a']);
    });

    test('using an existing value again moves it to the top', () async {
      final repo = repoFor('h');
      await repo.recordUse(item('a', 1));
      await repo.recordUse(item('b', 2));
      await repo.recordUse(item('a', 3));

      final all = await repo.getAll();
      expect(all.map((e) => e.value), ['a', 'b']);
      expect(all.first.usedAt, DateTime.utc(2026, 9, 27, 0, 3));
    });

    test('remove deletes only the given value', () async {
      final repo = repoFor('h');
      await repo.recordUse(item('a', 1));
      await repo.recordUse(item('b', 2));
      await repo.remove('a');

      expect((await repo.getAll()).map((e) => e.value), ['b']);
    });

    test('clear empties the history', () async {
      final repo = repoFor('h');
      await repo.recordUse(item('a', 1));
      await repo.clear();

      expect(await repo.getAll(), isEmpty);
    });

    test('histories with different keys do not mix', () async {
      final scanned = repoFor(
        SharedPreferencesCodeHistoryRepository.scannedStorageKey,
      );
      final generated = repoFor(
        SharedPreferencesCodeHistoryRepository.generatedStorageKey,
      );
      await scanned.recordUse(item('scan', 1));
      await generated.recordUse(item('gen', 2));
      await generated.clear();

      expect((await scanned.getAll()).map((e) => e.value), ['scan']);
      expect(await generated.getAll(), isEmpty);
    });

    test('keeps at most 50 entries', () async {
      final repo = repoFor('h');
      for (var i = 0; i < 55; i++) {
        await repo.recordUse(item('v$i', i));
      }

      final all = await repo.getAll();
      expect(all, hasLength(50));
      expect(all.first.value, 'v54');
    });

    test('reads scan history saved by earlier versions', () async {
      SharedPreferences.setMockInitialValues({
        SharedPreferencesCodeHistoryRepository.scannedStorageKey: [
          jsonEncode({
            'value': 'old',
            'scannedAt': '2026-09-01T00:00:00.000Z',
          }),
        ],
      });
      prefs = await SharedPreferences.getInstance();
      final repo = repoFor(
        SharedPreferencesCodeHistoryRepository.scannedStorageKey,
      );

      final all = await repo.getAll();
      expect(all.single.value, 'old');
      expect(all.single.usedAt, DateTime.utc(2026, 9, 1));
    });
  });
}
