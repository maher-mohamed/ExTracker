import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker_app/providers/expense_provider.dart';
import 'package:expense_tracker_app/data/models/expense_model.dart';
import 'package:expense_tracker_app/core/constants/colors.dart';
import 'package:expense_tracker_app/ui/widgets/glass_card.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    // Filter expenses for last 30 days
    final transactions = expenseProvider.expenses.where((e) => e.date.isAfter(thirtyDaysAgo)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  const Text('No transactions in the last 30 days', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final expense = transactions[index];
                return _buildTransactionItem(context, expense, expenseProvider);
              },
            ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Expense expense, ExpenseProvider provider) {
    final isExpense = expense.type == 'expense';
    final color = isExpense ? AppColors.expense : AppColors.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(expense.id ?? index.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
        ),
        onDismissed: (_) {
          if (expense.id != null) {
            provider.deleteExpense(expense.id!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          }
        },
        child: GlassCard(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(expense.category),
                color: color,
                size: 24,
              ),
            ),
            title: Text(
              expense.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(expense.date),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? "-" : "+"}\$${expense.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.category,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
            onTap: () => _showEditDialog(context, expense, provider),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'transport': return Icons.directions_bus_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.medical_services_rounded;
      case 'salary': return Icons.payments_rounded;
      default: return Icons.category_rounded;
    }
  }

  void _showEditDialog(BuildContext context, Expense expense, ExpenseProvider provider) {
    final titleController = TextEditingController(text: expense.title);
    final amountController = TextEditingController(text: expense.amount.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final updatedExpense = Expense(
                id: expense.id,
                userId: expense.userId,
                title: titleController.text,
                amount: double.tryParse(amountController.text) ?? expense.amount,
                date: expense.date,
                category: expense.category,
                type: expense.type,
              );
              provider.updateExpense(updatedExpense);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
