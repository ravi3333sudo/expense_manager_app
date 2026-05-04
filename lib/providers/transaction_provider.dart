import 'package:flutter/material.dart';
import 'package:expense_manager__app/entities/transaction.dart';
import 'package:expense_manager__app/repository/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _transactionRepository;

  TransactionProvider(this._transactionRepository);

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _transactionRepository.getAllTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionRepository.addTransaction(transaction);
      await loadTransactions(); // Refresh the list
    } catch (e) {
      _error = 'Failed to add transaction: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionRepository.updateTransaction(transaction);
      await loadTransactions(); // Refresh the list
    } catch (e) {
      _error = 'Failed to update transaction: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _transactionRepository.deleteTransaction(id);
      await loadTransactions(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete transaction: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<Transaction>> getRecentTransactions(int limit) async {
    try {
      return await _transactionRepository.getRecentTransactions(limit);
    } catch (e) {
      _error = 'Failed to get recent transactions: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    try {
      return await _transactionRepository.searchTransactions(query);
    } catch (e) {
      _error = 'Failed to search transactions: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<List<Transaction>> filterTransactions({
    TransactionType? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<Transaction> filteredTransactions = List.from(_transactions);

      if (type != null) {
        filteredTransactions = filteredTransactions.where((t) => t.type == type).toList();
      }

      if (category != null && category.isNotEmpty) {
        filteredTransactions = filteredTransactions.where((t) => t.category == category).toList();
      }

      if (startDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.timestamp.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
      }

      if (endDate != null) {
        filteredTransactions = filteredTransactions.where((t) => t.timestamp.isBefore(endDate.add(const Duration(days: 1)))).toList();
      }

      return filteredTransactions;
    } catch (e) {
      _error = 'Failed to filter transactions: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, double>> getCategoryExpenses([DateTime? start, DateTime? end]) async {
    try {
      return await _transactionRepository.getCategoryExpenses(start, end);
    } catch (e) {
      _error = 'Failed to get category expenses: ${e.toString()}';
      notifyListeners();
      return {};
    }
  }

  Future<Map<String, double>> getMonthlyExpenses() async {
    try {
      return await _transactionRepository.getMonthlyExpenses();
    } catch (e) {
      _error = 'Failed to get monthly expenses: ${e.toString()}';
      notifyListeners();
      return {};
    }
  }


  void clearError() {
    _error = null;
    notifyListeners();
  }
}