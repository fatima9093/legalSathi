import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screen_with_nav.dart';

class GeneratedComplaintScreen extends StatefulWidget {
  final String employerName;
  final String complaintIssue;
  final DateTime incidentDate;
  final String yourName;
  final String contactInfo;

  const GeneratedComplaintScreen({
    super.key,
    required this.employerName,
    required this.complaintIssue,
    required this.incidentDate,
    required this.yourName,
    required this.contactInfo,
  });

  @override
  State<GeneratedComplaintScreen> createState() =>
      _GeneratedComplaintScreenState();
}

class _GeneratedComplaintScreenState extends State<GeneratedComplaintScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _generateComplaintText() {
    final String formattedDate =
        '${widget.incidentDate.year.toString().padLeft(4, '0')}-${widget.incidentDate.month.toString().padLeft(2, '0')}-${widget.incidentDate.day.toString().padLeft(2, '0')}';

    final DateTime now = DateTime.now();
    final String currentDate =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return '''To: Labour Department / Relevant Authority

Subject: Formal Labour Complaint

Dear Sir/Madam,

I am writing to file a formal complaint against my employer, ${widget.employerName}, regarding the following issue:

Complaint Issue: ${widget.complaintIssue}

Date of Incident: $formattedDate

This matter has caused significant distress and violates my rights as an employee under the applicable labour laws. I have attempted to resolve this issue internally without success.

I hereby request that the relevant authorities investigate this matter and take appropriate action to ensure my rights are protected and such violations do not occur in the future.

I am available to provide any additional information or documentation required for this investigation.

Thank you for your attention to this serious matter.

Sincerely,
${widget.yourName}
${widget.contactInfo}
$currentDate''';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateComplaintText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _regenerate() {
    setState(() {
      // Refresh the UI to simulate regeneration
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Complaint regenerated'),
        duration: Duration(seconds: 2),
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
          'Draft Complaint Application',
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

            // Header with icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Generated Complaint',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.copy,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: _copyToClipboard,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.download,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Download feature coming soon'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Generated Complaint Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                _generateComplaintText(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                  height: 1.6,
                  fontFamily: 'monospace',
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                // Regenerate Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _regenerate,
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      label: Text(
                        'Regenerate',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Copy Text Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00401A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _copyToClipboard,
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Copy Text',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
