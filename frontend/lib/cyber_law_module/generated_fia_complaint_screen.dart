import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../screen_with_nav.dart';
import 'package:front_end/l10n/app_localizations.dart';

class GeneratedFIAComplaintScreen extends StatefulWidget {
  final String fullName;
  final String cnic;
  final String phone;
  final String email;
  final String address;
  final String dateOfIncident;
  final String incidentDescription;
  final String suspectInfo;
  final String evidenceAvailable;

  const GeneratedFIAComplaintScreen({
    super.key,
    required this.fullName,
    required this.cnic,
    required this.phone,
    required this.email,
    required this.address,
    required this.dateOfIncident,
    required this.incidentDescription,
    required this.suspectInfo,
    required this.evidenceAvailable,
  });

  @override
  State<GeneratedFIAComplaintScreen> createState() =>
      _GeneratedFIAComplaintScreenState();
}

class _GeneratedFIAComplaintScreenState
    extends State<GeneratedFIAComplaintScreen> {
  String _generateFullText() {
    final loc = AppLocalizations.of(context)!;
    final buffer = StringBuffer();

    buffer.writeln(loc.fiaCyberComplaint);
    buffer.writeln(loc.generatedByAI);
    buffer.writeln();
    buffer.writeln(loc.formalComplaintTitle);
    buffer.writeln();
    buffer.writeln(loc.toDirector);
    buffer.writeln(
      '${loc.date}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
    );
    buffer.writeln();
    buffer.writeln(loc.complainantDetails);
    buffer.writeln('${loc.name}: ${widget.fullName}');
    buffer.writeln('${loc.cnic}: ${widget.cnic}');
    buffer.writeln('${loc.phone}: ${widget.phone}');
    buffer.writeln('${loc.email}: ${widget.email}');
    buffer.writeln('${loc.address}: ${widget.address}');
    buffer.writeln();
    buffer.writeln(loc.subjectPeca);
    buffer.writeln();
    buffer.writeln(loc.respected);
    buffer.writeln(
      'I am writing to file a formal complaint regarding a cyber crime that I have experienced. This complaint is being submitted under the Prevention of Electronic Crimes Act (PECA), 2016.',
    );
    buffer.writeln();
    buffer.writeln(loc.incidentDetails);
    buffer.writeln('${loc.dateOfIncident}: ${widget.dateOfIncident}');
    buffer.writeln();
    buffer.writeln(loc.descriptionIncident);
    buffer.writeln(widget.incidentDescription);
    buffer.writeln();
    if (widget.suspectInfo.isNotEmpty) {
      buffer.writeln(loc.suspectInfo);
      buffer.writeln(widget.suspectInfo);
      buffer.writeln();
    }
    if (widget.evidenceAvailable.isNotEmpty) {
      buffer.writeln(loc.evidenceAvailable);
      buffer.writeln(widget.evidenceAvailable);
      buffer.writeln();
    }
    buffer.writeln(loc.finalRequest);
    buffer.writeln();
    buffer.writeln('${loc.sincerely}');
    buffer.writeln();
    buffer.writeln(widget.fullName);

    return buffer.toString();
  }

  Future<void> _downloadAsTxt() async {
    try {
      final text = _generateFullText();
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/fia_complaint_${DateTime.now().millisecondsSinceEpoch}.txt';
      final file = File(path);
      await file.writeAsString(text);

      await Share.shareXFiles([XFile(path)], subject: 'FIA Cyber Complaint');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final text = _generateFullText();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
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
          loc.generatedComplaint,
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
            // Success Message
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.fiaComplaintSuccess,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Complaint Document
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00401A),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.fiaCyberComplaint,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.generatedByAI,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(loc.formalComplaintTitle),
                          const SizedBox(height: 16),
                          _buildSection(loc.toDirector),
                          _buildSection(
                            '${loc.date}: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                          ),
                          const SizedBox(height: 16),
                          _buildSection(loc.complainantDetails),
                          _buildDetail(loc.name, widget.fullName),
                          _buildDetail(loc.cnic, widget.cnic),
                          _buildDetail(loc.phone, widget.phone),
                          _buildDetail(loc.email, widget.email),
                          _buildDetail(loc.address, widget.address),
                          const SizedBox(height: 16),
                          _buildSection(loc.subjectPeca),
                          const SizedBox(height: 16),
                          _buildSection(loc.respected),
                          const SizedBox(height: 8),
                          Text(
                            'I am writing to file a formal complaint regarding a cyber crime that I have experienced. This complaint is being submitted under the Prevention of Electronic Crimes Act (PECA), 2016.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(loc.incidentDetails),
                          _buildDetail(
                            loc.dateOfIncident,
                            widget.dateOfIncident,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.descriptionIncident,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.incidentDescription,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.suspectInfo.isNotEmpty) ...[
                            Text(
                              loc.suspectInfo,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.suspectInfo,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (widget.evidenceAvailable.isNotEmpty) ...[
                            Text(
                              loc.evidenceAvailable,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.evidenceAvailable,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          Text(
                            loc.finalRequest,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${loc.sincerely}\n\n${widget.fullName}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          label: Text(loc.edit),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00401A),
                            side: const BorderSide(color: Color(0xFF00401A)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.refresh_outlined, size: 18),
                          label: Text(loc.regenerate),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF00401A),
                            side: const BorderSide(color: Color(0xFF00401A)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _downloadAsTxt,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: Text(loc.downloadTxt),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00401A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.content_copy_outlined, size: 18),
                      label: Text(loc.copyClipboard),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: BorderSide(color: Colors.grey.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Next Steps
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow.shade200),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.nextSteps,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNextStep(loc.complaintStep1),
                    const SizedBox(height: 8),
                    _buildNextStep(loc.complaintStep2),

                    const SizedBox(height: 8),
                    _buildNextStep(loc.complaintStep3),

                    const SizedBox(height: 8),
                    _buildNextStep(loc.complaintStep4),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                loc.fiaHelpline,
                style: TextStyle(fontSize: 12, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

  Widget _buildSection(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStep(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.orange.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
          ),
        ),
      ],
    );
  }
}
