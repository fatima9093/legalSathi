import 'dart:typed_data';

/// Stub for non-web platforms
void downloadFileOnWeb(Uint8List bytes, String filename) {
  throw UnsupportedError('Web download is only supported on web platform');
}

