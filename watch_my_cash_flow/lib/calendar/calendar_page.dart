import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watch_my_cash_flow/calendar/calendar_controller.dart';
import 'package:watch_my_cash_flow/calendar/month_view.dart';
import 'package:watch_my_cash_flow/calendar/week_view.dart';

class CalendarPage extends GetView<CalendarController> {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Obx(() {
            final isMonth = controller.viewMode.value == CalendarViewMode.month;

            return IconButton(
              icon: Icon(isMonth ? Icons.view_week : Icons.calendar_month),
              onPressed: () {
                controller.viewMode.value =
                    isMonth ? CalendarViewMode.week : CalendarViewMode.month;
              },
            );
          }),
        ],
      ),

      // The animated switcher between month <-> week
      body: Obx(() {
        return AnimatedSwitcher(
          duration: Duration(milliseconds: 280),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: controller.viewMode.value == CalendarViewMode.month
              ? MonthPager()
              : WeekPager(),
        );
      }),
    );
  }
}
