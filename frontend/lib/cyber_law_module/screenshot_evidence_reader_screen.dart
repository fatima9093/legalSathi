import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:front_end/l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;

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
            SnackBar(
              content: Text(loc.errorReadingImage),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      if (bytes.length > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(loc.imageSizeError)));
        }
        return;
      }

      final name = file.name.isNotEmpty ? file.name : loc.defaultFileName;

      if (!mounted) return;
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) =>
              AnalyzingDocumentScreen(imageBytes: bytes, fileName: name),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${loc.errorLabel}: $e"),
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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.screenshotReaderTitle,
          style: const TextStyle(
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
                  color: const Color(0xFF00401A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.image_search,
                  size: 80,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                loc.uploadScreenshot,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                kIsWeb ? loc.webDescription : loc.mobileDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
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
                            color: const Color(
                              0xFF00401A,
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: Color(0xFF00401A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(loc.tapToUpload),
                        const SizedBox(height: 8),
                        Text(loc.fileFormatInfo),
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
                  child: Text(loc.tryDemo),
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
                    Text(loc.whatWeDo),
                    const SizedBox(height: 12),
                    _buildInfoItem(Icons.text_fields, loc.ocrText),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.category, loc.identifyDomain),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.menu_book, loc.suggestLaws),
                    const SizedBox(height: 8),
                    _buildInfoItem(Icons.description, loc.generateDraft),
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
