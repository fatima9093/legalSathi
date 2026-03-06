import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GeneratedComplaintScreen extends StatelessWidget {
  final String fullName;
  final String cnic;
  final String phone;
  final String email;
  final String designation;
  final String workplace;
  final String address;
  final String dateOfIncident;
  final String description;
  final String evidence;
  final String witnesses;
  final String mentalImpact;
  final String emotionalImpact;
  final String safetyConcerns;
  final List<String> reliefSought;

  const GeneratedComplaintScreen({
    super.key,
    required this.fullName,
    required this.cnic,
    required this.phone,
    required this.email,
    required this.designation,
    required this.workplace,
    required this.address,
    required this.dateOfIncident,
    required this.description,
    required this.evidence,
    required this.witnesses,
    required this.mentalImpact,
    required this.emotionalImpact,
    required this.safetyConcerns,
    required this.reliefSought,
  });

  String get complaintText {
    String currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());

    String complaint =
        '''FORMAL COMPLAINT OF HARASSMENT AT WORKPLACE

To: [Relevant Authority]
Date: $currentDate

COMPLAINANT DETAILS:
Name: ${fullName.isEmpty ? 'Not provided' : fullName}
CNIC: ${cnic.isEmpty ? 'Not provided' : cnic}
Phone: ${phone.isEmpty ? 'Not provided' : phone}
Email: ${email.isEmpty ? 'Not provided' : email}
Designation: ${designation.isEmpty ? 'Not provided' : designation}
Workplace: ${workplace.isEmpty ? 'Not provided' : workplace}
Address: ${address.isEmpty ? 'Not provided' : address}

SUBJECT: Formal Complaint of Harassment at Workplace

Dear Sir/Madam,

I am writing to file a formal complaint regarding harassment that I have experienced at the workplace. This complaint is being submitted under the Protection Against Harassment of Women at Workplace Act, 2010.

INCIDENT DETAILS:

Date(s) of Incident: ${dateOfIncident.isEmpty ? 'Not provided' : dateOfIncident}

Description of Harassment:
${description.isEmpty ? 'Not provided' : description}

EVIDENCE:
${evidence.isEmpty ? 'No evidence listed' : evidence}

WITNESSES:
${witnesses.isEmpty ? 'No witnesses listed' : witnesses}

IMPACT ON COMPLAINANT:

Mental Impact:
${mentalImpact.isEmpty ? 'Not provided' : mentalImpact}

Emotional Impact:
${emotionalImpact.isEmpty ? 'Not provided' : emotionalImpact}

Safety Concerns:
${safetyConcerns.isEmpty ? 'Not provided' : safetyConcerns}

RELIEF SOUGHT:

I respectfully request the following relief:
${_formatReliefSought()}

I hereby declare that the information provided above is true and correct to the best of my knowledge and belief. I am willing to provide any additional information or documentation as may be required during the inquiry process.

I request that this complaint be treated with utmost confidentiality and that appropriate action be taken in accordance with the law.

Thank you for your attention to this serious matter.

Respectfully submitted,

_____________________
${fullName.isEmpty ? '[Name]' : fullName}
${designation.isEmpty ? '[Designation]' : designation}

Date: $currentDate''';

    return complaint;
  }

  String _formatReliefSought() {
    if (reliefSought.isEmpty) {
      return 'No specific relief requested';
    }
    return reliefSought
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('\n');
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
        child: Column(
          children: [
            // Success banner
            Container(
              width: double.infinity,
              color: const Color(0xFFE6F7F0),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Color(0xFF00401A), size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Complaint Generated Successfully',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00401A),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Formal Complaint',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review, edit, and download your complaint',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Complaint preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00401A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Harassment Complaint',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Generated by Legal Sathi AI',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Complaint text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: SelectableText(
                  complaintText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement edit functionality
                        Navigator.pop(context);
                      },
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
                      onPressed: () {
                        _regenerateComplaint(context);
                      },
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
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _downloadAsPDF(context),
                icon: const Icon(Icons.download, size: 20),
                label: const Text('Download as PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard(context),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy to Clipboard'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00401A),
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: Color(0xFF00401A), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Warning message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFD966)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This is a draft document. Please review carefully and consult a legal professional before submission.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: complaintText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint copied to clipboard'),
        backgroundColor: Color(0xFF00401A),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _regenerateComplaint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Complaint'),
        content: const Text(
          'This will regenerate the complaint with the same information. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complaint regenerated'),
                  backgroundColor: Color(0xFF00401A),
                ),
              );
            },
            child: const Text(
              'Regenerate',
              style: TextStyle(color: Color(0xFF00401A)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAsPDF(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'FORMAL COMPLAINT OF HARASSMENT AT WORKPLACE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(complaintText, style: const pw.TextStyle(fontSize: 11)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
