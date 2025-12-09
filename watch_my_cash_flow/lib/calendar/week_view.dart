import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';

class WeekPager extends GetView<CalendarController> {
  const WeekPager({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.weekPageCtrl,
      onPageChanged: controller.handleWeekPageViewChanged,
      itemBuilder: (_, pageIndex) {
        print('Building week page index: ${controller.anchoredDate} :: $pageIndex >>> ${controller.centerWeekPage}');
        final diff = pageIndex - controller.centerWeekPage;
        final weekDate =
          controller.anchoredDate.add(Duration(days: diff * 7));
          // diff < 0 
          // ? controller.selectedDate.value.subtract(Duration(days: diff.abs() * 7))
          // : controller.selectedDate.value.add(Duration(days: diff * 7));

        return WeekView(
          weekDate: weekDate,
          selectedDate: controller.anchoredDate,
          onSelect: (d) { },
          // onSelect: (d) => controller.selectedDate.value = d.dateOnly,
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

    return Column(
      children: days.map((d) {
        final isToday = d.dateOnly == DateTime.now().dateOnly;
        final isSelected = d.dateOnly == selectedDate.dateOnly;
        final dayInMonthColor = Theme.of(context).colorScheme.onSurface;
        final dayNotInMonthColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        final isCurrentMonth = d.month == DateTime.now().month;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              margin: EdgeInsets.all(4),
              alignment: Alignment.center,
              // decoration: BoxDecoration(
              //   color: isSelected
              //       ? (isDark ? Colors.blueAccent : Colors.blue)
              //       : isToday
              //           ? (isDark ? Colors.blueGrey : Colors.blue.shade100)
              //           : Colors.transparent,
              //   shape: BoxShape.circle,
              // ),
              // height: 58,
              child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  color: isToday
                      ? Get.theme.colorScheme.primary.withValues(alpha: .05)
                      : Get.theme.cardTheme.color,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dateService.dayShort(d),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: isToday ? Get.theme.colorScheme.primary : dayInMonthColor)
                            ),
                            Text(
                              "${d.day}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isToday ? Get.theme.colorScheme.primary : dayInMonthColor,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(child: Column(
                        children: [
                          SizedBox()
                        ],
                      ))
                      // ...entries.map((e) {
                      //   return GestureDetector(
                      //     onTap: () async {
                      //       final result = await showDialog<CashFlowEntry>(
                      //         context: context,
                      //         builder: (context) => AddCashFlowEntryDialog(entry: e),
                      //       );
                      //       if (result != null) onAfterUpdated(e.date, result);
                      //     },
                      //     child: Container(
                      //       width: double.infinity,
                      //       decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(4),
                      //         border: Border.all(
                      //           color: Get.theme.colorScheme.primary,
                      //         ),
                      //       ),
                      //       padding: EdgeInsets.all(2),
                      //       child: Text(
                      //         formatAmount(e.amount),
                      //         style: TextStyle(
                      //           fontSize: 12,
                      //           height: 1,
                      //           color: Get.theme.colorScheme.primary,
                      //         ),
                      //       ),
                      //     ),
                      //   ).marginOnly(top: 2);
                      // }),
                    ],
                  ),
                )
            ),
          ),
        );
      }).toList(),
    );
  }
}
