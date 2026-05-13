import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:front_end/l10n/app_localizations.dart';

import 'challan_data_model.dart';

class ChallanPayOnlineScreen extends StatelessWidget {
  final ChallanData challanData;

  const ChallanPayOnlineScreen({super.key, required this.challanData});

  static final List<_PayPortal> _portals = [
    _PayPortal(
      titleKey: 'punjab_psca',
      subtitleKey: 'punjab_psca_subtitle',
      uri: Uri.parse('https://psca.gop.pk'),
    ),
    _PayPortal(
      titleKey: 'punjab_police',
      subtitleKey: 'punjab_police_subtitle',
      uri: Uri.parse('https://punjabpolice.gov.pk'),
    ),
    _PayPortal(
      titleKey: 'ict_police',
      subtitleKey: 'ict_police_subtitle',
      uri: Uri.parse('https://ictpolice.gov.pk'),
    ),
    _PayPortal(
      titleKey: 'sindh_police',
      subtitleKey: 'sindh_police_subtitle',
      uri: Uri.parse('https://sindhpolice.gov.pk'),
    ),
  ];

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.couldNotOpenLink),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.errorOpeningLink(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
          loc.payChallanOnline,
          style: const TextStyle(
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
                color: const Color(0xFF00401A).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.nextStep,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00401A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.useOfficialPortals,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            loc.challanNumberTitle,
            style: const TextStyle(
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
                Clipboard.setData(
                  ClipboardData(text: challanData.challanNumber),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.challanCopied),
                    backgroundColor: const Color(0xFF00401A),
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

          Text(
            loc.openPaymentPortal,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            loc.selectProvincePortal,
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
                    _getTitle(context, p.titleKey),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(_getSubtitle(context, p.subtitleKey)),
                  trailing: const Icon(
                    Icons.open_in_new,
                    color: Color(0xFF00401A),
                  ),
                  onTap: () => _open(context, p.uri),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            loc.fineShown(challanData.fineAmount),
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _getTitle(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'punjab_psca':
        return loc.punjabPsca;
      case 'punjab_police':
        return loc.punjabPolice;
      case 'ict_police':
        return loc.ictPolice;
      case 'sindh_police':
        return loc.sindhPolice;
      default:
        return '';
    }
  }

  String _getSubtitle(BuildContext context, String key) {
    final loc = AppLocalizations.of(context)!;
    switch (key) {
      case 'punjab_psca':
        return loc.punjabPscaSubtitle;
      case 'punjab_police':
        return loc.punjabPoliceSubtitle;
      case 'ict_police':
        return loc.ictPoliceSubtitle;
      case 'sindh_police':
        return loc.sindhPoliceSubtitle;
      default:
        return '';
    }
  }
}

class _PayPortal {
  final String titleKey;
  final String subtitleKey;
  final Uri uri;

  _PayPortal({
    required this.titleKey,
    required this.subtitleKey,
    required this.uri,
  });
}
