import 'package:flutter/material.dart';

class ChallanData {
  final String challanNumber;
  final String vehicleNumber;
  final String violationType;
  final String fineAmount;
  final String issueLocation;
  final String officerId;
  final DateTime issueDate;
  final String violationDescription;
  final String legalReference;
  final List<String> paymentOptions;
  final String nearestOffice;
  final String appealProcess;

  ChallanData({
    required this.challanNumber,
    required this.vehicleNumber,
    required this.violationType,
    required this.fineAmount,
    required this.issueLocation,
    required this.officerId,
    required this.issueDate,
    required this.violationDescription,
    required this.legalReference,
    required this.paymentOptions,
    required this.nearestOffice,
    required this.appealProcess,
  });

  // Simulate OCR extraction - in real app, this would call an API
  static Future<ChallanData> extractFromImage(String filePath) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 3));

    // Return simulated OCR data
    return ChallanData(
      challanNumber:
          'LHR-2024-${DateTime.now().millisecondsSinceEpoch % 100000}',
      vehicleNumber: 'ABC-1234',
      violationType: 'Over Speeding',
      fineAmount: 'Rs. 2,000',
      issueLocation: 'Mall Road, Lahore',
      officerId: 'TW-4521',
      issueDate: DateTime.now().subtract(const Duration(days: 5)),
      violationDescription:
          'You were driving above the legal speed limit for that road. Over speeding is a serious traffic violation that endangers lives and is strictly enforced under the Motor Vehicle Ordinance 1965.\n\nSpeed limits exist to ensure road safety. Repeated violations can lead to license suspension and higher penalties.',
      legalReference:
          'The fine of Rs. 2,000 is correct according to Punjab Traffic Rules 2024. Over speeding violations carry a fine between Rs. 1,000 to Rs. 2,000 depending on severity.',
      paymentOptions: [
        '• Online: Visit psca.gop.pk or e-challan portal',
        '• Bank: Pay at any designated bank branch',
        '• Mobile App: Use Punjab Police app',
        '• Traffic Office: Visit nearest traffic police office',
      ],
      nearestOffice:
          'Traffic Police Office, Mall Road, Lahore\nOpen: Mon-Sat, 9 AM - 5 PM',
      appealProcess:
          'If you believe this challan was issued incorrectly, you have the right to appeal within 15 days.\n\n• Submit written appeal to SP Traffic\n• Include challan number and evidence\n• Provide your contact information\n• Decision within 30 days',
    );
  }

  // Get violation color based on type
  Color getViolationColor() {
    switch (violationType.toLowerCase()) {
      case 'over speeding':
        return const Color(0xFFD97706);
      case 'no helmet':
        return const Color(0xFFDC2626);
      case 'signal violation':
        return const Color(0xFFDC2626);
      case 'wrong parking':
        return const Color(0xFFEAB308);
      default:
        return const Color(0xFF00401A);
    }
  }
}
