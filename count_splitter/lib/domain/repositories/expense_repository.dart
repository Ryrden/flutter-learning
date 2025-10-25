import '../entities/expense.dart';

/// Repository interface for expense operations
/// Follows Interface Segregation Principle - focused on expense-specific operations
abstract class ExpenseRepository {
  /// Create a new expense
  Future<Expense> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required List<String> splitAmong,
    required SplitType splitType,
    Map<String, double> customAmounts = const {},
  });

  /// Get expense by ID
  Future<Expense?> getExpenseById(String expenseId);

  /// Get all expenses for a group
  Future<List<Expense>> getExpensesForGroup(String groupId);

  /// Get expenses where user is involved (either paid or owes money)
  Future<List<Expense>> getExpensesForUser(String userId);

  /// Update expense
  Future<Expense> updateExpense({
    required String expenseId,
    String? description,
    double? amount,
    List<String>? splitAmong,
    SplitType? splitType,
    Map<String, double>? customAmounts,
  });

  /// Mark expense as settled
  Future<Expense> settleExpense(String expenseId);

  /// Delete expense
  Future<void> deleteExpense(String expenseId);

  /// Get expense statistics for a group
  Future<Map<String, double>> getGroupBalances(String groupId);

  /// Get expense statistics for a user across all groups
  Future<Map<String, double>> getUserBalances(String userId);
}