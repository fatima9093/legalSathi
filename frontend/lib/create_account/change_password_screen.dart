import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front_end/create_account/password_reset_done_screen.dart';
import 'package:front_end/create_account/signin_screen.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/services/supabase_auth_callback_handler.dart';

/// Change password — from Settings (signed in) or after email reset link.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.fromEmailReset = false});

  /// True when user opened the reset link from their email on the login flow.
  final bool fromEmailReset;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.fromEmailReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _verifyRecoverySession());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoggedIn());
    }
  }

  Future<void> _verifyRecoverySession() async {
    // Allow getSessionFromUrl (web) to finish establishing the recovery session.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    if (!_authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reset link expired or invalid. Request a new link from the login page.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _ensureLoggedIn() {
    if (!_authService.isLoggedIn && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    SupabaseAuthCallbackHandler.markChangePasswordScreenClosed();
    super.dispose();
  }

  String? _validatePassword(String? value, AppLocalizations loc) {
    if (value == null || value.isEmpty) {
      return loc.pleaseEnterPassword;
    }
    if (!_authService.isStrongPassword(value)) {
      return loc.passwordComplexity;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, AppLocalizations loc) {
    if (value == null || value.isEmpty) {
      return loc.pleaseConfirmPassword;
    }
    if (value != _passwordController.text) {
      return loc.passwordsDoNotMatch;
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    final loc = AppLocalizations.of(context)!;

    if (!_authService.isLoggedIn) {
      _ensureLoggedIn();
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final result = widget.fromEmailReset
        ? await _authService.completePasswordResetFromEmail(
            newPassword: _passwordController.text,
          )
        : await _authService.changePassword(
            newPassword: _passwordController.text,
          );

    if (result['success'] == true) {
      SupabaseAuthCallbackHandler.clearPendingPasswordRecovery();
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );

    if (result['success'] == true && mounted) {
      if (widget.fromEmailReset) {
        if (kIsWeb) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const PasswordResetDoneScreen()),
            (route) => false,
          );
        } else {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.check_circle, color: Color(0xFF00401A), size: 48),
              title: Text(loc.passwordResetSuccessTitle),
              content: Text(loc.passwordResetSuccessMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(loc.goToSignIn),
                ),
              ],
            ),
          );
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
          );
        }
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.fromEmailReset,
        leading: widget.fromEmailReset
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF00401A)),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          loc.changePassword,
          style: const TextStyle(
            color: Color(0xFF00401A),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Icon(Icons.lock_reset, size: 64, color: Color(0xFF00401A)),
                const SizedBox(height: 24),
                Text(
                  loc.resetPasswordTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00401A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.resetPasswordSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                Text(
                  loc.passwordLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  validator: (v) => _validatePassword(v, loc),
                  decoration: _fieldDecoration(
                    hint: loc.passwordHint,
                    suffix: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.passwordRule,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                Text(
                  loc.confirmPassword,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (v) => _validateConfirmPassword(v, loc),
                  decoration: _fieldDecoration(
                    hint: loc.confirmPassword,
                    suffix: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () => setState(
                        () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00401A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            loc.setNewPassword,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required Widget suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00401A), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: suffix,
    );
  }
}
