import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'challan_data_model.dart';

/// Official-style entry points for paying traffic challans (Pakistan).
/// URLs are public portals; update if your province changes domains.
class ChallanPayOnlineScreen extends StatelessWidget {
  final ChallanData challanData;

  const ChallanPayOnlineScreen({super.key, required this.challanData});

  static final List<_PayPortal> _portals = [
    _PayPortal(
      title: 'Punjab (PSCA / e-Challan)',
      subtitle: 'Safe Cities / Punjab digital challan services',
      uri: Uri.parse('https://psca.gop.pk'),
    ),
    _PayPortal(
      title: 'Punjab Police',
      subtitle: 'Provincial police website & services',
      uri: Uri.parse('https://punjabpolice.gov.pk'),
    ),
    _PayPortal(
      title: 'Islamabad Capital Police',
      subtitle: 'ICT traffic & challan information',
      uri: Uri.parse('https://ictpolice.gov.pk'),
    ),
    _PayPortal(
      title: 'Sindh Police',
      subtitle: 'Sindh traffic / citizen services',
      uri: Uri.parse('https://sindhpolice.gov.pk'),
    ),
  ];

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the link. Try copying the URL from your browser.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
        title: const Text(
          'Pay challan online',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7F0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00401A).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next step',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00401A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use only official government or police portals. Have your '
                  'challan number and vehicle details ready.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your challan number',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: challanData.challanNumber));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Challan number copied'),
                    backgroundColor: Color(0xFF00401A),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        challanData.challanNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.copy, color: Colors.grey.shade600, size: 22),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Open a payment portal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick your province or the site printed on your challan.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          ..._portals.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  title: Text(
                    p.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Text(p.subtitle),
                  trailing: const Icon(Icons.open_in_new, color: Color(0xFF00401A)),
                  onTap: () => _open(context, p.uri),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Fine shown in app: ${challanData.fineAmount}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _PayPortal {
  final String title;
  final String subtitle;
  final Uri uri;

  _PayPortal({
    required this.title,
    required this.subtitle,
    required this.uri,
  });
}
