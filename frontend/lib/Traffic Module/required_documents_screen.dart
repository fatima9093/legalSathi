import 'package:flutter/material.dart';

class RequiredDocumentsScreen extends StatelessWidget {
  const RequiredDocumentsScreen({super.key});

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
          'Required Documents',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Document icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EFEA),
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
              const Text(
                'Documents to Carry While Driving',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  children: const [
                    TextSpan(text: 'Always keep these documents in your '),
                    TextSpan(
                      text: 'vehicle',
                      style: TextStyle(
                        color: Color(0xFF00401A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Documents list
              _buildDocumentItem(
                title: 'Driving License',
                description: 'Must be valid and not expired',
                isRequired: true,
              ),

              const SizedBox(height: 12),

              _buildDocumentItem(
                title: 'Vehicle Registration',
                description: 'Original or certified copy',
                isRequired: true,
              ),

              const SizedBox(height: 12),

              _buildDocumentItem(
                title: 'Insurance Certificate',
                description: 'Valid third-party insurance minimum',
                isRequired: true,
              ),

              const SizedBox(height: 12),

              _buildDocumentItem(
                title: 'Route Permit',
                description: 'For commercial vehicles only',
                isRequired: false,
              ),

              const SizedBox(height: 12),

              _buildDocumentItem(
                title: 'Fitness Certificate',
                description: 'For vehicles over 3 years old',
                isRequired: false,
              ),

              const SizedBox(height: 12),

              _buildDocumentItem(
                title: 'Pollution Certificate',
                description: 'Valid emission test certificate',
                isRequired: true,
              ),

              const SizedBox(height: 24),

              // Warning message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Driving without required documents can result in Rs. 500-1000 fine',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem({
    required String title,
    required String description,
    required bool isRequired,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00401A), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.check, size: 14, color: Color(0xFF00401A)),
            ),
          ),

          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE6E6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    children: _buildDescriptionSpans(description),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildDescriptionSpans(String description) {
    // Highlight words like "vehicle", "vehicles", "valid"
    final words = description.split(' ');
    final List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final lowerWord = word.toLowerCase();

      if (lowerWord.contains('vehicle') || lowerWord == 'valid') {
        spans.add(
          TextSpan(
            text: i == words.length - 1 ? word : '$word ',
            style: const TextStyle(
              color: Color(0xFF00401A),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: i == words.length - 1 ? word : '$word '));
      }
    }

    return spans;
  }
}
