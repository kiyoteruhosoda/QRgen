import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterbase/presentation/widgets/scan_region_overlay.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  const frame = ValueKey('scan-region');

  Future<void> pump(WidgetTester tester, MobileScannerState state) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScanRegionOverlay(
            scannerState: ValueNotifier<MobileScannerState>(state),
          ),
        ),
      ),
    );
  }

  testWidgets('shows the frame while the camera works', (tester) async {
    await pump(tester, const MobileScannerState.uninitialized());

    expect(find.byKey(frame), findsOneWidget);
  });

  testWidgets('hides the frame when camera permission is missing',
      (tester) async {
    await pump(
      tester,
      const MobileScannerState.uninitialized().copyWith(
        error: const MobileScannerException(
          errorCode: MobileScannerErrorCode.permissionDenied,
        ),
      ),
    );

    expect(find.byKey(frame), findsNothing);
  });
}
