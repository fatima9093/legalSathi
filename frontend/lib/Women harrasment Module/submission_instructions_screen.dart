import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front_end/models/complaint_model.dart';
import 'package:front_end/services/pdf_generator_service.dart';
import 'package:front_end/services/complaint_service.dart';
import 'package:printing/printing.dart';
import 'package:front_end/utils/web_download.dart'
    if (dart.library.io) 'package:front_end/utils/web_download_stub.dart';

class SubmissionInstructionsScreen extends StatefulWidget {
  final String complaintId;
  final ComplaintModel complaint;

  const SubmissionInstructionsScreen({
    super.key,
    required this.complaintId,
    required this.complaint,
  });

  @override
  State<SubmissionInstructionsScreen> createState() =>
      _SubmissionInstructionsScreenState();
}

class _SubmissionInstructionsScreenState
    extends State<SubmissionInstructionsScreen> {
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  final ComplaintService _complaintService = ComplaintService();
  bool _isDownloading = false;
  bool _isSubmitting = false;

  Future<void> _downloadPDF() async {
    setState(() => _isDownloading = true);

    try {
      final pdfData = await _pdfService.generateComplaintPDF(widget.complaint);
      final filename = 'ombudsperson_complaint_${widget.complaintId}.pdf';

      if (kIsWeb) {
        // Direct download for web
        downloadFileOnWeb(pdfData, filename);
      } else {
        // Use printing package for mobile
        await Printing.sharePdf(bytes: pdfData, filename: filename);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _submitComplaint() async {
    setState(() => _isSubmitting = true);

    final result = await _complaintService.submitComplaint(widget.complaintId);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (result['success']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00401A), size: 32),
              SizedBox(width: 12),
              Text('Success!'),
            ],
          ),
          content: const Text(
            'Your complaint has been submitted successfully. You will receive further instructions via email.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
              ),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to submit'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                          'Submission Instructions',
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
                      _buildStep(
                        number: '4',
                        label: 'Preview',
                        isCompleted: true,
                      ),
                      _buildStepLine(),
                      _buildStep(number: '5', label: 'Submit', isActive: true),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),

                    // Success icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00401A).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFF00401A),
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Ready to Submit!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Follow these instructions to file your complaint',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Ombudsperson contact card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                            'Provincial Ombudsperson Punjab',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildContactItem(
                            icon: Icons.location_on_outlined,
                            text: '5-Zafar Ali Road, Gulberg V, Lahore',
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            icon: Icons.email_outlined,
                            text: 'complaints.ombudsperson@punjab.gov.pk',
                            isCopyable: true,
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            icon: Icons.phone_outlined,
                            text: '042-99203201',
                          ),
                          const SizedBox(height: 12),
                          _buildContactItem(
                            icon: Icons.language,
                            text: 'ombudsperson.punjab.gov.pk',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // How to Submit section
                    const Text(
                      'How to Submit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildSubmissionMethod(
                      number: '1',
                      title: 'Email Submission',
                      description:
                          'Send your complaint PDF to the email address above with subject: "Harassment Complaint - [Your Name]"',
                    ),

                    const SizedBox(height: 16),

                    _buildSubmissionMethod(
                      number: '2',
                      title: 'In-Person Submission',
                      description:
                          'Visit the office address above and submit printed complaint with evidence',
                    ),

                    const SizedBox(height: 16),

                    _buildSubmissionMethod(
                      number: '3',
                      title: 'Online Portal',
                      description:
                          'Visit the website and use the online complaint submission form',
                    ),

                    const SizedBox(height: 24),

                    // Expected Timeline section
                    const Text(
                      'Expected Timeline',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildTimelineItem(
                            title: 'Inquiry Process',
                            subtitle: 'Decision within 90 days of filing',
                          ),
                          const SizedBox(height: 16),
                          _buildTimelineItem(
                            title: 'Implementation',
                            subtitle: 'Organization must comply within 30 days',
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
                // Download PDF Button
                ElevatedButton(
                  onPressed: _isDownloading ? null : _downloadPDF,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: _isDownloading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.download, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Download Complaint PDF',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),

                // Copy Email Button
                OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'complaints.ombudsperson@punjab.gov.pk',
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Email address copied to clipboard'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy, size: 20, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        'Copy Email Address',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Mark as Submitted Button
                TextButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Mark as Submitted',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00401A),
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 213, 222, 218),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Text(
                    'Keep a copy of your complaint and all evidence for your records',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
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

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    bool isCopyable = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          ),
        ),
        if (isCopyable) Icon(Icons.copy, size: 16, color: Colors.grey.shade600),
      ],
    );
  }

  Widget _buildSubmissionMethod({
    required String number,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Text(
                '$number. ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
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
    );
  }
}
