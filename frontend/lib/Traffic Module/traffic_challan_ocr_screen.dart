import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'challan_processing_screen.dart';

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
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera access'),
        content: Text(
          kIsWeb
              ? 'Your browser will ask to use the camera. After you take a photo, we extract text from the image.'
              : 'Legal Sathi needs the camera to photograph your challan. '
                  'Tap Continue, then tap Allow when your phone asks for camera permission. '
                  'After you take the picture, we read the text from it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF00401A),
            ),
            child: const Text('Continue'),
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
              content: Text(
                cam.isPermanentlyDenied
                    ? 'Camera is blocked. Enable it in app settings, then try again.'
                    : 'Camera permission is required to take a photo.',
              ),
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
      if (!_checkSize(bytes)) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo captured. Extracting text from your challan…'),
            backgroundColor: Color(0xFF00401A),
            duration: Duration(seconds: 2),
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
            content: Text('Error taking photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importFromGallery() async {
    if (!kIsWeb) {
      await _ensurePhotosPermission();
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty || !mounted) return;

      final f = result.files.first;
      Uint8List? bytes = f.bytes;
      if (bytes == null && f.path != null) {
        // Some platforms return path only
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not read the selected file.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (f.size > _maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File exceeds 10 MB limit.'),
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
            content: Text('Error picking file: $e'),
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

  bool _checkSize(Uint8List bytes) {
    if (bytes.length > _maxBytes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo exceeds 10 MB limit.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  void _navigateToProcessing(
    Uint8List bytes,
    String fileName,
    String fileType,
  ) {
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
          'Traffic Challan OCR Reader',
          style: TextStyle(
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
              const Text(
                'Upload Your Challan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  children: const [
                    TextSpan(text: 'We '),
                    TextSpan(
                      text: 'extract text',
                      style: TextStyle(
                        color: Color(0xFF00401A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'explain the violation',
                      style: TextStyle(
                        color: Color(0xFF00401A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildOptionCard(
                icon: Icons.camera_alt,
                title: 'Take Photo',
                subtitle: 'Open camera and capture your challan',
                onTap: _takePhoto,
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.photo_library_outlined,
                title: 'Import from gallery',
                subtitle: 'JPG, PNG, or PDF (max 10 MB)',
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
                  'Tip: For PDFs and web, keep the Legal Sathi backend running '
                  '(localhost:8000) so text can be extracted.',
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00401A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
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
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
