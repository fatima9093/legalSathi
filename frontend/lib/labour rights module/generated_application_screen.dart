import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screen_with_nav.dart';

class GeneratedApplicationScreen extends StatefulWidget {
  final String employerName;
  final String issueDescription;
  final String relevantDates;

  const GeneratedApplicationScreen({
    super.key,
    required this.employerName,
    required this.issueDescription,
    required this.relevantDates,
  });

  @override
  State<GeneratedApplicationScreen> createState() =>
      _GeneratedApplicationScreenState();
}

class _GeneratedApplicationScreenState
    extends State<GeneratedApplicationScreen> {
  String _generateApplicationText() {
    final DateTime now = DateTime.now();
    final String currentDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    return '''APPLICATION TO LABOUR DEPARTMENT

To: The Labour Inspector
${widget.employerName}
Date: $currentDate

Subject: Complaint Against Labour Law Violation

Respected Sir/Madam,

I am an employee of ${widget.employerName} and I am writing to file a formal complaint regarding violation of labour laws.

ISSUE DESCRIPTION:

${widget.issueDescription}

RELEVANT DATES:

${widget.relevantDates}

I hereby request that appropriate action be taken against this violation and my rights as an employee be protected under the applicable labour laws.

I am available to provide any additional information or documentation required for this investigation.

Thank you for your attention to this serious matter.

Yours faithfully,
[Employee Name]
[Contact Information]''';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generateApplicationText()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF00401A),
      ),
    );
  }

  void _downloadAsPDF() {
    // Placeholder for PDF download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download PDF feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _editApplication() {
    Navigator.pop(context);
  }

  void _regenerateApplication() {
    setState(() {
      // Refresh the UI to simulate regeneration
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application regenerated'),
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
          'Generated Application',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Application Generated Badge
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
                    'Application Generated',
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

            // Application Card
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
                        const Text(
                          'Labour Application',
                          style: TextStyle(
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

                  // Application Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _generateApplicationText(),
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Edit and Regenerate Buttons Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _editApplication,
                    icon: const Icon(
                      Icons.edit_outlined,
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
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _regenerateApplication,
                    icon: const Icon(
                      Icons.refresh,
                      size: 18,
                      color: Color(0xFF00401A),
                    ),
                    label: const Text(
                      'Regenerate',
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

            const SizedBox(height: 12),

            // Download as PDF Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _downloadAsPDF,
                icon: const Icon(Icons.download, color: Colors.white, size: 20),
                label: const Text(
                  'Download as PDF',
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

            // Copy to Clipboard Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(
                  Icons.content_copy,
                  color: Color(0xFF00401A),
                  size: 20,
                ),
                label: const Text(
                  'Copy to Clipboard',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00401A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
