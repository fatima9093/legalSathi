import 'package:flutter/material.dart';
import '../screen_with_nav.dart';

class TrafficOffenceTypesScreen extends StatelessWidget {
  const TrafficOffenceTypesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Traffic Offence Types',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header subtitle
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Text(
              'Common traffic violations and penalties',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildOffenceCard(
                      number: '01',
                      title: 'Over Speeding',
                      fine: 'Rs. 1,000 - 2,000',
                      severity: 'Medium',
                      severityColor: Colors.yellow.shade700,
                      severityBg: Colors.yellow.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '02',
                      title: 'No Helmet',
                      fine: 'Rs. 500',
                      severity: 'Low',
                      severityColor: Colors.green.shade700,
                      severityBg: Colors.green.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '03',
                      title: 'Red Light Violation',
                      fine: 'Rs. 1,000',
                      severity: 'High',
                      severityColor: Colors.red.shade700,
                      severityBg: Colors.red.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '04',
                      title: 'Wrong Way Driving',
                      fine: 'Rs. 2,000',
                      severity: 'High',
                      severityColor: Colors.red.shade700,
                      severityBg: Colors.red.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '05',
                      title: 'No Seat Belt',
                      fine: 'Rs. 500',
                      severity: 'Low',
                      severityColor: Colors.green.shade700,
                      severityBg: Colors.green.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '06',
                      title: 'Mobile Phone Use',
                      fine: 'Rs. 1,000',
                      severity: 'Medium',
                      severityColor: Colors.yellow.shade700,
                      severityBg: Colors.yellow.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '07',
                      title: 'No License',
                      fine: 'Rs. 5,000',
                      severity: 'High',
                      severityColor: Colors.red.shade700,
                      severityBg: Colors.red.shade100,
                    ),
                    const SizedBox(height: 12),
                    _buildOffenceCard(
                      number: '08',
                      title: 'Parking Violation',
                      fine: 'Rs. 200 - 500',
                      severity: 'Low',
                      severityColor: Colors.green.shade700,
                      severityBg: Colors.green.shade100,
                    ),
                    const SizedBox(height: 16),

                    // Info box at bottom
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.amber.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Fines may vary by province. Repeat offences carry higher penalties.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade900,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: buildBottomNavBar(context, 2),
    );
  }

  Widget _buildOffenceCard({
    required String number,
    required String title,
    required String fine,
    required String severity,
    required Color severityColor,
    required Color severityBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Number badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fine:  $fine',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: severityBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        severity,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: severityColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Severity',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: severityColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
