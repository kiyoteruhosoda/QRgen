import 'package:flutterbase/domain/repositories/scanned_code_image_reader.dart';

class ReadScannedCodeFromImageUseCase {
  const ReadScannedCodeFromImageUseCase(this._reader);

  final ScannedCodeImageReader _reader;

  Future<String?> execute(String imagePath) => _reader.readFromImagePath(imagePath);
}
