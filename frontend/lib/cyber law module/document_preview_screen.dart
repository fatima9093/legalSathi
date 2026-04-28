import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';

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
  String _generateDocument(AppLocalizations l10n) {
    final now = DateTime.now();
    final currentDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    String headerTitle;
    switch (widget.documentType) {
      case 'FIR':
        headerTitle = l10n.firTitle;
        break;
      case 'PECA':
        headerTitle = l10n.pecaTitle;
        break;
      case 'Harassment':
        headerTitle = l10n.harassmentTitle;
        break;
      case 'Labour':
        headerTitle = l10n.labourTitle;
        break;
      default:
        headerTitle = l10n.formalComplaintTitle;
    }

    return '''
$headerTitle

${l10n.policeStation}
${l10n.district}
${l10n.dateLabel}: $currentDate

${l10n.complainantDetails}
${l10n.nameLabel}: ${widget.complaintantName}
CNIC: ${widget.cnic}
${l10n.addressLabel}: ${widget.address}

${l10n.incidentDetails}
${l10n.incidentDateLabel}: ${widget.incidentDate}
${l10n.locationLabel}

${l10n.description}
${widget.extractedText}

${l10n.relevantSections}
${widget.tags.map((t) => '- $t').join('\n')}

${l10n.prayer}

${l10n.signatureComplainant}
_____________________

${l10n.signatureOfficer}
_____________________
''';
  }

  void _copyDocument(AppLocalizations l10n) {
    Clipboard.setData(
      ClipboardData(text: _generateDocument(l10n)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.copiedMessage)),
    );
  }

  void _downloadPDF(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.downloadSoon)),
    );
  }

  void _share(AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareSoon)),
    );
  }

  void _edit() => Navigator.pop(context);

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
        title: Text(l10n.documentPreviewTitle),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF00401A)),
                  const SizedBox(width: 8),
                  Text(l10n.documentGenerated),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Document
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _generateDocument(l10n),
              ),
            ),

            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFFFF3CD),
              child: Text(l10n.warningMessage),
            ),

            const SizedBox(height: 24),

            // Buttons
            ElevatedButton(
              onPressed: () => _downloadPDF(l10n),
              child: Text(l10n.downloadPdf),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _share(l10n),
                    child: Text(l10n.share),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _edit,
                    child: Text(l10n.edit),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}