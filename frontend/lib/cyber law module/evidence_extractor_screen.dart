import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../screen_with_nav.dart';
import 'extracted_evidence_results_screen.dart';

class EvidenceExtractorScreen extends StatefulWidget {
  const EvidenceExtractorScreen({super.key});

  @override
  State<EvidenceExtractorScreen> createState() =>
      _EvidenceExtractorScreenState();
}

class _EvidenceExtractorScreenState extends State<EvidenceExtractorScreen> {
  final List<EvidenceFile> _uploadedFiles = [];
  final int _maxFileSizeInMB = 10;

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
          'Evidence Extractor',
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00401A),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.crop_free,
                        color: Color(0xFF00401A),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Upload Threat Evidence',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI will extract timestamps, numbers, URLs, and classify threats',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Upload Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Upload screenshots, messages, or text logs',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Upload Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildUploadButton(
                            icon: Icons.image,
                            label: 'Screenshots',
                            onPressed: _uploadScreenshots,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildUploadButton(
                            icon: Icons.description,
                            label: 'Text Logs',
                            onPressed: _uploadTextLogs,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Uploaded Evidence List
              if (_uploadedFiles.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    'Uploaded Evidence (${_uploadedFiles.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _uploadedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _uploadedFiles[index];
                    return _buildEvidenceFileWidget(file, index);
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Extract Button
              if (_uploadedFiles.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _extractEvidence,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00401A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome),
                        SizedBox(width: 8),
                        Text(
                          'Extract Data with AI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // What AI Extracts
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1976D2), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What AI Extracts:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoBullet('Timestamps and dates'),
                    _buildInfoBullet('Phone numbers and email addresses'),
                    _buildInfoBullet('URLs and social media links'),
                    _buildInfoBullet(
                      'Threat classification (harassment, blackmail, violence)',
                    ),
                    _buildInfoBullet('Key phrases and evidence markers'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Supported Formats
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF57F17), width: 1),
                ),
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Supported formats: JPG, PNG, PDF, TXT (max 10MB each)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Colors.grey),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00401A), size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF00401A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceFileWidget(EvidenceFile file, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              file.fileType == 'image' ? Icons.image : Icons.description,
              color: const Color(0xFF00401A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  file.fileType.toUpperCase(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            onPressed: () {
              setState(() {
                _uploadedFiles.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0, top: 4),
            child: SizedBox(
              width: 6,
              height: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF1976D2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadScreenshots() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        allowCompression: true,
      );

      if (result == null) {
        _showErrorSnackBar('No images selected');
        return;
      }

      _processPickedFiles(result, 'image');
    } catch (e) {
      _showErrorSnackBar('Error uploading screenshots: ${e.toString()}');
      debugPrint('Screenshot upload error: $e');
    }
  }

  Future<void> _uploadTextLogs() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
        allowMultiple: true,
      );

      if (result == null) {
        _showErrorSnackBar('No files selected');
        return;
      }

      _processPickedFiles(result, 'text');
    } catch (e) {
      _showErrorSnackBar('Error uploading text logs: ${e.toString()}');
      debugPrint('Text log upload error: $e');
    }
  }

  void _processPickedFiles(FilePickerResult result, String fileType) {
    if (result.files.isEmpty) {
      _showErrorSnackBar('No files selected. Please try again.');
      return;
    }

    List<EvidenceFile> validFiles = [];

    for (var file in result.files) {
      // Check if file has valid data
      if (file.name.isEmpty) {
        _showErrorSnackBar('Invalid file detected. Please try again.');
        continue;
      }

      // Check file size (max 10MB)
      final fileSize = file.size;
      if (fileSize > (_maxFileSizeInMB * 1024 * 1024)) {
        _showErrorSnackBar('File ${file.name} exceeds 10MB limit');
        continue;
      }

      // Get file path (may be null on web platform)
      final filePath = file.path ?? file.name;

      validFiles.add(
        EvidenceFile(
          fileName: file.name,
          filePath: filePath,
          fileType: fileType,
          fileSize: fileSize,
        ),
      );
    }

    if (validFiles.isEmpty) {
      _showErrorSnackBar(
        'No valid files to add. Please check file size and format.',
      );
      return;
    }

    if (validFiles.length + _uploadedFiles.length > 10) {
      _showErrorSnackBar(
        'Maximum 10 files allowed. You can add ${10 - _uploadedFiles.length} more file(s).',
      );
      return;
    }

    setState(() {
      _uploadedFiles.addAll(validFiles);
    });

    _showSuccessSnackBar('${validFiles.length} file(s) added successfully');
  }

  void _extractEvidence() {
    if (_uploadedFiles.isEmpty) {
      _showErrorSnackBar('Please upload at least one file');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ExtractingEvidenceLoadingScreen(uploadedFiles: _uploadedFiles),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF00401A),
      ),
    );
  }
}

class EvidenceFile {
  final String fileName;
  final String filePath;
  final String fileType; // 'image' or 'text'
  final int fileSize;

  EvidenceFile({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
  });
}

class ExtractingEvidenceLoadingScreen extends StatefulWidget {
  final List<EvidenceFile> uploadedFiles;

  const ExtractingEvidenceLoadingScreen({
    super.key,
    required this.uploadedFiles,
  });

  @override
  State<ExtractingEvidenceLoadingScreen> createState() =>
      _ExtractingEvidenceLoadingScreenState();
}

class _ExtractingEvidenceLoadingScreenState
    extends State<ExtractingEvidenceLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _simulateExtraction();
  }

  void _simulateExtraction() async {
    // Simulate AI extraction process
    await Future.delayed(const Duration(seconds: 4));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ExtractedEvidenceResultsScreen(
            uploadedFiles: widget.uploadedFiles,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00401A),
                  ),
                  backgroundColor: Colors.grey.shade300,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Extracting data from evidence...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
