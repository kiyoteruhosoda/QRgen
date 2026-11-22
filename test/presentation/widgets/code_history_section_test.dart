import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/application/usecases/history/clear_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/delete_code_history_item_usecase.dart';
import 'package:flutterbase/application/usecases/history/get_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/record_code_use_usecase.dart';
import 'package:flutterbase/application/usecases/history/set_code_note_usecase.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_code_history_repository.dart';
import 'package:flutterbase/presentation/viewmodels/code_history_viewmodel.dart';
import 'package:flutterbase/presentation/widgets/code_history_section.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CodeHistoryViewModel viewModel;
  late List<String> selected;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPreferencesCodeHistoryRepository(
      await SharedPreferences.getInstance(),
      storageKey: 'h',
    );
    viewModel = CodeHistoryViewModel(
      getHistory: GetCodeHistoryUseCase(repo),
      recordUse: RecordCodeUseUseCase(repo),
      setNote: SetCodeNoteUseCase(repo),
      deleteItem: DeleteCodeHistoryItemUseCase(repo),
      clearHistory: ClearCodeHistoryUseCase(repo),
    );
    selected = [];
  });

  Future<void> pumpSection(WidgetTester tester, {double? listHeight}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CodeHistorySection(
              viewModel: viewModel,
              emptyText: 'empty',
              listHeight: listHeight,
              onSelect: selected.add,
            ),
          ),
        ),
      ),
    );
  }

  List<String> shownValues(WidgetTester tester) => tester
      .widgetList<ListTile>(find.byType(ListTile))
      .map((t) => (t.title! as Text).data!)
      .toList();

  testWidgets('shows the empty text and disables clear-all', (tester) async {
    await pumpSection(tester);

    expect(find.text('empty'), findsOneWidget);
    final clear = tester.widget<TextButton>(
      find.widgetWithText(TextButton, AppStrings.historyClearAll),
    );
    expect(clear.onPressed, isNull);
  });

  testWidgets('tapping an entry selects it and moves it to the top',
      (tester) async {
    await tester.runAsync(() async {
      await viewModel.recordUse('first');
      await viewModel.recordUse('second');
    });
    await pumpSection(tester);
    expect(shownValues(tester), ['second', 'first']);

    await tester.tap(find.text('first'));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    expect(selected, ['first']);
    expect(shownValues(tester), ['first', 'second']);
  });

  testWidgets('the delete button removes one entry', (tester) async {
    await tester.runAsync(() async {
      await viewModel.recordUse('keep');
      await viewModel.recordUse('drop');
    });
    await pumpSection(tester);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'drop'),
        matching: find.byTooltip(AppStrings.historyDelete),
      ),
    );
    await tester.pump();

    expect(shownValues(tester), ['keep']);
  });

  testWidgets('swiping an entry away removes it', (tester) async {
    await tester.runAsync(() => viewModel.recordUse('swipe'));
    await pumpSection(tester, listHeight: 200);

    await tester.drag(find.text('swipe'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('swipe'), findsNothing);
    expect(find.text('empty'), findsOneWidget);
  });

  testWidgets('a note can be added, kept on cancel, and removed',
      (tester) async {
    await tester.runAsync(() => viewModel.recordUse('code'));
    await pumpSection(tester);

    Future<void> editNote(String tooltip, String text, String button) async {
      await tester.tap(find.byTooltip(tooltip));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), text);
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
    }

    await editNote(AppStrings.noteAdd, 'office wifi', AppStrings.noteSave);
    expect(find.text('office wifi'), findsOneWidget);
    expect(selected, isEmpty);

    await editNote(AppStrings.noteEdit, 'changed', AppStrings.noteCancel);
    expect(find.text('office wifi'), findsOneWidget);

    await editNote(AppStrings.noteEdit, '', AppStrings.noteSave);
    expect(find.text('office wifi'), findsNothing);
    expect(find.byTooltip(AppStrings.noteAdd), findsOneWidget);
  });

  testWidgets('clear-all asks first, then empties the list', (tester) async {
    await tester.runAsync(() async {
      await viewModel.recordUse('a');
      await viewModel.recordUse('b');
    });
    await pumpSection(tester);

    await tester.tap(find.text(AppStrings.historyClearAll));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.historyCancel));
    await tester.pumpAndSettle();
    expect(shownValues(tester), ['b', 'a']);

    await tester.tap(find.text(AppStrings.historyClearAll));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.historyClearConfirm));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('empty'), findsOneWidget);
  });
}
