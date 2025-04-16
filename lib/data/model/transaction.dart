class Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String category;

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
  });
}
