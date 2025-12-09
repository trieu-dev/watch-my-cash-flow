import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:watch_my_cash_flow/calendar/date_utils.dart';
import 'package:watch_my_cash_flow/data/model/cash_flow_entry.dart';

enum CalendarViewMode { month, week }

class CalendarController extends GetxController {
  final _anchoredDate = DateTime.now().dateOnly.obs;
  DateTime get anchoredDate => _anchoredDate.value;

  final _currentDate = DateTime.now().dateOnly.obs;
  DateTime get currentDate => _currentDate.value;

  var viewMode = CalendarViewMode.month.obs;

  /// Used for PageView initial index
  final int centerMonthPage = 5000;
  final int centerWeekPage = 5000;

  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  bool isDarkMode = true;
  final PageController monthPageCtrl = PageController(initialPage: 5000);
  final PageController weekPageCtrl = PageController(initialPage: 5000);

  final _cashFlowEntries = <CashFlowEntry>[].obs;
  List<CashFlowEntry> get cashFlowEntries => _cashFlowEntries;
  
  final _mDate2Entries = <DateTime, List<CashFlowEntry>>{}.obs;
  Map<DateTime, List<CashFlowEntry>> get mDate2Entries => _mDate2Entries;

  double get total {
    double total = 0;
    final keys = mDate2Entries.keys;
    for (var key in keys) {
      final entry = mDate2Entries[key]!;
      total += entry.fold(0, (prev, element) => prev + element.amount);
    }
    return total;
  }

  void handleMonthPageViewChanged(int pageIndex) {
    final diff = pageIndex - centerMonthPage;
    updateSelectedDate(addMonths(anchoredDate, diff).dateOnly);
  }

  void handleWeekPageViewChanged(int pageIndex) {
    final diff = pageIndex - centerWeekPage;
    final weekDate = anchoredDate.add(Duration(days: diff * 7));
    final days = getWeekDays(weekDate);

    final isNewMonth = days.every((o) => o.month != currentDate.month);
    if (isNewMonth) {
      final newDay = addMonths(anchoredDate, days[0].month - anchoredDate.month).dateOnly;
      print('Calendar controller ::: $newDay >>>');
      _currentDate.value = newDay;
    }
  }

  void updateSelectedDate(DateTime date) {
    _currentDate.value = date.dateOnly;
  }

  void handleMonthChanged() {
    
  }

  @override
  void onInit() {
    init();
    super.onInit();

    ever(viewMode, (mode) {
      print('Calendar view mode changed: $mode');
      _anchoredDate.value = currentDate;
      // _anchoredDate.value = currentDate;
    });
  }

  Future init() async {
    final res = await Supabase.instance.client.from('cash_flow_entries').select('id, amount, date, category_id, note');
    final data = (res as List).map((m) => CashFlowEntry.fromMap(m as Map<String, dynamic>))
                              .toList();
    _cashFlowEntries.value = data;
    for (var entry in data) {
      _mDate2Entries.putIfAbsent(entry.dateOnly, () => []).add(entry);
    }
  }

  void handleSave(CashFlowEntry? result) {
    if (result != null) {
      // cashFlowEntries.add(result);
      _mDate2Entries.putIfAbsent(
        DateTime(result.date.year, result.date.month, result.date.day),
        () => []
      ).add(result);
      // save to database, state, etc.
      print("Saved: ${result.amount}");

      _mDate2Entries.refresh();
    }
  }

  void handleAfterUpdated(DateTime oldKey, CashFlowEntry entry) {
    if (oldKey != entry.dateOnly) {
      // remove from old key
      final oldEntries = _mDate2Entries[oldKey];
      if (oldEntries != null) {
        oldEntries.removeWhere((e) => e.id == entry.id);
      }
      // add to new key
      _mDate2Entries.putIfAbsent(
        entry.dateOnly,
        () => []
      ).add(entry);
    } else {
      // same date, just update the entry
      final entries = _mDate2Entries[oldKey];
      if (entries != null) {
        final index = entries.indexWhere((e) => e.id == entry.id);
        if (index != -1) {
          entries[index] = entry;
        }
      }
    }

    _mDate2Entries.refresh();
  }
}
