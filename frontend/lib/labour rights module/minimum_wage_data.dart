/// Representative monthly minimum wages (PKR) used for in-app comparison.
/// Rates follow provincial tier ordering: Unskilled < Semi-skilled < Skilled < Highly skilled.
/// Update when governments notify new figures.
class MinimumWageData {
  MinimumWageData._();

  static const List<String> provinces = [
    'Punjab',
    'Sindh',
    'Khyber Pakhtunkhwa',
    'Balochistan',
    'Islamabad',
    'Gilgit-Baltistan',
    'Azad Jammu & Kashmir',
  ];

  static const List<String> workerTypes = [
    'Unskilled',
    'Semi-skilled',
    'Skilled',
    'Highly skilled',
  ];

  static const Map<String, Map<String, double>> _monthlyMinimumByProvince = {
    'Punjab': {
      'Unskilled': 37000,
      'Semi-skilled': 40500,
      'Skilled': 44500,
      'Highly skilled': 49500,
    },
    'Sindh': {
      'Unskilled': 36500,
      'Semi-skilled': 40000,
      'Skilled': 44000,
      'Highly skilled': 49000,
    },
    'Khyber Pakhtunkhwa': {
      'Unskilled': 35500,
      'Semi-skilled': 39000,
      'Skilled': 43000,
      'Highly skilled': 48000,
    },
    'Balochistan': {
      'Unskilled': 34000,
      'Semi-skilled': 37500,
      'Skilled': 41500,
      'Highly skilled': 46500,
    },
    'Islamabad': {
      'Unskilled': 38000,
      'Semi-skilled': 41500,
      'Skilled': 45500,
      'Highly skilled': 50500,
    },
    'Gilgit-Baltistan': {
      'Unskilled': 33000,
      'Semi-skilled': 36500,
      'Skilled': 40500,
      'Highly skilled': 45500,
    },
    'Azad Jammu & Kashmir': {
      'Unskilled': 33000,
      'Semi-skilled': 36500,
      'Skilled': 40500,
      'Highly skilled': 45500,
    },
  };

  static const Map<String, double> _fallbackByWorkerType = {
    'Unskilled': 35000,
    'Semi-skilled': 38500,
    'Skilled': 42500,
    'Highly skilled': 47500,
  };

  /// Legal monthly minimum for [province] and [workerType] (PKR).
  static double minimumMonthly(String province, String workerType) {
    final row = _monthlyMinimumByProvince[province];
    if (row == null) {
      return _fallbackByWorkerType[workerType] ?? 35000;
    }
    return row[workerType] ?? _fallbackByWorkerType[workerType] ?? 35000;
  }

  /// Parses salary from user input: strips commas, "Rs", spaces; keeps digits and one decimal.
  static double? tryParseSalary(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    s = s.replaceAll(',', '');
    // caseSensitive: false — (?i) is invalid on JS RegExp (Flutter web)
    s = s.replaceAll(RegExp(r'rs\.?', caseSensitive: false), '');
    s = s.replaceAll(RegExp(r'\s+'), '');
    s = s.replaceAll(RegExp(r'[^\d.]'), '');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  static bool isPositiveSalary(String raw) {
    final v = tryParseSalary(raw);
    return v != null && v > 0;
  }
}
