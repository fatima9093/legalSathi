import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:front_end/supabase_config.dart';
import 'splash_screen.dart';
import 'OnboardingScreen.dart';
import 'home_screen.dart';
import 'documents_screen.dart';
import 'chat_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal Sathi',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/documents': (context) => const DocumentsScreen(),
        '/profile': (context) =>
            const HomeScreen(),
      },
    );
  }
}
