import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../screen_with_nav.dart';
import 'file_labour_complaint_screen.dart';
import '../utils/validators.dart';

class ContractViolationCheckerScreen extends StatefulWidget {
  const ContractViolationCheckerScreen({super.key});

  @override
  State<ContractViolationCheckerScreen> createState() =>
      _ContractViolationCheckerScreenState();
}

class _ContractViolationCheckerScreenState
    extends State<ContractViolationCheckerScreen> {
  final TextEditingController _contractTextController = TextEditingController();
  File? _uploadedFile;
  String? _filePath;
  bool _showResult = false;

  List<Map<String, dynamic>> _violations = [];
  List<String> _recommendations = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _contractTextController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(bool isPdf) async {
    try {
      final XFile? result = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (result != null) {
        setState(() {
          _uploadedFile = File(result.path);
          _filePath = result.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _analyzeContract() {
    final contractText = _contractTextController.text.trim();

    if (!Validators.isNonEmpty(contractText) && _uploadedFile == null) {
      Validators.showError(
        context,
        'Please paste contract text or upload a file.',
      );
      return;
    }

    // Analyze contract text for common violations
    _violations = [];
    _recommendations = [];

    // Check for common violations
    final lowerText = contractText.toLowerCase();

    // Violation 1: No overtime pay provision
    if (!lowerText.contains('overtime') &&
        !lowerText.contains('extra time') &&
        !lowerText.contains('2x')) {
      _violations.add({
        'title': 'No overtime pay provision',
        'description': 'Contract must specify overtime pay at 2x regular rate',
        'severity': 'Serious',
        'law': 'Factories Act 1934, Section 51',
      });
    }

    // Violation 2: Unpaid leave for first 6 months
    if (lowerText.contains('no leave') ||
        (lowerText.contains('first') &&
            lowerText.contains('6') &&
            lowerText.contains('month') &&
            !lowerText.contains('paid leave'))) {
      _violations.add({
        'title': 'Unpaid leave for first 6 months',
        'description':
            'Workers entitled to sick leave after 3 months under law',
        'severity': 'Moderate',
        'law': 'Shops & Establishments Act',
      });
    }

    // Violation 3: Termination without notice
    if ((lowerText.contains('terminate') ||
            lowerText.contains('termination')) &&
        !lowerText.contains('notice') &&
        !lowerText.contains('30 day')) {
      _violations.add({
        'title': 'Termination without notice',
        'description':
            'Minimum 30 days notice or pay in lieu is required by law',
        'severity': 'Serious',
        'law': 'Industrial Relations Ordinance 2002',
      });
    }

    // Violation 4: Excessive working hours
    if (lowerText.contains('24/7') ||
        lowerText.contains('unlimited') ||
        lowerText.contains('as needed')) {
      _violations.add({
        'title': 'Excessive working hours',
        'description': 'Standard work week is 48 hours. Cannot exceed 60 hours',
        'severity': 'Serious',
        'law': 'Factories Act 1934',
      });
    }

    // Violation 5: No health and safety provisions
    if (!lowerText.contains('health') &&
        !lowerText.contains('safety') &&
        !lowerText.contains('ppe') &&
        !lowerText.contains('insurance')) {
      _violations.add({
        'title': 'No health and safety provisions',
        'description': 'Contract must include workplace safety measures',
        'severity': 'Moderate',
        'law': 'Factories Act 1934, Part II',
      });
    }

    // If no violations found
    if (_violations.isEmpty) {
      _violations.add({
        'title': 'Contract appears compliant',
        'description':
            'No major violations detected in the provided contract text',
        'severity': 'Info',
        'law': 'Pakistani Labour Laws',
      });
    }

    // Add recommendations
    _recommendations = [
      'Request contract revision to include legal protections',
      'Do not sign until violations are corrected',
      'Consult a labour lawyer for detailed review',
      'Report to Labour Department if employer refuses changes',
    ];

    setState(() {
      _showResult = true;
    });
  }

  void _removeFile() {
    setState(() {
      _uploadedFile = null;
      _filePath = null;
    });
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
          'Contract Violation Checker',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: !_showResult ? _buildFormView() : _buildResultView(),
    );
  }

  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00401A).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description_outlined,
              color: Color(0xFF00401A),
              size: 40,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Upload or Paste Employment Contract',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Our AI will analyze for labour law violations',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 28),

          // Upload Options
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Upload PDF',
                  onTap: () => _pickFile(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.image_outlined,
                  label: 'Upload Image',
                  onTap: () => _pickFile(false),
                ),
              ),
            ],
          ),

          if (_filePath != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF00401A),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _filePath!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.grey.shade600,
                      size: 18,
                    ),
                    onPressed: _removeFile,
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 24),

          // Paste Text Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Paste Contract Text',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _contractTextController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Paste your employment contract here...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade400,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF00401A)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Analyze Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _analyzeContract,
              child: const Text(
                'Analyze Contract',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    // Calculate risk level
    int seriousCount = _violations
        .where((v) => v['severity'] == 'Serious')
        .length;
    int moderateCount = _violations
        .where((v) => v['severity'] == 'Moderate')
        .length;

    String riskLevel;
    Color riskColor;

    if (seriousCount >= 2) {
      riskLevel = 'High Risk';
      riskColor = Colors.red;
    } else if (seriousCount == 1 || moderateCount >= 2) {
      riskLevel = 'Medium Risk';
      riskColor = Colors.orange;
    } else if (_violations.isNotEmpty && _violations[0]['severity'] == 'Info') {
      riskLevel = 'Low Risk';
      riskColor = Colors.green;
    } else {
      riskLevel = 'Medium Risk';
      riskColor = Colors.orange;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button and title
          GestureDetector(
            onTap: () {
              setState(() {
                _showResult = false;
              });
            },
            child: Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Contract Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Risk Alert Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: riskColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riskLevel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_violations.length} labour law ${_violations.length == 1 ? 'violation' : 'violations'} detected',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Problematic Clauses Header
          const Text(
            'Problematic Clauses',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // Violations List
          ...(_violations.map((violation) {
            // Determine icon and color based on severity
            IconData severityIcon;
            Color severityIconColor;

            switch (violation['severity']) {
              case 'Serious':
                severityIcon = Icons.error;
                severityIconColor = Colors.red;
                break;
              case 'Moderate':
                severityIcon = Icons.warning_amber_rounded;
                severityIconColor = Colors.orange;
                break;
              default:
                severityIcon = Icons.info_outline;
                severityIconColor = Colors.blue;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(severityIcon, color: severityIconColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          violation['title'],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: severityIconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          violation['severity'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: severityIconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    violation['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Colors.grey.shade600,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          violation['law'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          })),

          const SizedBox(height: 24),

          // Recommended Actions
          const Text(
            'Recommended Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          ...(_recommendations.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00401A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        entry.value,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          })),

          const SizedBox(height: 20),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Draft amendment request
              },
              child: const Text(
                'Draft Contract Amendment Request',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF00401A)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FileLabourComplaintScreen(),
                  ),
                );
              },
              child: const Text(
                'File Labour Complaint',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00401A),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black87, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
