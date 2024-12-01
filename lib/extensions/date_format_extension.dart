import 'package:intl/intl.dart';

extension DateFormatExtension on DateTime {
  /// Returns the date in the format of dd-MMMM-yyyy HH:mm:ss
  String toFormattedString() {
    return DateFormat('dd-MMMM-yyyy HH:mm:ss').format(this);
  }
}
