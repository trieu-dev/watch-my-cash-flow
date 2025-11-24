
class Category {
  final BigInt id;
  final String name;
  final bool isIncome; // true = income category, false = expense
  final String? icon;  // optional icon name
  final String? color; // save as hex

  Category({
    required this.id,
    required this.name,
    required this.isIncome,
    this.icon,
    this.color,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: BigInt.from(map['id']),
      name: map['name'],
      isIncome: map['isIncome'] ?? false,
      icon: map['icon'],
      color: map['color'],
    );
  }
}
