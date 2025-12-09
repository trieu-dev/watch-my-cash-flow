extension DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}

DateTime addMonths(DateTime d, int months) {
  int newYear = d.year;
  int newMonth = d.month + months;

  while (newMonth > 12) {
    newMonth -= 12;
    newYear++;
  }
  while (newMonth < 1) {
    newMonth += 12;
    newYear--;
  }

  int lastDay = DateTime(newYear, newMonth + 1, 0).day;
  int newDay = d.day.clamp(1, lastDay);

  return DateTime(newYear, newMonth, newDay);
}

List<DateTime> getMonthDays(DateTime date) {
  final first = DateTime(date.year, date.month, 1);
  final last = DateTime(date.year, date.month + 1, 0);

  final start = first.subtract(Duration(days: first.weekday - 1));
  final end = last.add(Duration(days: 7 - last.weekday));

  List<DateTime> days = [];
  for (var d = start;
      d.isBefore(end) || d.isAtSameMomentAs(end);
      d = d.add(Duration(days: 1))) {
    days.add(d);
  }
  return days;
}

List<DateTime> getWeekDays(DateTime date) {
  // DateTime.weekday: Monday=1 ... Sunday=7
  int daysFromSunday = date.weekday % 7; 
  DateTime sunday = date.subtract(Duration(days: daysFromSunday));

  // Return all 7 days starting from Sunday
  return List.generate(7, (i) => sunday.add(Duration(days: i)));
}
