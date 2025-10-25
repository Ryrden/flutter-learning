import 'package:flutter_test/flutter_test.dart';
import 'package:count_splitter/domain/entities/user.dart';
import 'package:count_splitter/domain/entities/user_profile.dart';
import 'package:count_splitter/domain/usecases/calculate_smart_split.dart';

void main() {
  group('SmartSplit Tests', () {
    late CalculateSmartSplit calculateSmartSplit;

    setUp(() {
      calculateSmartSplit = CalculateSmartSplit();
    });

    test('should calculate smart split based on fun budget proportions', () async {
      // Arrange - Create users with different financial profiles
      final users = [
        User(
          id: '1',
          name: 'Person A',
          email: 'a@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 5000,
            monthlyExpenses: 4000,
            monthlyFunBudget: 1000, // $1000 for fun
          ),
        ),
        User(
          id: '2',
          name: 'Person B',
          email: 'b@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 9500,
            monthlyFunBudget: 500, // $500 for fun (more conservative)
          ),
        ),
        User(
          id: '3',
          name: 'Person C',
          email: 'c@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 2000,
            monthlyExpenses: 1200,
            monthlyFunBudget: 800, // $800 for fun
          ),
        ),
      ];

      final params = SmartSplitParams(
        totalAmount: 100.0, // $100 dinner
        users: users,
        useEnhancedFairness: false,
      );

      // Act
      final result = await calculateSmartSplit(params);

      // Assert
      expect(result.amounts.length, equals(3));
      expect(result.amounts.containsKey('1'), isTrue);
      expect(result.amounts.containsKey('2'), isTrue);
      expect(result.amounts.containsKey('3'), isTrue);

      // Total should equal $100
      final total = result.amounts.values.fold(0.0, (sum, amount) => sum + amount);
      expect(total, closeTo(100.0, 0.01));

      // Person A (fun budget: $1000) should pay more than Person B (fun budget: $500)
      expect(result.amounts['1']! > result.amounts['2']!, isTrue);

      // Person C (fun budget: $800) should pay more than Person B (fun budget: $500)
      expect(result.amounts['3']! > result.amounts['2']!, isTrue);

      print('Smart Split Results:');
      print('Person A (fun budget: \$1000): \$${result.amounts['1']!.toStringAsFixed(2)}');
      print('Person B (fun budget: \$500): \$${result.amounts['2']!.toStringAsFixed(2)}');
      print('Person C (fun budget: \$800): \$${result.amounts['3']!.toStringAsFixed(2)}');
    });

    test('should detect 75% warning when someone pays too much', () async {
      // Arrange - Create scenario where one person would pay > 75%
      final users = [
        User(
          id: '1',
          name: 'Rich Person',
          email: 'rich@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 2000,
            monthlyFunBudget: 8000, // Very high fun budget
          ),
        ),
        User(
          id: '2',
          name: 'Poor Person',
          email: 'poor@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 1000,
            monthlyExpenses: 950,
            monthlyFunBudget: 50, // Very low fun budget
          ),
        ),
      ];

      final params = SmartSplitParams(
        totalAmount: 100.0,
        users: users,
      );

      // Act
      final result = await calculateSmartSplit(params);

      // Assert
      expect(result.hasWarning, isTrue);
      expect(result.warningUsers.isNotEmpty, isTrue);

      print('Warning Test Results:');
      print('Rich Person: \$${result.amounts['1']!.toStringAsFixed(2)}');
      print('Poor Person: \$${result.amounts['2']!.toStringAsFixed(2)}');
      print('Warning triggered: ${result.hasWarning}');
    });

    test('should handle enhanced fairness calculation', () async {
      // Arrange
      final users = [
        User(
          id: '1',
          name: 'High Earner Conservative',
          email: 'conservative@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 10000,
            monthlyExpenses: 8000,
            monthlyFunBudget: 500, // Conservative despite high income
          ),
        ),
        User(
          id: '2',
          name: 'Low Earner Generous',
          email: 'generous@test.com',
          createdAt: DateTime.now(),
          profile: const UserProfile(
            monthlyIncome: 2000,
            monthlyExpenses: 400,
            monthlyFunBudget: 800, // High percentage for fun
          ),
        ),
      ];

      final params = SmartSplitParams(
        totalAmount: 100.0,
        users: users,
        useEnhancedFairness: true, // Use enhanced calculation
      );

      // Act
      final result = await calculateSmartSplit(params);

      // Assert
      expect(result.amounts.length, equals(2));
      final total = result.amounts.values.fold(0.0, (sum, amount) => sum + amount);
      expect(total, closeTo(100.0, 0.01));

      print('Enhanced Fairness Results:');
      print('Conservative High Earner: \$${result.amounts['1']!.toStringAsFixed(2)}');
      print('Generous Low Earner: \$${result.amounts['2']!.toStringAsFixed(2)}');
    });
  });
}