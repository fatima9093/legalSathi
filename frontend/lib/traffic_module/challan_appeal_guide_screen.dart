import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import 'challan_data_model.dart';

/// Next steps after the user chooses to contest / appeal a challan.
class ChallanAppealGuideScreen extends StatelessWidget {
  final ChallanData challanData;

  const ChallanAppealGuideScreen({super.key, required this.challanData});

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
            content: Text(AppLocalizations.of(context)!.errorOccurred(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<String> _appealSteps() {
    final t = challanData.appealProcess.trim();
    if (t.isEmpty) return const [];
    return t
        .split(RegExp(r'\n\s*\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _appealSteps();
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
        AppLocalizations.of(context)!.fileAppeal,
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
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD966)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.nextStep,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context)!.appealGuidance,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(AppLocalizations.of(context)!.whatToDo,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (steps.isEmpty)
            Text(
              challanData.appealProcess,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.45),
            )
          else
            ...steps.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: Color(0xFF00401A),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${e.key + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          const SizedBox(height: 24),
          Text(AppLocalizations.of(context)!.officialReferences,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _linkTile(
            context,
            title: AppLocalizations.of(context)!.punjabPolice,
            subtitle: AppLocalizations.of(context)!.punjabPoliceSubtitle,
            uri: Uri.parse('https://punjabpolice.gov.pk'),
          ),
          _linkTile(
            context,
            title: AppLocalizations.of(context)!.islamabadPolice,

            subtitle:AppLocalizations.of(context)!.islamabadPoliceSubtitle,
            uri: Uri.parse('https://ictpolice.gov.pk'),
          ),
          _linkTile(
            context,
            title: AppLocalizations.of(context)!.sindhPolice,

            subtitle:AppLocalizations.of(context)!.sindhPoliceSubtitle,
            uri: Uri.parse('https://sindhpolice.gov.pk'),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.appealFooterNote,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _linkTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Uri uri,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.open_in_new, color: Color(0xFF00401A)),
          onTap: () => _open(context, uri),
        ),
      ),
    );
  }
}
