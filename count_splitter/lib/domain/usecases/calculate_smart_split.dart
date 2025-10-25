import '../entities/user.dart';
import 'usecase.dart';

/// Parameters for smart split calculation
class SmartSplitParams {
  final double totalAmount;
  final List<User> users;
  final bool useEnhancedFairness;

  const SmartSplitParams({
    required this.totalAmount,
    required this.users,
    this.useEnhancedFairness = false,
  });
}

/// Result of smart split calculation
class SmartSplitResult {
  final Map<String, double> amounts;
  final bool hasWarning;
  final List<String> warningUsers;

  const SmartSplitResult({
    required this.amounts,
    required this.hasWarning,
    required this.warningUsers,
  });
}

/// Use case for calculating smart split amounts based on user profiles
/// Follows Single Responsibility Principle - only handles smart splitting logic
class CalculateSmartSplit extends UseCase<SmartSplitResult, SmartSplitParams> {
  @override
  Future<SmartSplitResult> call(SmartSplitParams params) async {
    // Validate input
    if (params.totalAmount <= 0) {
      throw ArgumentError('Total amount must be greater than 0');
    }
    
    if (params.users.isEmpty) {
      throw ArgumentError('Users list cannot be empty');
    }

    // Check if all users have complete profiles
    final usersWithProfiles = params.users.where((user) => user.hasCompleteProfile).toList();
    if (usersWithProfiles.length != params.users.length) {
      throw StateError('All users must have complete profiles for smart split');
    }

    // Calculate splits based on method
    Map<String, double> amounts;
    if (params.useEnhancedFairness) {
      amounts = _calculateEnhancedFairnessSplit(params.totalAmount, usersWithProfiles);
    } else {
      amounts = _calculateFunBudgetSplit(params.totalAmount, usersWithProfiles);
    }

    // Check for warnings (75% threshold)
    final warningThreshold = params.totalAmount * 0.75;
    final warningUsers = amounts.entries
        .where((entry) => entry.value > warningThreshold)
        .map((entry) => entry.key)
        .toList();

    return SmartSplitResult(
      amounts: amounts,
      hasWarning: warningUsers.isNotEmpty,
      warningUsers: warningUsers,
    );
  }

  /// Calculate split based on fun budget proportions
  Map<String, double> _calculateFunBudgetSplit(double totalAmount, List<User> users) {
    final totalFunBudget = users.fold(0.0, (sum, user) => sum + user.funBudget);
    
    if (totalFunBudget <= 0) {
      // Fallback to equal split if no valid fun budgets
      final equalAmount = totalAmount / users.length;
      return Map.fromEntries(
        users.map((user) => MapEntry(user.id, equalAmount)),
      );
    }

    final amounts = <String, double>{};
    double allocatedAmount = 0.0;

    // Calculate proportional amounts based on fun budget
    for (int i = 0; i < users.length; i++) {
      final user = users[i];
      final proportion = user.funBudget / totalFunBudget;
      
      if (i == users.length - 1) {
        // Last user gets remaining amount to handle rounding
        amounts[user.id] = totalAmount - allocatedAmount;
      } else {
        final amount = totalAmount * proportion;
        amounts[user.id] = _roundToTwoDecimals(amount);
        allocatedAmount += amounts[user.id]!;
      }
    }

    return amounts;
  }

  /// Calculate split with enhanced fairness considering total financial picture
  Map<String, double> _calculateEnhancedFairnessSplit(double totalAmount, List<User> users) {
    final amounts = <String, double>{};
    
    // Calculate a composite score for each user
    // Higher score = should pay more (higher income, lower expense ratio)
    final userScores = users.map((user) {
      final profile = user.profile!;
      final disposableIncome = profile.disposableIncome;
      final funBudgetRatio = profile.monthlyFunBudget / profile.monthlyIncome;
      
      // Score considers:
      // 1. Absolute disposable income (higher = pay more)
      // 2. Fun budget as percentage of income (lower percentage = more conservative = pay less)
      // 3. Fun budget absolute amount (higher = pay more)
      
      final incomeWeight = disposableIncome * 0.4;
      final conservativenessWeight = (1.0 - funBudgetRatio) * disposableIncome * 0.3;
      final funBudgetWeight = profile.monthlyFunBudget * 0.3;
      
      final score = incomeWeight + funBudgetWeight - conservativenessWeight;
      
      return MapEntry(user.id, score.clamp(0.1, double.infinity)); // Minimum score to avoid 0
    }).toList();

    final totalScore = userScores.fold(0.0, (sum, entry) => sum + entry.value);
    
    if (totalScore <= 0) {
      // Fallback to fun budget split
      return _calculateFunBudgetSplit(totalAmount, users);
    }

    double allocatedAmount = 0.0;
    
    // Calculate proportional amounts based on scores
    for (int i = 0; i < userScores.length; i++) {
      final entry = userScores[i];
      final proportion = entry.value / totalScore;
      
      if (i == userScores.length - 1) {
        // Last user gets remaining amount to handle rounding
        amounts[entry.key] = totalAmount - allocatedAmount;
      } else {
        final amount = totalAmount * proportion;
        amounts[entry.key] = _roundToTwoDecimals(amount);
        allocatedAmount += amounts[entry.key]!;
      }
    }

    return amounts;
  }

  /// Round amount to 2 decimal places
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}