import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'evidence_analysis_result_screen.dart';

class AIEvidenceReviewScreen extends StatefulWidget {
  const AIEvidenceReviewScreen({super.key});

  @override
  State<AIEvidenceReviewScreen> createState() => _AIEvidenceReviewScreenState();
}

class _AIEvidenceReviewScreenState extends State<AIEvidenceReviewScreen> {
  List<PlatformFile> uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Evidence Review',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Upload icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.upload_outlined,
                  size: 40,
                  color: Color(0xFF00401A),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Upload Your Evidence',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Text(
                'AI will analyze strength and provide suggestions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Upload area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    // Upload icon in center
                    Icon(
                      Icons.upload_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 16),

                    // Drag and drop text
                    Text(
                      'Drag and drop files or click to upload',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // File type buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildFileTypeButton(
                            icon: Icons.image_outlined,
                            label: 'Images',
                            onTap: () => _pickFiles(['jpg', 'jpeg', 'png']),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFileTypeButton(
                            icon: Icons.picture_as_pdf_outlined,
                            label: 'PDFs',
                            onTap: () => _pickFiles(['pdf']),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildFileTypeButton(
                            icon: Icons.audiotrack_outlined,
                            label: 'Audio',
                            onTap: () => _pickFiles(['mp3', 'wav', 'm4a']),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildFileTypeButton(
                            icon: Icons.videocam_outlined,
                            label: 'Video',
                            onTap: () => _pickFiles(['mp4', 'mov', 'avi']),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Supported formats info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Supported formats: JPG, PNG, PDF, MP3, MP4 (max 10MB each)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),

              const SizedBox(height: 24),

              // Display uploaded files if any
              if (uploadedFiles.isNotEmpty) ...[
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Uploaded Files (${uploadedFiles.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...uploadedFiles.map((file) => _buildFileItem(file)),
                const SizedBox(height: 24),

                // Analyze button
                ElevatedButton(
                  onPressed: () {
                    _analyzeEvidence();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.analytics_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Analyze Evidence Strength',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileItem(PlatformFile file) {
    String fileName = file.name;
    String fileSize = _getFileSize(file);
    String fileType = _getFileType(fileName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EFEA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFileIcon(fileName),
              size: 24,
              color: const Color(0xFF00401A),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileType \u2022 $fileSize',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 22),
            color: Colors.grey.shade500,
            onPressed: () {
              setState(() {
                uploadedFiles.remove(file);
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image_outlined;
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'mp3':
      case 'wav':
      case 'm4a':
        return Icons.audiotrack_outlined;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _getFileType(String fileName) {
    String extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'IMAGE';
      case 'pdf':
        return 'PDF';
      case 'mp3':
      case 'wav':
      case 'm4a':
        return 'AUDIO';
      case 'mp4':
      case 'mov':
      case 'avi':
        return 'VIDEO';
      default:
        return 'FILE';
    }
  }

  String _getFileSize(PlatformFile file) {
    int bytes = file.size;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pickFiles(List<String> extensions) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
        allowMultiple: true,
        withData: kIsWeb,
        withReadStream: false,
      );

      if (result != null && mounted) {
        for (var file in result.files) {
          // Check file size (max 10MB)
          if (file.size <= 10 * 1024 * 1024) {
            setState(() {
              uploadedFiles.add(file);
            });
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${file.name} exceeds 10MB limit'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _analyzeEvidence() {
    // Show loading dialog with text
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00401A)),
                  strokeWidth: 5,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Analyzing your evidence...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Simulate AI analysis
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pop(context); // Close loading dialog

      // Navigate to analysis result screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              EvidenceAnalysisResultScreen(evidenceCount: uploadedFiles.length),
        ),
      );
    });
  }
}
