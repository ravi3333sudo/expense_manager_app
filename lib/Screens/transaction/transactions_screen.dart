import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_manager__app/entities/transaction.dart';
import 'package:expense_manager__app/providers/transaction_provider.dart';
import 'package:expense_manager__app/widgets/transaction_card.dart';
import 'package:expense_manager__app/screens/transaction/add_transaction_screen.dart';

enum TransactionFilter { all, income, expense }

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<TransactionProvider>().loadTransactions();
  }

  void _onFilterChanged(TransactionFilter filter) {
    setState(() {
      _selectedFilter = filter;
      _searchController.clear();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {

    });
  }

  List<Transaction> _getFilteredTransactions(List<Transaction> transactions, String searchQuery, TransactionFilter filter) {
    List<Transaction> result = transactions;

    // Apply type filter
    if (filter == TransactionFilter.income) {
      result = result.where((t) => t.type == TransactionType.income).toList();
    } else if (filter == TransactionFilter.expense) {
      result = result.where((t) => t.type == TransactionType.expense).toList();
    }

    // Apply search
    if (searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      result = result.where((t) {
        final matchesCategory = t.category.toLowerCase().contains(lowerQuery);
        final matchesNote = t.note?.toLowerCase().contains(lowerQuery) ?? false;
        return matchesCategory || matchesNote;
      }).toList();

      // Sort by relevance (more matches first)
      result.sort((a, b) {
        int countMatches(Transaction t) {
          int count = 0;
          if (t.category.toLowerCase().contains(lowerQuery)) count++;
          if (t.note?.toLowerCase().contains(lowerQuery) == true) count++;
          return count;
        }
        return countMatches(b).compareTo(countMatches(a));
      });
    }

    return result;
  }

  void _onTransactionTap(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _onTransactionDelete(int id) async {
    await context.read<TransactionProvider>().deleteTransaction(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction deleted'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Handle initial load
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle error
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Handle empty transaction list
          if (provider.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first transaction',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }


          final displayedTransactions = _getFilteredTransactions(
            provider.transactions,
            _searchController.text,
            _selectedFilter,
          );

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by category or note...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),

                // Filter Chips
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'All',
                          TransactionFilter.all,
                          Icons.category,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Income',
                          TransactionFilter.income,
                          Icons.trending_up,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Expense',
                          TransactionFilter.expense,
                          Icons.trending_down,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: displayedTransactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 60,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isNotEmpty
                                    ? 'No results for "${_searchController.text}"'
                                    : 'No transactions in this category',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction = displayedTransactions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: TransactionCard(
                                transaction: transaction,
                                onTap: () => _onTransactionTap(transaction),
                                onDelete: () => _onTransactionDelete(transaction.id!),
                              ),
                            );
                          },
                        ),
                ),


                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 77),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryItem(
                          'Income',
                          NumberFormat.currency(symbol: '\$').format(
                            displayedTransactions
                                .where((t) => t.type == TransactionType.income)
                                .fold(0.0, (sum, t) => sum + t.amount),
                          ),
                          Colors.greenAccent,
                        ),
                        _buildSummaryItem(
                          'Expense',
                          NumberFormat.currency(symbol: '\$').format(
                            displayedTransactions
                                .where((t) => t.type == TransactionType.expense)
                                .fold(0.0, (sum, t) => sum + t.amount),
                          ),
                          Colors.redAccent,
                        ),
                        const VerticalDivider(width: 32, color: Colors.white30),
                        _buildSummaryItem(
                          'Balance',
                          NumberFormat.currency(symbol: '\$').format(
                            displayedTransactions
                                .where((t) => t.type == TransactionType.income)
                                .fold(0.0, (sum, t) => sum + t.amount) -
                            displayedTransactions
                                .where((t) => t.type == TransactionType.expense)
                                .fold(0.0, (sum, t) => sum + t.amount),
                          ),
                          Colors.white,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    TransactionFilter filter,
    IconData icon,
  ) {
    final isSelected = _selectedFilter == filter;
    return FilterChip(
      label: Text(label),
      avatar: Icon(
        icon,
        size: 18,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          _onFilterChanged(filter);
        }
      },
      selectedColor: const Color(0xFF667EEA),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}