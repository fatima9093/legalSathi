import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:front_end/models/complaint_model.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  Future<Uint8List> generateComplaintPDF(
    ComplaintModel complaint,
  ) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM yyyy');

    final evidenceFiles =
        complaint.evidenceFiles ?? const <EvidenceFile>[];

    final complaintId = complaint.complaintId ?? 'N/A';

    final complaintStatus =
        (complaint.status ?? 'draft').toUpperCase();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(
            title: 'LEGAL COMPLAINT DRAFT',
            subtitle:
                'Protection Against Harassment of Women at Workplace',
            now: now,
            dateFormat: dateFormat,
            complaintId: complaintId,
            complaintStatus: complaintStatus,
          ),

          pw.SizedBox(height: 24),

          // TO ADDRESS
          pw.Text(
            'To,',
            style: const pw.TextStyle(fontSize: 12),
          ),

          pw.Text(
            'The Federal Ombudsperson',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),

          pw.Text(
            'Protection Against Harassment of Women at Workplace',
            style: const pw.TextStyle(fontSize: 12),
          ),

          pw.Text(
            'Islamabad, Pakistan',
            style: const pw.TextStyle(fontSize: 12),
          ),

          pw.SizedBox(height: 24),

          _buildSection(
            'APPLICANT DETAILS:',
            [
              {
                'label': 'Name',
                'value': complaint.fullName ?? 'N/A',
              },
              {
                'label': 'CNIC',
                'value': complaint.cnic ?? 'N/A',
              },
              {
                'label': 'Phone',
                'value': complaint.phone ?? 'N/A',
              },
              {
                'label': 'Email',
                'value': complaint.email ?? 'N/A',
              },
              {
                'label': 'Workplace',
                'value': complaint.workplace ?? 'N/A',
              },
              {
                'label': 'Designation',
                'value': complaint.designation ?? 'N/A',
              },
              {
                'label': 'City',
                'value': complaint.city ?? 'N/A',
              },
            ],
          ),

          pw.SizedBox(height: 20),

          _buildSection(
            'INCIDENT DETAILS:',
            [
              {
                'label': 'Date of Incident',
                'value': complaint.incidentDate ?? 'N/A',
              },
              {
                'label': 'Type of Harassment',
                'value':
                    complaint.harassmentType ?? 'N/A',
              },
              {
                'label': 'Complaint Status',
                'value': complaintStatus,
              },
              {
                'label': 'Complaint ID',
                'value': complaintId,
              },
            ],
          ),

          pw.SizedBox(height: 16),

          pw.Text(
            'DETAILED DESCRIPTION:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColors.grey400,
              ),
              borderRadius:
                  const pw.BorderRadius.all(
                pw.Radius.circular(4),
              ),
            ),
            child: pw.Text(
              complaint.description ??
                  'No description provided',
              style: const pw.TextStyle(
                fontSize: 11,
              ),
              textAlign: pw.TextAlign.justify,
            ),
          ),

          if (evidenceFiles.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _buildEvidenceSection(
              evidenceFiles,
              dateFormat,
            ),
          ],

          pw.SizedBox(height: 18),

          _buildNoteBox(
            'This draft is generated from your saved complaint data. Review names, dates, and evidence before submitting to any authority.',
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // TEMPLATE PDF
  Future<Uint8List> generateTemplatePdf(
    String title,
    String body,
  ) async {
    final pdf = pw.Document();

    final now = DateTime.now();

    final dateFormat = DateFormat('dd MMM yyyy');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          _buildHeader(
            title: title,
            subtitle: 'Legal document template',
            now: now,
            dateFormat: dateFormat,
          ),

          pw.SizedBox(height: 24),

          pw.Text(
            body,
            style: const pw.TextStyle(
              fontSize: 11,
              height: 1.5,
            ),
            textAlign: pw.TextAlign.justify,
          ),

          pw.SizedBox(height: 18),

          _buildNoteBox(
            'Generated by Legal Sathi. Exported templates should be reviewed before filing or sharing.',
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // SECTION
  pw.Widget _buildSection(
    String title,
    List<Map<String, String>> items,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.grey400,
            ),
            borderRadius:
                const pw.BorderRadius.all(
              pw.Radius.circular(4),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(
                      bottom: 6,
                    ),
                    child: pw.Row(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment
                              .start,
                      children: [
                        pw.SizedBox(
                          width: 120,
                          child: pw.Text(
                            '${item['label']}:',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  pw.FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        pw.Expanded(
                          child: pw.Text(
                            item['value']!,
                            style:
                                const pw.TextStyle(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  // HEADER
  pw.Widget _buildHeader({
    required String title,
    required String subtitle,
    required DateTime now,
    required DateFormat dateFormat,
    String? complaintId,
    String? complaintStatus,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.green900,
        borderRadius:
            const pw.BorderRadius.all(
          pw.Radius.circular(8),
        ),
      ),
      child: pw.Column(
        crossAxisAlignment:
            pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),

          pw.SizedBox(height: 4),

          pw.Text(
            subtitle,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),

          pw.SizedBox(height: 8),

          pw.Text(
            'Generated by Legal Sathi on ${dateFormat.format(now)}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.white,
            ),
          ),

          if (complaintId != null ||
              complaintStatus != null) ...[
            pw.SizedBox(height: 8),

            pw.Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (complaintId != null)
                  _headerChip(
                    'Complaint ID',
                    complaintId,
                  ),

                if (complaintStatus != null)
                  _headerChip(
                    'Status',
                    complaintStatus,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // HEADER CHIP
  pw.Widget _headerChip(
    String label,
    String value,
  ) {
    return pw.Container(
      padding:
          const pw.EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: pw.BoxDecoration(
        color: PdfColors.green700,
        borderRadius:
            const pw.BorderRadius.all(
          pw.Radius.circular(999),
        ),
      ),
      child: pw.Text(
        '$label: $value',
        style: const pw.TextStyle(
          fontSize: 9,
          color: PdfColors.white,
        ),
      ),
    );
  }

  // NOTE BOX
  pw.Widget _buildNoteBox(String text) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        border: pw.Border.all(
          color: PdfColors.green200,
        ),
        borderRadius:
            const pw.BorderRadius.all(
          pw.Radius.circular(6),
        ),
      ),
      child: pw.Text(
        text,
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.green900,
        ),
      ),
    );
  }

  // EVIDENCE SECTION
  pw.Widget _buildEvidenceSection(
    List<EvidenceFile> evidenceFiles,
    DateFormat dateFormat,
  ) {
    return pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'EVIDENCE APPENDIX:',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.grey400,
            ),
            borderRadius:
                const pw.BorderRadius.all(
              pw.Radius.circular(4),
            ),
          ),
          child: pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.start,
            children: List.generate(
              evidenceFiles.length,
              (index) {
                final evidence =
                    evidenceFiles[index];

                final uploadedAt =
                    evidence.uploadedAt != null
                        ? dateFormat.format(
                            evidence.uploadedAt!,
                          )
                        : 'N/A';

                return pw.Padding(
                  padding:
                      pw.EdgeInsets.only(
                    bottom:
                        index ==
                                evidenceFiles
                                        .length -
                                    1
                            ? 0
                            : 10,
                  ),
                  child: pw.Container(
                    padding:
                        const pw.EdgeInsets
                            .all(10),
                    decoration:
                        pw.BoxDecoration(
                      color:
                          PdfColors.grey100,
                      borderRadius:
                          const pw
                              .BorderRadius
                              .all(
                        pw.Radius.circular(
                          4,
                        ),
                      ),
                    ),
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment
                              .start,
                      children: [
                        pw.Text(
                          evidence.fileName,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight:
                                pw.FontWeight
                                    .bold,
                          ),
                        ),

                        pw.SizedBox(height: 4),

                        pw.Text(
                          'Type: ${evidence.fileType}',
                          style:
                              const pw.TextStyle(
                            fontSize: 9,
                          ),
                        ),

                        if (evidence.fileSize !=
                            null)
                          pw.Text(
                            'Size: ${_formatBytes(evidence.fileSize!)}',
                            style:
                                const pw.TextStyle(
                              fontSize: 9,
                            ),
                          ),

                        pw.Text(
                          'Uploaded: $uploadedAt',
                          style:
                              const pw.TextStyle(
                            fontSize: 9,
                          ),
                        ),

                        if ((evidence.fileUrl ??
                                '')
                            .isNotEmpty)
                          pw.Text(
                            'Source: ${evidence.fileUrl}',
                            style:
                                const pw.TextStyle(
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // FORMAT FILE SIZE
  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }

    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }

    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}