import 'package:watch_my_cash_flow/utils/money_text_formatter.dart';

class CashFlowEntry {
  final BigInt id;
  final DateTime date;
  final double amount;
  final BigInt categoryId;
  final String? note;

  CashFlowEntry({
    required this.id,
    required this.date,
    required this.amount,
    required this.categoryId,
    this.note,
  });

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
  String get amountAndNote {
    if (note == null || note!.isEmpty) {
      return formatAmount(amount);
    } else {
      return '${formatAmount(amount)} - $note';
    }
  }

  CashFlowEntry copyWith({
    DateTime? date,
    double? amount,
    BigInt? categoryId,
    String? note,
  }) {
    return CashFlowEntry(
      id: id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
    );
  }

  factory CashFlowEntry.fromMap(Map<String, dynamic> map) {
    return CashFlowEntry(
      id: BigInt.from(map['id']),
      date: DateTime.parse(map['date']),
      amount: double.parse(map['amount'].toString()),
      categoryId: BigInt.from(map['category_id']),
      note: map['note'],
    );
  }
}