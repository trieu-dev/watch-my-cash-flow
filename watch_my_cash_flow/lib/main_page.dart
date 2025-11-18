

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:watch_my_cash_flow/add_cash_flow_entry.dart';
import 'package:watch_my_cash_flow/data/database/app_database.dart';
// import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';
import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  bool isDarkMode = true;
  final PageController _pageController = PageController(initialPage: 5000);

  List<CashFlowEntry> cashFlowEntries = [];
  Map<DateTime, List<CashFlowEntry>> mDate2Entries = {};

  DateTime monthFromIndex(int pageIndex) {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month + (pageIndex - 5000),
    );
  }

  @override
  void initState() {
    month = DateTime(DateTime.now().year, DateTime.now().month);
    init();
    // TODO: implement initState
    super.initState();
  }

  Future init() async {
    List<CashFlowEntry> response = await db.entryDao.getAll();
    setState(() {
      cashFlowEntries = response;
      mDate2Entries = { for (var entry in cashFlowEntries) 
        DateTime(entry.date.year, entry.date.month, entry.date.day):
          (mDate2Entries[DateTime(entry.date.year, entry.date.month, entry.date.day)] ?? [])..add(entry)
      };
    });
  }

  void handleAfterUpdated(DateTime oldKey, CashFlowEntry entry) {
    setState(() {
      if (oldKey != DateTime(entry.date.year, entry.date.month, entry.date.day)) {
        // remove from old key
        final oldEntries = mDate2Entries[oldKey];
        if (oldEntries != null) {
          oldEntries.removeWhere((e) => e.id == entry.id);
        }
        // add to new key
        mDate2Entries.putIfAbsent(
          DateTime(entry.date.year, entry.date.month, entry.date.day),
          () => []
        ).add(entry);
      } else {
        // same date, just update the entry
        final entries = mDate2Entries[oldKey];
        if (entries != null) {
          final index = entries.indexWhere((e) => e.id == entry.id);
          if (index != -1) {
            entries[index] = entry;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(DateFormat('MMMM').format(month)),
        actions: [
          Switch(
            thumbIcon: WidgetStatePropertyAll(
              isDarkMode ? Icon(Icons.dark_mode) : Icon(Icons.light_mode)
            ),
            value: isDarkMode,
            onChanged: (value) {
              Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              setState(() { isDarkMode = value; });
            }
          )
        ],
      ),
      body: SafeArea(
        child: PageView.builder(
          onPageChanged: (value) {
            setState(() {
              month = DateTime(
                DateTime.now().year,
                DateTime.now().month + (value - 5000),
              );
            });
          },
          controller: _pageController,
          itemBuilder: (context, index) {
            final month = monthFromIndex(index);
            return MonthCalendar(month: month, mDate2Entries: mDate2Entries, onAfterUpdated: handleAfterUpdated); // your existing month grid
          },
        )
      ),
      floatingActionButton: addEntryButton(),
    );
  }

  Widget addEntryButton() {
    return FloatingActionButton(
      onPressed: () async {
        final result = await showDialog<CashFlowEntry>(
          context: context,
          builder: (context) => AddCashFlowEntryDialog(),
        );

        if (result != null) {
          // cashFlowEntries.add(result);
          mDate2Entries.putIfAbsent(
            DateTime(result.date.year, result.date.month, result.date.day),
            () => []
          ).add(result);
          setState(() {});
          // save to database, state, etc.
          print("Saved: ${result.amount}");
        }
      },
      backgroundColor: Get.theme.colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

class MonthCalendar extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, List<CashFlowEntry>> mDate2Entries;
  final Function(DateTime, CashFlowEntry) onAfterUpdated;

  const MonthCalendar({super.key, required this.month, required this.mDate2Entries, required this.onAfterUpdated});

  
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
                      DateFormat.E().format(day),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dayInMonthColor
                    )
                  ),
                  );
                },
              ),
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
                final entries = (mDate2Entries[day]??[]);

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
                      ...entries.map((e) {
                        return GestureDetector(
                          onTap: () async {
                            final result = await showDialog<CashFlowEntry>(
                              context: context,
                              builder: (context) => AddCashFlowEntryDialog(entry: e),
                            );
                            if (result != null) onAfterUpdated(e.date, result);
                          },
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                            padding: EdgeInsets.all(2),
                            child: Text(
                              formatter.format(e.amount),
                              style: TextStyle(
                                fontSize: 12,
                                height: 1,
                                color: Get.theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ).marginOnly(top: 2);
                      }),
                    ],
                  ),
                );
              },
            ))
          ],
        )
      );  
  });
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
