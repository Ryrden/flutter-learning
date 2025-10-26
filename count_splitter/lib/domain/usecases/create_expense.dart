import '../entities/expense.dart';
import '../repositories/expense_repository.dart';
import 'usecase.dart';

/// Parameters for creating an expense
class CreateExpenseParams {
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> splitAmong;
  final SplitType splitType;
  final Map<String, double> customAmounts;

  const CreateExpenseParams({
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitAmong,
    this.splitType = SplitType.equal,
    this.customAmounts = const {},
  });
}

/// Use case for creating a new expense
/// Follows Single Responsibility Principle - only handles expense creation
class CreateExpense extends UseCase<Expense, CreateExpenseParams> {
  final ExpenseRepository repository;

  CreateExpense(this.repository);

  @override
  Future<Expense> call(CreateExpenseParams params) async {
    // Validate input
    if (params.amount <= 0) {
      throw ArgumentError('Amount must be greater than 0');
    }

    if (params.description.trim().isEmpty) {
      throw ArgumentError('Description cannot be empty');
    }

    if (params.splitAmong.isEmpty) {
      throw ArgumentError('Must have at least one person to split among');
    }

    if (!params.splitAmong.contains(params.paidBy)) {
      throw ArgumentError('Person who paid must be included in split');
    }

    // Create the expense
    return await repository.createExpense(
      groupId: params.groupId,
      description: params.description.trim(),
      amount: params.amount,
      paidBy: params.paidBy,
      splitAmong: params.splitAmong,
      splitType: params.splitType,
      customAmounts: params.customAmounts,
    );
  }
}