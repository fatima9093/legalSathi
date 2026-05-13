import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/create_account/signin_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'generated_application_screen.dart';
import '../screen_with_nav.dart';
import '../utils/validators.dart';

class DraftLabourApplicationScreen extends StatefulWidget {
  const DraftLabourApplicationScreen({super.key});

  @override
  State<DraftLabourApplicationScreen> createState() =>
      _DraftLabourApplicationScreenState();
}

class _DraftLabourApplicationScreenState
    extends State<DraftLabourApplicationScreen> {
  final TextEditingController _employerNameController = TextEditingController();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _employeeContactController =
      TextEditingController();
  final TextEditingController _issueDescriptionController =
      TextEditingController();
  final TextEditingController _relevantDatesController =
      TextEditingController();

  bool get _isFormComplete {
    return _employerNameController.text.trim().isNotEmpty &&
        _employeeNameController.text.trim().isNotEmpty &&
        _employeeContactController.text.trim().isNotEmpty &&
        _issueDescriptionController.text.trim().isNotEmpty &&
        _relevantDatesController.text.trim().isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _employerNameController.addListener(() => setState(() {}));
    _employeeNameController.addListener(() => setState(() {}));
    _employeeContactController.addListener(() => setState(() {}));
    _issueDescriptionController.addListener(() => setState(() {}));
    _relevantDatesController.addListener(() => setState(() {}));

    // Check guest access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGuestAccess();
    });
  }

  void _checkGuestAccess() {
    final isGuest = Supabase.instance.client.auth.currentUser == null;
    if (isGuest && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Sign In Required'),
          content: const Text(
            'Filing labour complaints requires an account to save your information and track your request status. Please sign in to continue.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Exploring'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _employerNameController.dispose();
    _employeeNameController.dispose();
    _employeeContactController.dispose();
    _issueDescriptionController.dispose();
    _relevantDatesController.dispose();
    super.dispose();
  }

  void _generateApplication() {
    if (!_isFormComplete) {
      Validators.showError(context, 'Please fill all required fields.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GeneratedApplicationScreen(
          employerName: _employerNameController.text.trim(),
          employeeName: _employeeNameController.text.trim(),
          employeeContact: _employeeContactController.text.trim(),
          issueDescription: _issueDescriptionController.text.trim(),
          relevantDates: _relevantDatesController.text.trim(),
        ),
      ),
    );
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
          AppLocalizations.of(context)!.draftLabourApplicationTitle,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            // Document Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00401A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.description,
                size: 40,
                color: Color(0xFF00401A),
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              AppLocalizations.of(context)!.generateApplicationTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              AppLocalizations.of(context)!.generateApplicationSubtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Employer Name Field
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context)!.employerNameLabel} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _employerNameController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.companyNameHint,
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

            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${AppLocalizations.of(context)!.yourFullNameLabel} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _employeeNameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.asOnCnicHint,
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

            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${AppLocalizations.of(context)!.contactLabel} ',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _employeeContactController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.contactHint,
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

            // Issue Description Field
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Issue Description ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _issueDescriptionController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Describe the labour law violation in detail...',
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

            // Relevant Dates Field
            Align(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Relevant Dates ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: '*',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _relevantDatesController,
              decoration: InputDecoration(
                hintText: 'When did this occur?',
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

            const SizedBox(height: 32),

            // Generate Application Button
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
                onPressed: _isFormComplete ? _generateApplication : null,
                child: const Text(
                  'Generate Application',
                  style: TextStyle(
                    fontSize: 16,
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
