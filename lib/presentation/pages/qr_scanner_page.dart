import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutterbase/shared/l10n/app_strings.dart';
import 'package:flutterbase/shared/theme/theme.dart';

/// QR code scanner tab content.
class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController();
  String? _scannedValue;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null) return;
    final value = barcode.rawValue;
    if (value == null || value == _scannedValue) return;
    setState(() => _scannedValue = value);
  }

  Future<void> _copyToClipboard() async {
    if (_scannedValue == null) return;
    await Clipboard.setData(ClipboardData(text: _scannedValue!));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.qrScannerCopied)),
    );
  }

  Future<void> _openContent() async {
    if (_scannedValue == null) return;
    final raw = _scannedValue!.trim();
    var uri = Uri.tryParse(raw);
    // Scanned text like "example.com" has no scheme — assume https.
    if (uri != null && !uri.hasScheme && _looksLikeUrl(raw)) {
      uri = Uri.tryParse('https://$raw');
    }
    if (uri != null && uri.hasScheme && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.qrScannerCannotOpen)),
    );
  }

  static final RegExp _urlLikeRegExp =
      RegExp(r'^[\w-]+(\.[\w-]+)+(/\S*)?$');

  static bool _looksLikeUrl(String s) => _urlLikeRegExp.hasMatch(s);

  Future<void> _toggleTorch() async {
    await _controller.toggleTorch();
    setState(() => _torchOn = !_torchOn);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // ── Scanner viewport ──────────────────────────────────────────
        Expanded(
          flex: 5,
          child: Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                errorBuilder: (context, error) {
                  return _PermissionError(
                    error: error,
                    onRetry: () => _controller.start(),
                  );
                },
              ),
              // Overlay: scan region indicator
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
              ),
              // Torch & camera-switch controls
              Positioned(
                bottom: AppSpacing.md,
                right: AppSpacing.md,
                child: Column(
                  children: [
                    _IconCircleButton(
                      icon: _torchOn
                          ? Icons.flash_on
                          : Icons.flash_off,
                      tooltip: _torchOn
                          ? AppStrings.qrScannerTorchOff
                          : AppStrings.qrScannerTorchOn,
                      onPressed: _toggleTorch,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _IconCircleButton(
                      icon: Icons.cameraswitch_outlined,
                      tooltip: AppStrings.qrScannerSwitchCamera,
                      onPressed: () => _controller.switchCamera(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Result panel ──────────────────────────────────────────────
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pageMargin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.qrScannerResult,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.componentPadding),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _scannedValue ?? AppStrings.qrScannerNoResult,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _scannedValue != null
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            _scannedValue != null ? _copyToClipboard : null,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text(AppStrings.qrScannerCopy),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _scannedValue != null ? _openContent : null,
                        icon: const Icon(Icons.open_in_new),
                        label: const Text(AppStrings.qrScannerOpen),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper widgets ───────────────────────────────────────────────────────────

class _IconCircleButton extends StatelessWidget {
  const _IconCircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
          ),
        ),
      ),
    );
  }
}

class _PermissionError extends StatelessWidget {
  const _PermissionError({required this.error, required this.onRetry});

  final MobileScannerException error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 64,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                AppStrings.qrScannerPermissionDenied,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text(AppStrings.qrScannerPermissionRequest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
