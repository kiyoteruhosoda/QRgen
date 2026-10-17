import 'dart:typed_data';

import 'package:flutterbase/domain/repositories/picture_gallery.dart';
import 'package:flutterbase/shared/errors/app_error.dart';
import 'package:gal/gal.dart';

/// [PictureGallery] backed by the `gal` plugin (MediaStore on Android), so a
/// saved picture lands in Photos under the [album] instead of the app's
/// private folder.
final class GalPictureGallery implements PictureGallery {
  const GalPictureGallery({this.album = 'QRgen'});

  final String album;

  @override
  Future<void> savePng(Uint8List bytes, {required String name}) async {
    try {
      if (!await Gal.hasAccess(toAlbum: true) &&
          !await Gal.requestAccess(toAlbum: true)) {
        throw const AccessDeniedError('Gallery access was refused');
      }
      await Gal.putImageBytes(bytes, album: album, name: name);
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        throw const AccessDeniedError('Gallery access was refused');
      }
      throw InfrastructureError('Failed to save picture: ${e.type}', cause: e);
    }
  }
}
