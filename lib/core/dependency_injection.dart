import 'package:get_it/get_it.dart';
import 'package:expense_manager__app/data/impl/budget_repository_impl.dart';
import 'package:expense_manager__app/data/impl/transaction_repository_impl.dart';
import 'package:expense_manager__app/data/local/database_helper.dart';
import 'package:expense_manager__app/repository/transaction_repository.dart';
import 'package:expense_manager__app/repository/budget_repository.dart';

Future<void> setupDependencies() async {

  final databaseHelper = DatabaseHelper();


  await databaseHelper.database;


  GetIt.I.registerSingleton<TransactionRepository>(TransactionRepositoryImpl(databaseHelper));
  GetIt.I.registerSingleton<BudgetRepository>(BudgetRepositoryImpl(databaseHelper));
}