class Budget {
  final String id;
  final String categoryId;
  final double limit;
  final DateTime month;

  Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    required this.month,
  });
}
