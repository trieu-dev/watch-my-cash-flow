import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';

class WeekPager extends StatelessWidget {
  final controller = Get.find<CalendarController>();

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: PageController(initialPage: controller.centerPage),
      onPageChanged: (pageIndex) {
        final diff = pageIndex - controller.centerPage;
        controller.selectedDate.value =
            controller.selectedDate.value.add(Duration(days: diff * 7));
      },
      itemBuilder: (_, pageIndex) {
        final diff = pageIndex - controller.centerPage;
        final weekDate =
            controller.selectedDate.value.add(Duration(days: diff * 7));

        return WeekView(
          weekDate: weekDate,
          selectedDate: controller.selectedDate.value,
          onSelect: (d) => controller.selectedDate.value = d.dateOnly,
        );
      },
    );
  }
}

class WeekView extends StatelessWidget {
  final DateTime weekDate;
  final DateTime selectedDate;
  final Function(DateTime) onSelect;

  const WeekView({
    required this.weekDate,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = getWeekDays(weekDate);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: days.map((d) {
        final isToday = d.dateOnly == DateTime.now().dateOnly;
        final isSelected = d.dateOnly == selectedDate.dateOnly;

        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              margin: EdgeInsets.all(4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.blueAccent : Colors.blue)
                    : isToday
                        ? (isDark ? Colors.blueGrey : Colors.blue.shade100)
                        : Colors.transparent,
                shape: BoxShape.circle,
              ),
              height: 58,
              child: Text(
                "${d.day}",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
