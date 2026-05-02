import 'package:expense_manager__app/data/local/database_helper.dart';
import 'package:expense_manager__app/data/models/transaction_model.dart';
import 'package:expense_manager__app/entities/transaction.dart';
import 'package:expense_manager__app/repository/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DatabaseHelper _databaseHelper;

  TransactionRepositoryImpl(this._databaseHelper);

  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final maps = await _databaseHelper.getTransactionMaps();
      if (maps.isEmpty) {
        return [];
      }
      return maps.map((map) => TransactionModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end) async {
    final allTransactions = await getAllTransactions();
    return allTransactions.where((transaction) {
      return transaction.timestamp.isAfter(start.subtract(const Duration(days: 1))) &&
             transaction.timestamp.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String category) async {
    final allTransactions = await getAllTransactions();
    return allTransactions.where((transaction) => transaction.category == category).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final allTransactions = await getAllTransactions();
    return allTransactions.where((transaction) => transaction.type == type).toList();
  }

  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    final allTransactions = await getAllTransactions();
    final lowercaseQuery = query.toLowerCase();
    return allTransactions.where((transaction) {
      return transaction.category.toLowerCase().contains(lowercaseQuery) ||
             (transaction.note?.toLowerCase().contains(lowercaseQuery) ?? false);
    }).toList();
  }

  @override
  Future<Transaction?> getTransactionById(int id) async {
    final allTransactions = await getAllTransactions();
    try {
      return allTransactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    await _databaseHelper.insertTransaction(transaction);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    await _databaseHelper.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _databaseHelper.deleteTransaction(id);
  }

  @override
  Future<double> getTotalIncome([DateTime? start, DateTime? end]) async {
    final transactions = start != null && end != null
        ? await getTransactionsByDateRange(start, end)
        : await getAllTransactions();

    return transactions
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpense([DateTime? start, DateTime? end]) async {
    final transactions = start != null && end != null
        ? await getTransactionsByDateRange(start, end)
        : await getAllTransactions();

    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<Map<String, double>> getCategoryExpenses([DateTime? start, DateTime? end]) async {
    final transactions = start != null && end != null
        ? await getTransactionsByDateRange(start, end)
        : await getAllTransactions();

    final categoryExpenses = <String, double>{};
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryExpenses[transaction.category] =
            (categoryExpenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    return categoryExpenses;
  }

  @override
  Future<Map<String, double>> getMonthlyExpenses() async {
    final allTransactions = await getAllTransactions();
    final monthlyExpenses = <String, double>{};

    for (final transaction in allTransactions) {
      if (transaction.type == TransactionType.expense) {
        final monthKey = '${transaction.timestamp.year}-${transaction.timestamp.month.toString().padLeft(2, '0')}';
        monthlyExpenses[monthKey] = (monthlyExpenses[monthKey] ?? 0) + transaction.amount;
      }
    }
    return monthlyExpenses;
  }

  @override
  Future<List<Transaction>> getRecentTransactions(int limit) async {
    final allTransactions = await getAllTransactions();
    allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allTransactions.take(limit).toList();
  }
}