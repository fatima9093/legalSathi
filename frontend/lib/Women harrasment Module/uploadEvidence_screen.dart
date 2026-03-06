import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/Women%20harrasment%20Module/complain_preview_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:front_end/models/complaint_model.dart';
import 'package:front_end/services/complaint_service.dart';
import '../utils/validators.dart';

class UploadEvidenceScreen extends StatefulWidget {
  final String complaintId;

  const UploadEvidenceScreen({super.key, required this.complaintId});

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  final _witnessController = TextEditingController();
  final ComplaintService _complaintService = ComplaintService();
  List<EvidenceFile> _uploadedFiles = [];

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  @override
  void dispose() {
    _witnessController.dispose();
    super.dispose();
  }

  Future<void> _loadComplaint() async {
    final result = await _complaintService.getComplaint(widget.complaintId);
    if (result['success'] && result['complaint'] != null) {
      final complaint = result['complaint'] as ComplaintModel;
      setState(() {
        _uploadedFiles = complaint.evidenceFiles ?? [];
      });
    }
  }

  Future<void> _pickFile(String fileType) async {
    try {
      FilePickerResult? result;

      // Different file types
      if (fileType == 'screenshot') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          withData: true, // Important for web - loads bytes
        );
      } else if (fileType == 'audio') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.audio,
          allowMultiple: true,
          withData: true,
        );
      } else if (fileType == 'video') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: true,
          withData: true,
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowMultiple: true,
          withData: true,
        );
      }

      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          // For web: file.path is null, use file.name
          // For mobile: file.path is available
          // We store the filename as path for web since actual bytes are in memory
          final filePath = file.name; // Just store filename for reference

          final evidenceFile = EvidenceFile(
            fileName: file.name,
            fileType: fileType,
            localPath: filePath, // Store filename
            fileSize: file.size,
            uploadedAt: DateTime.now(),
          );

          // Add to database (no need to access file.path)
          final addResult = await _complaintService.addEvidenceMetadata(
            complaintId: widget.complaintId,
            fileName: file.name,
            fileType: fileType,
            localPath: filePath,
            fileSize: file.size,
          );

          if (addResult['success']) {
            setState(() {
              _uploadedFiles.add(evidenceFile);
            });
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} file(s) added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _removeFile(EvidenceFile file) async {
    final result = await _complaintService.removeEvidenceFile(
      complaintId: widget.complaintId,
      fileName: file.fileName,
    );

    if (result['success']) {
      setState(() {
        _uploadedFiles.remove(file);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File removed'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _continueToPreview() {
    // Optional: Validate witness information if provided
    if (Validators.isNonEmpty(_witnessController.text) &&
        !Validators.isNonEmpty(_witnessController.text)) {
      Validators.showError(
        context,
        'Please provide valid witness information.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ComplaintPreviewScreen(complaintId: widget.complaintId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 56,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Ombudsperson Complaint',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      _buildStep(number: '1', label: 'Info', isCompleted: true),
                      _buildStepLine(),
                      _buildStep(
                        number: '2',
                        label: 'Incident',
                        isCompleted: true,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '3',
                        label: 'Evidence',
                        isActive: true,
                      ),
                      _buildStepLine(),
                      _buildStep(
                        number: '4',
                        label: 'Preview',
                        isActive: false,
                      ),
                      _buildStepLine(),
                      _buildStep(number: '5', label: 'Submit', isActive: false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Upload Evidence',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add supporting documents and witness information',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Evidence upload cards in grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildEvidenceCard(
                            icon: Icons.image_outlined,
                            label: 'Screenshots',
                            onTap: () => _pickFile('screenshot'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEvidenceCard(
                            icon: Icons.chat_outlined,
                            label: 'WhatsApp Chats',
                            onTap: () => _pickFile('whatsapp_chat'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildEvidenceCard(
                            icon: Icons.email_outlined,
                            label: 'Emails',
                            onTap: () => _pickFile('email'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildEvidenceCard(
                            icon: Icons.mic_outlined,
                            label: 'Audio Files',
                            onTap: () => _pickFile('audio'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildEvidenceCard(
                            icon: Icons.videocam_outlined,
                            label: 'Video Files',
                            onTap: () => _pickFile('video'),
                          ),
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Show uploaded files
                    if (_uploadedFiles.isNotEmpty) ...[
                      _buildLabel('Uploaded Files (${_uploadedFiles.length})'),
                      const SizedBox(height: 12),
                      ...List.generate(_uploadedFiles.length, (index) {
                        final file = _uploadedFiles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildFileChip(file),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 24),

                    // Witness Names
                    _buildLabel('Witness Names (Optional)'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _witnessController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'List names of witnesses, one per line...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF00401A),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),

          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _continueToPreview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Continue to Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

  Widget _buildStep({
    required String number,
    required String label,
    bool isActive = false,
    bool isCompleted = false,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF00401A)
                  : isActive
                  ? Colors.white
                  : Colors.grey.shade300,
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted || isActive
                    ? const Color(0xFF00401A)
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      number,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isActive
                            ? const Color(0xFF00401A)
                            : Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isCompleted || isActive
                  ? Colors.black87
                  : Colors.grey.shade600,
              fontWeight: isCompleted || isActive
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 2, right: 2),
        color: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildEvidenceCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE6EFEA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF00401A), size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileChip(EvidenceFile file) {
    IconData icon;
    Color color;

    switch (file.fileType) {
      case 'screenshot':
        icon = Icons.image;
        color = Colors.blue;
        break;
      case 'whatsapp_chat':
        icon = Icons.chat;
        color = Colors.green;
        break;
      case 'email':
        icon = Icons.email;
        color = Colors.orange;
        break;
      case 'audio':
        icon = Icons.mic;
        color = Colors.purple;
        break;
      case 'video':
        icon = Icons.videocam;
        color = Colors.red;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${(file.fileSize ?? 0) ~/ 1024} KB',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            color: Colors.red,
            onPressed: () => _removeFile(file),
          ),
        ],
      ),
    );
  }
}
