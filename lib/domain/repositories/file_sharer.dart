/// Hands a file to the platform's share sheet, so the user picks where it
/// goes (Files, Drive, mail, …).
abstract interface class FileSharer {
  Future<void> shareFile(String path, {required String mimeType});
}
