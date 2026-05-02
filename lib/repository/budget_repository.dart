import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<Budget?> getBudgetById(int id);
  Future<Budget?> getBudgetByCategory(String category);
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
  Future<double> getBudgetSpent(String category, DateTime start, DateTime end);
  Future<Map<String, double>> getAllBudgetsWithSpent(DateTime start, DateTime end);
}