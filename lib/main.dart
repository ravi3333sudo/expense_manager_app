import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager__app/core/dependency_injection.dart';
import 'package:expense_manager__app/repository/transaction_repository.dart';
import 'package:expense_manager__app/repository/budget_repository.dart';
import 'package:expense_manager__app/providers/theme_provider.dart';
import 'package:expense_manager__app/providers/transaction_provider.dart';
import 'package:expense_manager__app/providers/budget_provider.dart';
import 'package:expense_manager__app/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider(GetIt.I.get<TransactionRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => BudgetProvider(GetIt.I.get<BudgetRepository>()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Manager App',
            theme: themeProvider.themeData,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

