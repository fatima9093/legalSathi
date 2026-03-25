import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  String _languageString = 'English';

  Locale get locale => _locale;
  String get languageString => _languageString;

  // Call this on app start
  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String lang = prefs.getString('selected_language') ?? 'English';
    _setLocale(lang);
  }

  // Call this when user picks a language
  Future<void> changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    _setLocale(lang);
  }

  void _setLocale(String lang) {
    _languageString = lang;
    switch (lang) {
      case 'Urdu':
        _locale = const Locale('ur');
        break;
      case 'Roman Urdu':
        _locale = const Locale('ro');
        break;
      default:
        _locale = const Locale('en');
    }
    notifyListeners();
  }
}