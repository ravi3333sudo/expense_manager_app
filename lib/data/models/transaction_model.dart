import '../../entities/transaction.dart';

class TransactionModel {
  static Transaction fromMap(Map<String, dynamic> map) {

    final amount = map['amount'] ?? 0.0;
    final typeIndex = map['type'] ?? TransactionType.expense.index;
    final category = map['category'] ?? 'Other';
    final timestampStr = map['timestamp'] ?? DateTime.now().toIso8601String();
    
    return Transaction(
      id: map['id'],
      amount: amount.toDouble(),
      type: TransactionType.values[typeIndex],
      category: category,
      note: map['note'],
      timestamp: DateTime.parse(timestampStr),
    );
  }

  static Map<String, dynamic> toMap(Transaction transaction) {
    return transaction.toJson();
  }
}