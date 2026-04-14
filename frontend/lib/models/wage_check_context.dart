/// Carries minimum-wage check numbers when opening the labour complaint form from results.
class WageCheckContext {
  final String province;
  final String workerType;
  final double userSalary;
  final double legalMinimum;

  const WageCheckContext({
    required this.province,
    required this.workerType,
    required this.userSalary,
    required this.legalMinimum,
  });

  double get monthlyShortfall {
    final gap = legalMinimum - userSalary;
    return gap > 0 ? gap : 0;
  }

  bool get isUnderpaid => userSalary < legalMinimum;
}
