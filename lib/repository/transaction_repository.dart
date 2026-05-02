import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getTransactionsByDateRange(DateTime start, DateTime end);
  Future<List<Transaction>> getTransactionsByCategory(String category);
  Future<List<Transaction>> getTransactionsByType(TransactionType type);
  Future<List<Transaction>> searchTransactions(String query);
  Future<Transaction?> getTransactionById(int id);
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(int id);
  Future<double> getTotalIncome([DateTime? start, DateTime? end]);
  Future<double> getTotalExpense([DateTime? start, DateTime? end]);
  Future<Map<String, double>> getCategoryExpenses([DateTime? start, DateTime? end]);
  Future<Map<String, double>> getMonthlyExpenses();
  Future<List<Transaction>> getRecentTransactions(int limit);
}