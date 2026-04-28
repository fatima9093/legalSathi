import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import 'package:front_end/l10n/app_localizations.dart';

import 'file_general_complaint_screen.dart';
import 'file_labour_complaint_screen.dart';
import '../screen_with_nav.dart';
import '../utils/validators.dart';
import 'package:front_end/services/challan_text_extraction_service.dart';
import 'package:front_end/services/contract_analysis_service.dart';

class ContractViolationCheckerScreen extends StatefulWidget {
  const ContractViolationCheckerScreen({super.key});

  @override
  State<ContractViolationCheckerScreen> createState() =>
      _ContractViolationCheckerScreenState();
}

class _ContractViolationCheckerScreenState
    extends State<ContractViolationCheckerScreen> {
  final TextEditingController _contractTextController = TextEditingController();

  Uint8List? _pickedBytes;
  String? _pickedFileName;
  String _pickedKind = '';

  bool _extracting = false;
  bool _analyzing = false;
  bool _showResult = false;

  ContractAnalysisResult? _analysis;

  static const int _maxBytes = 10 * 1024 * 1024;

  @override
  void dispose() {
    _contractTextController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final f = result.files.first;
      Uint8List? bytes = f.bytes;
      if (bytes == null && f.path != null && !kIsWeb) {
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }
      if (bytes == null) {
        _toast('Could not read the PDF.');
        return;
      }
      if (bytes.length > _maxBytes) {
        _toast('File exceeds 10 MB.');
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedFileName = f.name.isNotEmpty ? f.name : 'contract.pdf';
        _pickedKind = 'pdf';
      });
    } catch (e) {
      _toast('Error picking PDF: $e');
    }
  }

  Future<void> _pickImageGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final f = result.files.first;
      Uint8List? bytes = f.bytes;
      if (bytes == null && f.path != null && !kIsWeb) {
        try {
          bytes = await XFile(f.path!).readAsBytes();
        } catch (_) {}
      }
      if (bytes == null) {
        _toast('Could not read the image.');
        return;
      }
      if (bytes.length > _maxBytes) {
        _toast('File exceeds 10 MB.');
        return;
      }
      setState(() {
        _pickedBytes = bytes;
        _pickedFileName = f.name.isNotEmpty ? f.name : 'contract.jpg';
        _pickedKind = 'image';
      });
    } catch (e) {
      _toast('Error picking image: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  void _removeFile() {
    setState(() {
      _pickedBytes = null;
      _pickedFileName = null;
      _pickedKind = '';
    });
  }

  Future<void> _analyzeContract() async {
    var combined = _contractTextController.text.trim();

    if (combined.isEmpty && _pickedBytes == null) {
      Validators.showError(
        context,
        'Paste contract text or upload a PDF / image.',
      );
      return;
    }

    setState(() {
      _extracting = _pickedBytes != null;
      _analyzing = true;
    });

    if (_pickedBytes != null && _pickedFileName != null) {
      final ft = _pickedKind == 'pdf' ? 'pdf' : 'image';
      final extracted = await ChallanTextExtractionService.extractRawText(
        bytes: _pickedBytes!,
        fileName: _pickedFileName!,
        fileType: ft,
      );
      if (!mounted) return;
      if (extracted.isEmpty && combined.isEmpty) {
        setState(() {
          _extracting = false;
          _analyzing = false;
        });
        Validators.showError(
          context,
          'Could not read text from the file. Try another scan, a text-based PDF, or paste the contract text. '
          'If you use a PDF, ensure the backend extract service is running (for desktop builds) or use an image.',
        );
        return;
      }
      if (extracted.isNotEmpty) {
        combined = combined.isEmpty
            ? extracted
            : '$combined\n\n--- Text extracted from document ---\n$extracted';
        _contractTextController.text = combined;
      }
    }

    if (!mounted) return;
    setState(() {
      _extracting = false;
    });

    final result = ContractAnalysisService.analyze(combined);

    if (!mounted) return;
    if (result.insufficientText) {
      setState(() {
        _analyzing = false;
      });
      Validators.showError(
        context,
        result.insufficientMessage ?? 'More text needed.',
      );
      return;
    }
    setState(() {
      _analyzing = false;
      _analysis = result;
      _showResult = true;
    });
  }

  List<String> _recommendationsForResult(ContractAnalysisResult r) {
    if (r.looksBroadlyCompliant) {
      return [
        'Keep a signed copy of the final contract and any amendments.',
        'Confirm pay, hours, and leave match what you agreed verbally.',
        'For disputes, document dates and communications with HR.',
      ];
    }
    return [
      'Ask the employer to revise unfair clauses before signing.',
      'Do not sign under pressure — seek a labour lawyer if needed.',
      'You may use Legal Sathi to draft a complaint or amendment request.',
      'Report serious breaches to the relevant Labour Department.',
    ];
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
        title: Text(
          AppLocalizations.of(context)!.contractViolationTitle,
          style: const TextStyle(
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
            'We extract text from PDFs and images (OCR), or use what you paste — then scan for common risky clauses.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.picture_as_pdf_outlined,
                  label: 'Upload PDF',
                  onTap: (_extracting || _analyzing) ? null : _pickPdf,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.image_outlined,
                  label: 'Upload Image',
                  onTap: (_extracting || _analyzing) ? null : _pickImageGallery,
                ),
              ),
            ],
          ),
          if (_pickedFileName != null) ...[
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
                    _pickedKind == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: const Color(0xFF00401A),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _pickedFileName!,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey.shade600, size: 18),
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
                    Icon(Icons.edit_note, color: Colors.grey.shade700, size: 20),
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
                    hintText: 'Paste your employment contract or key clauses here…',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
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
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                disabledBackgroundColor: Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: (_extracting || _analyzing) ? null : _analyzeContract,
              child: _analyzing || _extracting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _extracting ? 'Reading file…' : 'Analyze Contract',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            kIsWeb
                ? 'PDF text extraction may use your backend (same as challan OCR). Images use the browser; for best OCR use the mobile app.'
                : 'PDFs: server extract if configured; images: on-device OCR when available.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final r = _analysis;
    if (r == null || r.insufficientText) {
      return const SizedBox.shrink();
    }

    final compliant = r.looksBroadlyCompliant;
    final riskColor = compliant ? const Color(0xFF2E7D32) : Colors.orange.shade800;
    final riskLabel = compliant ? 'Looks broadly compliant' : 'Review recommended';
    final riskSub = compliant
        ? 'No obvious red-flag wording found in this excerpt.'
        : '${r.concerns.length} issue(s) worth a closer look';

    final recs = _recommendationsForResult(r);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showResult = false;
                _analysis = null;
              });
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: Colors.black, size: 24),
                SizedBox(width: 12),
                Text(
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
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: riskColor.withOpacity(0.35), width: 1.5),
            ),
            child: Row(
              children: [
                Icon(
                  compliant ? Icons.verified_outlined : Icons.warning_amber_rounded,
                  color: riskColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riskLabel,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: riskColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        riskSub,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              r.summary,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.45,
              ),
            ),
          ),
          if (r.positiveNotes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Positive signals in text',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            ...r.positiveNotes.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.add_circle_outline, size: 18, color: Color(0xFF00401A)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (r.concerns.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              compliant ? 'Minor notes' : 'Issues to review',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...r.concerns.map((violation) {
              IconData severityIcon;
              Color severityIconColor;
              switch (violation.severity) {
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
                            violation.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: severityIconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            violation.severity,
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
                      violation.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.description_outlined, color: Colors.grey.shade600, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            violation.law,
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
            }),
          ],
          const SizedBox(height: 20),
          const Text(
            'Suggested next steps',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...recs.asMap().entries.map((entry) {
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
          }),
          const SizedBox(height: 16),
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
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => FileGeneralComplaintScreen(
                      complaintIssue:
                          'Request regarding unfair or unclear terms in my employment contract. '
                          'I seek written clarification and amendment of clauses that may not comply with applicable labour laws.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Draft amendment / complaint (general)',
                style: TextStyle(
                  fontSize: 14,
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
                  MaterialPageRoute<void>(
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
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(
                icon,
                color: onTap == null ? Colors.grey : Colors.black87,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: onTap == null ? Colors.grey : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
