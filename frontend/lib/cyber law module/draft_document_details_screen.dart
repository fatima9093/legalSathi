import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../screen_with_nav.dart';
import '../l10n/app_localizations.dart';
import 'draft_document_review_screen.dart';

class DraftDocumentDetailsScreen extends StatefulWidget {
  final String documentType;
  final String extractedText;
  final String classifiedDomain;
  final List<String> tags;

  const DraftDocumentDetailsScreen({
    super.key,
    required this.documentType,
    required this.extractedText,
    required this.classifiedDomain,
    required this.tags,
  });

  @override
  State<DraftDocumentDetailsScreen> createState() =>
      _DraftDocumentDetailsScreenState();
}

class _DraftDocumentDetailsScreenState
    extends State<DraftDocumentDetailsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  bool get _isFormComplete =>
      _nameController.text.trim().isNotEmpty &&
      _cnicController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _dateController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
    _cnicController.addListener(() => setState(() {}));
    _addressController.addListener(() => setState(() {}));
    _dateController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnicController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  void _continueToReview() {
    final l10n = AppLocalizations.of(context)!;

    if (!_isFormComplete) {
      Validators.showError(context, l10n.pleaseFillFields);
      return;
    }

    if (!Validators.isValidCnic(_cnicController.text)) {
      Validators.showError(context, l10n.cnicFormatError);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DraftDocumentReviewScreen(
          documentType: widget.documentType,
          complaintantName: _nameController.text.trim(),
          cnic: _cnicController.text.trim(),
          address: _addressController.text.trim(),
          incidentDate: _dateController.text.trim(),
          extractedText: widget.extractedText,
          classifiedDomain: widget.classifiedDomain,
          tags: widget.tags,
        ),
      ),
    );
  }

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
        title: Text(
          l10n.draftDocumentTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.enterDetailsTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            _buildField(
              label: l10n.complainantName,
              hint: l10n.enterFullName,
              controller: _nameController,
              icon: Icons.person,
            ),

            const SizedBox(height: 16),

            _buildField(
              label: l10n.cnicNumber,
              hint: l10n.cnicHint,
              controller: _cnicController,
              icon: Icons.credit_card,
              inputType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            _buildField(
              label: l10n.address,
              hint: l10n.enterAddress,
              controller: _addressController,
              icon: Icons.location_on,
            ),

            const SizedBox(height: 16),

            Text(l10n.incidentDate),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  _dateController.text.isEmpty
                      ? l10n.incidentDate
                      : _dateController.text,
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isFormComplete ? _continueToReview : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00401A),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(l10n.continueButton),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(l10n.backButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}