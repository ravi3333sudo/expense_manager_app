import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final int? id;
  final String category;
  final double limit;
  final DateTime periodStart;
  final DateTime periodEnd;

  const Budget({
    this.id,
    required this.category,
    required this.limit,
    required this.periodStart,
    required this.periodEnd,
  });

  Budget copyWith({
    int? id,
    String? category,
    double? limit,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      category: json['category'],
      limit: json['limit'],
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }

  @override
  List<Object?> get props => [id, category, limit, periodStart, periodEnd];
}