import 'package:flutter/material.dart';
import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'document_preview_screen.dart';

class DraftDocumentReviewScreen extends StatefulWidget {
  final String documentType;
  final String complaintantName;
  final String cnic;
  final String address;
  final String incidentDate;
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DraftDocumentReviewScreen({
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
  State<DraftDocumentReviewScreen> createState() =>
      _DraftDocumentReviewScreenState();
}

class _DraftDocumentReviewScreenState extends State<DraftDocumentReviewScreen> {
  void _generate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentPreviewScreen(
          documentType: widget.documentType,
          complaintantName: widget.complaintantName,
          cnic: widget.cnic,
          address: widget.address,
          incidentDate: widget.incidentDate,
          extractedText: widget.extractedText,
          classifiedDomain: widget.classifiedDomain,
          tags: widget.tags,
        ),
      ),
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
        title: Text(l10n.reviewTitle),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reviewInformationTitle,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            _field(l10n.documentType, widget.documentType),
            _field(l10n.complainant, widget.complaintantName.isNotEmpty ? widget.complaintantName : l10n.notProvided),
            _field(l10n.cnic, widget.cnic.isNotEmpty ? widget.cnic : l10n.notProvided),
            _field(l10n.address, widget.address.isNotEmpty ? widget.address : l10n.notProvided),
            _field(l10n.incidentDate, widget.incidentDate.isNotEmpty ? widget.incidentDate : l10n.notProvided),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _generate,
              child: Text(l10n.generateDocumentButton),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: _edit,
              child: Text(l10n.editDetailsButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}