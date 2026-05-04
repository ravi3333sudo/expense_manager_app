import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_manager__app/entities/budget.dart';
import 'package:expense_manager__app/entities/transaction.dart';
import 'package:expense_manager__app/providers/budget_provider.dart';
import 'package:expense_manager__app/providers/transaction_provider.dart';
import 'package:expense_manager__app/widgets/professional_card.dart';
import 'package:expense_manager__app/widgets/professional_button.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _limitController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedMonth = DateTime.now();

  final List<String> _categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Bills',
    'Shopping',
    'Health',
    'Education',
    'Other',
  ];

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  DateTime get _firstDayOfMonth =>
      DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  DateTime get _lastDayOfMonth =>
      DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

  Future<void> _refreshData(BudgetProvider budgetProvider,
      TransactionProvider transactionProvider) async {
    await Future.wait([
      budgetProvider.loadBudgets(),
      transactionProvider.loadTransactions(),
    ]);
  }

  Future<void> _showAddBudgetDialog(
      BudgetProvider budgetProvider, TransactionProvider transactionProvider) async {
    _selectedCategory = null;
    _limitController.clear();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Budget'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _limitController,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Limit',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a limit';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            Consumer<BudgetProvider>(
              builder: (context, provider, child) => TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final budget = Budget(
                              category: _selectedCategory!,
                              limit: double.parse(_limitController.text),
                              periodStart: _firstDayOfMonth,
                              periodEnd: _lastDayOfMonth,
                            );
                            await provider.addBudget(budget);
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Budget added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await _refreshData(budgetProvider, transactionProvider);
    }
  }

  Future<void> _showEditBudgetDialog(
      BudgetProvider budgetProvider,
      TransactionProvider transactionProvider,
      Budget budget,
      double currentSpent) async {
    _limitController.text = budget.limit.toString();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Budget'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Category: ${budget.category}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _limitController,
                decoration: const InputDecoration(
                  labelText: 'Monthly Limit',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a limit';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
           Consumer<BudgetProvider>(
              builder: (context, provider, child) => TextButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            final updatedBudget = budget.copyWith(
                              limit: double.parse(_limitController.text),
                            );
                            await provider.updateBudget(updatedBudget);
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Budget updated successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                child: const Text('Update'),
              ),
              ),
          ],
        ),
      );

    if (result == true) {
      await _refreshData(budgetProvider, transactionProvider);
    }
  }

  Future<void> _showDeleteConfirmation(
      BudgetProvider budgetProvider, TransactionProvider transactionProvider, Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for ${budget.category}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          Consumer<BudgetProvider>(
            builder: (context, provider, child) => TextButton(
              onPressed: provider.isLoading
                  ? null
                  : () async {
                      try {
                        await provider.deleteBudget(budget.id!);
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Budget deleted successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _refreshData(budgetProvider, transactionProvider);
    }
  }

  void _showBudgetOptions(
      BuildContext context,
      BudgetProvider budgetProvider,
      TransactionProvider transactionProvider,
      Budget budget,
      double spent) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditBudgetDialog(
                    budgetProvider, transactionProvider, budget, spent);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Budget'),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmation(
                    budgetProvider, transactionProvider, budget);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage, bool isOverBudget) {
    if (isOverBudget) return Colors.red;
    if (percentage < 50) return Colors.green;
    if (percentage < 90) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer2<BudgetProvider, TransactionProvider>(
        builder: (context, budgetProvider, transactionProvider, child) {
          if (budgetProvider.isLoading && budgetProvider.budgets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (budgetProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    budgetProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshData(budgetProvider, transactionProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get current month's spending per category
          final transactions = transactionProvider.transactions.where((t) =>
            t.type == TransactionType.expense &&
            t.timestamp.isAfter(_firstDayOfMonth.subtract(const Duration(days: 1))) &&
            t.timestamp.isBefore(_lastDayOfMonth.add(const Duration(days: 1)))
          );

          final categorySpending = <String, double>{};
          for (final t in transactions) {
            categorySpending[t.category] = (categorySpending[t.category] ?? 0) + t.amount;
          }

              // Calculate summary stats
              double totalBudgetLimit = 0;
              double totalSpent = 0;
              int overBudgetCount = 0;

              for (final budget in budgetProvider.budgets) {
                final spent = categorySpending[budget.category] ?? 0.0;
                totalBudgetLimit += budget.limit;
                totalSpent += spent;
                if (spent > budget.limit) overBudgetCount++;
              }

          return RefreshIndicator(
            onRefresh: () => _refreshData(budgetProvider, transactionProvider),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month - 1,
                            );
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _selectedMonth = DateTime(
                              _selectedMonth.year,
                              _selectedMonth.month + 1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Budget Summary Card
                  ProfessionalCard(
                    title: 'Budget Summary',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildSummaryItem(
                              'Total Budget',
                              totalBudgetLimit,
                              Colors.blue,
                            ),
                            _buildSummaryItem(
                              'Total Spent',
                              totalSpent,
                              totalSpent > totalBudgetLimit
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                             color: overBudgetCount > 0
                                 ? Colors.red.withValues(alpha: 26)
                                 : Colors.green.withValues(alpha: 26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning,
                                color: overBudgetCount > 0
                                    ? Colors.red
                                    : Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                overBudgetCount > 0
                                    ? '$overBudgetCount category(ies) over budget'
                                    : 'All categories within budget',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: overBudgetCount > 0
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Budget List
                  if (budgetProvider.budgets.isEmpty)
                    ProfessionalCard(
                      child: Column(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            size: 48,
                            color: Colors.white.withValues(alpha: 128),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No budgets set',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Set your first budget to start tracking',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ProfessionalButton(
                            text: 'Add First Budget',
                            onPressed: () => _showAddBudgetDialog(
                                budgetProvider, transactionProvider),
                            isLoading: budgetProvider.isLoading,
                          ),
                        ],
                      ),
                    )
                  else
                    ...budgetProvider.budgets.map((budget) {
                      final spent = categorySpending[budget.category] ?? 0.0;
                      final remaining = budget.limit - spent;
                      final percentage =
                          budget.limit > 0 ? (spent / budget.limit) * 100 : 0.0;
                      final isOverBudget = spent > budget.limit;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ProfessionalCard(
                          onTap: () => _showBudgetOptions(
                            context,
                            budgetProvider,
                            transactionProvider,
                            budget,
                            spent,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      budget.category,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getProgressColor(
                                                percentage,
                                                isOverBudget,
                                              )
                                              .withValues(alpha: 51),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isOverBudget
                                          ? 'Over by \$${(-remaining).toStringAsFixed(2)}'
                                          : 'Remaining: \$${remaining.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getProgressColor(
                                          percentage,
                                          isOverBudget,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Spent: \$${spent.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    ' / Limit: \$${budget.limit.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: percentage.clamp(0.0, 100.0) / 100,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 51),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProgressColor(
                                      percentage,
                                      isOverBudget,
                                    ),
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}% used',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 153),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) => Container(
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
            onPressed: () async {
              final transactionProvider =
                  Provider.of<TransactionProvider>(context, listen: false);
              await _showAddBudgetDialog(budgetProvider, transactionProvider);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, size: 32),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 204),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.currency(symbol: '\$').format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
