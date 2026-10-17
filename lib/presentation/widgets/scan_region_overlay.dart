import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutterbase/shared/theme/theme.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// The square that shows where to hold a code, drawn over the camera.
///
/// Hidden while the camera reports an error (for example, permission denied):
/// the scanner then shows its explanation and retry button in the same place,
/// and the square would sit on top of that text.
class ScanRegionOverlay extends StatelessWidget {
  const ScanRegionOverlay({super.key, required this.scannerState});

  /// Usually the [MobileScannerController] itself.
  final ValueListenable<MobileScannerState> scannerState;

  static const double size = 220;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: scannerState,
      builder: (context, state, _) {
        if (state.error != null) return const SizedBox.shrink();
        return Center(
          child: Container(
            key: const ValueKey('scan-region'),
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              ),
              borderRadius: AppRadius.mdBorder,
            ),
          ),
        );
      },
    );
  }
}
