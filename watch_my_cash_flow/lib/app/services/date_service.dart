import 'package:intl/intl.dart';
import 'package:get/get.dart';

final dateService = DateService();

class DateService {
  /// This picks the current GetX locale automatically
  String format(DateTime date, {String pattern = 'yMMMd'}) {
    final locale = Get.locale?.toString() ?? 'en_US';
    return DateFormat(pattern, locale).format(date);
  }

  /// Day of week (Mon, Tue…)
  String dayShort(DateTime date) {
    final locale = Get.locale?.toString() ?? 'en_US';
    return DateFormat.E(locale).format(date);
  }

  /// Full day name (Monday, Tuesday…)
  String dayLong(DateTime date) {
    final locale = Get.locale?.toString() ?? 'en_US';
    return DateFormat.EEEE(locale).format(date);
  }

  /// Full month name (November, December)
  String monthLong(DateTime date) {
    final locale = Get.locale?.toString() ?? 'en_US';
    return DateFormat.MMMM(locale).format(date);
  }

  /// 1/2025
  String monthYearShort(DateTime date) {
    final locale = Get.locale?.toString() ?? 'en_US';
    return DateFormat.yM(locale).format(date);
  }
}
