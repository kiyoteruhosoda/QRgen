import 'package:flutterbase/domain/repositories/scanned_code_image_reader.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobileScannerImageReader implements ScannedCodeImageReader {
  MobileScannerImageReader(this._controller);

  final MobileScannerController _controller;

  @override
  Future<String?> readFromImagePath(String imagePath) async {
    final capture = await _controller.analyzeImage(imagePath);
    return capture?.barcodes.firstOrNull?.rawValue;
  }
}
