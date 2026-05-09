import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutterbase/app/di/service_locator.dart';
import 'package:flutterbase/application/usecases/scanner/read_scanned_code_from_image_usecase.dart';
import 'package:flutterbase/infrastructure/scanner/mobile_scanner_image_reader.dart';
import 'package:flutterbase/presentation/viewmodels/scanned_code_history_viewmodel.dart';
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
  final ScannedCodeHistoryViewModel _historyViewModel =
      sl<ScannedCodeHistoryViewModel>();
  late final ReadScannedCodeFromImageUseCase _readFromImageUseCase;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _historyViewModel.load();
    _readFromImageUseCase =
        ReadScannedCodeFromImageUseCase(MobileScannerImageReader(_controller));
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
    _historyViewModel.add(value);
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
    final uri = Uri.tryParse(_scannedValue!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.qrScannerCannotOpen)),
    );
  }


  Future<void> _scanFromImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final value = await _readFromImageUseCase.execute(image.path);
    if (value == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.qrScannerImageNotFound)),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _scannedValue = value);
    await _historyViewModel.add(value);
  }

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
                      icon: Icons.image_search_outlined,
                      tooltip: AppStrings.qrScannerReadFromImage,
                      onPressed: _scanFromImage,
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

	        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            0,
            AppSpacing.pageMargin,
            AppSpacing.pageMargin,
          ),
          child: ListenableBuilder(
            listenable: _historyViewModel,
            builder: (context, _) {
              final history = _historyViewModel.items;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.qrScannerHistory,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    height: 120,
                    child: history.isEmpty
                        ? Center(
                            child: Text(
                              AppStrings.qrScannerNoHistory,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  item.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  item.scannedAt.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first,
                                ),
                                onTap: () => setState(() => _scannedValue = item.value),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
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
