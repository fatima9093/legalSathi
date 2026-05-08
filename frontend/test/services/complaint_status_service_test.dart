import 'package:flutter_test/flutter_test.dart';
import 'package:front_end/models/complaint_status_model.dart';
import 'package:front_end/models/error_models.dart';
import 'package:front_end/services/complaint_status_service.dart';
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

  group('ComplaintStatusService', () {
    test(
      'getComplaintStatus returns unauthorized when no user is signed in',
      () async {
        final service = ComplaintStatusService();

        final result = await service.getComplaintStatus('complaint-id');

        expect(result.isSuccess, isFalse);
        expect(result.error?.type, ErrorType.unauthorized);
      },
    );

    test(
      'updateComplaintStatus returns unauthorized when no user is signed in',
      () async {
        final service = ComplaintStatusService();

        final result = await service.updateComplaintStatus(
          complaintId: 'complaint-id',
          newStatus: ComplaintStatus.underReview,
        );

        expect(result.isSuccess, isFalse);
        expect(result.error?.type, ErrorType.unauthorized);
      },
    );
  });
}
