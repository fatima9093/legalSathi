import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';
import 'challan_processing_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';

class TrafficChallanOCRScreen extends StatefulWidget {
  const TrafficChallanOCRScreen({super.key});

  @override
  State<TrafficChallanOCRScreen> createState() =>
      _TrafficChallanOCRScreenState();
}

class _TrafficChallanOCRScreenState extends State<TrafficChallanOCRScreen> {
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

      _navigateToProcessing(
        bytes,
        _nameFromPath(photo.path, 'challan_camera.jpg'),
        'image',
      );
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

  Future<void> _importFromGallery() async {
    final loc = AppLocalizations.of(context)!;

    if (!kIsWeb) {
      await _ensurePhotosPermission();
    }

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
          : _nameFromPath(f.path, 'challan_import');

      final isPdf = name.toLowerCase().endsWith('.pdf');

      _navigateToProcessing(bytes, name, isPdf ? 'pdf' : 'image');
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

  Future<void> _navigateToProcessing(
    Uint8List bytes,
    String fileName,
    String fileType,
  ) async {
    // Pre-extract OCR for challan
    String? extractedText;
    try {
      extractedText = await ChallanTextExtractionService.extractRawText(
        bytes: bytes,
        fileName: fileName,
        fileType: fileType,
      );
      if (extractedText.isEmpty) extractedText = null;
    } catch (e) {
      debugPrint('OCR extraction failed: $e');
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallanProcessingScreen(
          bytes: bytes,
          fileName: fileName,
          fileType: fileType,
        ),
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
          loc.ocrTitle,
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
              const SizedBox(height: 32),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 40,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                loc.uploadChallan,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loc.extractExplainText,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              _buildOptionCard(
                icon: Icons.camera_alt,
                title: loc.takePhoto,
                subtitle: loc.takePhotoSub,
                onTap: _takePhoto,
              ),

              const SizedBox(height: 16),

              _buildOptionCard(
                icon: Icons.photo_library_outlined,
                title: loc.importGallery,
                subtitle: loc.importSub,
                onTap: _importFromGallery,
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.backendTip,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EFEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF00401A), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.35,
                    ),
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
