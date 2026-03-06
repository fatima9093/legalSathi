import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screen_with_nav.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String documentType;
  final String complaintantName;
  final String cnic;
  final String address;
  final String incidentDate;
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DocumentPreviewScreen({
    super.key,
    required this.documentType,
    required this.complaintantName,
    required this.cnic,
    required this.address,
    required this.incidentDate,
    required this.extractedText,
    required this.classifiedDomain,
    required this.tags,
  });

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  String _generateDocument() {
    final DateTime now = DateTime.now();
    final String currentDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    String headerTitle = '';
    switch (widget.documentType) {
      case 'FIR':
        headerTitle = 'FIRST INFORMATION REPORT (FIR)';
        break;
      case 'PECA':
        headerTitle = 'PECA COMPLAINT';
        break;
      case 'Harassment':
        headerTitle = 'HARASSMENT COMPLAINT';
        break;
      case 'Labour':
        headerTitle = 'LABOUR COMPLAINT';
        break;
      default:
        headerTitle = 'FORMAL COMPLAINT';
    }

    return '''$headerTitle

Police Station: _______________
District: _______________
Date: $currentDate

COMPLAINANT DETAILS:
Name: ${widget.complaintantName}
CNIC: ${widget.cnic}
Address: ${widget.address}

INCIDENT DETAILS:
Date of Incident: ${widget.incidentDate}
Time: Approximately 3:00 PM
Location: Online - Social Media Platform

DESCRIPTION:
${widget.extractedText}

RELEVANT SECTIONS:
${widget.tags.map((tag) => '- $tag').join('\n')}

PRAYER:
The complainant requests that appropriate legal action be taken against the accused under the relevant laws.

Signature of Complainant
_____________________

Signature of Police Officer
_____________________''';
  }

  void _downloadPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download PDF feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareDocument() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editDocument() {
    Navigator.pop(context);
  }

  void _copyDocument() {
    Clipboard.setData(ClipboardData(text: _generateDocument()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Document copied to clipboard'),
        duration: Duration(seconds: 2),
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
          'Document Preview',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Document Generated Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00401A),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Document Generated',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Document Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Green Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFF00401A),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.documentType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generated by Legal Sathi AI',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Document Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _generateDocument(),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Warning Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFE69C)),
              ),
              child: const Text(
                'This is a draft document. Please review and verify all information before submission to authorities.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF856404),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Download PDF Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _downloadPDF,
                icon: const Icon(Icons.download, color: Colors.white),
                label: const Text(
                  'Download PDF',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareDocument,
                    icon: const Icon(
                      Icons.share,
                      size: 18,
                      color: Color(0xFF00401A),
                    ),
                    label: const Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00401A),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                    onPressed: _editDocument,
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Color(0xFF00401A),
                    ),
                    label: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF00401A),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF00401A)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
