import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/cyber_law_module/analyzing_document_screen.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';

class UploadEvidenceSelectionScreen extends StatefulWidget {
  const UploadEvidenceSelectionScreen({super.key});

  @override
  State<UploadEvidenceSelectionScreen> createState() =>
      _UploadEvidenceSelectionScreenState();
}

class _UploadEvidenceSelectionScreenState
    extends State<UploadEvidenceSelectionScreen> {
  final ImagePicker _picker = ImagePicker();
  static const int _maxBytes = 10 * 1024 * 1024;

  Future<void> _ensurePhotosPermission() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final p = await Permission.photos.request();
      if (!p.isGranted) {
        await Permission.photosAddOnly.request();
      }
    } else {
      await Permission.photos.request();
    }
  }

  Future<void> _takePhoto() async {
    final loc = AppLocalizations.of(context)!;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.cameraAccessTitle),
        content: Text(loc.cameraAccessDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00401A),
            ),
            child: Text(loc.continueBtn),
          ),
        ],
      ),
    );

    if (proceed != true || !mounted) return;

    if (!kIsWeb) {
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.cameraPermissionDenied),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2400,
      );

      if (photo == null || !mounted) return;

      final bytes = await photo.readAsBytes();
      if (!_checkSize(bytes, loc)) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.photoCaptured),
            backgroundColor: const Color(0xFF00401A),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      if (mounted) {
        _navigateToAnalysis(bytes, _nameFromPath(photo.path, 'evidence.jpg'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorTakingPhoto} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _chooseFromGallery() async {
    final loc = AppLocalizations.of(context)!;

    if (!kIsWeb) {
      await _ensurePhotosPermission();
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final f = result.files.first;
      Uint8List? bytes = f.bytes;

      if (bytes == null && f.path != null) {
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }

      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileReadError),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (f.size > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileTooLarge),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final name = f.name.isNotEmpty
          ? f.name
          : _nameFromPath(f.path, 'evidence');

      if (mounted) {
        _navigateToAnalysis(bytes, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorPickingFile} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPdf() async {
    final loc = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final f = result.files.first;
      Uint8List? bytes = f.bytes;

      if (bytes == null && f.path != null) {
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }

      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileReadError),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (f.size > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileTooLarge),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final name = f.name.isNotEmpty
          ? f.name
          : _nameFromPath(f.path, 'evidence.pdf');

      if (mounted) {
        _navigateToAnalysis(bytes, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorPickingFile} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _browseFiles() async {
    final loc = AppLocalizations.of(context)!;

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final f = result.files.first;
      Uint8List? bytes = f.bytes;

      if (bytes == null && f.path != null) {
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }

      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileReadError),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (f.size > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.fileTooLarge),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final name = f.name.isNotEmpty
          ? f.name
          : _nameFromPath(f.path, 'evidence');

      if (mounted) {
        _navigateToAnalysis(bytes, name);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.errorPickingFile} $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _nameFromPath(String? path, String fallback) {
    if (path == null || path.isEmpty) return fallback;
    final i = path.replaceAll('\\', '/').lastIndexOf('/');
    if (i < 0 || i >= path.length - 1) return fallback;
    return path.substring(i + 1);
  }

  bool _checkSize(Uint8List bytes, AppLocalizations loc) {
    if (bytes.length > _maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.photoTooLarge), backgroundColor: Colors.red),
      );
      return false;
    }
    return true;
  }

  Future<void> _navigateToAnalysis(Uint8List bytes, String fileName) async {
    if (!mounted) return;

    // Pre-extract OCR text in background
    String? ocrText;
    final lower = fileName.toLowerCase();
    final isImage =
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg');
    final isPdf = lower.endsWith('.pdf');

    if ((isImage || isPdf)) {
      try {
        ocrText = await ChallanTextExtractionService.extractRawText(
          bytes: bytes,
          fileName: fileName,
          fileType: isPdf ? 'pdf' : 'image',
        );
        if (ocrText.isEmpty) ocrText = null;
      } catch (e) {
        debugPrint('OCR failed in _navigateToAnalysis: $e');
      }
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AnalyzingDocumentScreen(imageBytes: bytes, fileName: fileName),
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
          loc.uploadEvidence,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Text(
                'Select Upload Method',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how you want to upload your evidence document',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // Take Photo
              _buildUploadOptionCard(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Capture document using camera',
                onTap: _takePhoto,
              ),
              const SizedBox(height: 16),

              // Choose from Gallery
              _buildUploadOptionCard(
                icon: Icons.photo_library,
                title: 'Choose from Gallery',
                subtitle: 'Select existing image',
                onTap: _chooseFromGallery,
              ),
              const SizedBox(height: 16),

              // Upload PDF
              _buildUploadOptionCard(
                icon: Icons.picture_as_pdf,
                title: 'Upload PDF',
                subtitle: 'Select PDF document',
                onTap: _uploadPdf,
              ),
              const SizedBox(height: 16),

              // Browse Files
              _buildUploadOptionCard(
                icon: Icons.folder_open,
                title: 'Browse Files',
                subtitle: 'Select from device storage',
                onTap: _browseFiles,
              ),
              const SizedBox(height: 24),

              // Supported formats notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Supported formats: JPG, PNG, PDF (max 10MB)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00401A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EFEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF00401A)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
