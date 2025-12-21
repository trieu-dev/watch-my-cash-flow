import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/add_cash_flow_entry.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';
import 'package:watch_my_cash_flow/utils/pie_chart.dart';

class MonthStatistic extends GetView<CalendarController> {
  const MonthStatistic({super.key});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller.monthPageCtrl,
      onPageChanged: controller.handleMonthPageViewChanged,
      itemBuilder: (context, index) {
        final month = monthFromIndex(index);
        return MonthStatisticView(month: month); // your existing month grid
      },
    );
  }

  DateTime monthFromIndex(int pageIndex) {
    return DateTime(
      controller.anchoredDate.year,
      controller.anchoredDate.month + (pageIndex - 5000),
    );
  }
}

class MonthStatisticView extends GetView<CalendarController> {
  final DateTime month;

  const MonthStatisticView({ super.key, required this.month });

  
  @override
  Widget build(BuildContext context) {
    Map<BigInt, List<CashFlowEntry>> mCate2Entries = {};
    Map<BigInt, double> mCate2Total = {};
    final first = firstDayOfMonth(month);
    final last = lastDayOfMonth(month);
    
    final dayInMonthColor = Theme.of(context).colorScheme.onSurface;
    final dayNotInMonthColor = Theme.of(context).colorScheme.surfaceContainerHighest;

    final entries = controller.cashFlowEntries.where((o) => o.date.isAfter(first) && o.date.isBefore(last)).toList();
    for (var e in entries) {
      mCate2Entries.putIfAbsent(e.categoryId, () => []).add(e);
      if (mCate2Total.containsKey(e.categoryId)) {
        mCate2Total.update(e.categoryId, (value) => value + e.amount);
      } else {
        mCate2Total.addAll({e.categoryId: e.amount});
      }
      // mCate2Total.putIfAbsent(e.categoryId, () => e.amount) + e.amount;
    }

    return LayoutBuilder(builder: (context, constraints) {
      // total usable width/height inside SafeArea
      final totalWidth = constraints.maxWidth;
      final totalHeight = constraints.maxHeight;

      // subtract header (if you want no header set headerHeight = 0)
      final availableHeight = totalHeight - 30;

      // compute cell sizes
      final cellWidth = (totalWidth - (6 * 2)) / 7;
      final cellHeight = (availableHeight - (7 * 2)) / 6;
      print(mCate2Total.values.join(','));

      // childAspectRatio = cellWidth / cellHeight
      final childAspectRatio = cellWidth / cellHeight;
      return Padding(padding: EdgeInsets.all(2),
        child: Column(
          children: [
            PieChart(
              values: mCate2Total.values.toList()
            ),

            SizedBox(height: 16),

            Expanded(child: DefaultTabController(
              length: mCate2Entries.keys.length,
              child: Column(
                children: [
                  TabBar(
                    isScrollable: true, // 👈 allows scrolling
                    // labelColor: appColor.white,
                    // unselectedLabelColor: appColor.textPrimary,
                    // indicatorColor: appColor.white,
                    tabs: [
                      ...mCate2Entries.keys.map((o) => Text(o.toString()))
                    ]
                  ),
                  Expanded(child: TabBarView(
                    children: [
                      ...mCate2Entries.keys.map((o) => Text(o.toString()))
                    ],
                  ))
                ]
              )
            ))

          ],
        )
      );  
  });
  }
}

class EntryList extends GetView<CalendarController> {
  final DateTime day;
  const EntryList({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entries = (controller.mDate2Entries[day]??[]);
      final total = entries.length;
      final shownItems = total > 3 ? entries.take(3) : entries;
      final isLimitExceeded = entries.length > 3;
      return SingleChildScrollView(
        child: Column(
          children: [
            ...shownItems.map((e) => clickableItem(e, context)),
            isLimitExceeded ? moreItem(rest: total - 3) : SizedBox.shrink(),
          ],
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
        formatAmount(item.amount),
        style: TextStyle(
          fontSize: item.amount < 100000 ? 12 : 11,
          height: 1,
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget moreItem({required int rest}) {
    return baseItem(
      child: Text(
        '+$rest',
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

DateTime firstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime lastDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
}

