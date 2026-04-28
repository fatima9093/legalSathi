import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/l10n/app_localizations.dart';

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
  String _generateComplaintText(AppLocalizations l10n) {
    final String formattedDate =
        '${widget.incidentDate.year.toString().padLeft(4, '0')}-'
        '${widget.incidentDate.month.toString().padLeft(2, '0')}-'
        '${widget.incidentDate.day.toString().padLeft(2, '0')}';

    final DateTime now = DateTime.now();
    final String currentDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    return '''${l10n.complaintToHeader}

${l10n.complaintSubject}

${l10n.complaintSalutation}

${l10n.complaintBody(widget.employerName)}

${l10n.complaintIssueLabel(widget.complaintIssue)}

${l10n.complaintDateLabel(formattedDate)}

${l10n.complaintMiddlePara}

${l10n.complaintRequestPara}

${l10n.complaintAvailabilityPara}

${l10n.complaintThankYou}

${l10n.complaintSignoff}
${widget.yourName}
${widget.contactInfo}
$currentDate''';
  }

  void _copyToClipboard(AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: _generateComplaintText(l10n)));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.complaintCopiedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _regenerate(AppLocalizations l10n) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.complaintRegeneratedMessage),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.draftComplaintApplicationTitle,
          style: const TextStyle(
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
                Text(
                  l10n.generatedComplaintLabel,
                  style: const TextStyle(
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
                        onPressed: () => _copyToClipboard(l10n),
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
                            SnackBar(
                              content: Text(l10n.downloadFeatureComingSoon),
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
                _generateComplaintText(l10n),
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
                      onPressed: () => _regenerate(l10n),
                      icon: Icon(
                        Icons.refresh,
                        color: Colors.grey.shade700,
                        size: 20,
                      ),
                      label: Text(
                        l10n.regenerateButton,
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
                      onPressed: () => _copyToClipboard(l10n),
                      icon: const Icon(
                        Icons.copy,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: Text(
                        l10n.copyTextButton,
                        style: const TextStyle(
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