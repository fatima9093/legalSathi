import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../screen_with_nav.dart';
import 'analyzing_document_screen.dart';

class ScreenshotEvidenceReaderScreen extends StatefulWidget {
  const ScreenshotEvidenceReaderScreen({super.key});

  @override
  State<ScreenshotEvidenceReaderScreen> createState() =>
      _ScreenshotEvidenceReaderScreenState();
}

class _ScreenshotEvidenceReaderScreenState
    extends State<ScreenshotEvidenceReaderScreen> {
  static const int _maxBytes = 10 * 1024 * 1024;

  Future<void> _uploadScreenshot() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        try {
          bytes = await XFile(file.path!).readAsBytes();
        } catch (_) {}
      }

      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read the image. On web, try another browser or smaller file.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (bytes.length > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image must be under 10 MB.')),
          );
        }
        return;
      }

      final name = file.name.isNotEmpty ? file.name : 'screenshot.jpg';

      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => AnalyzingDocumentScreen(
            imageBytes: bytes,
            fileName: name,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openDemo() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AnalyzingDocumentScreen(isDemo: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Screenshot Evidence Reader',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF00401A).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.image_search,
                  size: 80,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Upload Screenshot',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                kIsWeb
                    ? 'We read text from your image, classify the legal area, suggest relevant laws, then you can generate a draft document. Keep the backend running on port 8000 for best results.'
                    : 'Text is read on-device when possible, then analyzed via the Legal Sathi backend.',
                style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _uploadScreenshot,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF00401A),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00401A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tap to upload',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'PNG, JPG, WebP — up to 10 MB',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _openDemo,
                  child: const Text(
                    'Try demo (sample analysis)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What we do:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(Icons.text_fields, 'Extract text (OCR)'),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.category, 'Identify legal domain'),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.menu_book, 'Suggest relevant laws (indicative)'),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.description, 'Generate a draft document in the next step'),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF00401A)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
