import 'package:intl/intl.dart';

extension DateTimeExtensions on DateTime {
  String asTimeString() => DateFormat.Hm().format(this);
}

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