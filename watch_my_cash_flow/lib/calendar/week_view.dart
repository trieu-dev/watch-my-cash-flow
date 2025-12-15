import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/add_cash_flow_entry.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class WeekPager extends GetView<CalendarController> {
  const WeekPager({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.weekPageCtrl,
      onPageChanged: controller.handleWeekPageViewChanged,
      itemBuilder: (_, pageIndex) {
        final diff = pageIndex - controller.centerWeekPage;
        final weekDate = controller.anchoredDate.add(Duration(days: diff * 7));
        return WeekView(
          weekDate: weekDate,
          selectedDate: controller.anchoredDate,
          onSelect: (d) { },
        );
      },
    );
  }
}

class WeekView extends GetView<CalendarController> {
  final DateTime weekDate;
  final DateTime selectedDate;
  final Function(DateTime) onSelect;

  const WeekView({super.key, 
    required this.weekDate,
    required this.selectedDate,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final days = getWeekDays(weekDate);

    return Column(
      children: days.map((d) {
        final isToday = d.dateOnly == DateTime.now().dateOnly;
        final dayInMonthColor = Theme.of(context).colorScheme.onSurface;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 180),
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              alignment: Alignment.center,
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
                              style: TextStyle(
                                color: isToday ? Get.theme.colorScheme.primary : dayInMonthColor,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              )
                            ),
                            Obx(() {
                              return Text(
                                d.month == controller.currentDate.month ? dateService.dayOfMonthShort(d) : dateService.dayAndMonthShort(d),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isToday ? Get.theme.colorScheme.primary : dayInMonthColor,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 16
                                ),
                              );
                            })
                          ],
                        ),
                      ),
                      Expanded(child: EntryList(day: d))
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

class EntryList extends GetView<CalendarController> {
  final DateTime day;
  const EntryList({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = (controller.mDate2Entries[day]??[]);
      double totalAmount = entries.fold(0, (a, b) => a + b.amount);
      return Padding(
        padding: EdgeInsetsGeometry.all(4),
        child: Row(
          children: [
            Expanded(child: Column(
              children: [
                Expanded(child: ListView.separated(
                  itemBuilder:(context, index) {
                    return clickableItem(entries.elementAt(index), context);
                  },
                  separatorBuilder:(context, index) {
                    return SizedBox(height: 2);
                  },
                  itemCount: entries.length
                ))
              ],
            )),
            if (totalAmount != 0) Container(
              padding: EdgeInsets.only(left: 8),
              width: 80,
              child: Text(
                formatAmount(totalAmount),
                style: TextStyle(
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w500,
                  // fontStyle: FontStyle.italic,
                  color: Get.theme.colorScheme.primary,
                )
              )
            ),
          ]
        )
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
        item.amountAndNote,
        style: TextStyle(
          fontSize: item.amount < 100000 ? 12 : 11,
          height: 1,
          color: Get.theme.colorScheme.primary,
        ),
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
