import 'package:flutter/material.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// The launcher icon, drawn in Flutter: a white QR code on the brand blue.
///
/// Mirrors the Android 16 launcher icon — `mipmap-anydpi-v36/ic_launcher.xml`,
/// whose foreground is `drawable/ic_launcher_foreground.xml` inset by 25 %
/// (`drawable-v36/ic_launcher_foreground_inset.xml`) — so the About and
/// Licenses pages show the same mark as the home screen (task #451).
/// Change both together.
class AppIconMark extends StatelessWidget {
  const AppIconMark({super.key, this.size = AppSpacing.aboutIconContainer});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.xlBorder,
      child: SizedBox.square(
        dimension: size,
        child: const CustomPaint(painter: _AppIconPainter()),
      ),
    );
  }
}

class _AppIconPainter extends CustomPainter {
  const _AppIconPainter();

  /// The adaptive icon is 108 units; the launcher shows the central 72.
  static const double _viewport = 72;
  static const double _inset = (108 - _viewport) / 2;

  /// The 25 % inset on every side shrinks the artwork to half its size.
  static const double _insetScale = 0.5;

  /// The QR grid: 15 × 15 modules of 4 units from (24, 24).
  static const double _origin = 24;
  static const double _module = 4;

  /// Dark modules of the data area (rows 8–14, columns 8–14), as
  /// (column, row).
  static const List<(int, int)> _data = [
    (9, 8), (11, 8), (12, 8), (14, 8), //
    (8, 9), (11, 9), (13, 9),
    (9, 10), (10, 10), (12, 10), (14, 10),
    (8, 11), (9, 11), (11, 11), (14, 11),
    (10, 12), (12, 12), (13, 12),
    (8, 13), (10, 13), (11, 13), (13, 13),
    (9, 14), (12, 14), (14, 14),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..drawRect(Offset.zero & size, Paint()..color = AppColors.blue800)
      ..save()
      ..scale(size.width / _viewport, size.height / _viewport)
      ..translate(-_inset, -_inset)
      ..translate(54, 54)
      ..scale(_insetScale)
      ..translate(-54, -54);

    final white = Paint()..color = Colors.white;

    Rect modules(int col, int row, [int span = 1]) => Rect.fromLTWH(
          _origin + col * _module,
          _origin + row * _module,
          span * _module,
          span * _module,
        );

    // The three finder patterns: a ring of 7 modules around a 3-module eye.
    for (final (col, row) in const [(0, 0), (8, 0), (0, 8)]) {
      final ring = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(modules(col, row, 7))
        ..addRect(modules(col + 1, row + 1, 5));
      canvas
        ..drawPath(ring, white)
        ..drawRect(modules(col + 2, row + 2, 3), white);
    }

    // The timing patterns: every other module of column 7 and row 7.
    for (var i = 0; i < 15; i += 2) {
      canvas
        ..drawRect(modules(7, i), white)
        ..drawRect(modules(i, 7), white);
    }

    for (final (col, row) in _data) {
      canvas.drawRect(modules(col, row), white);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AppIconPainter oldDelegate) => false;
}
