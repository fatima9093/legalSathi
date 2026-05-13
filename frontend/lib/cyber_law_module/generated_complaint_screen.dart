import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front_end/l10n/app_localizations.dart';
import '../screen_with_nav.dart';

class GeneratedComplaintScreen extends StatelessWidget {
  const GeneratedComplaintScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          loc.generatedComplaint,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.complaintGeneratedSuccess,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section title
              Text(
                loc.yourFiaComplaint,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loc.reviewEditDownload,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 20),

              // Complaint document
              Column(
                children: [
                  // Header
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
                          loc.fiaCyberCrimeComplaint,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loc.generatedBy,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.formalComplaintTitle,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.toDirector,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        Text(
                          loc.dateLabel,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.complainantDetails,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        Text(
                          loc.sampleName,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        Text(
                          loc.sampleCnic,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        Text(
                          loc.samplePhone,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        Text(
                          loc.sampleEmail,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        Text(
                          loc.sampleAddress,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.subject,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.respected,
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.complaintBody(loc.sampleName),
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Edit complaint
                          },
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Color(0xFF00401A),
                          ),
                          label: Text(
                            loc.edit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00401A),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFF00401A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Regenerate complaint
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Color(0xFF00401A),
                          ),
                          label: Text(
                            loc.regenerate,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF00401A),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFF00401A)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Download button
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Download as TXT
                },
                icon: const Icon(Icons.download, size: 20),
                label: Text(
                  loc.downloadTxt,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00401A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Copy to Clipboard button
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: loc.sampleComplaintText),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.copiedClipboard),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy,
                  size: 20,
                  color: Color(0xFF00401A),
                ),
                label: Text(
                  loc.copyClipboard,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00401A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFF00401A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Next Steps section
              Text(
                loc.nextSteps,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 12),

              _buildNextStep(loc.step1),
              _buildNextStep(loc.step2),
              _buildNextStep(loc.step3),
              _buildNextStep(loc.step4),

              const SizedBox(height: 24),

              // Footer info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.fiaHelpline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00401A),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 3),
    );
  }

  Widget _buildNextStep(String text) {
    // Extract number and rest of text
    final parts = text.split('. ');
    final number = parts[0];
    final content = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
