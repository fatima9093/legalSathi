import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Completes Supabase OAuth (Google) when the app opens via deep link.
class SupabaseDeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static StreamSubscription<Uri>? _subscription;

  static Future<void> init() async {
    if (kIsWeb) return;

    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (e) {
      debugPrint('SupabaseDeepLinkHandler initial link: $e');
    }

    await _subscription?.cancel();
    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (Object e) => debugPrint('SupabaseDeepLinkHandler stream: $e'),
    );
  }

  static Future<void> _handleUri(Uri uri) async {
    if (!_looksLikeAuthCallback(uri)) return;

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Supabase OAuth session restored from deep link');
    } catch (e) {
      debugPrint('Supabase getSessionFromUrl failed: $e');
    }
  }

  static bool _looksLikeAuthCallback(Uri uri) {
    final s = uri.toString();
    return s.contains('login-callback') ||
        uri.queryParameters.containsKey('code') ||
        uri.fragment.contains('access_token') ||
        (uri.host.contains('supabase.co') && uri.queryParameters.containsKey('code'));
  }

  static Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
