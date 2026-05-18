import 'package:flutter/material.dart';
import 'package:front_end/l10n/app_localizations.dart';

/// Representative monthly minimum wages (PKR) used for in-app comparison.
/// Rates follow provincial tier ordering: Unskilled < Semi-skilled < Skilled < Highly skilled.
/// Update when governments notify new figures.
class MinimumWageData {
  MinimumWageData._();

  static List<String> provinces(BuildContext context) => [
    AppLocalizations.of(context)!.mwProvincePunjab,
    AppLocalizations.of(context)!.mwProvinceSindh,
    AppLocalizations.of(context)!.mwProvinceKPK,
    AppLocalizations.of(context)!.mwProvinceBalochistan,
    AppLocalizations.of(context)!.mwProvinceIslamabad,
    AppLocalizations.of(context)!.mwProvinceGB,
    AppLocalizations.of(context)!.mwProvinceAJK,
  ];

  static List<String> workerTypes(BuildContext context) => [
    AppLocalizations.of(context)!.mwWorkerUnskilled,
    AppLocalizations.of(context)!.mwWorkerSemiskilled,
    AppLocalizations.of(context)!.mwWorkerSkilled,
    AppLocalizations.of(context)!.mwWorkerHighlySkilled,
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

  static double minimumMonthly(String province, String workerType) {
    final row = _monthlyMinimumByProvince[province];
    if (row == null) {
      return _fallbackByWorkerType[workerType] ?? 35000;
    }
    return row[workerType] ?? _fallbackByWorkerType[workerType] ?? 35000;
  }

  /// Convenience when UI passes localized labels: map the displayed labels
  /// back to canonical keys used in `_monthlyMinimumByProvince`.
  static double minimumMonthlyFromLabels(
    BuildContext context,
    String provinceLabel,
    String workerTypeLabel,
  ) {
    final localizedProvinces = provinces(context);
    final canonicalProvinces = _monthlyMinimumByProvince.keys.toList();
    String canonicalProvince = provinceLabel;
    final pIndex = localizedProvinces.indexOf(provinceLabel);
    if (pIndex >= 0 && pIndex < canonicalProvinces.length) {
      canonicalProvince = canonicalProvinces[pIndex];
    }

    final localizedWorkerTypes = workerTypes(context);
    final canonicalWorkerTypes = [
      'Unskilled',
      'Semi-skilled',
      'Skilled',
      'Highly skilled',
    ];
    String canonicalWorkerType = workerTypeLabel;
    final wIndex = localizedWorkerTypes.indexOf(workerTypeLabel);
    if (wIndex >= 0 && wIndex < canonicalWorkerTypes.length) {
      canonicalWorkerType = canonicalWorkerTypes[wIndex];
    }

    return minimumMonthly(canonicalProvince, canonicalWorkerType);
  }

  static double? tryParseSalary(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;
    s = s.replaceAll(',', '');
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
