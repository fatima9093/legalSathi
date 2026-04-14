import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'traffic_police_contacts.dart';

/// Phone, WhatsApp, web, maps, and address sheet for traffic police complaint flows.
class TrafficContactLauncher {
  TrafficContactLauncher._();

  static Future<void> _launch(
    BuildContext context,
    Uri uri, {
    String? errorMessage,
  }) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage ?? 'Could not open this link on this device.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> dial(BuildContext context, String numberDigits) async {
    final cleaned = numberDigits.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    await _launch(
      context,
      uri,
      errorMessage: 'Cannot start a call on this device.',
    );
  }

  static Future<void> whatsAppComplaint(BuildContext context) async {
    final phone = TrafficPoliceContacts.whatsappComplaintE164;
    final text = Uri.encodeComponent(
      'Assalam-o-Alaikum. I wish to file a complaint regarding traffic police conduct. '
      '(Sent via Legal Sathi app — please advise next steps.)',
    );
    await _launch(
      context,
      Uri.parse('https://wa.me/$phone?text=$text'),
    );
  }

  static Future<void> openHttpUrl(BuildContext context, String url) async {
    await _launch(context, Uri.parse(url));
  }

  static Future<void> openMapsSearch(
    BuildContext context,
    String query,
  ) async {
    final q = Uri.encodeComponent(query);
    await _launch(
      context,
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$q'),
    );
  }

  static void showWrittenComplaintAddressesSheet(BuildContext context) {
    final offices = <_OfficeAddress>[
      _OfficeAddress(
        title: 'Lahore — Traffic HQ (indicative)',
        address:
            'Confirm the current SP Traffic / submission desk on Punjab Police website or your challan.',
        mapsQuery: 'Traffic Police Headquarters Lahore',
      ),
      _OfficeAddress(
        title: 'Karachi — Traffic Police (indicative)',
        address:
            'Use the address or portal printed on your notice or sindhpolice.gov.pk.',
        mapsQuery: 'Traffic Police Headquarters Karachi',
      ),
      _OfficeAddress(
        title: 'Islamabad — ICT Traffic',
        address:
            'Follow ICT Police citizen services or the office named on your document.',
        mapsQuery: 'ICT Traffic Police Office Islamabad',
      ),
      _OfficeAddress(
        title: 'Online — Punjab complaint portal',
        address: TrafficPoliceContacts.punjabOnlineComplaint,
        isUrl: true,
      ),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Written complaint — addresses & links',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verify with your official challan or provincial police site.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: offices.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final o = offices[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          o.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SelectableText(
                            o.address,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade800,
                              height: 1.35,
                            ),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Copy',
                              icon: const Icon(Icons.copy, size: 22),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: o.address),
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Copied to clipboard'),
                                      backgroundColor: Color(0xFF00401A),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              tooltip: o.isUrl ? 'Open link' : 'Open in Maps',
                              icon: Icon(
                                o.isUrl ? Icons.open_in_new : Icons.map_outlined,
                                size: 22,
                              ),
                              onPressed: () {
                                if (o.isUrl) {
                                  openHttpUrl(context, o.address);
                                } else {
                                  openMapsSearch(
                                    context,
                                    o.mapsQuery ?? o.title,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OfficeAddress {
  final String title;
  final String address;
  final String? mapsQuery;
  final bool isUrl;

  _OfficeAddress({
    required this.title,
    required this.address,
    this.mapsQuery,
    this.isUrl = false,
  });
}
