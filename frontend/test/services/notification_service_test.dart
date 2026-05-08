import 'package:flutter_test/flutter_test.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  group('NotificationService', () {
    test(
      'getNotifications returns unauthorized when no user is signed in',
      () async {
        final service = NotificationService();

        final result = await service.getNotifications();

        expect(result.isSuccess, isFalse);
        expect(result.error?.type, ErrorType.unauthorized);
      },
    );

    test(
      'getUnreadCount returns unauthorized when no user is signed in',
      () async {
        final service = NotificationService();

        final result = await service.getUnreadCount();

        expect(result.isSuccess, isFalse);
        expect(result.error?.type, ErrorType.unauthorized);
      },
    );

    test(
      'markAllAsRead returns unauthorized when no user is signed in',
      () async {
        final service = NotificationService();

        final result = await service.markAllAsRead();

        expect(result.isSuccess, isFalse);
        expect(result.error?.type, ErrorType.unauthorized);
      },
    );

    test('unsubscribeFromNotifications completes without throwing', () async {
      final service = NotificationService();

      await service.unsubscribeFromNotifications('user-id');
    });
  });
}
