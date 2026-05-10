import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'expenses';

  Stream<List<Expense>> getExpenses(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
      list.sort((a, b) => b.date.compareTo(a.date)); // Client-side sort
      return list;
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _firestore.collection(_collection).add(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection(_collection).doc(expenseId).delete();
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestore.collection(_collection).doc(expense.id).update(expense.toMap());
  }
}
