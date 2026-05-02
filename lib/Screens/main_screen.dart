import 'package:expense_manager__app/Screens/analytics/analytics_screen.dart';
import 'package:expense_manager__app/Screens/budget/budgets_screen.dart';
import 'package:expense_manager__app/Screens/dashboard/dashboard_screen.dart';
import 'package:expense_manager__app/Screens/settings/settings_screen.dart';
import 'package:expense_manager__app/Screens/transaction/transactions_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/modern_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const AnalyticsScreen(),
    const BudgetsScreen(),
    const SettingsScreen(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      extendBody: true,
    );
  }
}