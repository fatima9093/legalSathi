import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/l10n/app_localizations.dart';
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
  final String complainantName;
  final String contactNumber;
  final String cnic;

  /// Supabase row id when the draft was saved; used so edits call UPDATE, not INSERT.
  final String? savedComplaintId;

  /// Opens the edit form (provided by the caller to avoid circular imports).
  final VoidCallback? onEditPressed;

  const PoliceGeneratedComplaintScreen({
    super.key,
    required this.whatHappened,
    required this.location,
    required this.date,
    required this.time,
    required this.officerId,
    required this.witnesses,
    required this.complainantName,
    required this.contactNumber,
    required this.cnic,
    this.savedComplaintId,
    this.onEditPressed,
  });

  @override
  State<PoliceGeneratedComplaintScreen> createState() =>
      _PoliceGeneratedComplaintScreenState();
}

class _PoliceGeneratedComplaintScreenState
    extends State<PoliceGeneratedComplaintScreen> {
  String complaintText (AppLocalizations loc) {
    final currentDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final officerInfo = widget.officerId.isEmpty
        ? loc.notNoted 
        : widget.officerId;
    final witnessInfo = widget.witnesses.isEmpty
        ? loc.noWitnesses
        : widget.witnesses;

    return '''${loc.complaintTitle}

${loc.toSSP}
${loc.date}: $currentDate

${loc.subject}

${loc.respected}

${loc.intro}

${loc.incidentDetails}

${loc.date}: ${widget.date}
${loc.time}: ${widget.time}
${loc.location}: ${widget.location}
${loc.officerIdLabel}: $officerInfo

${loc.description}

${widget.whatHappened}

${loc.witnessSection}

$witnessInfo

${loc.requestAction}

${loc.closing}

${loc.yoursSincerely},
${widget.complainantName}
${loc.contact}: ${widget.contactNumber}
${loc.cnic}: ${widget.cnic}''';
}

  Future<void> _downloadAsPDF() async {
    final loc = AppLocalizations.of(context)!;
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
                pw.Text(complaintText(loc),
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
    final loc = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: complaintText(loc)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.copiedToClipboard),
          backgroundColor: const Color(0xFF00401A),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _regenerate() {
    Navigator.pop(context);
  }

  void _editComplaint() {
    widget.onEditPressed?.call();
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
        title: Text(loc.generatedComplaint,
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
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF00401A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(loc.complaintGenerated,
                      style: const TextStyle(
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
              Text(loc.yourFormalComplaint,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(loc.reviewEditSubmit,
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
                        children: [
                          Text(loc.policeMisbehavior,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(loc.generatedByAI,
                            style: const TextStyle(
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
                      child: SelectableText(complaintText(loc),
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
                      onPressed:
                          widget.onEditPressed != null ? _editComplaint : null,
                      icon: const Icon(Icons.edit, size: 18),
                     label: Text(loc.edit),
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
                      label: Text(loc.regenerate),
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
                  label: Text(loc.downloadPdf,
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
                  label: Text(loc.copyClipboard,
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
                    Text(loc.submitInstruction,
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
