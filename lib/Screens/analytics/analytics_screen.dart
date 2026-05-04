import 'package:expense_manager__app/providers/transaction_provider.dart';
import 'package:expense_manager__app/widgets/professional_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';



class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Analytics'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Categories'),
              Tab(text: 'Trends'),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => context.read<TransactionProvider>().loadTransactions(),
          child: Consumer<TransactionProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.transactions.isEmpty) {
                return const _EmptyState();
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${provider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadTransactions(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const TabBarView(
                children: [
                  _OverviewTab(),
                  _CategoriesTab(),
                  _TrendsTab(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add transactions to see analytics',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ProfessionalCard(
                  title: 'Total Income',
                  value: provider.totalIncome,
                  icon: Icons.arrow_upward,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfessionalCard(
                  title: 'Total Expense',
                  value: provider.totalExpense,
                  icon: Icons.arrow_downward,
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfessionalCard(
            title: 'Balance',
            value: provider.balance,
            icon: Icons.account_balance_wallet,
            gradient: provider.balance >= 0
                ? LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  )
                : LinearGradient(
                    colors: [Colors.orange.shade400, Colors.orange.shade700],
                  ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Income vs Expense',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxY(provider.totalIncome, provider.totalExpense),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (spot) => Colors.blueGrey,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Income');
                          case 1:
                            return const Text('Expense');
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(currencyFormat.format(value)),
                      reservedSize: 50,
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: provider.totalIncome,
                        color: Colors.green,
                        width: 30,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: provider.totalExpense,
                        color: Colors.red,
                        width: 30,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(double income, double expense) {
    final max = income > expense ? income : expense;
    return max * 1.2;
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return FutureBuilder<Map<String, double>>(
      future: provider.getCategoryExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading categories: ${snapshot.error}'),
          );
        }

        final categoryExpenses = snapshot.data ?? {};
        if (categoryExpenses.isEmpty) {
          return const Center(
            child: Text('No expense data available'),
          );
        }

        final totalExpenses = categoryExpenses.values.fold(0.0, (sum, e) => sum + e);
        final sortedEntries = categoryExpenses.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: sortedEntries.map((entry) {
                      final percentage = (entry.value / totalExpenses) * 100;
                      return PieChartSectionData(
                        value: entry.value,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        color: _getCategoryColor(entry.key),
                      );
                    }).toList(),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Expense Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: sortedEntries.map((entry) {
                  final percentage = (entry.value / totalExpenses) * 100;
                  return Chip(
                    label: Text(
                      '${entry.key}: \$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(color: _getCategoryColor(entry.key)),
                    ),
                    backgroundColor: _getCategoryColor(entry.key).withValues(alpha: 0.1),
                    avatar: CircleAvatar(
                      backgroundColor: _getCategoryColor(entry.key),
                      child: Icon(
                        _getCategoryIcon(entry.key),
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[category.hashCode.abs() % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }
}

class _TrendsTab extends StatelessWidget {
  const _TrendsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return FutureBuilder<Map<String, double>>(
      future: provider.getMonthlyExpenses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading trends: ${snapshot.error}'),
          );
        }

        final monthlyExpenses = snapshot.data ?? {};
        if (monthlyExpenses.isEmpty) {
          return const Center(
            child: Text('No monthly expense data available'),
          );
        }

        final sortedEntries = monthlyExpenses.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        final lastSix = sortedEntries.length > 6
            ? sortedEntries.sublist(sortedEntries.length - 6)
            : sortedEntries;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Last 6 Months Expense Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (spot) => Colors.blueGrey,
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < lastSix.length) {
                              return Text(lastSix[index].key);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text('\$${value.toInt()}'),
                          reservedSize: 40,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: lastSix.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value.value);
                        }).toList(),
                        isCurved: true,
                        color: Theme.of(context).primaryColor,
                        barWidth: 4,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}