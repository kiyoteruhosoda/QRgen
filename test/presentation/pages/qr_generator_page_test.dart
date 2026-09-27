import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/usecases/history/clear_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/delete_code_history_item_usecase.dart';
import 'package:flutterbase/application/usecases/history/get_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/record_code_use_usecase.dart';
import 'package:flutterbase/domain/value_objects/code_history_kind.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_code_history_repository.dart';
import 'package:flutterbase/presentation/pages/qr_generator_page.dart';
import 'package:flutterbase/presentation/viewmodels/code_history_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CodeHistoryViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPreferencesCodeHistoryRepository(
      await SharedPreferences.getInstance(),
      storageKey: SharedPreferencesCodeHistoryRepository.generatedStorageKey,
    );
    viewModel = CodeHistoryViewModel(
      getHistory: GetCodeHistoryUseCase(repo),
      recordUse: RecordCodeUseUseCase(repo),
      deleteItem: DeleteCodeHistoryItemUseCase(repo),
      clearHistory: ClearCodeHistoryUseCase(repo),
    );
    await sl.reset();
    sl.registerSingleton<CodeHistoryViewModel>(
      viewModel,
      instanceName: CodeHistoryKind.generated.name,
    );
  });

  tearDown(() => sl.reset());

  Future<void> settleStorage(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
  }

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: QrGeneratorPage())),
    );
    await settleStorage(tester);
  }

  testWidgets('typing alone does not add to history', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'https://a.example');
    await settleStorage(tester);

    expect(viewModel.items, isEmpty);
  });

  testWidgets('leaving the input records the code', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'https://a.example');
    FocusManager.instance.primaryFocus?.unfocus();
    await settleStorage(tester);

    expect(viewModel.items.map((e) => e.value), ['https://a.example']);
  });

  testWidgets('picking from history fills the input and moves it up',
      (tester) async {
    await tester.runAsync(() async {
      await viewModel.recordUse('older');
      await viewModel.recordUse('newer');
    });
    await pumpPage(tester);

    await tester.ensureVisible(find.text('older'));
    await tester.tap(find.text('older'));
    await settleStorage(tester);

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.controller!.text, 'older');
    expect(viewModel.items.map((e) => e.value), ['older', 'newer']);
  });
}
