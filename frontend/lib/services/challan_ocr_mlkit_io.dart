import 'dart:io';
import 'dart:typed_data';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// On-device OCR for images (Android / iOS; may fail on desktop).
Future<String> recognizeTextFromImageBytes(Uint8List bytes, String ext) async {
  final safeExt = ext.replaceAll(RegExp(r'[^a-z0-9]'), '');
  final extUse = safeExt.isEmpty ? 'jpg' : safeExt;
  final dir = await getTemporaryDirectory();
  final file = File(
    p.join(dir.path, 'challan_${DateTime.now().millisecondsSinceEpoch}.$extUse'),
  );
  await file.writeAsBytes(bytes);
  final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
  try {
    final input = InputImage.fromFilePath(file.path);
    final recognized = await recognizer.processImage(input);
    return recognized.text;
  } finally {
    await recognizer.close();
    try {
      await file.delete();
    } catch (_) {}
  }
}
