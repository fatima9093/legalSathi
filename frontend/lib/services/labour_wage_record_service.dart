import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:front_end/models/overtime_context.dart';
import 'package:front_end/models/wage_check_context.dart';

/// Persists labour flows to [labour_wage_records] (minimum wage, back pay, overtime).
class LabourWageRecordService {
  SupabaseClient get _client => Supabase.instance.client;

  String? get _userId =>
      _client.auth.currentSession?.user.id ?? _client.auth.currentUser?.id;

  bool _isMissingTable(Object e) {
    final s = e.toString();
    return s.contains('Could not find the table') ||
        s.contains('schema cache') ||
        s.contains('42P01') ||
        (s.contains('labour_wage_records') &&
            (s.contains('not find') || s.contains('does not exist')));
  }

  Future<Map<String, dynamic>> saveBackPay({
    required String province,
    required String workerType,
    required double monthlySalary,
    required double legalMinimumWage,
    required bool meetsMinimum,
    required double monthlyShortfall,
    required int monthsOwed,
    required double totalBackPay,
  }) async {
    return _insert({
      'record_type': 'back_pay',
      'province': province,
      'worker_type': workerType,
      'monthly_salary': monthlySalary,
      'legal_minimum_wage': legalMinimumWage,
      'meets_minimum': meetsMinimum,
      'monthly_shortfall': monthlyShortfall,
      'months_owed': monthsOwed,
      'total_back_pay': totalBackPay,
    });
  }

  Future<Map<String, dynamic>> saveWageComplaint({
    required WageCheckContext ctx,
    required String employerName,
    required String complaintIssue,
  }) async {
    return _insert({
      'record_type': 'wage_complaint',
      'province': ctx.province,
      'worker_type': ctx.workerType,
      'monthly_salary': ctx.userSalary,
      'legal_minimum_wage': ctx.legalMinimum,
      'meets_minimum': !ctx.isUnderpaid,
      'monthly_shortfall': ctx.monthlyShortfall,
      'complaint_issue': complaintIssue,
      'employer_name': employerName,
    });
  }

  /// Snapshot of overtime calculation (e.g. demand letter screen).
  Future<Map<String, dynamic>> saveOvertimeCalc(OvertimeContext ctx) async {
    return _insert({
      'record_type': 'overtime_calc',
      'monthly_salary': ctx.monthlySalary,
      'weekly_hours': ctx.weeklyHours,
      'overtime_hours': ctx.overtimeHoursPerMonth,
      'hourly_rate': ctx.hourlyRate,
      'legal_overtime_hourly_rate': ctx.legalOvertimeHourlyRate,
      'overtime_pay_total': ctx.totalOvertimePayOwed,
    });
  }

  Future<Map<String, dynamic>> saveOvertimeComplaint({
    required OvertimeContext ctx,
    required String employerName,
    required String complaintIssue,
  }) async {
    return _insert({
      'record_type': 'overtime_complaint',
      'monthly_salary': ctx.monthlySalary,
      'weekly_hours': ctx.weeklyHours,
      'overtime_hours': ctx.overtimeHoursPerMonth,
      'hourly_rate': ctx.hourlyRate,
      'legal_overtime_hourly_rate': ctx.legalOvertimeHourlyRate,
      'overtime_pay_total': ctx.totalOvertimePayOwed,
      'complaint_issue': complaintIssue,
      'employer_name': employerName,
    });
  }

  /// Hub: "File Labour Complaint (General)" → [FileGeneralComplaintScreen].
  Future<Map<String, dynamic>> saveGeneralLabourComplaint({
    required String employerName,
    required String complaintIssue,
  }) async {
    return _insert({
      'record_type': 'general_labour_complaint',
      'monthly_salary': 0,
      'employer_name': employerName,
      'complaint_issue': complaintIssue,
    });
  }

  /// Hub: "Denied Leave" → [FileDeniedLeaveComplaintScreen] → [FileGeneralComplaintScreen].
  Future<Map<String, dynamic>> saveDeniedLeaveComplaint({
    required String employerName,
    required String complaintIssue,
  }) async {
    return _insert({
      'record_type': 'denied_leave_complaint',
      'monthly_salary': 0,
      'employer_name': employerName,
      'complaint_issue': complaintIssue,
    });
  }

  Future<Map<String, dynamic>> _insert(Map<String, dynamic> row) async {
    final userId = _userId;
    if (userId == null) {
      return {
        'success': false,
        'needAuth': true,
        'message': 'Sign in to save to your account.',
      };
    }
    try {
      final res = await _client
          .from('labour_wage_records')
          .insert({
            'user_id': userId,
            ...row,
          })
          .select('id')
          .single();
      return {
        'success': true,
        'id': res['id']?.toString(),
      };
    } catch (e) {
      if (_isMissingTable(e)) {
        return {'success': false, 'missingTable': true};
      }
      return {'success': false, 'message': e.toString()};
    }
  }
}
