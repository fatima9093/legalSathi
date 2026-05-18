import 'package:flutter/foundation.dart';

/// Central backend URL for phone ↔ laptop HTTP (seminar / local dev).
///
/// **Physical phone + laptop server:** set [laptopHost] to your laptop Wi-Fi
/// IPv4 (`ipconfig` on Windows). Phone and laptop must be on the same Wi-Fi.
///
/// **Chrome on the same laptop:** uses `localhost` automatically.
///
/// **Android emulator:** run with
/// `flutter run --dart-define=API_HOST=10.0.2.2`
///
/// **Override anytime:**
/// `flutter run --dart-define=API_HOST=192.168.1.105`
class ApiConfig {
  /// ← Change this to your laptop IP before the seminar demo.
  static const String laptopHost = '192.168.1.215';

  static const int port = 8000;

  static String get host {
    const fromEnv = String.fromEnvironment('API_HOST');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) return 'localhost';
    return laptopHost;
  }

  static String get baseUrl => 'http://$host:$port';

  static String get apiBaseUrl => '$baseUrl/api';

  static String get askUrl => '$apiBaseUrl/ask';

  static String get askStreamUrl => '$apiBaseUrl/ask/stream';

  /// Shown in offline / connection error messages.
  static String get displayAddress => '$host:$port';
}
