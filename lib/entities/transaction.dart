import 'package:equatable/equatable.dart';

enum TransactionType { income, expense }

class Transaction extends Equatable {
  final int? id;
  final double amount;
  final TransactionType type;
  final String category;
  final String? note;
  final DateTime timestamp;

  const Transaction({
    this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.note,
    required this.timestamp,
  });

  Transaction copyWith({
    int? id,
    double? amount,
    TransactionType? type,
    String? category,
    String? note,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type.index,
      'category': category,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // Handle null values for non-nullable fields to prevent errors
    final amount = json['amount'] ?? 0.0;
    final typeIndex = json['type'] ?? TransactionType.expense.index;
    final category = json['category'] ?? 'Other';
    final timestampStr = json['timestamp'] ?? DateTime.now().toIso8601String();

    return Transaction(
      id: json['id'],
      amount: amount.toDouble(),
      type: TransactionType.values[typeIndex],
      category: category,
      note: json['note'],
      timestamp: DateTime.parse(timestampStr),
    );
  }

  @override
  List<Object?> get props => [id, amount, type, category, note, timestamp];
}
