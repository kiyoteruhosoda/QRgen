import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/application/usecases/history/set_code_note_usecase.dart';
import 'package:flutterbase/domain/repositories/code_history_repository.dart';

class _FakeRepository extends Fake implements CodeHistoryRepository {
  final List<(String, String?)> saved = [];

  @override
  Future<void> setNote(String value, String? note) async {
    saved.add((value, note));
  }
}

void main() {
  late _FakeRepository repository;

  setUp(() => repository = _FakeRepository());

  test('trims the note but leaves the code untouched', () async {
    await SetCodeNoteUseCase(repository).execute(' code ', '  shop\n');

    expect(repository.saved, [(' code ', 'shop')]);
  });

  test('a blank note is stored as no note', () async {
    await SetCodeNoteUseCase(repository).execute('code', ' \n ');

    expect(repository.saved, [('code', null)]);
  });
}
