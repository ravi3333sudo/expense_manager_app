import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:expense_manager__app/entities/transaction.dart' as domain;
import 'package:expense_manager__app/entities/budget.dart' as domain;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, 'expense_manager.db');

    return await openDatabase(
      dbPath,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        "limit" REAL NOT NULL,
        periodStart TEXT NOT NULL,
        periodEnd TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        type INTEGER NOT NULL
      )
    ''');

    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          "limit" REAL NOT NULL,
          periodStart TEXT NOT NULL,
          periodEnd TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          icon TEXT NOT NULL,
          color TEXT NOT NULL,
          type INTEGER NOT NULL
        )
      ''');
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = [
      ['Salary', 'work', 'FF4CAF50', 0],
      ['Freelance', 'person', 'FF2196F3', 0],
      ['Investment', 'trending_up', 'FFFF9800', 0],
      ['Other Income', 'attach_money', 'FF9C27B0', 0],
      ['Food & Dining', 'restaurant', 'FFF44336', 1],
      ['Transportation', 'directions_car', 'FF2196F3', 1],
      ['Shopping', 'shopping_cart', 'FF9C27B0', 1],
      ['Entertainment', 'movie', 'FFFF9800', 1],
      ['Bills & Utilities', 'receipt', 'FF607D8B', 1],
      ['Health & Fitness', 'fitness_center', 'FF4CAF50', 1],
      ['Education', 'school', 'FF3F51B5', 1],
      ['Travel', 'flight', 'FF009688', 1],
      ['Other', 'category', 'FF795548', 1],
    ];

    for (final category in categories) {
      await db.insert('categories', {
        'name': category[0],
        'icon': category[1],
        'color': category[2],
        'type': category[3],
      });
    }
  }

  Future<int> insertTransaction(domain.Transaction transaction) async {
    final db = await database;
    try {
      return await db.insert('transactions', transaction.toJson());
    } catch (e) {
      debugPrint('Error inserting transaction: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionMaps() async {
    final db = await database;
    try {
      final result = await db.query('transactions', orderBy: 'timestamp DESC');
      return result;
    } catch (e) {
      debugPrint('Error getting transactions: $e');
      return [];
    }
  }

  Future<int> updateTransaction(domain.Transaction transaction) async {
    final db = await database;
    try {
      return await db.update(
        'transactions',
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  Future<int> insertBudget(domain.Budget budget) async {
    final db = await database;
    try {
      return await db.insert('budgets', budget.toJson());
    } catch (e) {
      debugPrint('Error inserting budget: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getBudgetMaps() async {
    final db = await database;
    try {
      final result = await db.query('budgets');
      return result;
    } catch (e) {
      debugPrint('Error getting budgets: $e');
      return [];
    }
  }

  Future<int> updateBudget(domain.Budget budget) async {
    final db = await database;
    try {
      return await db.update(
        'budgets',
        budget.toJson(),
        where: 'id = ?',
        whereArgs: [budget.id],
      );
    } catch (e) {
      debugPrint('Error updating budget: $e');
      rethrow;
    }
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'budgets',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      debugPrint('Error deleting budget: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getCategoriesByType(int type) async {
    final db = await database;
    try {
      final result = await db.query(
        'categories',
        where: 'type = ?',
        whereArgs: [type],
        orderBy: 'name',
      );
      return result;
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  Future<String> exportDataToJson() async {
    final db = await database;
    final transactions = await getTransactionMaps();
    final budgets = await getBudgetMaps();
    final categories = await db.query('categories');

    final data = {
      'transactions': transactions,
      'budgets': budgets,
      'categories': categories,
      'exportDate': DateTime.now().toIso8601String(),
      'version': 2,
    };

    return jsonEncode(data);
  }

  Future<void> importDataFromJson(String jsonData) async {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('categories');

      final categories = data['categories'] as List<dynamic>? ?? [];
      for (final category in categories) {
        await txn.insert('categories', category as Map<String, dynamic>);
      }

      final transactions = data['transactions'] as List<dynamic>? ?? [];
      for (final transaction in transactions) {
        await txn.insert('transactions', transaction as Map<String, dynamic>);
      }

      final budgets = data['budgets'] as List<dynamic>? ?? [];
      for (final budget in budgets) {
        await txn.insert('budgets', budget as Map<String, dynamic>);
      }
    });
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('budgets');
    });
  }

  Future<Map<String, dynamic>> getDatabaseStats() async {
    final db = await database;

    final transactionCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM transactions'),
    ) ?? 0;

    final budgetCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM budgets'),
    ) ?? 0;

    final totalIncome = (await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [domain.TransactionType.income.index],
    )).first['total'] as double? ?? 0.0;

    final totalExpense = (await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
      [domain.TransactionType.expense.index],
    )).first['total'] as double? ?? 0.0;

    return {
      'transactionCount': transactionCount,
      'budgetCount': budgetCount,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }
}