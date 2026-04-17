import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';

import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// QR code generator tab content.
class QrGeneratorPage extends StatefulWidget {
  const QrGeneratorPage({super.key});

  @override
  State<QrGeneratorPage> createState() => _QrGeneratorPageState();
}

class _QrGeneratorPageState extends State<QrGeneratorPage> {
  static const List<int> _ecLevels = [
    QrErrorCorrectLevel.L,
    QrErrorCorrectLevel.M,
    QrErrorCorrectLevel.Q,
    QrErrorCorrectLevel.H,
  ];
  static const List<String> _ecLabels = ['L', 'M', 'Q', 'H'];
  static const int _defaultEcIndex = 1; // M

  final TextEditingController _textController = TextEditingController();
  final GlobalKey _qrKey = GlobalKey();
  String? _qrData;
  int _ecIndex = _defaultEcIndex;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateQr(String text) {
    final trimmed = text.trim();
    setState(() => _qrData = trimmed.isEmpty ? null : trimmed);
  }

  Future<void> _copyText() async {
    if (_qrData == null) return;
    await Clipboard.setData(ClipboardData(text: _qrData!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.qrGeneratorCopied)),
    );
  }

  Future<void> _saveImage() async {
    if (_qrData == null) return;
    try {
      final boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      await _writePng(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.qrGeneratorSaved)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.qrGeneratorSaveError)),
      );
    }
  }

  Future<void> _writePng(Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/qrcode_$timestamp.png');
    await file.writeAsBytes(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Input ──────────────────────────────────────────────────
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              labelText: AppStrings.qrGeneratorInputLabel,
              hintText: AppStrings.qrGeneratorInputHint,
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _textController.clear();
                  _updateQr('');
                },
              ),
            ),
            maxLines: 3,
            onChanged: _updateQr,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Error correction level ─────────────────────────────────
          Row(
            children: [
              Text(
                AppStrings.qrGeneratorErrorCorrection,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                _ecLabels[_ecIndex],
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
          Slider(
            value: _ecIndex.toDouble(),
            min: 0,
            max: (_ecLevels.length - 1).toDouble(),
            divisions: _ecLevels.length - 1,
            label: _ecLabels[_ecIndex],
            onChanged: (v) => setState(() => _ecIndex = v.round()),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── QR Code display ────────────────────────────────────────
          if (_qrData != null) ...[
            Center(
              child: RepaintBoundary(
                key: _qrKey,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: QrImageView(
                    data: _qrData!,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    errorCorrectionLevel: _ecLevels[_ecIndex],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _qrData!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _copyText,
                    icon: const Icon(Icons.copy_outlined),
                    label: const Text(AppStrings.qrGeneratorCopy),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text(AppStrings.qrGeneratorDownload),
                  ),
                ),
              ],
            ),
          ] else ...[
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_2_outlined,
                      size: 80,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppStrings.qrGeneratorNoCode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
