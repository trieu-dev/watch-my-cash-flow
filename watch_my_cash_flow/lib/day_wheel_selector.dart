import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/app/services/date_service.dart';
import 'package:watch_my_cash_flow/app/services/localization_service.dart';

class FullDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime>? onDateChanged;
  final int startYear;
  final int endYear;

  const FullDatePicker({
    super.key,
    required this.initialDate,
    this.onDateChanged,
    this.startYear = 1900,
    this.endYear = 2100,
  });

  @override
  State<FullDatePicker> createState() => _FullDatePickerState();
}

class _FullDatePickerState extends State<FullDatePicker> {
  late int selectedYear;
  late int selectedMonth;
  late int selectedDay;

  late FixedExtentScrollController yearController;
  late FixedExtentScrollController monthController;
  late FixedExtentScrollController dayController;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialDate.year;
    selectedMonth = widget.initialDate.month;
    selectedDay = widget.initialDate.day;

    yearController = FixedExtentScrollController(
      initialItem: selectedYear - widget.startYear,
    );
    monthController = FixedExtentScrollController(
      initialItem: selectedMonth - 1,
    );
    dayController = FixedExtentScrollController(
      initialItem: selectedDay - 1,
    );
  }

  int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void updateDate() {
    final date = DateTime(selectedYear, selectedMonth, selectedDay);
    widget.onDateChanged?.call(date);
  }

  final List<DateElement> dateOrder = Get.find<LocalizationService>().getDateOrder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          ...dateOrder.map((element) {
            switch (element) {
              case DateElement.day:
                return dayWheel();
              case DateElement.month:
                return monthWheel();
              case DateElement.year:
                return yearWheel();
            }
          })
        ],
      ),
    );
  }

  Widget monthWheel() {
    /// MONTH PICKER
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: monthController,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedMonth = index + 1;

            int maxDays = daysInMonth(selectedYear, selectedMonth);
            if (selectedDay > maxDays) {
              selectedDay = maxDays;
              dayController.jumpToItem(maxDays - 1);
            }

            updateDate();
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (_, index) {
            if (index < 0 || index > 11) return null;
            return Center(
              child: Text(
                dateService.monthLong(DateTime(0, index + 1)),
                style: const TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget dayWheel() {
    /// DAY PICKER
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListWheelScrollView.useDelegate(
        controller: dayController,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedDay = index + 1;
            updateDate();
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (_, index) {
            int maxDays = daysInMonth(selectedYear, selectedMonth);
            if (index < 0 || index >= maxDays) return null;
            return Center(
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget yearWheel() {
    /// YEAR PICKER
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListWheelScrollView.useDelegate(
        controller: yearController,
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedYear = widget.startYear + index;

            int maxDays = daysInMonth(selectedYear, selectedMonth);
            if (selectedDay > maxDays) {
              selectedDay = maxDays;
              dayController.jumpToItem(maxDays - 1);
            }

            updateDate();
          });
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (_, index) {
            int year = widget.startYear + index;
            if (year > widget.endYear) return null;
            return Center(
              child: Text(
                year.toString(),
                style: const TextStyle(fontSize: 20),
              ),
            );
          },
        ),
      ),
    );
  }
}

