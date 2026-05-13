import 'package:web/web.dart' as web;
import 'package:flutter/foundation.dart';
import 'dart:js_interop';

/// Download file on web platform
void downloadFileOnWeb(Uint8List bytes, String filename) {
  try {
    // Convert Uint8List to a JSUint8Array for the Blob
    final jsBytes = bytes.toJS;

    // Create a blob from the bytes
    final blobParts = [jsBytes].toJS;
    final blob = web.Blob(blobParts);

    // Create a download URL
    final url = web.URL.createObjectURL(blob);

    // Create an anchor element and trigger download
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = filename;

    // Add to body, click, and remove
    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);

    // Revoke the URL
    web.URL.revokeObjectURL(url);
  } catch (e) {
    debugPrint('Error downloading file on web: $e');
    rethrow;
  }
}
