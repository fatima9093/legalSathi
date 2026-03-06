import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'submission_instructions_screen.dart';
import 'package:front_end/models/complaint_model.dart';
import 'package:front_end/services/complaint_service.dart';
import 'package:front_end/services/pdf_generator_service.dart';
import 'package:front_end/Women%20harrasment%20Module/ombudspersonComplaintForm_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:printing/printing.dart';
import 'package:front_end/utils/web_download.dart'
    if (dart.library.io) 'package:front_end/utils/web_download_stub.dart';

class ComplaintPreviewScreen extends StatefulWidget {
  final String complaintId;

  const ComplaintPreviewScreen({super.key, required this.complaintId});

  @override
  State<ComplaintPreviewScreen> createState() => _ComplaintPreviewScreenState();
}

class _ComplaintPreviewScreenState extends State<ComplaintPreviewScreen> {
  final ComplaintService _complaintService = ComplaintService();
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  ComplaintModel? _complaint;
  bool _isLoading = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  Future<void> _loadComplaint() async {
    setState(() => _isLoading = true);
    final result = await _complaintService.getComplaint(widget.complaintId);

    if (result['success'] && result['complaint'] != null) {
      setState(() {
        _complaint = result['complaint'] as ComplaintModel;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load complaint'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadPDF() async {
    setState(() => _isDownloading = true);

    try {
      final pdfData = await _pdfService.generateComplaintPDF(_complaint!);
      final filename = 'ombudsperson_complaint_${widget.complaintId}.pdf';

      if (kIsWeb) {
        downloadFileOnWeb(pdfData, filename);
      } else {
        await Printing.sharePdf(bytes: pdfData, filename: filename);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isDownloading = false);
    }
  }

  void _editComplaint() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            OmbudspersonComplaintFormScreen(complaintId: widget.complaintId),
      ),
    );
  }

  Future<void> _regenerate() async {
    setState(() => _isLoading = true);
    await _loadComplaint();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint regenerated!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00401A)),
        ),
      );
    }

    if (_complaint == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load complaint'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
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
                        isCompleted: true,
                      ),
                      _buildStepLine(),
                      _buildStep(number: '4', label: 'Preview', isActive: true),
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

          // Success badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.white,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF00401A), size: 20),
                SizedBox(width: 8),
                Text(
                  'Complaint Generated',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00401A),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    const Text(
                      'Complaint Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Review your complaint before submission',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00401A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ombudsperson Complaint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Generated by Legal Sathi',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Complaint content
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'COMPLAINT TO FEDERAL OMBUDSPERSON FOR PROTECTION AGAINST HARASSMENT OF WOMEN AT WORKPLACE',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'To,',
                            style: TextStyle(fontSize: 13, height: 1.6),
                          ),
                          const Text(
                            'The Federal Ombudsperson',
                            style: TextStyle(fontSize: 13, height: 1.6),
                          ),
                          const Text(
                            'Protection Against Harassment of Women at Workplace',
                            style: TextStyle(fontSize: 13, height: 1.6),
                          ),
                          const Text(
                            'Islamabad, Pakistan',
                            style: TextStyle(fontSize: 13, height: 1.6),
                          ),

                          const SizedBox(height: 20),

                          _buildSection('APPLICANT DETAILS:', [
                            'Name: ${_complaint!.fullName ?? "Not provided"}',
                            'CNIC: ${_complaint!.cnic ?? "Not provided"}',
                            'Phone: ${_complaint!.phone ?? "Not provided"}',
                            'Email: ${_complaint!.email ?? "Not provided"}',
                            'Workplace: ${_complaint!.workplace ?? "Not provided"}',
                            'Designation: ${_complaint!.designation ?? "Not provided"}',
                            'City: ${_complaint!.city ?? "Not provided"}',
                          ]),

                          const SizedBox(height: 16),

                          _buildSection('INCIDENT DETAILS:', [
                            'Date of Incident: ${_complaint!.incidentDate ?? "Not provided"}',
                            'Type of Harassment: ${_complaint!.harassmentType ?? "Not provided"}',
                            'Description: ${_complaint!.description ?? "Not provided"}',
                          ]),

                          const SizedBox(height: 16),

                          _buildSection('ACCUSED PERSON:', [
                            'Name: ${_complaint!.accusedName ?? "Not provided"}',
                            'Designation: ${_complaint!.accusedDesignation ?? "Not provided"}',
                          ]),

                          const SizedBox(height: 16),

                          if (_complaint!.evidenceFiles != null &&
                              _complaint!.evidenceFiles!.isNotEmpty)
                            _buildSection('EVIDENCE FILES:', [
                              ..._complaint!.evidenceFiles!.map(
                                (file) =>
                                    '• ${file.fileName} (${file.fileType})',
                              ),
                            ]),

                          const SizedBox(height: 24),

                          // Action buttons at bottom of document
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _editComplaint,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _regenerate,
                                  icon: const Icon(Icons.refresh, size: 18),
                                  label: const Text('Regenerate'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade400,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isDownloading
                                      ? null
                                      : _downloadPDF,
                                  icon: _isDownloading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.download_outlined,
                                          size: 18,
                                        ),
                                  label: const Text('Download'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00401A),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmissionInstructionsScreen(
                          complaintId: widget.complaintId,
                          complaint: _complaint!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Text(
                    'Continue to Submission Instructions',
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

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              item,
              style: const TextStyle(fontSize: 13, height: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}
