import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/usecases/history/clear_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/delete_code_history_item_usecase.dart';
import 'package:flutterbase/application/usecases/history/get_code_history_usecase.dart';
import 'package:flutterbase/application/usecases/history/record_code_use_usecase.dart';
import 'package:flutterbase/application/usecases/history/set_code_note_usecase.dart';
import 'package:flutterbase/domain/value_objects/code_history_kind.dart';
import 'package:flutterbase/infrastructure/repositories/shared_preferences_code_history_repository.dart';
import 'package:flutterbase/presentation/pages/main_page.dart';
import 'package:flutterbase/presentation/viewmodels/code_history_viewmodel.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/screenshot.dart';

const _scanner = 'dev.steenbakker.mobile_scanner/scanner';

void main() {
  late CodeHistoryViewModel viewModel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final repo = SharedPreferencesCodeHistoryRepository(
      await SharedPreferences.getInstance(),
      storageKey: SharedPreferencesCodeHistoryRepository.scannedStorageKey,
    );
    viewModel = CodeHistoryViewModel(
      getHistory: GetCodeHistoryUseCase(repo),
      recordUse: RecordCodeUseUseCase(repo),
      setNote: SetCodeNoteUseCase(repo),
      deleteItem: DeleteCodeHistoryItemUseCase(repo),
      clearHistory: ClearCodeHistoryUseCase(repo),
    );
    await sl.reset();
    sl.registerSingleton<CodeHistoryViewModel>(
      viewModel,
      instanceName: CodeHistoryKind.scanned.name,
    );
  });

  tearDown(sl.reset);

  /// Stands in for the camera plugin, which refuses the camera permission.
  void mockScanner(WidgetTester tester) {
    for (final name in ['method', 'event', 'deviceOrientation']) {
      final channel = MethodChannel('$_scanner/$name');
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        channel,
        (call) async => switch (call.method) {
          'state' => 2,
          'request' => false,
          _ => null,
        },
      );
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets('notes on the scanner fit a phone (${brightness.name})',
        (tester) async {
      await preparePhoneScreen(tester);
      mockScanner(tester);
      await tester.runAsync(() async {
        await viewModel.recordUse('https://example.com/menu');
        await viewModel.setNote('https://example.com/menu', 'Lunch place');
      });

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
          home: const MainPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lunch place'), findsOneWidget);
      await saveScreenshot(
        find.byType(MaterialApp),
        'note_history_${brightness.name}',
      );

      await tester.tap(find.byTooltip(AppStrings.noteEdit));
      await tester.pumpAndSettle();
      // A keyboard of 336 logical px.
      tester.view.viewInsets = const FakeViewPadding(bottom: 1008);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final save = tester.getRect(find.text(AppStrings.noteSave));
      expect(save.bottom, lessThan(844 - 336));
      await saveScreenshot(
        find.byType(MaterialApp),
        'note_dialog_${brightness.name}',
      );
    });
  }
}
