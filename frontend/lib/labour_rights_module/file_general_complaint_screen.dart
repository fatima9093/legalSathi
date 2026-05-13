import 'package:flutter/material.dart';
import 'generated_complaint_screen.dart';
import '../screen_with_nav.dart';
import '../utils/validators.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/models/overtime_context.dart';
import 'package:front_end/models/wage_check_context.dart';
import 'package:front_end/services/labour_wage_record_service.dart';

class FileGeneralComplaintScreen extends StatefulWidget {
  final String? employerName;
  final String? complaintIssue;
  final DateTime? incidentDate;
  final WageCheckContext? wageCheckContext;
  final OvertimeContext? overtimeContext;
  final bool fromDeniedLeaveFlow;

  const FileGeneralComplaintScreen({
    super.key,
    this.employerName,
    this.complaintIssue,
    this.incidentDate,
    this.wageCheckContext,
    this.overtimeContext,
    this.fromDeniedLeaveFlow = false,
  });

  @override
  State<FileGeneralComplaintScreen> createState() =>
      _FileGeneralComplaintScreenState();
}

class _FileGeneralComplaintScreenState
    extends State<FileGeneralComplaintScreen> {
  final TextEditingController _employerNameController = TextEditingController();
  final TextEditingController _complaintIssueController =
      TextEditingController();
  final TextEditingController _yourNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final LabourWageRecordService _labourWageService = LabourWageRecordService();

  DateTime? _selectedDate;

  bool get _isFormComplete {
    return _employerNameController.text.trim().isNotEmpty &&
        _complaintIssueController.text.trim().isNotEmpty &&
        _yourNameController.text.trim().isNotEmpty &&
        _contactController.text.trim().isNotEmpty &&
        _selectedDate != null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.employerName != null) {
      _employerNameController.text = widget.employerName!;
    }
    if (widget.complaintIssue != null && widget.complaintIssue!.isNotEmpty) {
      _complaintIssueController.text = widget.complaintIssue!;
    }
    if (widget.incidentDate != null) {
      _selectedDate = widget.incidentDate;
    }
    _employerNameController.addListener(() => setState(() {}));
    _complaintIssueController.addListener(() => setState(() {}));
    _yourNameController.addListener(() => setState(() {}));
    _contactController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _employerNameController.dispose();
    _complaintIssueController.dispose();
    _yourNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _showLabourRecordSaveFeedback(Map<String, dynamic> res) {
    final l10n = AppLocalizations.of(context)!;
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.complaintSavedMessage),
          backgroundColor: const Color(0xFF00401A),
        ),
      );
    } else if (res['needAuth'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.signInToSaveComplaint),
          backgroundColor: const Color(0xFFD97706),
        ),
      );
    } else if (res['missingTable'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.runSupabaseSqlMessage),
          backgroundColor: const Color(0xFFD97706),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF00401A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _generateComplaint() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_isFormComplete) {
      Validators.showError(context, l10n.fillAllFieldsError);
      return;
    }
    if (!Validators.isValidPhone(_contactController.text)) {
      Validators.showError(context, l10n.validContactError);
      return;
    }

    final wageCtx = widget.wageCheckContext;
    final otCtx = widget.overtimeContext;

    if (wageCtx != null) {
      final res = await _labourWageService.saveWageComplaint(
        ctx: wageCtx,
        employerName: _employerNameController.text.trim(),
        complaintIssue: _complaintIssueController.text.trim(),
      );
      if (!mounted) return;
      _showLabourRecordSaveFeedback(res);
    } else if (otCtx != null) {
      final res = await _labourWageService.saveOvertimeComplaint(
        ctx: otCtx,
        employerName: _employerNameController.text.trim(),
        complaintIssue: _complaintIssueController.text.trim(),
      );
      if (!mounted) return;
      _showLabourRecordSaveFeedback(res);
    } else if (widget.fromDeniedLeaveFlow) {
      final res = await _labourWageService.saveDeniedLeaveComplaint(
        employerName: _employerNameController.text.trim(),
        complaintIssue: _complaintIssueController.text.trim(),
      );
      if (!mounted) return;
      _showLabourRecordSaveFeedback(res);
    } else {
      final res = await _labourWageService.saveGeneralLabourComplaint(
        employerName: _employerNameController.text.trim(),
        complaintIssue: _complaintIssueController.text.trim(),
      );
      if (!mounted) return;
      _showLabourRecordSaveFeedback(res);
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedComplaintScreen(
          employerName: _employerNameController.text.trim(),
          complaintIssue: _complaintIssueController.text.trim(),
          incidentDate: _selectedDate!,
          yourName: _yourNameController.text.trim(),
          contactInfo: _contactController.text.trim(),
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
          l10n.draftComplaintTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Employer Name
            Text(
              l10n.employerNameLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _employerNameController,
              decoration: InputDecoration(
                hintText: l10n.employerNameHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Complaint Issue
            Text(
              // ✅ Use the plain section label key, NOT complaintIssueLabel(...)
              l10n.complaintIssueSectionLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _complaintIssueController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: l10n.complaintIssueHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
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
            ),

            const SizedBox(height: 20),

            // Your Name
            Text(
              l10n.yourNameLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yourNameController,
              decoration: InputDecoration(
                hintText: l10n.yourNameHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Contact Information
            Text(
              l10n.contactInfoLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: l10n.contactInfoHint,
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Incident Date
            Text(
              l10n.incidentDateLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? l10n.selectDateHint
                          : '${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDate == null
                            ? Colors.grey.shade400
                            : Colors.black87,
                      ),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: Colors.grey.shade700,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormComplete
                      ? const Color(0xFF00401A)
                      : Colors.grey.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isFormComplete ? _generateComplaint : null,
                child: Text(
                  l10n.generateComplaintButton,
                  style: const TextStyle(
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
      ),
    );
  }
}