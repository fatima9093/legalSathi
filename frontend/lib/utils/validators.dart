import 'package:flutter/material.dart';

class Validators {
  static bool isNonEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  static bool isValidEmail(String? value) {
    if (!isNonEmpty(value)) return false;
    final email = value!.trim();
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  static bool isValidPhone(String? value) {
    if (!isNonEmpty(value)) return false;
    final phone = value!.replaceAll(RegExp(r'[^0-9+]'), '');
    return phone.length >= 10;
  }

  static bool isValidCnic(String? value) {
    if (!isNonEmpty(value)) return false;
    final cnic = value!.trim();
    final regex = RegExp(r'^\d{5}-\d{7}-\d$');
    return regex.hasMatch(cnic);
  }

  static bool isValidUrl(String? value) {
    if (!isNonEmpty(value)) return false;
    final url = value!.trim();
    return Uri.tryParse(url)?.hasAbsolutePath == true ||
        Uri.tryParse(url)?.isAbsolute == true;
  }

  static bool isPositiveNumber(String? value) {
    if (!isNonEmpty(value)) return false;
    final numVal = double.tryParse(value!.trim());
    return numVal != null && numVal > 0;
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}
