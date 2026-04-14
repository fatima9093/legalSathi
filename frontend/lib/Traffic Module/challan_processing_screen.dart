import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'challan_data_model.dart';
import 'challan_details_screen.dart';

class ChallanProcessingScreen extends StatefulWidget {
  final Uint8List bytes;
  final String fileName;
  final String fileType;

  const ChallanProcessingScreen({
    super.key,
    required this.bytes,
    required this.fileName,
    required this.fileType,
  });

  @override
  State<ChallanProcessingScreen> createState() =>
      _ChallanProcessingScreenState();
}

class _ChallanProcessingScreenState extends State<ChallanProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _progress = 0.0;
  String _statusLabel = 'Reading document…';

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 8), vsync: this)
          ..addListener(() {
            if (mounted) {
              setState(() {
                _progress = _controller.value;
              });
            }
          });

    _controller.forward();
    _runExtraction();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _runExtraction() async {
    try {
      if (mounted) {
        setState(() {
          _statusLabel = widget.fileType == 'pdf'
              ? 'Extracting text from PDF…'
              : 'Running OCR on image…';
        });
      }

      final challanData = await ChallanData.extractFromDocument(
        bytes: widget.bytes,
        fileName: widget.fileName,
        fileType: widget.fileType,
      );

      if (!mounted) return;

      _controller.value = 1.0;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChallanDetailsScreen(challanData: challanData),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not process challan: $e'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Processing Challan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00401A),
                  ),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Extracting Challan Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  children: const [
                    TextSpan(text: 'Please wait while '),
                    TextSpan(
                      text: 'AI reads',
                      style: TextStyle(
                        color: Color(0xFF00401A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' your challan'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00401A),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
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
}
