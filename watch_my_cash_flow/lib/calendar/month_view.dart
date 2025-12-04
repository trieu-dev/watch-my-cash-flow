import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';

class MonthPager extends StatelessWidget {
  final controller = Get.find<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(initialPage: controller.centerPage),
      onPageChanged: (pageIndex) {
        final diff = pageIndex - controller.centerPage;
        controller.selectedDate.value =
            addMonths(controller.selectedDate.value, diff).dateOnly;
      },
      itemBuilder: (_, pageIndex) {
        final diff = pageIndex - controller.centerPage;
        final monthDate =
            addMonths(controller.selectedDate.value, diff).dateOnly;

        return MonthView(
          displayMonth: monthDate,
          selectedDate: controller.selectedDate.value,
          onSelect: (d) => controller.selectedDate.value = d,
        );
      },
    );
  }
}

class MonthView extends StatelessWidget {
  final DateTime displayMonth;
  final DateTime selectedDate;
  final Function(DateTime) onSelect;

  const MonthView({
    required this.displayMonth,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = getMonthDays(displayMonth);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: days.length,
      itemBuilder: (_, i) {
        final d = days[i];
        final isToday = d.dateOnly == DateTime.now().dateOnly;
        final isSelected = d.dateOnly == selectedDate.dateOnly;
        final inMonth = d.month == displayMonth.month;

        Color textColor = inMonth
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white30 : Colors.black38);

        return GestureDetector(
          onTap: () => onSelect(d),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 180),
            margin: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.blueAccent : Colors.blue)
                  : isToday
                      ? (isDark ? Colors.blueGrey : Colors.blue.shade100)
                      : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "${d.day}",
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
}

