import 'package:intl/intl.dart';

// Used when only interested in the time of a DateTime
extension DateTimeExtensions on DateTime {
  String asTimeString() => DateFormat.Hm().format(this);
}

// A little helper to sum up a list of numbers (doubles, ints, etc)
extension NumberExtensions on List<num> {
  num sum() {
    if (this == null) {
      return 0.0;
    }
    num total = 0.0;
    this.forEach((e) => e != null ? total += e : null);

    return total;
  }
}