extension StringFormatExtension on String {
  /// Formats a numeric string according to the Indian number system (with commas)
  /// Example: "1234567" becomes "12,34,567"
  String toIndianFormat() {
    // Return original string if it can't be parsed to number
    if (double.tryParse(this) == null) return this;

    // Split number into integer and decimal parts
    List<String> parts = split('.');
    String integerPart = parts[0].replaceAll(',', '');
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Handle numbers less than 1000
    if (integerPart.length <= 3) {
      return decimalPart.isEmpty ? integerPart : '$integerPart.$decimalPart';
    }

    // Format integer part according to Indian system
    String result =
        integerPart.substring(integerPart.length - 3); // Last 3 digits
    String remaining = integerPart.substring(0, integerPart.length - 3);

    // Add remaining digits in groups of 2 from right
    while (remaining.isNotEmpty) {
      int groupSize = remaining.length > 2 ? 2 : remaining.length;
      String group = remaining.substring(remaining.length - groupSize);
      result = '$group,$result';
      remaining = remaining.substring(0, remaining.length - groupSize);
    }

    // Add decimal part if exists
    if (decimalPart.isNotEmpty) {
      result += '.$decimalPart';
    }

    return result;
  }
}
