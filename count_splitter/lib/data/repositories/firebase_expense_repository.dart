import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

/// Firebase Firestore implementation of ExpenseRepository
/// Follows Dependency Inversion Principle - implements abstract interface
class FirebaseExpenseRepository implements ExpenseRepository {
  final FirebaseFirestore _firestore;

  FirebaseExpenseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Expense> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required SplitType splitType,
    Map<String, double> customAmounts = const {},
  }) async {
    final docRef = _firestore.collection('expenses').doc();
    
    final expense = ExpenseModel(
      id: docRef.id,
      groupId: groupId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      splitAmong: splitAmong,
      splitType: splitType,
      customAmounts: customAmounts,
      createdAt: DateTime.now(),
    );

    await docRef.set(expense.toJson());
    return expense;
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    final doc = await _firestore.collection('expenses').doc(expenseId).get();
    
    if (!doc.exists) return null;
    
    return ExpenseModel.fromJson({
      'id': doc.id,
      ...doc.data()!,
    });
  }

  @override
  Future<List<Expense>> getExpensesForGroup(String groupId) async {
    final querySnapshot = await _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ExpenseModel.fromJson({
              'id': doc.id,
              ...doc.data(),
            }))
        .toList();
  }

  @override
  Future<List<Expense>> getExpensesForUser(String userId) async {
    // Get expenses where user paid
    final paidQuery = _firestore
        .collection('expenses')
        .where('paidBy', isEqualTo: userId);
    
    // Get expenses where user is in splitAmong
    final splitQuery = _firestore
        .collection('expenses')
        .where('splitAmong', arrayContains: userId);

    final [paidSnapshot, splitSnapshot] = await Future.wait([
      paidQuery.get(),
      splitQuery.get(),
    ]);

    final expenseMap = <String, ExpenseModel>{};
    
    // Add paid expenses
    for (final doc in paidSnapshot.docs) {
      expenseMap[doc.id] = ExpenseModel.fromJson({
        'id': doc.id,
        ...doc.data(),
      });
    }
    
    // Add split expenses (avoid duplicates)
    for (final doc in splitSnapshot.docs) {
      if (!expenseMap.containsKey(doc.id)) {
        expenseMap[doc.id] = ExpenseModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }
    }

    return expenseMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Expense> updateExpense({
    required String expenseId,
    String? description,
    double? amount,
    List<String>? splitAmong,
    SplitType? splitType,
    Map<String, double>? customAmounts,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (description != null) updateData['description'] = description;
    if (amount != null) updateData['amount'] = amount;
    if (splitAmong != null) updateData['splitAmong'] = splitAmong;
    if (splitType != null) updateData['splitType'] = splitType.name;
    if (customAmounts != null) updateData['customAmounts'] = customAmounts;

    await _firestore.collection('expenses').doc(expenseId).update(updateData);
    
    final updatedExpense = await getExpenseById(expenseId);
    if (updatedExpense == null) {
      throw Exception('Expense not found after update');
    }
    
    return updatedExpense;
  }

  @override
  Future<Expense> settleExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).update({
      'isSettled': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
    
    final settledExpense = await getExpenseById(expenseId);
    if (settledExpense == null) {
      throw Exception('Expense not found after settling');
    }
    
    return settledExpense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }

  @override
  Future<Map<String, double>> getGroupBalances(String groupId) async {
    final expenses = await getExpensesForGroup(groupId);
    final balances = <String, double>{};

    for (final expense in expenses) {
      if (expense.isSettled) continue;

      for (final userId in expense.splitAmong) {
        final amountOwed = expense.getAmountOwedBy(userId);
        balances[userId] = (balances[userId] ?? 0.0) + amountOwed;
        
        // The person who paid gets credited
        if (userId != expense.paidBy) {
          balances[expense.paidBy] = (balances[expense.paidBy] ?? 0.0) - amountOwed;
        }
      }
    }

    return balances;
  }

  @override
  Future<Map<String, double>> getUserBalances(String userId) async {
    final expenses = await getExpensesForUser(userId);
    final balances = <String, double>{};

    for (final expense in expenses) {
      if (expense.isSettled) continue;

      if (expense.splitAmong.contains(userId)) {
        final amountOwed = expense.getAmountOwedBy(userId);
        final groupKey = expense.groupId;
        balances[groupKey] = (balances[groupKey] ?? 0.0) + amountOwed;
      }

      if (expense.paidBy == userId) {
        for (final splitterId in expense.splitAmong) {
          if (splitterId != userId) {
            final amountOwed = expense.getAmountOwedBy(splitterId);
            final groupKey = expense.groupId;
            balances[groupKey] = (balances[groupKey] ?? 0.0) - amountOwed;
          }
        }
      }
    }

    return balances;
  }

  /// Stream expenses for a group (real-time updates)
  Stream<List<Expense>> streamExpensesForGroup(String groupId) {
    return _firestore
        .collection('expenses')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromJson({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  /// Stream balances for a group (real-time updates)
  Stream<Map<String, double>> streamGroupBalances(String groupId) {
    return streamExpensesForGroup(groupId).map((expenses) {
      final balances = <String, double>{};

      for (final expense in expenses) {
        if (expense.isSettled) continue;

        for (final userId in expense.splitAmong) {
          final amountOwed = expense.getAmountOwedBy(userId);
          balances[userId] = (balances[userId] ?? 0.0) + amountOwed;
          
          if (userId != expense.paidBy) {
            balances[expense.paidBy] = (balances[expense.paidBy] ?? 0.0) - amountOwed;
          }
        }
      }

      return balances;
    });
  }
}