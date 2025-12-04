import 'package:get/get.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';

enum CalendarViewMode { month, week }

class CalendarController extends GetxController {
  var selectedDate = DateTime.now().dateOnly.obs;
  var viewMode = CalendarViewMode.month.obs;

  /// Used for PageView initial index
  final int centerPage = 5000;
}
