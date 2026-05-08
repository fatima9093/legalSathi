import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:front_end/l10n/app_localizations.dart';

import 'traffic_police_contacts.dart';

class TrafficContactLauncher {
  TrafficContactLauncher._();

  static Future<void> _launch(
    BuildContext context,
    Uri uri, {
    String? errorMessage,
  }) async {
    final loc = AppLocalizations.of(context)!;

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? loc.couldNotOpenLink),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.errorOpeningLink(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> dial(BuildContext context, String numberDigits) async {
    final loc = AppLocalizations.of(context)!;

    final cleaned = numberDigits.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);

    await _launch(
      context,
      uri,
      errorMessage: loc.cannotStartCall,
    );
  }

  static Future<void> whatsAppComplaint(BuildContext context) async {
    final phone = TrafficPoliceContacts.whatsappComplaintE164;
    final text = Uri.encodeComponent(
      AppLocalizations.of(context)!.whatsappComplaintMessage,
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
    final loc = AppLocalizations.of(context)!;

    final offices = <_OfficeAddress>[
      _OfficeAddress(
        title: loc.lahoreTrafficHQ,
        address: loc.lahoreTrafficDesc,
        mapsQuery: 'Traffic Police Headquarters Lahore',
      ),
      _OfficeAddress(
        title: loc.karachiTrafficHQ,
        address: loc.karachiTrafficDesc,
        mapsQuery: 'Traffic Police Headquarters Karachi',
      ),
      _OfficeAddress(
        title: loc.islamabadTrafficHQ,
        address: loc.islamabadTrafficDesc,
        mapsQuery: 'ICT Traffic Police Office Islamabad',
      ),
      _OfficeAddress(
        title: loc.onlinePunjabComplaint,
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
        final loc = AppLocalizations.of(ctx)!;

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
                Text(
                  loc.writtenComplaintTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loc.verifyWithOfficialSources,
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
                              icon: const Icon(Icons.copy, size: 22),
                              onPressed: () async {
                                await Clipboard.setData(
                                  ClipboardData(text: o.address),
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(loc.copiedToClipboard),
                                      backgroundColor: const Color(0xFF00401A),
                                    ),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                o.isUrl
                                    ? Icons.open_in_new
                                    : Icons.map_outlined,
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