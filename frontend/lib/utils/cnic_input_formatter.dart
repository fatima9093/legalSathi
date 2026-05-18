import 'package:flutter/services.dart';

class CnicInputFormatter extends TextInputFormatter {
  // Expected CNIC format: 12345-1234567-1 (5-7-1) -> 13 digits
  static const _maxDigits = 13;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final digits = digitsOnly.length <= _maxDigits
        ? digitsOnly
        : digitsOnly.substring(0, _maxDigits);

    // Build formatted value with dashes at positions 5 and 12 (0-based)
    final buffer = StringBuffer();
    final groups = [5, 7, 1];
    var index = 0;
    for (var g = 0; g < groups.length && index < digits.length; g++) {
      final take = (index + groups[g] <= digits.length)
          ? groups[g]
          : (digits.length - index);
      buffer.write(digits.substring(index, index + take));
      index += take;
      if (g < groups.length - 1 && index < digits.length) buffer.write('-');
    }

    final formatted = buffer.toString();

    // Calculate new cursor position: map number of digits before new selection
    final digitCursorPosition =
        newValue.selection.end -
        RegExp(
          r'[^0-9]',
        ).allMatches(newValue.text.substring(0, newValue.selection.end)).length;
    // The above expression subtracts count of non-digits before cursor to get digit index.

    // Now map digitCursorPosition to formatted index
    var formattedCursor = 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        digitsSeen++;
        formattedCursor = i + 1;
        if (digitsSeen >= digitCursorPosition) break;
      }
    }

    // If cursor is at start (no digits), ensure it's 0
    if (digitCursorPosition == 0) formattedCursor = 0;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formattedCursor),
    );
  }
}
