import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PoliceGeneratedComplaintScreen extends StatefulWidget {
  final String whatHappened;
  final String location;
  final String date;
  final String time;
  final String officerId;
  final String witnesses;

  const PoliceGeneratedComplaintScreen({
    super.key,
    required this.whatHappened,
    required this.location,
    required this.date,
    required this.time,
    required this.officerId,
    required this.witnesses,
  });

  @override
  State<PoliceGeneratedComplaintScreen> createState() =>
      _PoliceGeneratedComplaintScreenState();
}

class _PoliceGeneratedComplaintScreenState
    extends State<PoliceGeneratedComplaintScreen> {
  String get complaintText {
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final officerInfo = widget.officerId.isEmpty
        ? 'Not noted'
        : widget.officerId;
    final witnessInfo = widget.witnesses.isEmpty
        ? 'No witnesses present'
        : widget.witnesses;

    return '''FORMAL COMPLAINT AGAINST POLICE OFFICER MISBEHAVIOR

To: Senior Superintendent of Police (SSP) Traffic
Date: $currentDate

Subject: Complaint Against Police Officer Misbehavior

Respected Sir/Madam,

I am writing to file a formal complaint regarding the unprofessional and inappropriate conduct of a traffic police officer.

INCIDENT DETAILS:

Date: ${widget.date}
Time: ${widget.time}
Location: ${widget.location}
Officer ID/Badge Number: $officerInfo

DESCRIPTION OF INCIDENT:

${widget.whatHappened}

WITNESSES:

$witnessInfo

REQUEST FOR ACTION:

I request that you kindly investigate this matter and take appropriate action against the officer involved. Such behavior violates the code of conduct expected from police officers and undermines public trust in law enforcement.

I am willing to provide any additional information or evidence if required and would appreciate being informed of the outcome of this complaint.

Thank you for your attention to this matter.

Yours sincerely,
[Your Name]
[Your Contact Number]
[Your CNIC Number]''';
  }

  Future<void> _downloadAsPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'FORMAL COMPLAINT AGAINST POLICE OFFICER MISBEHAVIOR',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  complaintText,
                  style: const pw.TextStyle(fontSize: 11, lineSpacing: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: complaintText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint copied to clipboard'),
          backgroundColor: Color(0xFF00401A),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _regenerate() {
    Navigator.pop(context);
  }

  void _editComplaint() {
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit feature coming soon'),
        backgroundColor: Color(0xFF00401A),
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
          'Generated Complaint',
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
              const SizedBox(height: 16),

              // Success banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: Color(0xFF00401A),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Complaint Letter Generated',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00401A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Text(
                'Your Formal Complaint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Review, edit, and submit your complaint',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // Complaint card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFF00401A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Police Misbehavior Complaint',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Generated by Legal Sathi AI',
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
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      child: SelectableText(
                        complaintText,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editComplaint,
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00401A),
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: Color(0xFF00401A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _regenerate,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00401A),
                        minimumSize: const Size(0, 48),
                        side: const BorderSide(color: Color(0xFF00401A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Download button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _downloadAsPDF,
                  icon: const Icon(Icons.download, size: 20),
                  label: const Text(
                    'Download as PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Copy button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _copyToClipboard,
                  icon: const Icon(Icons.copy, size: 20),
                  label: const Text(
                    'Copy to Clipboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00401A),
                    minimumSize: const Size(double.infinity, 54),
                    side: const BorderSide(
                      color: Color(0xFF00401A),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submission tip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD966)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFD97706),
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submit this complaint to SSP Traffic office or file online through provincial police portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade800,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
