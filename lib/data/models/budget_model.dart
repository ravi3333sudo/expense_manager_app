import '../../entities/budget.dart';

class BudgetModel {
  static Budget fromMap(Map<String, dynamic> map) {

    final category = map['category'] ?? 'Other';
    final limit = map['limit'] ?? 0.0;
    final periodStartStr = map['periodStart'] ?? DateTime.now().toIso8601String();
    final periodEndStr = map['periodEnd'] ?? DateTime.now().toIso8601String();
    
    return Budget(
      id: map['id'],
      category: category,
      limit: limit.toDouble(),
      periodStart: DateTime.parse(periodStartStr),
      periodEnd: DateTime.parse(periodEndStr),
    );
  }

  static Map<String, dynamic> toMap(Budget budget) {
    return budget.toJson();
  }
}