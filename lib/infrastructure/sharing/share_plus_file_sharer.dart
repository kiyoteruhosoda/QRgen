import 'package:share_plus/share_plus.dart';
import 'package:flutterbase/domain/repositories/file_sharer.dart';

/// [FileSharer] backed by `share_plus` (the Android share sheet).
final class SharePlusFileSharer implements FileSharer {
  const SharePlusFileSharer();

  @override
  Future<void> shareFile(String path, {required String mimeType}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: mimeType)]),
    );
  }
}
