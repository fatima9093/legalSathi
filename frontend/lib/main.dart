import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';
import 'package:front_end/services/supabase_deep_link_handler.dart';
import 'package:front_end/services/auth_service.dart';
import 'package:front_end/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:front_end/supabase_config.dart';
import 'package:front_end/utils/smooth_transitions_observer.dart';
import 'providers/language_provider.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';
import 'screens/dynamic_documents_screen.dart';
import 'chat_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
  AuthService.initializeSessionExpiryMonitoring();
  if (!kIsWeb) {
    await SupabaseDeepLinkHandler.init();
  }
  await NotificationService().initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider()..loadSavedLanguage(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Legal Sathi',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      navigatorObservers: [SmoothTransitionsObserver()],

      // Localization
      locale: langProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ur'), Locale('ro')],
      builder: (context, child) {
        return Directionality(
          textDirection: langProvider.locale.languageCode == 'ur'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/chat': (context) => const ChatScreen(),
        '/documents': (context) => const DynamicDocumentsScreen(),
        '/profile': (context) => const HomeScreen(),
      },
    );
  }
}
