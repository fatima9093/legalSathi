/// Carries overtime calculator results when filing a complaint or saving a demand letter.
class OvertimeContext {
  final double monthlySalary;
  final double weeklyHours;
  final double overtimeHoursPerMonth;
  final double hourlyRate;
  final double legalOvertimeHourlyRate;
  final double totalOvertimePayOwed;

  const OvertimeContext({
    required this.monthlySalary,
    required this.weeklyHours,
    required this.overtimeHoursPerMonth,
    required this.hourlyRate,
    required this.legalOvertimeHourlyRate,
    required this.totalOvertimePayOwed,
  });
}
