import 'dart:typed_data';
import 'dart:html' as html;

/// Download file on web platform
void downloadFileOnWeb(Uint8List bytes, String filename) {
  try {
    // Create a blob from the bytes
    final blob = html.Blob([bytes]);
    
    // Create a download URL
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // Create an anchor element and trigger download
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = filename;
    
    // Add to body, click, and remove
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    
    // Revoke the URL
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading file: $e');
    rethrow;
  }
}

