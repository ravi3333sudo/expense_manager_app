import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_manager__app/providers/transaction_provider.dart';
import 'package:expense_manager__app/entities/transaction.dart';
import 'package:expense_manager__app/widgets/professional_card.dart';
import 'package:expense_manager__app/widgets/transaction_card.dart';
import 'package:expense_manager__app/screens/transaction/add_transaction_screen.dart';
import 'package:expense_manager__app/screens/transaction/transactions_screen.dart';
import 'package:expense_manager__app/screens/analytics/analytics_screen.dart';
import 'package:expense_manager__app/screens/budget/budgets_screen.dart';
import 'package:expense_manager__app/screens/settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  List<Transaction> _recentTransactions = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );

    await transactionProvider.loadTransactions();

    final recent = await transactionProvider.getRecentTransactions(5);
    if (mounted) {
      setState(() {
        _recentTransactions = recent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.analytics, color: Colors.blueGrey),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.account_balance, color: Colors.blueGrey),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BudgetsScreen(),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.blueGrey),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667EEA),
              Color(0xFF764BA2),
              Color(0xFFF093FB),
              Color(0xFFF5576C),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 51),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.waving_hand,
                            color: Colors.yellow,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 204),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Here\'s your financial overview',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Financial Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: ProfessionalCard(
                            title: 'Total Balance',
                            value: transactionProvider.balance,
                            icon: Icons.account_balance_wallet,
                            gradient: transactionProvider.balance >= 0
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF4CAF50),
                                      Color(0xFF66BB6A),
                                    ],
                                  )
                                : const LinearGradient(
                                    colors: [
                                      Color(0xFFF44336),
                                      Color(0xFFEF5350),
                                    ],
                                  ),
                            isAnimated: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ProfessionalCard(
                            title: 'Monthly Income',
                            value: transactionProvider.totalIncome,
                            icon: Icons.trending_up,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
                            ),
                            isAnimated: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ProfessionalCard(
                            title: 'Monthly Expenses',
                            value: transactionProvider.totalExpense,
                            icon: Icons.trending_down,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                            ),
                            isAnimated: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    ProfessionalCard(
                      title: 'Quick Actions',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickActionButton(
                              context,
                              'Add Income',
                              Icons.add_circle,
                              Colors.green,
                              () => _addTransaction(
                                context,
                                TransactionType.income,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickActionButton(
                              context,
                              'Add Expense',
                              Icons.remove_circle,
                              Colors.red,
                              () => _addTransaction(
                                context,
                                TransactionType.expense,
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickActionButton(
                              context,
                              'View All',
                              Icons.list,
                              Colors.blue,
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TransactionsScreen(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildQuickActionButton(
                              context,
                              'Analytics',
                              Icons.analytics,
                              Colors.purple,
                              () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AnalyticsScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Recent Transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransactionsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (transactionProvider.isLoading)
                      const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else if (_recentTransactions.isEmpty)
                      ProfessionalCard(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 64,
                                color: Colors.white.withValues(alpha: 128),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No transactions yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withValues(alpha: 179),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start by adding your first transaction',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 128),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentTransactions.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: TransactionCard(
                              transaction: _recentTransactions[index],
                              onTap: () {
                                Navigator.of(context)
                                    .push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddTransactionScreen(
                                              transaction:
                                                  _recentTransactions[index],
                                            ),
                                      ),
                                    )
                                    .then((_) => _loadData());
                              },
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 77),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                )
                .then((_) => _loadData());
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 31),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 51),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _addTransaction(BuildContext context, TransactionType type) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => AddTransactionScreen(initialType: type),
          ),
        )
        .then((_) => _loadData());
  }
}
