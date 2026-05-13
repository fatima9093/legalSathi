import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'reporting_guidance_screen.dart';
import 'package:front_end/services/fake_account_report_service.dart';
import '../utils/validators.dart';

class ReportFakeAccountScreen extends StatefulWidget {
  const ReportFakeAccountScreen({super.key});

  @override
  State<ReportFakeAccountScreen> createState() =>
      _ReportFakeAccountScreenState();
}

class _ReportFakeAccountScreenState extends State<ReportFakeAccountScreen> {
  final _profileUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _selectedPlatform;
  List<PlatformFile> _uploadedFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _profileUrlController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool get _isFormComplete {
    bool hasProfileInfo =
        _profileUrlController.text.trim().isNotEmpty ||
        _usernameController.text.trim().isNotEmpty;
    bool hasPlatform = _selectedPlatform != null;
    return hasProfileInfo && hasPlatform;
  }

  Future<void> _uploadScreenshots() async {
    final loc = AppLocalizations.of(context)!;
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result == null) return;

      if (result.files.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
               content: Text(loc.noFilesSelected),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      setState(() {
        _uploadedFiles = result.files;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
             '${_uploadedFiles.length} ${loc.filesUploadedSuccess}',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.error}: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _proceedToGuidance() async {
    final loc = AppLocalizations.of(context)!;
    if (!_isFormComplete) {
      Validators.showError(
        context,
        'Please provide profile info and platform.',
      );
      return;
    }
    final url = _profileUrlController.text.trim();
    final username = _usernameController.text.trim();
    if (url.isNotEmpty && !Validators.isValidUrl(url)) {
       Validators.showError(context, loc.invalidUrl);
      return;
    }
    if (url.isEmpty && username.isEmpty) {
      Validators.showError(context, loc.provideUrlOrUsername);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final save = await FakeAccountReportService().saveReport(
      platform: _selectedPlatform!,
      profileUrl: _profileUrlController.text.trim(),
      username: _usernameController.text.trim(),
      evidenceFiles: _uploadedFiles,
    );

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    if (!(save['success'] as bool? ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(save['message'] as String? ?? loc.couldNotSaveReport),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportingGuidanceScreen(
          profileUrl: _profileUrlController.text.trim(),
          username: _usernameController.text.trim(),
          platform: _selectedPlatform!,
          uploadedFiles: _uploadedFiles,
          reportId: save['reportId'] as String?,
        ),
      ),
    );
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
          loc.reportFakeAccount,
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
            // Header Icon
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 48,
                    color: const Color(0xFF00401A),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.close, size: 20, color: Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title and subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    loc.reportFakeOrImpersonating,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.platformSpecificGuidance,
                    style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Account Details Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.accountDetails,

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Profile URL
                      Text(loc.profileUrl,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _profileUrlController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'https://facebook.com/fake-profile',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF9F9F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Username
                    Text(loc.username,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                       hintText: loc.usernameHint,
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF9F9F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Platform selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.platformRequired,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                              _buildPlatformButton(loc.facebook),
                              _buildPlatformButton(loc.instagram),
                              _buildPlatformButton(loc.twitter),
                              _buildPlatformButton(loc.tiktok),
                              _buildPlatformButton(loc.linkedin),
                              _buildPlatformButton(loc.other),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Upload Screenshots Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      loc.uploadScreenshotsRecommended,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Upload area
                    GestureDetector(
                      onTap: _uploadScreenshots,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              loc.fakeProfileScreenshots,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.image_outlined,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                      loc.uploadScreenshot,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Uploaded files list
                    if (_uploadedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        loc.uploadedScreenshots(_uploadedFiles.length),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._uploadedFiles.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 20,
                                  color: const Color(0xFF00401A),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.value.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${(entry.value.size / 1024).toStringAsFixed(1)} KB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _uploadedFiles.removeAt(entry.key);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Proceed Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_isFormComplete && !_isSubmitting)
                      ? _proceedToGuidance
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isFormComplete
                        ? const Color(0xFF00401A)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      :  Text(
                          loc.checkReportingSteps,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info message
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                 loc.pecaInfoMessage,
                style: TextStyle(fontSize: 13, color: Colors.blue.shade700),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformButton(String platform) {
    bool isSelected = _selectedPlatform == platform;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlatform = _selectedPlatform == platform ? null : platform;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00401A) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF00401A) : Colors.grey.shade300,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            platform,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
