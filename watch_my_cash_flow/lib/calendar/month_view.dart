import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/add_cash_flow_entry.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class MonthPager extends GetView<CalendarController> {
  const MonthPager({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.monthPageCtrl,
      onPageChanged: controller.handleMonthPageViewChanged,
      itemBuilder: (context, index) {
        final month = monthFromIndex(index);
        return MonthCalendar(month: month); // your existing month grid
      },
    );
  }
}

class MonthCalendar extends GetView<CalendarController> {
  final DateTime month;

  const MonthCalendar({ super.key, required this.month });

  
  @override
  Widget build(BuildContext context) {
    final days = getCalendarDays(month);
    final weekdays = days.sublist(0, 7);
    final dayInMonthColor = Theme.of(context).colorScheme.onSurface;
    final dayNotInMonthColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    return LayoutBuilder(builder: (context, constraints) {
      // total usable width/height inside SafeArea
      final totalWidth = constraints.maxWidth;
      final totalHeight = constraints.maxHeight;

      // subtract header (if you want no header set headerHeight = 0)
      final availableHeight = totalHeight - 30;

      // compute cell sizes
      final cellWidth = (totalWidth - (6 * 2)) / 7;
      final cellHeight = (availableHeight - (7 * 2)) / 6;

      // childAspectRatio = cellWidth / cellHeight
      final childAspectRatio = cellWidth / cellHeight;
      return Padding(padding: EdgeInsets.all(2),
        child: Column(
          children: [
            SizedBox(
              height: 30,
              child: Center(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: weekdays.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 7 days per row
                    childAspectRatio: cellWidth / 30
                  ),
                  itemBuilder: (context, index) {
                    final day = weekdays[index];

                    return Center(
                      child: Text(
                        dateService.dayShort(day),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: dayInMonthColor)
                      )
                    );
                  }
                )
              )
            ),
            Expanded(child: GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: days.length,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 days per row
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: childAspectRatio
              ),
              itemBuilder: (context, index) {
                final day = days[index];
                final isToday = isSameDate(day, DateTime.now());
                final isCurrentMonth = day.month == month.month;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  color: isToday
                      ? Get.theme.colorScheme.primary.withValues(alpha: .05)
                      : Get.theme.cardTheme.color,
                  child: Column(
                    children: [
                      Text(
                        "${day.day}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isToday ? Get.theme.colorScheme.primary : (isCurrentMonth ? dayInMonthColor : dayNotInMonthColor),
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      EntryList(day: day)
                    ],
                  )
                );
            }))
          ],
        )
      );  
  });
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class EntryList extends GetView<CalendarController> {
  final DateTime day;
  const EntryList({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = (controller.mDate2Entries[day]??[]);
      final items = entries.length > 3 ? entries.take(3) : entries;
      final isLimitExceeded = entries.length > 3;
      return Column(
        children: [
          ...items.map((e) => clickableItem(e, context)),
          isLimitExceeded ? moreItem() : SizedBox.shrink(),
        ],
      );
    });
  }

  Widget clickableItem(CashFlowEntry item, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showDialog<CashFlowEntry>(
          context: context,
          builder: (context) => AddCashFlowEntryDialog(entry: item),
        );
        if (result != null) controller.handleAfterUpdated(item.date, result);
      },
      child: amountItem(item)
    );
  }

  Widget amountItem(CashFlowEntry item) {
    return baseItem(
      child: Text(
        formatAmount(item.amount),
        style: TextStyle(
          fontSize: item.amount < 100000 ? 12 : 11,
          height: 1,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget moreItem() {
    return baseItem(
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 12,
          height: 1,
          color: Get.theme.colorScheme.primary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget baseItem({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Get.theme.colorScheme.primary,
        ),
      ),
      padding: EdgeInsets.all(2),
      child: child
    ).marginOnly(top: 2);
  }
}

List<DateTime> getCalendarDays(DateTime month) {
  // 1. First day of the month
  final firstDayOfMonth = DateTime(month.year, month.month, 1);

  // 2. Weekday of the first day (Mon=1 ... Sun=7)
  int weekdayOfFirst = firstDayOfMonth.weekday;
  // int weekdayOfFirst = DateTime.monday;

  // 3. Calculate the first date shown in the calendar (previous Monday/Sunday)
  DateTime firstDisplayDate = firstDayOfMonth.subtract(Duration(days: weekdayOfFirst % 7));

  // 4. Generate 42 days for a 6×7 grid
  return List.generate(42, (i) => firstDisplayDate.add(Duration(days: i)));
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

DateTime monthFromIndex(int pageIndex) {
  return DateTime(
    DateTime.now().year,
    DateTime.now().month + (pageIndex - 5000),
  );
}
