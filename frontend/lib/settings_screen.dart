import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:front_end/providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _voiceMode = true;
  bool _notifications = true;
  bool _darkMode = false;
  String _selectedLanguage = 'English'; // ← still kept for local display

  @override
  void initState() {
    super.initState();
    // ← Load the globally saved language on screen open
    _selectedLanguage = context.read<LanguageProvider>().languageString;
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
        title:  Text((AppLocalizations.of(context)!.settings),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Language
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.language,
                          color: Colors.black87,
                          size: 24,
                        ),
                        title: Text(AppLocalizations.of(context)!.language,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Text(
                          _selectedLanguage, // ← shows current language
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          _showLanguageDialog();
                        },
                      ),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Voice Mode
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.volume_up,
                          color: Colors.black87,
                          size: 24,
                        ),
                        title: Text(AppLocalizations.of(context)!.voiceMode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Switch(
                          value: _voiceMode,
                          onChanged: (value) {
                            setState(() {
                              _voiceMode = value;
                            });
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF00401A),
                        ),
                      ),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Notifications
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.black87,
                          size: 24,
                        ),
                        title: Text(AppLocalizations.of(context)!.notifications,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Switch(
                          value: _notifications,
                          onChanged: (value) {
                            setState(() {
                              _notifications = value;
                            });
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF00401A),
                        ),
                      ),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),

                      // Dark Mode
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: const Icon(
                          Icons.dark_mode_outlined,
                          color: Colors.black87,
                          size: 24,
                        ),
                        title:  Text(AppLocalizations.of(context)!.darkMode,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: (value) {
                            setState(() {
                              _darkMode = value;
                            });
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF00401A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version info
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: Text(
              AppLocalizations.of(context)!.appVersion,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final langProvider = context.read<LanguageProvider>(); // ← NEW

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ← Added Roman Urdu option, fixed Urdu string mismatch
            ListTile(
              title:  Text(AppLocalizations.of(context)!.english),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: Color(0xFF00401A))
                  : null,
              onTap: () {
                langProvider.changeLanguage('English'); // ← NEW
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title:  Text(AppLocalizations.of(context)!.romanUrdu),
              trailing: _selectedLanguage == 'Roman Urdu'
                  ? const Icon(Icons.check, color: Color(0xFF00401A))
                  : null,
              onTap: () {
                langProvider.changeLanguage('Roman Urdu'); // ← NEW
                setState(() {
                  _selectedLanguage = 'Roman Urdu';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.urdu),
              trailing: _selectedLanguage == 'Urdu'
                  ? const Icon(Icons.check, color: Color(0xFF00401A))
                  : null,
              onTap: () {
                langProvider.changeLanguage('Urdu'); // ← NEW
                setState(() {
                  _selectedLanguage = 'Urdu';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}