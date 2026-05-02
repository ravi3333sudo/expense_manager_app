import 'package:expense_manager__app/data/local/database_helper.dart';
import 'package:expense_manager__app/data/models/budget_model.dart';
import 'package:expense_manager__app/entities/budget.dart';
import 'package:expense_manager__app/repository/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseHelper _databaseHelper;

  BudgetRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Budget>> getAllBudgets() async {
    final maps = await _databaseHelper.getBudgetMaps();
    return maps.map((map) => BudgetModel.fromMap(map)).toList();
  }

  @override
  Future<Budget?> getBudgetById(int id) async {
    final allBudgets = await getAllBudgets();
    try {
      return allBudgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Budget?> getBudgetByCategory(String category) async {
    final allBudgets = await getAllBudgets();
    try {
      return allBudgets.firstWhere((budget) => budget.category == category);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addBudget(Budget budget) async {
    await _databaseHelper.insertBudget(budget);
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _databaseHelper.updateBudget(budget);
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _databaseHelper.deleteBudget(id);
  }

  @override
  Future<double> getBudgetSpent(String category, DateTime start, DateTime end) async {
    // This would need to be implemented with a more complex query in the database
    // For now, we'll use the transaction repository to get expenses
    // In a real implementation, this could be optimized with a direct query
    return 0.0; // Placeholder - would need transaction repository access
  }

  @override
  Future<Map<String, double>> getAllBudgetsWithSpent(DateTime start, DateTime end) async {
    final budgets = await getAllBudgets();
    final result = <String, double>{};

    for (final budget in budgets) {
      final spent = await getBudgetSpent(budget.category, start, end);
      result[budget.category] = spent;
    }

    return result;
  }
}