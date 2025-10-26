import 'package:flutter_test/flutter_test.dart';
import 'package:count_splitter/domain/entities/expense.dart';
import 'package:count_splitter/domain/usecases/create_expense.dart';
import 'package:count_splitter/data/repositories/local_expense_repository.dart';

void main() {
  group('CreateExpense Use Case Tests', () {
    late CreateExpense createExpense;
    late LocalExpenseRepository repository;

    setUp(() {
      repository = LocalExpenseRepository();
      createExpense = CreateExpense(repository);
    });

    tearDown(() {
      repository.clear();
    });

    test('should create expense with equal split successfully', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Dinner at restaurant',
        amount: 120.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2', 'user3'],
        splitType: SplitType.equal,
      );

      // Act
      final expense = await createExpense(params);

      // Assert
      expect(expense.groupId, equals('group1'));
      expect(expense.description, equals('Dinner at restaurant'));
      expect(expense.amount, equals(120.0));
      expect(expense.paidBy, equals('user1'));
      expect(expense.splitAmong, equals(['user1', 'user2', 'user3']));
      expect(expense.splitType, equals(SplitType.equal));
      expect(expense.equalSplitAmount, equals(40.0)); // 120 / 3 = 40
      expect(expense.isSettled, isFalse);
      expect(expense.id.isNotEmpty, isTrue);
    });

    test('should create expense with custom split successfully', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Grocery shopping',
        amount: 100.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.custom,
        customAmounts: {
          'user1': 60.0,
          'user2': 40.0,
        },
      );

      // Act
      final expense = await createExpense(params);

      // Assert
      expect(expense.splitType, equals(SplitType.custom));
      expect(expense.customAmounts['user1'], equals(60.0));
      expect(expense.customAmounts['user2'], equals(40.0));
      expect(expense.hasValidSplit, isTrue);
    });

    test('should throw error for invalid amount', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Invalid expense',
        amount: -10.0, // Invalid negative amount
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
      );

      // Act & Assert
      expect(
        () => createExpense(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error for empty description', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: '   ', // Empty description
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
      );

      // Act & Assert
      expect(
        () => createExpense(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error when payer is not in split list', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Test expense',
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user2', 'user3'], // user1 not included
      );

      // Act & Assert
      expect(
        () => createExpense(params),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should calculate amounts correctly for equal split', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Pizza party',
        amount: 99.99,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2', 'user3'],
        splitType: SplitType.equal,
      );

      // Act
      final expense = await createExpense(params);

      // Assert
      final equalAmount = 99.99 / 3;
      expect(expense.equalSplitAmount, closeTo(equalAmount, 0.01));
      expect(expense.getAmountOwedBy('user2'), closeTo(equalAmount, 0.01));
      expect(expense.getAmountOwedBy('user3'), closeTo(equalAmount, 0.01));
      expect(expense.getAmountOwedBy('user1'), equals(0.0)); // Payer owes nothing to themselves
    });

    test('should store expense in repository', () async {
      // Arrange
      final params = CreateExpenseParams(
        groupId: 'group1',
        description: 'Coffee',
        amount: 15.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
      );

      // Act
      final expense = await createExpense(params);
      final retrievedExpense = await repository.getExpenseById(expense.id);

      // Assert
      expect(retrievedExpense, isNotNull);
      expect(retrievedExpense!.id, equals(expense.id));
      expect(retrievedExpense.description, equals('Coffee'));
      expect(retrievedExpense.amount, equals(15.0));
    });
  });

  group('LocalExpenseRepository Tests', () {
    late LocalExpenseRepository repository;

    setUp(() {
      repository = LocalExpenseRepository();
    });

    tearDown(() {
      repository.clear();
    });

    test('should retrieve expenses for group', () async {
      // Arrange
      await repository.createExpense(
        groupId: 'group1',
        description: 'Expense 1',
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.equal,
      );

      await repository.createExpense(
        groupId: 'group1',
        description: 'Expense 2',
        amount: 75.0,
        paidBy: 'user2',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.equal,
      );

      await repository.createExpense(
        groupId: 'group2',
        description: 'Different group',
        amount: 100.0,
        paidBy: 'user3',
        splitAmong: ['user3', 'user4'],
        splitType: SplitType.equal,
      );

      // Act
      final group1Expenses = await repository.getExpensesForGroup('group1');

      // Assert
      expect(group1Expenses.length, equals(2));
      expect(group1Expenses.every((e) => e.groupId == 'group1'), isTrue);
    });

    test('should calculate group balances correctly', () async {
      // Arrange
      // User1 pays $100, split among user1, user2, user3 ($33.33 each)
      // User1 should be owed $66.67 total
      await repository.createExpense(
        groupId: 'group1',
        description: 'Dinner',
        amount: 100.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2', 'user3'],
        splitType: SplitType.equal,
      );

      // Act
      final balances = await repository.getGroupBalances('group1');

      // Assert
      expect(balances['user1'], closeTo(-66.67, 0.01)); // Negative means owed money
      expect(balances['user2'], closeTo(33.33, 0.01)); // Positive means owes money
      expect(balances['user3'], closeTo(33.33, 0.01));
    });

    test('should update expense successfully', () async {
      // Arrange
      final expense = await repository.createExpense(
        groupId: 'group1',
        description: 'Original description',
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.equal,
      );

      // Act
      final updatedExpense = await repository.updateExpense(
        expenseId: expense.id,
        description: 'Updated description',
        amount: 75.0,
      );

      // Assert
      expect(updatedExpense.description, equals('Updated description'));
      expect(updatedExpense.amount, equals(75.0));
      expect(updatedExpense.updatedAt, isNotNull);
    });

    test('should settle expense successfully', () async {
      // Arrange
      final expense = await repository.createExpense(
        groupId: 'group1',
        description: 'Test expense',
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.equal,
      );

      // Act
      final settledExpense = await repository.settleExpense(expense.id);

      // Assert
      expect(settledExpense.isSettled, isTrue);
      expect(settledExpense.updatedAt, isNotNull);
    });

    test('should delete expense successfully', () async {
      // Arrange
      final expense = await repository.createExpense(
        groupId: 'group1',
        description: 'Test expense',
        amount: 50.0,
        paidBy: 'user1',
        splitAmong: ['user1', 'user2'],
        splitType: SplitType.equal,
      );

      // Act
      await repository.deleteExpense(expense.id);
      final retrievedExpense = await repository.getExpenseById(expense.id);

      // Assert
      expect(retrievedExpense, isNull);
    });
  });
}