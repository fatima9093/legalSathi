import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/pdf_generator_service.dart';
import 'package:printing/printing.dart';

import 'package:front_end/utils/web_download.dart'
    if (dart.library.io) 'package:front_end/utils/web_download_stub.dart';

class EscalationTemplates {
  static const String committeeReconstitutionTitle =
      'Request for Reconstitution of Inquiry Committee';

  static const String committeeReconstitutionBody = '''
To,
The [Employer/HR Department/Managing Director]
[Organization Name]
[Address]

Date: _______________

Subject: Request for reconstitution of the Inquiry Committee under the Protection Against Harassment of Women at the Workplace Act, 2010

Dear Sir/Madam,

I am writing to formally request the reconstitution of the Inquiry Committee constituted to hear my complaint of harassment at the workplace.

REASONS FOR REQUEST:
The current committee has failed to conduct a fair and impartial inquiry as required under the Act.

I request that a new committee be formed within seven (7) days with:
• At least three (3) members
• At least one (1) female member
• A senior management representative
• Members with no conflict of interest in this matter

Under the Act, I reserve my right to approach the Federal Ombudsperson if the committee is not reconstituted or if the inquiry is not completed within 30 days.

I request a written acknowledgment of this letter and the steps taken.

Yours sincerely,

[Your Full Name]
[Designation]
[Contact Number]
[Email]
''';

  static const String escalationLetterTitle =
      'Escalation Letter to Federal Ombudsperson (FOSPAH)';

  static const String escalationLetterBody = '''
To,
The Federal Ombudsperson Secretariat for Protection Against Harassment of Women at the Workplace (FOSPAH) Islamabad, Pakistan

Date: _______________

Subject: Escalation of complaint under the Protection Against Harassment of Women at the Workplace Act, 2010

Dear Sir/Madam,

I wish to escalate my complaint of workplace harassment to your office for inquiry and redress.

BACKGROUND: [Briefly state: your workplace, designation, and that you had filed an internal complaint with the workplace Inquiry Committee / or that no committee was formed.] 
REASONS FOR ESCALATION:
 [Choose as applicable:] 
 • The workplace did not constitute an Inquiry Committee within the required time. 
 • The Inquiry Committee did not complete the inquiry within 30 days. 
 • The inquiry was biased or the procedure was not followed. 
 • The recommendations of the committee were not implemented. 
 • I faced retaliation after filing the complaint. 
 • The accused is my employer, so I am filing directly with the Ombudsperson as provided under the Act. I request that my complaint be inquired into by your office and appropriate relief be granted under the law. I am ready to provide further details, documents, and evidence as required.

Yours sincerely,
[Your Full Name] 
[CNIC] 
[Contact Number]
[Email] 
[Workplace Name & Address]

''';
}

class TemplateViewScreen extends StatefulWidget {
  final String title;
  final String body;
  final String downloadFilename;

  const TemplateViewScreen({
    super.key,
    required this.title,
    required this.body,
    required this.downloadFilename,
  });

  @override
  State<TemplateViewScreen> createState() => _TemplateViewScreenState();
}

class _TemplateViewScreenState extends State<TemplateViewScreen> {
  final PdfGeneratorService _pdfService = PdfGeneratorService();
  bool _isDownloading = false;

  Future<void> _downloadPdf() async {
    final loc = AppLocalizations.of(context)!;

    setState(() => _isDownloading = true);
    try {
      final pdfData = await _pdfService.generateTemplatePdf(
        widget.title,
        widget.body,
      );
      final filename = widget.downloadFilename;

      if (kIsWeb) {
        downloadFileOnWeb(pdfData, filename);
      } else {
        await Printing.sharePdf(bytes: pdfData, filename: filename);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.templateDownloaded),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${loc.error}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
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
                child: SelectableText(
                  widget.body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _downloadPdf,
                icon: _isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.download, color: Colors.white, size: 22),
                label: Text(
                  _isDownloading
                      ? loc.downloading
                      : loc.downloadAsPDF,
                  style: const TextStyle(
                    fontSize: 16,
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
          ),
        ],
      ),
    );
  }
}