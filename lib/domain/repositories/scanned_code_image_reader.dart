abstract interface class ScannedCodeImageReader {
  Future<String?> readFromImagePath(String imagePath);
}
