import 'dart:typed_data';

import 'package:flutterbase/shared/errors/app_error.dart';

/// The device's photo gallery, where saved pictures show up for the user.
///
/// Throws [AccessDeniedError] when the user refused access, and
/// [InfrastructureError] for any other failure.
abstract interface class PictureGallery {
  Future<void> savePng(Uint8List bytes, {required String name});
}
