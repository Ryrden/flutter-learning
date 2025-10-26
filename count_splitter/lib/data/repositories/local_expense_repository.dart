import 'package:uuid/uuid.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_model.dart';

/// Local implementation of ExpenseRepository for testing and development
/// Follows Dependency Inversion Principle - implements abstract interface
class LocalExpenseRepository implements ExpenseRepository {
  final Map<String, ExpenseModel> _expenses = {};
  final Uuid _uuid = const Uuid();

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
    final expense = ExpenseModel(
      id: _uuid.v4(),
      groupId: groupId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      splitAmong: splitAmong,
      splitType: splitType,
      customAmounts: customAmounts,
      createdAt: DateTime.now(),
    );

    _expenses[expense.id] = expense;
    return expense;
  }

  @override
  Future<Expense?> getExpenseById(String expenseId) async {
    return _expenses[expenseId];
  }

  @override
  Future<List<Expense>> getExpensesForGroup(String groupId) async {
    return _expenses.values
        .where((expense) => expense.groupId == groupId)
        .toList();
  }

  @override
  Future<List<Expense>> getExpensesForUser(String userId) async {
    return _expenses.values
        .where((expense) => 
            expense.paidBy == userId || expense.splitAmong.contains(userId))
        .toList();
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
    final existingExpense = _expenses[expenseId];
    if (existingExpense == null) {
      throw Exception('Expense not found');
    }

    final updatedExpense = existingExpense.copyWithModel(
      description: description,
      amount: amount,
      splitAmong: splitAmong,
      splitType: splitType,
      customAmounts: customAmounts,
      updatedAt: DateTime.now(),
    );

    _expenses[expenseId] = updatedExpense;
    return updatedExpense;
  }

  @override
  Future<Expense> settleExpense(String expenseId) async {
    final existingExpense = _expenses[expenseId];
    if (existingExpense == null) {
      throw Exception('Expense not found');
    }

    final settledExpense = existingExpense.copyWithModel(
      isSettled: true,
      updatedAt: DateTime.now(),
    );

    _expenses[expenseId] = settledExpense;
    return settledExpense;
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    _expenses.remove(expenseId);
  }

  @override
  Future<Map<String, double>> getGroupBalances(String groupId) async {
    final groupExpenses = await getExpensesForGroup(groupId);
    final balances = <String, double>{};

    for (final expense in groupExpenses) {
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
    final userExpenses = await getExpensesForUser(userId);
    final balances = <String, double>{};

    for (final expense in userExpenses) {
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

  // Helper methods for testing
  void clear() {
    _expenses.clear();
  }

  List<Expense> getAllExpenses() {
    return _expenses.values.toList();
  }
}