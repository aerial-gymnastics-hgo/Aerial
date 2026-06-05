class Transaction {
  final String id;
  final String studentId;
  final String parentId;
  final String concept;
  final double amount;
  final String paymentMethod;
  final DateTime date;
  final String? notes;

  Transaction({
    required this.id,
    required this.studentId,
    required this.parentId,
    required this.concept,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    this.notes,
  });
}
