import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screen_with_nav.dart';
import 'evidence_extractor_screen.dart';

class ExtractedEvidenceResultsScreen extends StatefulWidget {
  final List<EvidenceFile> uploadedFiles;

  const ExtractedEvidenceResultsScreen({
    super.key,
    required this.uploadedFiles,
  });

  @override
  State<ExtractedEvidenceResultsScreen> createState() =>
      _ExtractedEvidenceResultsScreenState();
}

class _ExtractedEvidenceResultsScreenState
    extends State<ExtractedEvidenceResultsScreen> {
  late ExtractedEvidence _extractedEvidence;

  @override
  void initState() {
    super.initState();
    _extractedEvidence = _generateMockExtraction();
  }

  // Generate dynamic mock extraction based on uploaded files
  ExtractedEvidence _generateMockExtraction() {
    // Simulate AI analysis of uploaded files
    List<String> timestamps = [
      '2024-01-15 14:32:15',
      '2024-01-15 18:45:22',
      '2024-01-16 09:12:08',
      '2024-01-16 22:18:45',
    ];

    List<String> phoneNumbers = ['+92-300-1234567', '+92-321-9876543'];

    List<String> urls = [
      'https://facebook.com/fake-profile',
      'https://instagram.com/harasser123',
    ];

    List<ThreatClassification> threats = [
      ThreatClassification(
        type: 'Blackmail with Threats',
        confidence: 92,
        severity: 'High',
      ),
      ThreatClassification(
        type: 'Online Harassment',
        confidence: 87,
        severity: 'High',
      ),
    ];

    List<String> keyPhrases = [
      '"will share your photos"',
      '"pay me 50,000 rupees"',
      '"I know where you live"',
      '"you will regret this"',
    ];

    return ExtractedEvidence(
      timestamps: timestamps,
      phoneNumbers: phoneNumbers,
      urls: urls,
      threats: threats,
      keyPhrases: keyPhrases,
      totalFilesAnalyzed: widget.uploadedFiles.length,
    );
  }

  void _useInFIAComplaint() {
    // Navigate to FIA complaint generation with extracted data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening FIA Complaint with evidence...'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF00401A),
      ),
    );

    // In a real implementation, this would navigate to a complaint form
    // pre-populated with the extracted evidence data
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _exportAsPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting evidence as PDF...'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF00401A),
      ),
    );
    // In a real app, this would generate and share a PDF
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
          'Extracted Evidence',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Threat Classifications
              if (_extractedEvidence.threats.isNotEmpty) ...[
                for (var threat in _extractedEvidence.threats)
                  _buildThreatCard(threat),
                const SizedBox(height: 24),
              ],

              // Extracted Timestamps
              if (_extractedEvidence.timestamps.isNotEmpty) ...[
                _buildSectionHeader('Extracted Timestamps', Icons.access_time),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _extractedEvidence.timestamps
                        .map((timestamp) => _buildTimestampItem(timestamp))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Phone Numbers
              if (_extractedEvidence.phoneNumbers.isNotEmpty) ...[
                _buildSectionHeader('Phone Numbers Found', Icons.phone),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _extractedEvidence.phoneNumbers
                        .map((phone) => _buildPhoneItem(phone))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // URLs/Links
              if (_extractedEvidence.urls.isNotEmpty) ...[
                _buildSectionHeader('URLs/Links Found', Icons.link),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: _extractedEvidence.urls
                        .map((url) => _buildUrlItem(url))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Key Threatening Phrases
              if (_extractedEvidence.keyPhrases.isNotEmpty) ...[
                _buildSectionHeader(
                  'Key Threatening Phrases',
                  Icons.warning_amber,
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _extractedEvidence.keyPhrases
                        .map((phrase) => _buildPhraseItem(phrase))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _useInFIAComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00401A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description),
                      SizedBox(width: 8),
                      Text(
                        'Use in FIA Complaint',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _exportAsPDF,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF00401A), width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, color: Color(0xFF00401A)),
                      SizedBox(width: 8),
                      Text(
                        'Export as PDF',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00401A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Important Notice
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[700]!),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This evidence is court-admissible. Keep original files safe and secure.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThreatCard(ThreatClassification threat) {
    Color severityColor = threat.severity == 'High'
        ? Colors.red
        : threat.severity == 'Medium'
        ? Colors.orange
        : Colors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_rounded, color: severityColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  threat.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${threat.severity} Risk • ${threat.confidence}% confidence',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF00401A), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampItem(String timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.schedule, size: 20, color: const Color(0xFF00401A)),
          const SizedBox(width: 12),
          Text(
            timestamp,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneItem(String phone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.phone, size: 20, color: const Color(0xFF00401A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phone,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontFamily: 'Courier',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: phone));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Icon(Icons.content_copy, size: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlItem(String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.link, size: 20, color: const Color(0xFF00401A)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1976D2),
                fontFamily: 'Courier',
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhraseItem(String phrase) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 20, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              phrase,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExtractedEvidence {
  final List<String> timestamps;
  final List<String> phoneNumbers;
  final List<String> urls;
  final List<ThreatClassification> threats;
  final List<String> keyPhrases;
  final int totalFilesAnalyzed;

  ExtractedEvidence({
    required this.timestamps,
    required this.phoneNumbers,
    required this.urls,
    required this.threats,
    required this.keyPhrases,
    required this.totalFilesAnalyzed,
  });
}

class ThreatClassification {
  final String type;
  final int confidence;
  final String severity;

  ThreatClassification({
    required this.type,
    required this.confidence,
    required this.severity,
  });
}
