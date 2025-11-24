class CashFlowEntry {
  final String id;
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

  factory CashFlowEntry.fromMap(Map<String, dynamic> map) {
    return CashFlowEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      amount: map['amount'],
      categoryId: map['categoryId'],
      note: map['note'],
    );
  }
}