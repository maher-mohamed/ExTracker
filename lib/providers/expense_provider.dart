import 'package:flutter/material.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository = ExpenseRepository();
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  void listenToExpenses(String userId) {
    _isLoading = true;
    notifyListeners();
    _repository.getExpenses(userId).listen((expenses) {
      _expenses = expenses;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
  }

  double get totalExpenses {
    return _expenses
        .where((e) => e.type == 'expense')
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get totalIncome {
    return _expenses
        .where((e) => e.type == 'income')
        .fold(0, (sum, item) => sum + item.amount);
  }

  double get balance => totalIncome - totalExpenses;
}
