import 'package:flutter/material.dart';
import 'package:expense_manager__app/entities/budget.dart';
import 'package:expense_manager__app/repository/budget_repository.dart';

class BudgetProvider with ChangeNotifier {
  final BudgetRepository _budgetRepository;

  BudgetProvider(this._budgetRepository);

  List<Budget> _budgets = [];
  bool _isLoading = false;
  String? _error;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _budgetRepository.getAllBudgets();
      _error = null;
    } catch (e) {
      _error = 'Failed to load budgets: ${e.toString()}';
      debugPrint('Error loading budgets: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBudget(Budget budget) async {
    try {
      await _budgetRepository.addBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add budget: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBudget(Budget budget) async {
    try {
      await _budgetRepository.updateBudget(budget);
      await loadBudgets(); // Refresh the list
    } catch (e) {
      _error = 'Failed to update budget: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBudget(int id) async {
    try {
      await _budgetRepository.deleteBudget(id);
      await loadBudgets(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete budget: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<Budget?> getBudgetByCategory(String category) async {
    try {
      return await _budgetRepository.getBudgetByCategory(category);
    } catch (e) {
      _error = 'Failed to get budget by category: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  Future<double> getBudgetSpent(String category, DateTime start, DateTime end) async {
    try {
      return await _budgetRepository.getBudgetSpent(category, start, end);
    } catch (e) {
      _error = 'Failed to get budget spent: ${e.toString()}';
      notifyListeners();
      return 0.0;
    }
  }

  Future<Map<String, double>> getAllBudgetsWithSpent(DateTime start, DateTime end) async {
    try {
      return await _budgetRepository.getAllBudgetsWithSpent(start, end);
    } catch (e) {
      _error = 'Failed to get budgets with spent: ${e.toString()}';
      notifyListeners();
      return {};
    }
  }


  Future<List<Map<String, dynamic>>> getBudgetsWithStatus(DateTime start, DateTime end) async {
    final budgetsWithSpent = await getAllBudgetsWithSpent(start, end);
    final result = <Map<String, dynamic>>[];

    for (final budget in _budgets) {
      final spent = budgetsWithSpent[budget.category] ?? 0.0;
      final remaining = budget.limit - spent;
      final percentage = budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;

      result.add({
        'budget': budget,
        'spent': spent,
        'remaining': remaining,
        'percentage': percentage,
        'isOverBudget': spent > budget.limit,
      });
    }

    return result;
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}